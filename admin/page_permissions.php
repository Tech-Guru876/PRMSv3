<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/pagination.php';

$schemaError = null;
$requiredColumns = ['id', 'page_path', 'page_title', 'permission_name', 'module', 'is_active'];

try {
    $dbStmt = $pdo->prepare("SELECT DATABASE()");
    $dbStmt->execute();
    $dbNameResult = $dbStmt->fetchColumn();

    if ($dbNameResult === false || $dbNameResult === '') {
        $schemaError = 'Database schema could not be determined. Please verify database configuration.';
    } else {
        $currentDb = (string)$dbNameResult;
        $tblStmt = $pdo->prepare("
            SELECT COUNT(*)
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = ?
              AND TABLE_NAME = 'page_permissions'
        ");
        $tblStmt->execute([$currentDb]);
        $tableExists = (int)$tblStmt->fetchColumn();

        if (!$tableExists) {
            $schemaError = 'Page permissions table is missing. Please run the latest database migrations.';
        } else {
            $columnPlaceholders = implode(',', array_fill(0, count($requiredColumns), '?'));
            $colStmt = $pdo->prepare("
                SELECT COUNT(*)
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = ?
                  AND TABLE_NAME = 'page_permissions'
                  AND COLUMN_NAME IN ($columnPlaceholders)
            ");
            $colStmt->execute(array_merge([$currentDb], $requiredColumns));
            $columnCount = (int)$colStmt->fetchColumn();

            if ($columnCount < count($requiredColumns)) {
                $schemaError = 'Page permissions table is outdated. Please run the latest database migrations.';
            }
        }
    }
} catch (\PDOException $e) {
    error_log('page_permissions schema check failed: ' . $e->getMessage());
    $schemaError = 'Unable to verify page permissions schema at this time.';
}

/* ─── Handle AJAX / form actions ──────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($schemaError !== null) {
        jsonError($schemaError);
    }

    $action = $_POST['action'] ?? '';

    /* ── Update a page's required permission ── */
    if ($action === 'update') {
        $id      = (int)($_POST['id'] ?? 0);
        $newPerm = trim($_POST['permission_name'] ?? '');

        if ($id <= 0 || $newPerm === '') {
            jsonError('Invalid data.');
        }

        // Validate the permission exists
        $chk = $pdo->prepare("SELECT COUNT(*) FROM permissions WHERE name = ?");
        $chk->execute([$newPerm]);
        if (!$chk->fetchColumn()) {
            jsonError("Permission '{$newPerm}' does not exist.");
        }

        $pdo->prepare("UPDATE page_permissions SET permission_name = ? WHERE id = ?")
            ->execute([$newPerm, $id]);

        logAudit($pdo, 'page_permissions', $id, 'UPDATE', "Permission changed to '{$newPerm}'");

        echo json_encode(['ok' => true, 'message' => 'Updated.']);
        exit;
    }

    /* ── Add a new page entry ── */
    if ($action === 'add') {
        $pagePath  = trim($_POST['page_path'] ?? '');
        $pageTitle = trim($_POST['page_title'] ?? '');
        $permName  = trim($_POST['permission_name'] ?? '');
        $module    = trim($_POST['module'] ?? 'general');

        if ($pagePath === '' || $pageTitle === '' || $permName === '') {
            jsonError('All fields are required.');
        }

        // Validate permission exists
        $chk = $pdo->prepare("SELECT COUNT(*) FROM permissions WHERE name = ?");
        $chk->execute([$permName]);
        if (!$chk->fetchColumn()) {
            jsonError("Permission '{$permName}' does not exist.");
        }

        try {
            $pdo->prepare("
                INSERT INTO page_permissions (page_path, page_title, permission_name, module)
                VALUES (?, ?, ?, ?)
            ")->execute([$pagePath, $pageTitle, $permName, $module]);

            $newId = $pdo->lastInsertId();
            logAudit($pdo, 'page_permissions', (int)$newId, 'CREATE',
                     "Page '{$pagePath}' mapped to '{$permName}'");

            echo json_encode(['ok' => true, 'message' => 'Page added.']);
        } catch (\PDOException $e) {
            if ($e->getCode() == '23000') {
                jsonError('A page with that path already exists.');
            }
            jsonError('Database error: ' . $e->getMessage());
        }
        exit;
    }

    /* ── Toggle active flag ── */
    if ($action === 'toggle') {
        $id = (int)($_POST['id'] ?? 0);
        $pdo->prepare("UPDATE page_permissions SET is_active = NOT is_active WHERE id = ?")
            ->execute([$id]);
        logAudit($pdo, 'page_permissions', $id, 'TOGGLE', 'Active flag toggled');
        echo json_encode(['ok' => true]);
        exit;
    }

    /* ── Delete a custom entry ── */
    if ($action === 'delete') {
        $id = (int)($_POST['id'] ?? 0);
        $pdo->prepare("DELETE FROM page_permissions WHERE id = ?")->execute([$id]);
        logAudit($pdo, 'page_permissions', $id, 'DELETE', 'Page permission entry deleted');
        echo json_encode(['ok' => true]);
        exit;
    }

    jsonError('Unknown action.');
}

/**
 * @return never
 */
function jsonError(string $msg) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'message' => $msg]);
    exit;
}

