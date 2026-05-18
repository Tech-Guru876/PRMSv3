<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/pagination.php';

/* ─── Only Admin / SuperAdmin may manage permissions ────────────────── */
$canManage = in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'], true);

/* ─── POST handlers ─────────────────────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$canManage) {
        modalPop('Access Denied', 'You do not have permission to manage permissions.', '/admin/permissions.php', 'error');
        exit;
    }

    $action = $_POST['action'] ?? '';

    /* ── Create a new permission ── */
    if ($action === 'create') {
        $name = preg_replace('/[^a-z0-9_]/', '_', strtolower(trim($_POST['name'] ?? '')));
        $desc = trim($_POST['description'] ?? '');

        if ($name === '') {
            modalPop('Validation Error', 'Permission name is required.', '/admin/permissions.php', 'error');
            exit;
        }

        $chk = $pdo->prepare("SELECT COUNT(*) FROM permissions WHERE name = ?");
        $chk->execute([$name]);
        if ($chk->fetchColumn() > 0) {
            modalPop('Duplicate', "A permission named '{$name}' already exists.", '/admin/permissions.php', 'error');
            exit;
        }

        $stmt = $pdo->prepare("INSERT INTO permissions (name, description) VALUES (?, ?)");
        $stmt->execute([$name, $desc ?: null]);
        $newId = (int)$pdo->lastInsertId();

        logAudit($pdo, 'permissions', $newId, 'CREATE', "Permission '{$name}' created");

        pop("Permission '{$name}' created successfully.", '/admin/permissions.php', 1200, 'success');
        exit;
    }

    /* ── Delete a permission ── */
    if ($action === 'delete') {
        $id = (int)($_POST['id'] ?? 0);

        if ($id <= 0) {
            modalPop('Error', 'Invalid permission ID.', '/admin/permissions.php', 'error');
            exit;
        }

        $nameStmt = $pdo->prepare("SELECT name FROM permissions WHERE id = ?");
        $nameStmt->execute([$id]);
        $permName = $nameStmt->fetchColumn();

        if (!$permName) {
            modalPop('Error', 'Permission not found.', '/admin/permissions.php', 'error');
            exit;
        }

        /* Remove role and user associations first */
        $pdo->prepare("DELETE FROM role_permissions WHERE permission_id = ?")->execute([$id]);
        $pdo->prepare("DELETE FROM user_permissions WHERE permission_id = ?")->execute([$id]);
        $pdo->prepare("DELETE FROM permissions WHERE id = ?")->execute([$id]);

        logAudit($pdo, 'permissions', $id, 'DELETE', "Permission '{$permName}' deleted");

        pop("Permission '{$permName}' deleted.", '/admin/permissions.php', 1200, 'success');
        exit;
    }

    /* ── Update permission description ── */
    if ($action === 'update_desc') {
        $id   = (int)($_POST['id'] ?? 0);
        $desc = trim($_POST['description'] ?? '');

        if ($id <= 0) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'message' => 'Invalid ID.']);
            exit;
        }

        $pdo->prepare("UPDATE permissions SET description = ? WHERE id = ?")
            ->execute([$desc ?: null, $id]);

        logAudit($pdo, 'permissions', $id, 'UPDATE', "Description updated");
        echo json_encode(['ok' => true]);
        exit;
    }

    /* ── Toggle role assignment ── */
    if ($action === 'toggle_role') {
        $permId = (int)($_POST['perm_id'] ?? 0);
        $roleId = (int)($_POST['role_id'] ?? 0);

        if ($permId <= 0 || $roleId <= 0) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'message' => 'Invalid IDs.']);
            exit;
        }

        /* Check current state */
        $chk = $pdo->prepare("SELECT COUNT(*) FROM role_permissions WHERE role_id = ? AND permission_id = ?");
        $chk->execute([$roleId, $permId]);
        $exists = (bool)$chk->fetchColumn();

        if ($exists) {
            $pdo->prepare("DELETE FROM role_permissions WHERE role_id = ? AND permission_id = ?")
                ->execute([$roleId, $permId]);
            $granted = false;
        } else {
            $pdo->prepare("INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES (?, ?)")
                ->execute([$roleId, $permId]);
            $granted = true;
        }

        logAudit($pdo, 'role_permissions', $permId, 'TOGGLE',
                 "Role #{$roleId} " . ($granted ? 'granted' : 'revoked') . " permission #{$permId}");

        echo json_encode(['ok' => true, 'granted' => $granted]);
        exit;
    }

    http_response_code(400);
    echo json_encode(['ok' => false, 'message' => 'Unknown action.']);
    exit;
}

/* ─── Pagination & search ────────────────────────────────────────────── */
$search = trim($_GET['search'] ?? '');
['perPage' => $perPage, 'page' => $page, 'offset' => $offset] = getPaginationParams(25);

$searchWhere  = '';
$searchParams = [];
if ($search !== '') {
    $searchWhere  = ' WHERE name LIKE ? OR description LIKE ?';
    $searchParams = ["%$search%", "%$search%"];
}

