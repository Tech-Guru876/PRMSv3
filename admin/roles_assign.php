<?php
$REQUIRE_PERMISSION = 'manage_roles';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/pagination.php';

$canManage = in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'], true);
if (!$canManage) {
    pop('Access denied.', '/admin/roles.php', 1500, 'error');
    exit;
}

/* ─── POST: Assign/revoke roles ─────────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $userId = (int)($_POST['user_id'] ?? 0);

    if ($userId <= 0) {
        modalPop('Error', 'Invalid user ID.', '/admin/roles_assign.php', 'error');
        exit;
    }

    // Get user name for logging
    $userStmt = $pdo->prepare("SELECT full_name FROM users WHERE user_id = ?");
    $userStmt->execute([$userId]);
    $targetUser = $userStmt->fetchColumn();
    if (!$targetUser) {
        modalPop('Error', 'User not found.', '/admin/roles_assign.php', 'error');
        exit;
    }

    if ($action === 'save_roles') {
        $selectedRoles = $_POST['roles'] ?? [];
        $selectedRoles = array_map('intval', array_filter($selectedRoles));

        try {
            $pdo->beginTransaction();

            // Remove all existing user_roles entries for this user
            $pdo->prepare("DELETE FROM user_roles WHERE user_id = ?")->execute([$userId]);

            // Insert selected roles
            if (!empty($selectedRoles)) {
                $insStmt = $pdo->prepare("INSERT INTO user_roles (user_id, role_id, assigned_by) VALUES (?, ?, ?)");
                foreach ($selectedRoles as $rid) {
                    $insStmt->execute([$userId, $rid, $_SESSION['user_id']]);
                }
            }

            $pdo->commit();

            $roleNames = [];
            if (!empty($selectedRoles)) {
                $inPlaceholders = implode(',', array_fill(0, count($selectedRoles), '?'));
                $rnStmt = $pdo->prepare("SELECT name FROM roles WHERE id IN ($inPlaceholders)");
                $rnStmt->execute($selectedRoles);
                $roleNames = $rnStmt->fetchAll(PDO::FETCH_COLUMN);
            }

            try { logAudit($pdo, 'user_roles', $userId, 'UPDATE', "Roles assigned to '{$targetUser}': " . implode(', ', $roleNames)); } catch (Throwable $e) {}
            pop("Roles updated for '{$targetUser}'.", "/admin/roles_assign.php?user_id=$userId", 1200, 'success');
        } catch (Throwable $e) {
            $pdo->rollBack();
            error_log('roles_assign.php save error: ' . $e->getMessage());
            modalPop('Error', 'Failed to save role assignments.', '/admin/roles_assign.php', 'error');
        }
        exit;
    }
}

/* ─── Fetch users ──────────────────────────────────────────────────── */
$search = trim($_GET['search'] ?? '');
$selectedUserId = (int)($_GET['user_id'] ?? 0);

$usersQuery = "
    SELECT u.user_id, u.full_name, u.email, r.name AS primary_role
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.is_active = 1
";
$params = [];
if ($search !== '') {
    $usersQuery .= " AND (u.full_name LIKE ? OR u.email LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}
$usersQuery .= " ORDER BY u.full_name ASC";

$usersStmt = $pdo->prepare($usersQuery);
$usersStmt->execute($params);
$users = $usersStmt->fetchAll(PDO::FETCH_ASSOC);

/* Fetch all active roles */
$roles = $pdo->query("SELECT id, name, description, is_active FROM roles ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);

/* If a user is selected, fetch their assigned roles */
$userAssignedRoles = [];
if ($selectedUserId > 0) {
    $arStmt = $pdo->prepare("SELECT role_id FROM user_roles WHERE user_id = ?");
    $arStmt->execute([$selectedUserId]);
    $userAssignedRoles = array_column($arStmt->fetchAll(PDO::FETCH_ASSOC), 'role_id');
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-person-badge"></i> Assign Roles to Users</h2>
    <a href="/admin/roles.php" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left me-1"></i>Back to Roles
    </a>
</div>

<div class="row">
    <!-- User List -->
    <div class="col-md-5">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-dark text-white">
                <i class="bi bi-people me-2"></i>Select User
            </div>
            <div class="card-body p-2">
                <form method="GET" class="mb-2 p-2">
                    <div class="input-group input-group-sm">
                        <input type="text" name="search" class="form-control" placeholder="Search users..."
                               value="<?= htmlspecialchars($search) ?>">
                        <button class="btn btn-outline-secondary" type="submit"><i class="bi bi-search"></i></button>
                    </div>
                </form>
                <div style="max-height: 500px; overflow-y: auto;">
                    <div class="list-group list-group-flush">
                        <?php foreach ($users as $u): ?>
                        <a href="?user_id=<?= $u['user_id'] ?>&search=<?= urlencode($search) ?>"
                           class="list-group-item list-group-item-action <?= $selectedUserId === $u['user_id'] ? 'active' : '' ?>">
                            <div class="fw-semibold small"><?= htmlspecialchars($u['full_name']) ?></div>
                            <small class="<?= $selectedUserId === $u['user_id'] ? 'text-white-50' : 'text-muted' ?>">
                                <?= htmlspecialchars($u['primary_role'] ?? 'No role') ?>
                            </small>
                        </a>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Role Assignment -->
    <div class="col-md-7">
        <?php if ($selectedUserId > 0): ?>
        <?php
            $selUser = null;
            foreach ($users as $u) { if ($u['user_id'] === $selectedUserId) { $selUser = $u; break; } }
        ?>
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-dark text-white">
                <i class="bi bi-shield-check me-2"></i>Roles for: <?= htmlspecialchars($selUser['full_name'] ?? 'Unknown') ?>
            </div>
            <div class="card-body">
                <form method="POST">
                    <input type="hidden" name="action" value="save_roles">
                    <input type="hidden" name="user_id" value="<?= $selectedUserId ?>">

                    <p class="text-muted small mb-3">
                        Primary role: <strong><?= htmlspecialchars($selUser['primary_role'] ?? 'None') ?></strong>
                        (change via User Management)
                    </p>

                    <div class="row g-2">
                        <?php foreach ($roles as $r): ?>
                        <div class="col-md-6">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox"
                                       name="roles[]" value="<?= $r['id'] ?>"
                                       id="role_<?= $r['id'] ?>"
                                       <?= in_array($r['id'], $userAssignedRoles) ? 'checked' : '' ?>
                                       <?= !$r['is_active'] ? 'disabled' : '' ?>>
                                <label class="form-check-label" for="role_<?= $r['id'] ?>">
                                    <?= htmlspecialchars($r['name']) ?>
                                    <?php if (!$r['is_active']): ?>
                                        <span class="badge bg-secondary">Inactive</span>
                                    <?php endif; ?>
                                </label>
                                <?php if ($r['description']): ?>
                                <div class="text-muted" style="font-size:0.75rem; margin-left:1.5rem;">
                                    <?= htmlspecialchars($r['description']) ?>
                                </div>
                                <?php endif; ?>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>

                    <div class="text-end mt-3">
                        <button type="submit" class="btn btn-success"><i class="bi bi-save me-1"></i>Save Roles</button>
                    </div>
                </form>
            </div>
        </div>
        <?php else: ?>
        <div class="card border-0 shadow-sm">
            <div class="card-body text-center text-muted py-5">
                <i class="bi bi-arrow-left-circle" style="font-size:2rem;"></i>
                <p class="mt-2">Select a user from the list to manage their role assignments.</p>
            </div>
        </div>
        <?php endif; ?>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
