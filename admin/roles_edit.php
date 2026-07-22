<?php
$REQUIRE_PERMISSION = 'manage_roles';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$canManage = in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'], true);
if (!$canManage) {
    pop('Access denied.', '/admin/roles.php', 1500, 'error');
    exit;
}

$roleId = (int)($_GET['id'] ?? $_POST['role_id'] ?? 0);
if ($roleId <= 0) { pop("Invalid role ID.", "/admin/roles.php", 1500, 'warning'); exit; }

/* Fetch role */
$roleStmt = $pdo->prepare("SELECT * FROM roles WHERE id = ?");
$roleStmt->execute([$roleId]);
$role = $roleStmt->fetch(PDO::FETCH_ASSOC);
if (!$role) { pop("Role not found.", "/admin/roles.php", 1500, 'warning'); exit; }

/* ─── POST: Update role details ─────────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postAction = $_POST['action'] ?? '';

    /* ── Update role name/description ── */
    if ($postAction === 'update_details') {
        $name = trim($_POST['name'] ?? '');
        $desc = trim($_POST['description'] ?? '');

        if ($name === '') {
            modalPop('Validation Error', 'Role name is required.', "/admin/roles_edit.php?id=$roleId", 'error');
            exit;
        }

        // Check uniqueness (excluding current role)
        $chk = $pdo->prepare("SELECT COUNT(*) FROM roles WHERE name = ? AND id != ?");
        $chk->execute([$name, $roleId]);
        if ($chk->fetchColumn() > 0) {
            modalPop('Duplicate', "A role named '{$name}' already exists.", "/admin/roles_edit.php?id=$roleId", 'error');
            exit;
        }

        try {
            $pdo->prepare("UPDATE roles SET name = ?, description = ? WHERE id = ?")
                ->execute([$name, $desc ?: null, $roleId]);

            try { logAudit($pdo, 'roles', $roleId, 'UPDATE', "Role updated: name='{$name}'"); } catch (Throwable $e) {}
            pop("Role details updated.", "/admin/roles_edit.php?id=$roleId", 1200, 'success');
        } catch (Throwable $e) {
            error_log('roles_edit.php update error: ' . $e->getMessage());
            modalPop('Error', 'Failed to update role.', "/admin/roles_edit.php?id=$roleId", 'error');
        }
        exit;
    }

    /* ── Save permission assignments ── */
    if ($postAction === 'save_permissions') {
        $selectedPermissions = $_POST['permissions'] ?? [];
        $selectedPermissions = array_map('intval', $selectedPermissions);

        try {
            $pdo->beginTransaction();

            // Remove all existing permissions for this role
            $pdo->prepare("DELETE FROM role_permissions WHERE role_id = ?")->execute([$roleId]);

            // Insert selected permissions
            if (!empty($selectedPermissions)) {
                $insStmt = $pdo->prepare("INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)");
                foreach ($selectedPermissions as $pid) {
                    $insStmt->execute([$roleId, $pid]);
                }
            }

            $pdo->commit();

            try { logAudit($pdo, 'role_permissions', $roleId, 'UPDATE', "Permissions updated for role '{$role['name']}': " . count($selectedPermissions) . " permissions assigned"); } catch (Throwable $e) {}
            pop("Permissions updated for '{$role['name']}'.", "/admin/roles_edit.php?id=$roleId", 1200, 'success');
        } catch (Throwable $e) {
            $pdo->rollBack();
            error_log('roles_edit.php save_permissions error: ' . $e->getMessage());
            modalPop('Error', 'Failed to save permissions.', "/admin/roles_edit.php?id=$roleId", 'error');
        }
        exit;
    }
}

/* ─── Fetch all permissions grouped by module ──────────────────────── */
$allPerms = $pdo->query("
    SELECT id, name, description, module, operation
    FROM permissions
    ORDER BY COALESCE(module, 'zzz'), name
")->fetchAll(PDO::FETCH_ASSOC);

/* Group permissions by module */
$permsByModule = [];
foreach ($allPerms as $p) {
    $mod = $p['module'] ?: 'General';
    $permsByModule[$mod][] = $p;
}

/* Fetch currently assigned permission IDs */
$assignedStmt = $pdo->prepare("SELECT permission_id FROM role_permissions WHERE role_id = ?");
$assignedStmt->execute([$roleId]);
$assignedPerms = array_column($assignedStmt->fetchAll(PDO::FETCH_ASSOC), 'permission_id');

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-pencil-square"></i> Edit Role: <?= htmlspecialchars($role['name']) ?></h2>
    <a href="/admin/roles.php" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left me-1"></i>Back to Roles
    </a>
</div>

<!-- Role Details -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-dark text-white"><i class="bi bi-info-circle me-2"></i>Role Details</div>
    <div class="card-body">
        <form method="POST">
            <input type="hidden" name="action" value="update_details">
            <input type="hidden" name="role_id" value="<?= $roleId ?>">
            <div class="row g-3">
                <div class="col-md-5">
                    <label class="form-label">Role Name <span class="text-danger">*</span></label>
                    <input type="text" name="name" class="form-control" required maxlength="100"
                           value="<?= htmlspecialchars($role['name']) ?>">
                </div>
                <div class="col-md-5">
                    <label class="form-label">Description</label>
                    <input type="text" name="description" class="form-control"
                           value="<?= htmlspecialchars($role['description'] ?? '') ?>">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100"><i class="bi bi-check-lg me-1"></i>Save</button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Permission Assignment -->
<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
        <span><i class="bi bi-key me-2"></i>Permission Assignment</span>
        <small class="text-white-50"><?= count($assignedPerms) ?> / <?= count($allPerms) ?> assigned</small>
    </div>
    <div class="card-body">
        <form method="POST">
            <input type="hidden" name="action" value="save_permissions">
            <input type="hidden" name="role_id" value="<?= $roleId ?>">

            <div class="mb-3">
                <button type="button" class="btn btn-sm btn-outline-secondary me-2" onclick="toggleAll(true)">Select All</button>
                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="toggleAll(false)">Deselect All</button>
            </div>

            <?php foreach ($permsByModule as $module => $perms): ?>
            <div class="mb-4">
                <h6 class="text-uppercase text-muted border-bottom pb-1 mb-2">
                    <i class="bi bi-folder me-1"></i><?= htmlspecialchars(ucfirst($module)) ?>
                </h6>
                <div class="row g-2">
                    <?php foreach ($perms as $p): ?>
                    <div class="col-md-4 col-lg-3">
                        <div class="form-check">
                            <input class="form-check-input perm-checkbox" type="checkbox"
                                   name="permissions[]" value="<?= $p['id'] ?>"
                                   id="perm_<?= $p['id'] ?>"
                                   <?= in_array($p['id'], $assignedPerms) ? 'checked' : '' ?>>
                            <label class="form-check-label small" for="perm_<?= $p['id'] ?>"
                                   title="<?= htmlspecialchars($p['description'] ?? '') ?>">
                                <?= htmlspecialchars($p['name']) ?>
                                <?php if ($p['operation']): ?>
                                    <span class="badge bg-light text-dark" style="font-size:0.65rem"><?= htmlspecialchars($p['operation']) ?></span>
                                <?php endif; ?>
                            </label>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>

            <div class="text-end mt-3">
                <button type="submit" class="btn btn-success"><i class="bi bi-save me-1"></i>Save Permissions</button>
            </div>
        </form>
    </div>
</div>

<script>
function toggleAll(state) {
    document.querySelectorAll('.perm-checkbox').forEach(cb => cb.checked = state);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
