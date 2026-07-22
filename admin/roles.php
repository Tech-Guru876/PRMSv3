<?php
$REQUIRE_PERMISSION = 'manage_roles';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/pagination.php';

/* ─── Only Admin / SuperAdmin may manage roles ──────────────────────── */
$canManage = in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'], true);

/* ─── System roles that cannot be deleted ───────────────────────────── */
$systemRoles = ['Admin', 'SuperAdmin'];

/* ─── POST handlers ─────────────────────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$canManage) {
        modalPop('Access Denied', 'You do not have permission to manage roles.', '/admin/roles.php', 'error');
        exit;
    }

    $action = $_POST['action'] ?? '';

    /* ── Create a new role ── */
    if ($action === 'create') {
        $name = trim($_POST['name'] ?? '');
        $desc = trim($_POST['description'] ?? '');

        if ($name === '') {
            modalPop('Validation Error', 'Role name is required.', '/admin/roles.php', 'error');
            exit;
        }

        if (strlen($name) > 100) {
            modalPop('Validation Error', 'Role name must be 100 characters or less.', '/admin/roles.php', 'error');
            exit;
        }

        try {
            $chk = $pdo->prepare("SELECT COUNT(*) FROM roles WHERE name = ?");
            $chk->execute([$name]);
            if ($chk->fetchColumn() > 0) {
                modalPop('Duplicate', "A role named '{$name}' already exists.", '/admin/roles.php', 'error');
                exit;
            }

            $stmt = $pdo->prepare("INSERT INTO roles (name, description, is_active) VALUES (?, ?, 1)");
            $stmt->execute([$name, $desc ?: null]);
            $newId = (int)$pdo->lastInsertId();

            try { logAudit($pdo, 'roles', $newId, 'CREATE', "Role '{$name}' created"); } catch (Throwable $e) { error_log('logAudit error: ' . $e->getMessage()); }

            pop("Role '{$name}' created successfully.", '/admin/roles.php', 1200, 'success');
        } catch (Throwable $e) {
            error_log('roles.php create error: ' . $e->getMessage());
            modalPop('Error', 'Failed to create role. Please try again.', '/admin/roles.php', 'error');
        }
        exit;
    }

    /* ── Deactivate a role ── */
    if ($action === 'deactivate') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id <= 0) { modalPop('Error', 'Invalid role ID.', '/admin/roles.php', 'error'); exit; }

        $nameStmt = $pdo->prepare("SELECT name FROM roles WHERE id = ?");
        $nameStmt->execute([$id]);
        $roleName = $nameStmt->fetchColumn();

        if (!$roleName) { modalPop('Error', 'Role not found.', '/admin/roles.php', 'error'); exit; }
        if (in_array($roleName, $systemRoles, true)) { modalPop('Error', 'System roles cannot be deactivated.', '/admin/roles.php', 'error'); exit; }

        try {
            $pdo->prepare("UPDATE roles SET is_active = 0 WHERE id = ?")->execute([$id]);
            try { logAudit($pdo, 'roles', $id, 'DEACTIVATE', "Role '{$roleName}' deactivated"); } catch (Throwable $e) {}
            pop("Role '{$roleName}' deactivated.", '/admin/roles.php', 1200, 'success');
        } catch (Throwable $e) {
            error_log('roles.php deactivate error: ' . $e->getMessage());
            modalPop('Error', 'Failed to deactivate role.', '/admin/roles.php', 'error');
        }
        exit;
    }

    /* ── Reactivate a role ── */
    if ($action === 'reactivate') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id <= 0) { modalPop('Error', 'Invalid role ID.', '/admin/roles.php', 'error'); exit; }

        $nameStmt = $pdo->prepare("SELECT name FROM roles WHERE id = ?");
        $nameStmt->execute([$id]);
        $roleName = $nameStmt->fetchColumn();

        if (!$roleName) { modalPop('Error', 'Role not found.', '/admin/roles.php', 'error'); exit; }

        try {
            $pdo->prepare("UPDATE roles SET is_active = 1 WHERE id = ?")->execute([$id]);
            try { logAudit($pdo, 'roles', $id, 'REACTIVATE', "Role '{$roleName}' reactivated"); } catch (Throwable $e) {}
            pop("Role '{$roleName}' reactivated.", '/admin/roles.php', 1200, 'success');
        } catch (Throwable $e) {
            error_log('roles.php reactivate error: ' . $e->getMessage());
            modalPop('Error', 'Failed to reactivate role.', '/admin/roles.php', 'error');
        }
        exit;
    }

    /* ── Delete a role ── */
    if ($action === 'delete') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id <= 0) { modalPop('Error', 'Invalid role ID.', '/admin/roles.php', 'error'); exit; }

        $nameStmt = $pdo->prepare("SELECT name FROM roles WHERE id = ?");
        $nameStmt->execute([$id]);
        $roleName = $nameStmt->fetchColumn();

        if (!$roleName) { modalPop('Error', 'Role not found.', '/admin/roles.php', 'error'); exit; }
        if (in_array($roleName, $systemRoles, true)) { modalPop('Error', 'System roles cannot be deleted.', '/admin/roles.php', 'error'); exit; }

        // Check if any users currently have this as primary role
        $userCount = $pdo->prepare("SELECT COUNT(*) FROM users WHERE role_id = ?");
        $userCount->execute([$id]);
        if ($userCount->fetchColumn() > 0) {
            modalPop('Error', "Cannot delete role '{$roleName}' — it is assigned as primary role to one or more users.", '/admin/roles.php', 'error');
            exit;
        }

        try {
            $pdo->beginTransaction();
            $pdo->prepare("DELETE FROM role_permissions WHERE role_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM user_roles WHERE role_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM roles WHERE id = ?")->execute([$id]);
            $pdo->commit();

            try { logAudit($pdo, 'roles', $id, 'DELETE', "Role '{$roleName}' deleted"); } catch (Throwable $e) {}
            pop("Role '{$roleName}' deleted.", '/admin/roles.php', 1200, 'success');
        } catch (Throwable $e) {
            $pdo->rollBack();
            error_log('roles.php delete error: ' . $e->getMessage());
            modalPop('Error', 'Failed to delete role.', '/admin/roles.php', 'error');
        }
        exit;
    }
}

