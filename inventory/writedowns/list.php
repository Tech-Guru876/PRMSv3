<?php
$REQUIRE_PERMISSION = 'manage_write_downs';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$statusFilter = $_GET['status'] ?? '';
$pagination = getPaginationParams();
extract($pagination);

$where = ["1=1"];
$params = [];
if ($statusFilter && in_array($statusFilter, ['DRAFT','PENDING_APPROVAL','APPROVED','REVERSED','CANCELLED'])) {
    $where[] = "w.status = ?";
    $params[] = $statusFilter;
}
$whereClause = implode(' AND ', $where);

$totalRows = $pdo->prepare("SELECT COUNT(*) FROM inv_write_downs w WHERE $whereClause");
$totalRows->execute($params);
$totalRows = (int) $totalRows->fetchColumn();

$stmt = $pdo->prepare("
    SELECT w.*, i.item_code, i.item_name, u.full_name AS requested_by_name,
           ua.full_name AS approved_by_name, l.location_code
    FROM inv_write_downs w
    JOIN inv_items i ON w.item_id = i.item_id
    LEFT JOIN users u ON w.requested_by = u.user_id
    LEFT JOIN users ua ON w.approved_by = ua.user_id
    LEFT JOIN inv_locations l ON w.location_id = l.location_id
    WHERE $whereClause
    ORDER BY w.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$writedowns = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-graph-down-arrow"></i> Write-Downs (NRV / IPSAS 12)</h2>
    <a href="/inventory/writedowns/add.php" class="btn btn-primary"><i class="bi bi-plus-lg"></i> New Write-Down</a>
</div>

<div class="card border-0 shadow-sm mb-3">
    <div class="card-body py-2">
        <form method="GET" class="row g-2 align-items-end">
            <div class="col-auto">
                <select name="status" class="form-select form-select-sm">
                    <option value="">All Statuses</option>
                    <?php foreach (['DRAFT','PENDING_APPROVAL','APPROVED','REVERSED','CANCELLED'] as $s): ?>
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
                    <tr><th>WD #</th><th>Item</th><th>Reason</th><th class="text-end">Cost</th><th class="text-end">NRV</th><th class="text-end">Write-Down</th><th>Status</th><th>Date</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if (empty($writedowns)): ?>
                    <tr><td colspan="9" class="text-muted text-center py-4">No write-downs found.</td></tr>
                    <?php else: foreach ($writedowns as $w):
                        $sc = match($w['status']) { 'DRAFT' => 'secondary', 'PENDING_APPROVAL' => 'warning', 'APPROVED' => 'success', 'REVERSED' => 'info', 'CANCELLED' => 'danger', default => 'secondary' };
                    ?>
                    <tr>
                        <td><strong><?= htmlspecialchars($w['write_down_number']) ?></strong></td>
                        <td><code><?= htmlspecialchars($w['item_code']) ?></code> <?= htmlspecialchars($w['item_name']) ?></td>
                        <td><span class="badge bg-secondary"><?= str_replace('_', ' ', $w['reason']) ?></span></td>
                        <td class="text-end">$<?= number_format($w['original_cost'], 2) ?></td>
                        <td class="text-end">$<?= number_format($w['nrv_value'], 2) ?></td>
                        <td class="text-end text-danger fw-bold">$<?= number_format($w['write_down_amount'], 2) ?></td>
                        <td><span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $w['status']) ?></span></td>
                        <td><?= date('Y-m-d', strtotime($w['created_at'])) ?></td>
                        <td><a href="/inventory/writedowns/view.php?id=<?= $w['write_down_id'] ?>" class="btn btn-sm btn-outline-primary">View</a></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php renderPagination($totalRows, $perPage, $page, ['status' => $statusFilter]); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
