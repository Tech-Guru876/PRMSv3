<?php
$REQUIRE_PERMISSION = 'manage_returns';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$statusFilter = $_GET['status'] ?? '';
$pagination = getPaginationParams();
extract($pagination);

$where = ["1=1"];
$params = [];
if ($statusFilter && in_array($statusFilter, ['DRAFT','PENDING_APPROVAL','APPROVED','DISPATCHED','COMPLETED','CANCELLED'])) {
    $where[] = "r.status = ?";
    $params[] = $statusFilter;
}
$whereClause = implode(' AND ', $where);

$totalRows = $pdo->prepare("SELECT COUNT(*) FROM inv_returns r WHERE $whereClause");
$totalRows->execute($params);
$totalRows = (int) $totalRows->fetchColumn();

$stmt = $pdo->prepare("
    SELECT r.*, u.full_name AS requested_by_name, ua.full_name AS approved_by_name
    FROM inv_returns r
    LEFT JOIN users u ON r.requested_by = u.user_id
    LEFT JOIN users ua ON r.approved_by = ua.user_id
    WHERE $whereClause
    ORDER BY r.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$returns = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-return-left"></i> Returns to Supplier</h2>
    <a href="/inventory/returns/add.php" class="btn btn-primary"><i class="bi bi-plus-lg"></i> New Return</a>
</div>

<div class="card border-0 shadow-sm mb-3">
    <div class="card-body py-2">
        <form method="GET" class="row g-2 align-items-end">
            <div class="col-auto">
                <select name="status" class="form-select form-select-sm">
                    <option value="">All Statuses</option>
                    <?php foreach (['DRAFT','PENDING_APPROVAL','APPROVED','DISPATCHED','COMPLETED','CANCELLED'] as $s): ?>
                    <option value="<?= $s ?>" <?= $statusFilter === $s ? 'selected' : '' ?>><?= str_replace('_', ' ', $s) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-auto"><button type="submit" class="btn btn-sm btn-outline-primary">Filter</button></div>
        </form>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Return #</th><th>Type</th><th>Supplier</th><th>Status</th><th>Requested By</th><th>Date</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if (empty($returns)): ?>
                    <tr><td colspan="7" class="text-muted text-center py-4">No returns found.</td></tr>
                    <?php else: foreach ($returns as $r):
                        $sc = match($r['status']) { 'DRAFT' => 'secondary', 'PENDING_APPROVAL' => 'warning', 'APPROVED' => 'info', 'DISPATCHED' => 'primary', 'COMPLETED' => 'success', 'CANCELLED' => 'danger', default => 'secondary' };
                    ?>
                    <tr>
                        <td><strong><?= htmlspecialchars($r['return_number']) ?></strong></td>
                        <td><span class="badge bg-secondary"><?= str_replace('_', ' ', $r['return_type']) ?></span></td>
                        <td><?= htmlspecialchars($r['supplier_name'] ?: '-') ?></td>
                        <td><span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $r['status']) ?></span></td>
                        <td><?= htmlspecialchars($r['requested_by_name']) ?></td>
                        <td><?= date('Y-m-d', strtotime($r['created_at'])) ?></td>
                        <td><a href="/inventory/returns/view.php?id=<?= $r['return_id'] ?>" class="btn btn-sm btn-outline-primary">View</a></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php renderPagination($totalRows, $perPage, $page, ['status' => $statusFilter]); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