/* ─── Fetch roles with user count ──────────────────────────────────── */
$filter = $_GET['filter'] ?? 'all';
$whereClause = '';
if ($filter === 'active') $whereClause = 'WHERE r.is_active = 1';
elseif ($filter === 'inactive') $whereClause = 'WHERE r.is_active = 0';

$roles = $pdo->query("
    SELECT r.*, COUNT(DISTINCT u.user_id) AS user_count
    FROM roles r
    LEFT JOIN users u ON u.role_id = r.id
    {$whereClause}
    GROUP BY r.id
    ORDER BY r.name ASC
")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-shield-check"></i> Role Management</h2>
    <?php if ($canManage): ?>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createRoleModal">
        <i class="bi bi-plus-circle me-1"></i>Create Role
    </button>
    <?php endif; ?>
</div>

<!-- Filter tabs -->
<ul class="nav nav-tabs mb-3">
    <li class="nav-item">
        <a class="nav-link <?= $filter === 'all' ? 'active' : '' ?>" href="?filter=all">All</a>
    </li>
    <li class="nav-item">
        <a class="nav-link <?= $filter === 'active' ? 'active' : '' ?>" href="?filter=active">Active</a>
    </li>
    <li class="nav-item">
        <a class="nav-link <?= $filter === 'inactive' ? 'active' : '' ?>" href="?filter=inactive">Inactive</a>
    </li>
</ul>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="table-dark">
                <tr>
                    <th>Role Name</th>
                    <th>Description</th>
                    <th>Status</th>
                    <th>Users</th>
                    <th>Created</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($roles)): ?>
                <tr><td colspan="6" class="text-center text-muted py-4">No roles found.</td></tr>
                <?php else: ?>
                <?php foreach ($roles as $role): ?>
                <tr>
                    <td class="fw-semibold"><?= htmlspecialchars($role['name']) ?></td>
                    <td class="text-muted small"><?= htmlspecialchars($role['description'] ?? '—') ?></td>
                    <td>
                        <?php if (($role['is_active'] ?? 1)): ?>
                            <span class="badge bg-success">Active</span>
                        <?php else: ?>
                            <span class="badge bg-secondary">Inactive</span>
                        <?php endif; ?>
                    </td>
                    <td><span class="badge bg-info"><?= (int)$role['user_count'] ?></span></td>
                    <td class="small"><?= date('M j, Y', strtotime($role['created_at'])) ?></td>
                    <td class="text-end">
                        <?php if ($canManage): ?>
                            <a href="/admin/roles_edit.php?id=<?= $role['id'] ?>" class="btn btn-sm btn-outline-primary" title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <?php if (!in_array($role['name'], $systemRoles, true)): ?>
                                <?php if (($role['is_active'] ?? 1)): ?>
                                <form method="POST" class="d-inline" onsubmit="return confirm('Deactivate this role?')">
                                    <input type="hidden" name="action" value="deactivate">
                                    <input type="hidden" name="id" value="<?= $role['id'] ?>">
                                    <button class="btn btn-sm btn-outline-warning" title="Deactivate"><i class="bi bi-pause-circle"></i></button>
                                </form>
                                <?php else: ?>
                                <form method="POST" class="d-inline">
                                    <input type="hidden" name="action" value="reactivate">
                                    <input type="hidden" name="id" value="<?= $role['id'] ?>">
                                    <button class="btn btn-sm btn-outline-success" title="Reactivate"><i class="bi bi-play-circle"></i></button>
                                </form>
                                <?php endif; ?>
                                <form method="POST" class="d-inline" onsubmit="return confirm('Permanently delete this role? This cannot be undone.')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $role['id'] ?>">
                                    <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                                </form>
                            <?php endif; ?>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Create Role Modal -->
<?php if ($canManage): ?>
<div class="modal fade" id="createRoleModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-plus-circle me-2"></i>Create New Role</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Role Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control" required maxlength="100" placeholder="e.g. Procurement Manager">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="3" placeholder="Brief description of this role's purpose"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-check-lg me-1"></i>Create Role</button>
                </div>
            </form>
        </div>
    </div>
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
