<?php
$REQUIRE_PERMISSION = 'manage_quarantine';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$statusFilter = $_GET['status'] ?? '';
$where = "1=1";
$params = [];
if ($statusFilter && in_array($statusFilter, ['QUARANTINED', 'UNDER_INSPECTION', 'RELEASED', 'DISPOSED'])) {
    $where .= " AND q.status = ?";
    $params[] = $statusFilter;
}

$countStmt = $pdo->prepare("SELECT COUNT(*) FROM inv_quarantine_log q WHERE $where");
$countStmt->execute($params);
$totalRows = (int) $countStmt->fetchColumn();

extract(getPaginationParams());

$stmt = $pdo->prepare("
    SELECT q.*, i.item_code, i.item_name, l.location_code, l.site_name,
           u.full_name AS quarantined_by_name, ru.full_name AS released_by_name
    FROM inv_quarantine_log q
    JOIN inv_items i ON q.item_id = i.item_id
    LEFT JOIN inv_locations l ON q.location_id = l.location_id
    LEFT JOIN users u ON q.quarantined_by = u.user_id
    LEFT JOIN users ru ON q.released_by = ru.user_id
    WHERE $where
    ORDER BY q.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-shield-exclamation"></i> Quarantine Management</h2>
    <a href="/inventory/quarantine/add.php" class="btn btn-danger"><i class="bi bi-plus-circle"></i> Quarantine Stock</a>
</div>

<div class="btn-group mb-3">
    <a href="?status=" class="btn btn-sm btn-<?= !$statusFilter ? 'dark' : 'outline-dark' ?>">All</a>
    <a href="?status=QUARANTINED" class="btn btn-sm btn-<?= $statusFilter === 'QUARANTINED' ? 'danger' : 'outline-danger' ?>">Quarantined</a>
    <a href="?status=UNDER_INSPECTION" class="btn btn-sm btn-<?= $statusFilter === 'UNDER_INSPECTION' ? 'warning' : 'outline-warning' ?>">Under Inspection</a>
    <a href="?status=RELEASED" class="btn btn-sm btn-<?= $statusFilter === 'RELEASED' ? 'success' : 'outline-success' ?>">Released</a>
    <a href="?status=DISPOSED" class="btn btn-sm btn-<?= $statusFilter === 'DISPOSED' ? 'secondary' : 'outline-secondary' ?>">Disposed</a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Item</th><th>Location</th><th>Qty</th><th>Reason</th><th>Status</th><th>Quarantined By</th><th>Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No quarantined stock found.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($rows as $r): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['location_code'] . ' - ' . $r['site_name']) ?></td>
                        <td class="fw-bold"><?= number_format($r['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars(mb_strimwidth($r['reason'], 0, 50, '...')) ?></td>
                        <td>
                            <?php $sc = match($r['status']) { 'QUARANTINED' => 'danger', 'UNDER_INSPECTION' => 'warning', 'RELEASED' => 'success', 'DISPOSED' => 'secondary', default => 'light' }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $r['status']) ?></span>
                        </td>
                        <td><?= htmlspecialchars($r['quarantined_by_name']) ?></td>
                        <td><?= date('Y-m-d', strtotime($r['created_at'])) ?></td>
                        <td><a href="/inventory/quarantine/view.php?id=<?= $r['quarantine_id'] ?>" class="btn btn-sm btn-outline-dark">View</a></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?= renderPagination($totalRows, $perPage, $page, $_GET) ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