/* ─── Pagination & module filter ────────────────────────────────────── */
$activeModule = trim($_GET['module'] ?? '');
['perPage' => $perPage, 'page' => $page, 'offset' => $offset] = getPaginationParams(20);

/* ─── Fetch all page permissions (paginated + optional module filter) ── */
$pages      = [];
$totalCount = 0;
if ($schemaError === null) {
    $whereClause = '';
    $whereParams = [];
    if ($activeModule !== '') {
        $whereClause = ' WHERE pp.module = ?';
        $whereParams = [$activeModule];
    }

    try {
        $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM page_permissions pp" . $whereClause);
        $cntStmt->execute($whereParams);
        $totalCount = (int)$cntStmt->fetchColumn();

        $pgStmt = $pdo->prepare("
            SELECT pp.id, pp.page_path, pp.page_title, pp.permission_name,
                   pp.module, pp.is_active,
                   p.description AS perm_description
            FROM page_permissions pp
            LEFT JOIN permissions p ON pp.permission_name = p.name
            $whereClause
            ORDER BY pp.module, pp.page_title
            LIMIT ? OFFSET ?
        ");
        $pgStmt->execute(array_merge($whereParams, [$perPage, $offset]));
        $pages = $pgStmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Throwable $e) {
        $schemaError = 'Failed to load page permissions data. Please try again.';
        error_log('admin/page_permissions.php list query error: ' . $e->getMessage());
    }
}

/* ─── Distinct modules for tab bar ─────────────────────────────────── */
$allModules = [];
if ($schemaError === null) {
    try {
        $allModules = $pdo->query(
            "SELECT DISTINCT module FROM page_permissions ORDER BY module"
        )->fetchAll(PDO::FETCH_COLUMN);
    } catch (Throwable $e) {
        error_log('admin/page_permissions.php modules query error: ' . $e->getMessage());
    }
}

/* ─── Fetch all permissions for the dropdown ───────────────────────── */
$allPerms = [];
try {
    $allPerms = $pdo->query("
        SELECT name, description FROM permissions ORDER BY name
    ")->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    error_log('admin/page_permissions.php allPerms query error: ' . $e->getMessage());
}

/* ─── Unique modules for the new-page form ─────────────────────────── */
$modules = $allModules;

require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';
?>

<div class="container-fluid">

    <!-- Page header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-0"><i class="bi bi-shield-lock me-2"></i>Page Permissions</h2>
            <p class="text-muted small mb-0">Assign which permission is required to access each page in the system.</p>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addPageModal">
            <i class="bi bi-plus-lg me-1"></i>Add Page
        </button>
    </div>

    <!-- Info alert -->
    <div class="alert alert-info d-flex gap-2 align-items-start mb-4">
        <i class="bi bi-info-circle-fill fs-5 mt-1"></i>
        <div>
            <strong>How this works:</strong> Each page in the system normally requires a specific permission that is set in its PHP code.
            You can override that requirement here — when a row for a page is active, the database value takes precedence.
            Users must then have the assigned permission (via their role or a user-level override) to access the page.
        </div>
    </div>
    <?php if ($schemaError !== null): ?>
    <div class="alert alert-warning mb-4">
        <i class="bi bi-exclamation-triangle-fill me-1"></i><?= htmlspecialchars($schemaError) ?>
    </div>
    <?php endif; ?>

    <!-- Module filter tabs (server-side) -->
    <ul class="nav nav-pills mb-3 flex-wrap gap-1">
        <?php
        $allCount = $schemaError === null
            ? (int)$pdo->query("SELECT COUNT(*) FROM page_permissions")->fetchColumn()
            : 0;
        ?>
        <li class="nav-item">
            <a class="nav-link <?= $activeModule === '' ? 'active' : '' ?>"
               href="?module=">All (<?= $allCount ?>)</a>
        </li>
        <?php foreach ($allModules as $mod): ?>
        <li class="nav-item">
            <a class="nav-link <?= $activeModule === $mod ? 'active' : '' ?>"
               href="?module=<?= urlencode($mod) ?>">
                <?= htmlspecialchars($mod) ?>
            </a>
        </li>
        <?php endforeach; ?>
    </ul>

    <!-- Search box (filters rows within current page) -->
    <div class="mb-3">
        <input type="text" id="searchBox" class="form-control" placeholder="&#128269; Search pages or permissions…">
    </div>

    <!-- Table -->
    <div class="table-responsive mb-3">
        <table class="table table-hover table-sm align-middle">
            <thead class="table-light">
                <tr>
                    <th style="width:28%">Page</th>
                    <th style="width:12%">Module</th>
                    <th style="width:22%">Required Permission</th>
                    <th style="width:20%">Description</th>
                    <th style="width:12%" class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($pages as $pg): ?>
                <tr class="page-row <?= $pg['is_active'] ? '' : 'table-secondary opacity-50' ?>"
                    data-id="<?= $pg['id'] ?>"
                    data-path="<?= htmlspecialchars($pg['page_path']) ?>"
                    data-perm="<?= htmlspecialchars($pg['permission_name']) ?>"
                    data-title="<?= htmlspecialchars($pg['page_title']) ?>"
                    data-module="<?= htmlspecialchars($pg['module']) ?>">

                    <td>
                        <div class="fw-medium"><?= htmlspecialchars($pg['page_title']) ?></div>
                        <code class="small text-muted"><?= htmlspecialchars($pg['page_path']) ?></code>
                        <?php if (!$pg['is_active']): ?>
                            <span class="badge bg-secondary ms-1">Inactive</span>
                        <?php endif; ?>
                    </td>

                    <td>
                        <span class="badge bg-light text-dark border"><?= htmlspecialchars($pg['module']) ?></span>
                    </td>

                    <td>
                        <span class="badge bg-primary perm-badge">
                            <?= htmlspecialchars($pg['permission_name']) ?>
                        </span>
                    </td>

                    <td class="small text-muted">
                        <?= htmlspecialchars($pg['perm_description'] ?? '—') ?>
                    </td>

                    <td class="text-center">
                        <button class="btn btn-sm btn-outline-primary me-1 btn-edit"
                                title="Edit permission" data-id="<?= $pg['id'] ?>"
                                data-path="<?= htmlspecialchars($pg['page_path']) ?>"
                                data-perm="<?= htmlspecialchars($pg['permission_name']) ?>"
                                data-title="<?= htmlspecialchars($pg['page_title']) ?>">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-secondary me-1 btn-toggle"
                                title="Toggle active" data-id="<?= $pg['id'] ?>">
                            <i class="bi bi-<?= $pg['is_active'] ? 'eye-slash' : 'eye' ?>"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger btn-delete"
                                title="Delete" data-id="<?= $pg['id'] ?>"
                                data-path="<?= htmlspecialchars($pg['page_path']) ?>">
                            <i class="bi bi-trash3"></i>
                        </button>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($pages)): ?>
                <tr><td colspan="5" class="text-center text-muted py-3">No page permissions found.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <?php renderShowingInfo($page, $perPage, $totalCount); ?>
    <?php renderPagination($totalCount, $perPage, $page, array_filter(['module' => $activeModule])); ?>

</div>

<!-- ── Edit Permission Modal ──────────────────────────────────────── -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-pencil me-2"></i>Edit Page Permission</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editId">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Page</label>
                    <input type="text" id="editPath" class="form-control" readonly>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Required Permission</label>
                    <select id="editPerm" class="form-select">
                        <?php foreach ($allPerms as $p): ?>
                        <option value="<?= htmlspecialchars($p['name']) ?>">
                            <?= htmlspecialchars($p['name']) ?>
                            <?= $p['description'] ? ' — ' . htmlspecialchars($p['description']) : '' ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div id="editMsg" class="alert d-none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnSaveEdit">
                    <i class="bi bi-check-lg me-1"></i>Save
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ── Add Page Modal ─────────────────────────────────────────────── -->
<div class="modal fade" id="addPageModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-plus-circle me-2"></i>Add Page Permission</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Page Path <span class="text-danger">*</span></label>
                        <input type="text" id="addPath" class="form-control" placeholder="/module/page.php">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Page Title <span class="text-danger">*</span></label>
                        <input type="text" id="addTitle" class="form-control" placeholder="Human-readable name">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Required Permission <span class="text-danger">*</span></label>
                        <select id="addPerm" class="form-select">
                            <option value="">-- Select permission --</option>
                            <?php foreach ($allPerms as $p): ?>
                            <option value="<?= htmlspecialchars($p['name']) ?>">
                                <?= htmlspecialchars($p['name']) ?>
                                <?= $p['description'] ? ' — ' . htmlspecialchars($p['description']) : '' ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Module</label>
                        <input type="text" id="addModule" class="form-control" list="moduleList" placeholder="e.g. Procurement">
                        <datalist id="moduleList">
                            <?php foreach ($modules as $m): ?>
                            <option value="<?= htmlspecialchars($m) ?>">
                            <?php endforeach; ?>
                        </datalist>
                    </div>
                </div>
                <div id="addMsg" class="alert d-none mt-3"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnSaveAdd">
                    <i class="bi bi-plus-lg me-1"></i>Add Page
                </button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {

/* ── Search (filters rows within current page) ── */
document.getElementById('searchBox').addEventListener('input', function () {
    const q = this.value.toLowerCase();
    document.querySelectorAll('.page-row').forEach(function (row) {
        const text = (row.dataset.path + row.dataset.perm + row.dataset.title + row.dataset.module).toLowerCase();
        row.style.display = text.includes(q) ? '' : 'none';
    });
});

/* ── Edit ── */
const editModal = new bootstrap.Modal(document.getElementById('editModal'));
document.querySelectorAll('.btn-edit').forEach(function (btn) {
    btn.addEventListener('click', function () {
        document.getElementById('editId').value   = this.dataset.id;
        document.getElementById('editPath').value = this.dataset.path;
        const sel = document.getElementById('editPerm');
        for (let o of sel.options) o.selected = (o.value === this.dataset.perm);
        document.getElementById('editMsg').className = 'alert d-none';
        editModal.show();
    });
});

document.getElementById('btnSaveEdit').addEventListener('click', function () {
    const id   = document.getElementById('editId').value;
    const perm = document.getElementById('editPerm').value;
    postAction({ action: 'update', id, permission_name: perm }, 'editMsg', function (ok) {
        if (ok) {
            const row = document.querySelector('tr[data-id="' + id + '"]');
            if (row) {
                row.querySelector('.perm-badge').textContent = perm;
                row.dataset.perm = perm;
            }
            editModal.hide();
        }
    });
});

/* ── Toggle active ── */
document.querySelectorAll('.btn-toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
        const id = this.dataset.id;
        postAction({ action: 'toggle', id }, null, function (ok) {
            if (ok) location.reload();
        });
    });
});