$totalPerms    = 0;
$permissions   = [];
$roles         = [];
$rpMap         = [];
$overrideStats = [];
$pageError     = null;

try {
    /* ─── Total permission count ─────────────────────────────────────────── */
    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM permissions" . $searchWhere);
    $cntStmt->execute($searchParams);
    $totalPerms = (int)$cntStmt->fetchColumn();

    /* ─── Paginated permission list ─────────────────────────────────────── */
    $permStmt = $pdo->prepare(
        "SELECT id, name, description FROM permissions" .
        $searchWhere .
        " ORDER BY name LIMIT ? OFFSET ?"
    );
    $permStmt->execute(array_merge($searchParams, [$perPage, $offset]));
    $permissions = $permStmt->fetchAll(PDO::FETCH_ASSOC);

    $permIds = array_column($permissions, 'id');

    /* ─── Fetch all roles ───────────────────────────────────────────────── */
    $roles = $pdo->query("
        SELECT id, name
        FROM roles
        ORDER BY name
    ")->fetchAll(PDO::FETCH_ASSOC);

    /* ─── Build role_permissions map for current-page permissions ────────── */
    if (!empty($permIds)) {
        $holders = implode(',', array_fill(0, count($permIds), '?'));
        $rpStmt  = $pdo->prepare(
            "SELECT role_id, permission_id FROM role_permissions WHERE permission_id IN ($holders)"
        );
        $rpStmt->execute($permIds);
        foreach ($rpStmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $rpMap[$row['permission_id']][$row['role_id']] = true;
        }
    }

    /* ─── Per-permission override stats for current-page permissions ─────── */
    if (!empty($permIds)) {
        $holders = implode(',', array_fill(0, count($permIds), '?'));
        $oStmt   = $pdo->prepare(
            "SELECT permission_id, COUNT(*) AS cnt
             FROM user_permissions
             WHERE is_granted = 1 AND permission_id IN ($holders)
             GROUP BY permission_id"
        );
        $oStmt->execute($permIds);
        foreach ($oStmt->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $overrideStats[$r['permission_id']] = (int)$r['cnt'];
        }
    }
} catch (Throwable $e) {
    $pageError = 'Permission data is temporarily unavailable. Please try again or contact your administrator.';
    error_log('admin/permissions.php load error: ' . $e->getMessage());
}

require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';
?>

<div class="container-fluid">

    <!-- Page header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-0"><i class="bi bi-key me-2"></i>Permissions</h2>
            <p class="text-muted small mb-0">
                Create permissions and assign them to roles. Individual user overrides can be managed from the
                <a href="/users/list.php">Users</a> page.
            </p>
        </div>
        <?php if ($canManage): ?>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createPermModal">
            <i class="bi bi-plus-lg me-1"></i>New Permission
        </button>
        <?php endif; ?>
    </div>

    <?php if ($pageError !== null): ?>
    <div class="alert alert-warning d-flex gap-2 align-items-start mb-4">
        <i class="bi bi-exclamation-triangle-fill fs-5 mt-1"></i>
        <div><?= htmlspecialchars($pageError) ?></div>
    </div>
    <?php endif; ?>

    <!-- Info alert -->
    <div class="alert alert-info d-flex gap-2 align-items-start mb-4">
        <i class="bi bi-info-circle-fill fs-5 mt-1"></i>
        <div>
            <strong>How it works:</strong>
            Tick a cell to grant a role that permission. Untick to revoke it. Changes save instantly.
            User-level overrides (granted or denied individually) always take precedence over role defaults.
        </div>
    </div>

    <!-- Search -->
    <form method="get" class="row g-2 mb-3 align-items-end">
        <div class="col-auto flex-grow-1">
            <input type="text" name="search" class="form-control"
                   placeholder="&#128269; Search permissions…"
                   value="<?= htmlspecialchars($search) ?>">
        </div>
        <div class="col-auto">
            <button class="btn btn-outline-secondary" type="submit">
                <i class="bi bi-search me-1"></i>Search
            </button>
            <?php if ($search !== ''): ?>
            <a href="?" class="btn btn-outline-danger ms-1">
                <i class="bi bi-x-lg me-1"></i>Clear
            </a>
            <?php endif; ?>
        </div>
    </form>

    <?php if ($pageError === null && $totalPerms === 0 && $search === ''): ?>
    <div class="alert alert-warning">No permissions found. Create one to get started.</div>
    <?php elseif ($pageError === null && $totalPerms === 0): ?>
    <div class="alert alert-warning">No permissions match "<strong><?= htmlspecialchars($search) ?></strong>".</div>
    <?php elseif ($pageError === null): ?>

    <!-- Role×Permission Matrix -->
    <div class="card shadow-sm mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span><i class="bi bi-grid-3x3-gap me-2"></i>Role Assignment Matrix</span>
            <span class="badge bg-secondary"><?= $totalPerms ?> permissions &nbsp;·&nbsp; <?= count($roles) ?> roles</span>
        </div>
        <div class="card-body p-0">
            <div style="overflow-x: auto;">
                <table class="table table-bordered table-sm mb-0 align-middle" id="matrixTable">
                    <thead class="table-light">
                        <tr>
                            <th style="min-width:220px;">Permission</th>
                            <?php foreach ($roles as $role): ?>
                            <th class="text-center" style="min-width:110px; font-size:0.8rem;">
                                <?= htmlspecialchars($role['name']) ?>
                            </th>
                            <?php endforeach; ?>
                            <th class="text-center" style="min-width:80px;">Users</th>
                            <?php if ($canManage): ?>
                            <th class="text-center" style="min-width:70px;">Actions</th>
                            <?php endif; ?>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($permissions as $perm): ?>
                        <tr data-perm-id="<?= $perm['id'] ?>">
                            <td>
                                <code class="text-primary fw-semibold"><?= htmlspecialchars($perm['name']) ?></code>
                                <?php if ($perm['description']): ?>
                                <br><small class="text-muted"><?= htmlspecialchars($perm['description']) ?></small>
                                <?php endif; ?>
                            </td>
                            <?php foreach ($roles as $role): ?>
                            <?php $checked = !empty($rpMap[$perm['id']][$role['id']]); ?>
                            <td class="text-center">
                                <?php if ($canManage): ?>
                                <div class="form-check form-switch d-flex justify-content-center m-0">
                                    <input class="form-check-input role-toggle" type="checkbox"
                                           style="cursor:pointer;"
                                           data-perm-id="<?= $perm['id'] ?>"
                                           data-role-id="<?= $role['id'] ?>"
                                           <?= $checked ? 'checked' : '' ?>>
                                </div>
                                <?php else: ?>
                                    <?php if ($checked): ?>
                                    <i class="bi bi-check-circle-fill text-success"></i>
                                    <?php else: ?>
                                    <i class="bi bi-dash text-muted"></i>
                                    <?php endif; ?>
                                <?php endif; ?>
                            </td>
                            <?php endforeach; ?>
                            <td class="text-center">
                                <?php $uc = $overrideStats[$perm['id']] ?? 0; ?>
                                <?php if ($uc > 0): ?>
                                <span class="badge bg-info text-dark"><?= $uc ?></span>
                                <?php else: ?>
                                <span class="text-muted">—</span>
                                <?php endif; ?>
                            </td>
                            <?php if ($canManage): ?>
                            <td class="text-center">
                                <button class="btn btn-sm btn-outline-danger delete-perm"
                                        data-perm-id="<?= $perm['id'] ?>"
                                        data-perm-name="<?= htmlspecialchars($perm['name']) ?>"
                                        title="Delete permission">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                            <?php endif; ?>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div><!-- /.card -->

    <div class="mt-3">
        <?php renderShowingInfo($page, $perPage, $totalPerms); ?>
        <?php renderPagination($totalPerms, $perPage, $page, array_filter(['search' => $search])); ?>
    </div>

    <?php endif; ?>

</div><!-- /.container-fluid -->

<?php if ($canManage): ?>
<!-- Create Permission Modal -->
<div class="modal fade" id="createPermModal" tabindex="-1" aria-labelledby="createPermModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post">
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title" id="createPermModalLabel"><i class="bi bi-plus-circle me-2"></i>New Permission</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Permission Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control"
                               placeholder="e.g. export_reports"
                               pattern="[a-zA-Z0-9_]+"
                               title="Letters, numbers and underscores only"
                               required>
                        <div class="form-text">Lowercase letters, digits, and underscores only (auto-sanitised).</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <input type="text" name="description" class="form-control"
                               placeholder="e.g. Allow exporting report files">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-check-lg me-1"></i>Create</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Permission Form (hidden, submitted via JS) -->
<form method="post" id="deletePermForm" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deletePermId">
</form>
<?php endif; ?>

<script>
(function () {
    'use strict';

    /* ── Role toggle (AJAX) ─────────────────────────────────── */
    document.querySelectorAll('.role-toggle').forEach(function (cb) {
        cb.addEventListener('change', function () {
            var permId = this.dataset.permId;
            var roleId = this.dataset.roleId;
            var self   = this;
            self.disabled = true;

            var fd = new FormData();
            fd.append('action',  'toggle_role');
            fd.append('perm_id', permId);
            fd.append('role_id', roleId);

            fetch('', {method: 'POST', body: fd})
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    if (!data.ok) {
                        alert('Error: ' + data.message);
                        self.checked = !self.checked; // revert
                    }
                    self.disabled = false;
                })
                .catch(function () {
                    alert('Network error. Please try again.');
                    self.checked = !self.checked;
                    self.disabled = false;
                });
        });
    });

    /* ── Delete permission ──────────────────────────────────── */
    document.querySelectorAll('.delete-perm').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var permName = this.dataset.permName;
            var permId   = this.dataset.permId;

            if (!confirm('Delete permission "' + permName + '"?\n\nThis will also remove it from all roles and user overrides. This cannot be undone.')) {
                return;
            }

            document.getElementById('deletePermId').value = permId;
            document.getElementById('deletePermForm').submit();
        });
    });
})();
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
