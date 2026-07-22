<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/helper.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    try {
        if ($action === 'create') {
            $branchName = trim($_POST['branch_name'] ?? '');
            if ($branchName === '') {
                throw new InvalidArgumentException('Branch name is required.');
            }

            if (mb_strlen($branchName) > 100) {
                throw new InvalidArgumentException('Branch name must be 100 characters or less.');
            }

            $chk = $pdo->prepare("SELECT COUNT(*) FROM branches WHERE LOWER(branch_name) = LOWER(?)");
            $chk->execute([$branchName]);
            if ((int) $chk->fetchColumn() > 0) {
                throw new InvalidArgumentException("Branch '{$branchName}' already exists.");
            }

            $ins = $pdo->prepare("INSERT INTO branches (branch_name, is_active) VALUES (?, 1)");
            $ins->execute([$branchName]);
            $newId = (int) $pdo->lastInsertId();
            try { logAudit($pdo, 'branches', $newId, 'CREATE', "Branch '{$branchName}' created"); } catch (Throwable $e) {}

            $_SESSION['toast'] = ['message' => "Branch '{$branchName}' created.", 'type' => 'success'];
        } elseif ($action === 'toggle') {
            $id = (int) ($_POST['branch_id'] ?? 0);
            if ($id <= 0) {
                throw new InvalidArgumentException('Invalid branch selected.');
            }

            $rowStmt = $pdo->prepare("SELECT branch_name, is_active FROM branches WHERE branch_id = ?");
            $rowStmt->execute([$id]);
            $branch = $rowStmt->fetch(PDO::FETCH_ASSOC);
            if (!$branch) {
                throw new InvalidArgumentException('Branch not found.');
            }

            $pdo->prepare("UPDATE branches SET is_active = NOT is_active WHERE branch_id = ?")->execute([$id]);
            $newState = ((int) $branch['is_active'] === 1) ? 'inactive' : 'active';
            try { logAudit($pdo, 'branches', $id, 'TOGGLE', "Branch '{$branch['branch_name']}' set {$newState}"); } catch (Throwable $e) {}

            $_SESSION['toast'] = ['message' => "Branch '{$branch['branch_name']}' set {$newState}.", 'type' => 'success'];
        }
    } catch (Throwable $e) {
        $_SESSION['toast'] = ['message' => extractDbMessage($e), 'type' => 'danger'];
    }

    header('Location: /admin/branches.php');
    exit;
}

$search = trim($_GET['q'] ?? '');
$branches = [];

try {
    if ($search !== '') {
        $stmt = $pdo->prepare("
            SELECT branch_id, branch_name, is_active
            FROM branches
            WHERE branch_name LIKE ?
            ORDER BY branch_name ASC
        ");
        $stmt->execute(["%{$search}%"]);
    } else {
        $stmt = $pdo->query("
            SELECT branch_id, branch_name, is_active
            FROM branches
            ORDER BY branch_name ASC
        ");
    }
    $branches = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $_SESSION['toast'] = ['message' => 'Failed to load branches.', 'type' => 'danger'];
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1"><i class="bi bi-diagram-3 me-2"></i>Branch Management</h3>
            <small class="text-muted">Manage branch values used in request dropdowns.</small>
        </div>
    </div>

    <div class="card shadow-sm mb-3">
        <div class="card-header bg-light"><strong>Add Branch</strong></div>
        <div class="card-body">
            <form method="post" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="create">
                <div class="col-md-8">
                    <label class="form-label">Branch Name</label>
                    <input type="text" name="branch_name" class="form-control" maxlength="100" required>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-primary w-100"><i class="bi bi-plus-circle me-1"></i>Add Branch</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-light d-flex justify-content-between align-items-center">
            <strong>Existing Branches</strong>
            <form method="get" class="d-flex gap-2">
                <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control form-control-sm" placeholder="Search branch...">
                <button class="btn btn-outline-secondary btn-sm">Search</button>
            </form>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-sm table-hover mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">Branch</th>
                            <th>Status</th>
                            <th class="text-end pe-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($branches)): ?>
                            <tr><td colspan="3" class="text-center text-muted py-3">No branches found.</td></tr>
                        <?php else: ?>
                            <?php foreach ($branches as $b): ?>
                                <tr>
                                    <td class="ps-3"><?= htmlspecialchars($b['branch_name']) ?></td>
                                    <td>
                                        <?php if ((int) $b['is_active'] === 1): ?>
                                            <span class="badge bg-success">Active</span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary">Inactive</span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-end pe-3">
                                        <form method="post" class="d-inline">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="branch_id" value="<?= (int) $b['branch_id'] ?>">
                                            <button class="btn btn-sm <?= (int) $b['is_active'] === 1 ? 'btn-outline-warning' : 'btn-outline-success' ?>">
                                                <?= (int) $b['is_active'] === 1 ? 'Deactivate' : 'Activate' ?>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