/* ── Delete ── */
document.querySelectorAll('.btn-delete').forEach(function (btn) {
    btn.addEventListener('click', function () {
        if (!confirm('Delete this page permission entry for:\n' + this.dataset.path + '?')) return;
        const id = this.dataset.id;
        postAction({ action: 'delete', id }, null, function (ok) {
            if (ok) {
                const row = document.querySelector('tr[data-id="' + id + '"]');
                if (row) row.remove();
            }
        });
    });
});

/* ── Add page ── */
const addModal = new bootstrap.Modal(document.getElementById('addPageModal'));
document.getElementById('btnSaveAdd').addEventListener('click', function () {
    postAction({
        action:          'add',
        page_path:       document.getElementById('addPath').value,
        page_title:      document.getElementById('addTitle').value,
        permission_name: document.getElementById('addPerm').value,
        module:          document.getElementById('addModule').value || 'general'
    }, 'addMsg', function (ok) {
        if (ok) location.reload();
    });
});

/* ── Generic POST helper ── */
function postAction(data, msgId, callback) {
    const body = new URLSearchParams(data);
    fetch('', { method: 'POST', body })
        .then(function (r) { return r.json(); })
        .then(function (res) {
            if (msgId) {
                const el = document.getElementById(msgId);
                el.className = 'alert ' + (res.ok ? 'alert-success' : 'alert-danger');
                el.textContent = res.message || (res.ok ? 'Done.' : 'Error.');
            }
            if (callback) callback(res.ok);
        })
        .catch(function () {
            if (msgId) {
                const el = document.getElementById(msgId);
                el.className = 'alert alert-danger';
                el.textContent = 'Request failed.';
            }
        });
}

}); // end DOMContentLoaded
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
