<?php
$REQUIRE_PERMISSION = 'manage_recalls';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$statusFilter = $_GET['status'] ?? '';
$where = "1=1";
$params = [];
if ($statusFilter && in_array($statusFilter, ['INITIATED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'])) {
    $where .= " AND r.status = ?";
    $params[] = $statusFilter;
}

$countStmt = $pdo->prepare("SELECT COUNT(*) FROM inv_recalls r WHERE $where");
$countStmt->execute($params);
$totalRows = (int) $countStmt->fetchColumn();

extract(getPaginationParams());

$stmt = $pdo->prepare("
    SELECT r.*, i.item_code, i.item_name, u.full_name AS initiator_name
    FROM inv_recalls r
    JOIN inv_items i ON r.item_id = i.item_id
    LEFT JOIN users u ON r.initiated_by = u.user_id
    WHERE $where
    ORDER BY r.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-counterclockwise"></i> Recall / Withdrawal Register</h2>
    <a href="/inventory/recall/add.php" class="btn btn-danger"><i class="bi bi-plus-circle"></i> Initiate Recall</a>
</div>

<div class="btn-group mb-3">
    <a href="?status=" class="btn btn-sm btn-<?= !$statusFilter ? 'dark' : 'outline-dark' ?>">All</a>
    <a href="?status=INITIATED" class="btn btn-sm btn-<?= $statusFilter === 'INITIATED' ? 'warning' : 'outline-warning' ?>">Initiated</a>
    <a href="?status=IN_PROGRESS" class="btn btn-sm btn-<?= $statusFilter === 'IN_PROGRESS' ? 'info' : 'outline-info' ?>">In Progress</a>
    <a href="?status=COMPLETED" class="btn btn-sm btn-<?= $statusFilter === 'COMPLETED' ? 'success' : 'outline-success' ?>">Completed</a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Recall #</th><th>Type</th><th>Item</th><th>Batch/Lot</th><th>Severity</th><th>Status</th><th>Initiated By</th><th>Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="9" class="text-center text-muted py-4">No recall records found.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($rows as $r): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($r['recall_number']) ?></code></td>
                        <td><span class="badge bg-info"><?= $r['recall_type'] ?></span></td>
                        <td><?= htmlspecialchars($r['item_code'] . ' — ' . $r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['batch_lot_number'] ?: '-') ?></td>
                        <td>
                            <?php $sv = match($r['severity']) { 'CLASS_I' => 'danger', 'CLASS_II' => 'warning', 'CLASS_III' => 'info', default => 'secondary' }; ?>
                            <span class="badge bg-<?= $sv ?>"><?= str_replace('_', ' ', $r['severity']) ?></span>
                        </td>
                        <td>
                            <?php $sc = match($r['status']) { 'INITIATED' => 'warning', 'IN_PROGRESS' => 'info', 'COMPLETED' => 'success', default => 'secondary' }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $r['status']) ?></span>
                        </td>
                        <td><?= htmlspecialchars($r['initiator_name']) ?></td>
                        <td><?= date('Y-m-d', strtotime($r['created_at'])) ?></td>
                        <td><a href="/inventory/recall/view.php?id=<?= $r['recall_id'] ?>" class="btn btn-sm btn-outline-dark">View</a></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?= renderPagination($totalRows, $perPage, $page, $_GET) ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
