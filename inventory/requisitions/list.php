<?php
$REQUIRE_PERMISSION = 'view_inventory';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$where = [];
$params = [];

if (!empty($_GET['q'])) {
    $where[] = "(r.requisition_number LIKE :q)";
    $params[':q'] = '%' . $_GET['q'] . '%';
}
if (!empty($_GET['status'])) {
    $where[] = "r.status = :status";
    $params[':status'] = $_GET['status'];
}
if (!empty($_GET['urgency'])) {
    $where[] = "r.urgency = :urgency";
    $params[':urgency'] = $_GET['urgency'];
}

// Non-admin users see only their own requisitions
$roleName = $_SESSION['role_name'] ?? '';
if (!in_array($roleName, ['Admin', 'SuperAdmin', 'HOD', 'Finance Officer'])) {
    $where[] = "r.requester_user_id = :uid";
    $params[':uid'] = $_SESSION['user_id'];
}

$whereSQL = $where ? 'WHERE ' . implode(' AND ', $where) : '';
extract(getPaginationParams(20));

$sql = "
    SELECT r.*, u.full_name AS requester_name, b.branch_name,
           (SELECT COUNT(*) FROM inv_requisition_items ri WHERE ri.requisition_id = r.requisition_id) AS item_count
    FROM inv_requisitions r
    JOIN users u ON r.requester_user_id = u.user_id
    LEFT JOIN branches b ON r.department_id = b.branch_id
    $whereSQL
    ORDER BY r.created_at DESC
    LIMIT :limit OFFSET :offset
";

$stmt = $pdo->prepare($sql);
foreach ($params as $k => $v) $stmt->bindValue($k, $v);
$stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$countSql = "SELECT COUNT(*) FROM inv_requisitions r $whereSQL";
$countStmt = $pdo->prepare($countSql);
foreach ($params as $k => $v) $countStmt->bindValue($k, $v);
$countStmt->execute();
$totalRows = (int) $countStmt->fetchColumn();

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clipboard-check"></i> Stock Requisitions</h2>
    <?php if (has_permission('submit_stock_requisition')): ?>
    <a href="/inventory/requisitions/add.php" class="btn btn-primary"><i class="bi bi-plus-circle"></i> New Requisition</a>
    <?php endif; ?>
</div>

<!-- Filters -->
<form method="GET" class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label">Search</label>
                <input type="text" name="q" class="form-control" placeholder="Requisition number..."
                       value="<?= htmlspecialchars($_GET['q'] ?? '') ?>">
            </div>
            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select name="status" class="form-select">
                    <option value="">All</option>
                    <?php foreach (['DRAFT','SUBMITTED','APPROVED','PARTIALLY_ISSUED','ISSUED','REJECTED','CANCELLED'] as $s): ?>
                    <option value="<?= $s ?>" <?= ($_GET['status'] ?? '') === $s ? 'selected' : '' ?>><?= $s ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label">Urgency</label>
                <select name="urgency" class="form-select">
                    <option value="">All</option>
                    <option value="NORMAL" <?= ($_GET['urgency'] ?? '') === 'NORMAL' ? 'selected' : '' ?>>Normal</option>
                    <option value="URGENT" <?= ($_GET['urgency'] ?? '') === 'URGENT' ? 'selected' : '' ?>>Urgent</option>
                    <option value="EMERGENCY" <?= ($_GET['urgency'] ?? '') === 'EMERGENCY' ? 'selected' : '' ?>>Emergency</option>
                </select>
            </div>
            <div class="col-md-1"><button type="submit" class="btn btn-dark w-100">Filter</button></div>
            <div class="col-md-1"><a href="/inventory/requisitions/list.php" class="btn btn-outline-secondary w-100">Clear</a></div>
        </div>
    </div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Req #</th>
                        <th>Requester</th>
                        <th>Department</th>
                        <th>Items</th>
                        <th>Urgency</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No requisitions found.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($rows as $row): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($row['requisition_number']) ?></code></td>
                        <td><?= htmlspecialchars($row['requester_name']) ?></td>
                        <td><?= htmlspecialchars($row['branch_name'] ?? '-') ?></td>
                        <td><?= $row['item_count'] ?></td>
                        <td>
                            <span class="badge bg-<?= $row['urgency'] === 'EMERGENCY' ? 'danger' : ($row['urgency'] === 'URGENT' ? 'warning' : 'info') ?>">
                                <?= $row['urgency'] ?>
                            </span>
                        </td>
                        <td>
                            <?php
                            $sc = match($row['status']) {
                                'DRAFT' => 'secondary', 'SUBMITTED' => 'primary', 'APPROVED' => 'success',
                                'PARTIALLY_ISSUED' => 'info', 'ISSUED' => 'dark', 'REJECTED' => 'danger',
                                'CANCELLED' => 'secondary', default => 'secondary'
                            };
                            ?>
                            <span class="badge bg-<?= $sc ?>"><?= $row['status'] ?></span>
                            <?php if ($row['is_duplicate_flagged']): ?>
                            <span class="badge bg-warning text-dark" title="Possible duplicate">⚠️ DUP</span>
                            <?php endif; ?>
                        </td>
                        <td><?= date('Y-m-d', strtotime($row['created_at'])) ?></td>
                        <td class="text-center">
                            <a href="/inventory/requisitions/view.php?id=<?= $row['requisition_id'] ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php if ($totalRows > 0): ?>
<div class="mt-3">
    <?php renderShowingInfo($page, $perPage, $totalRows); ?>
    <?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
