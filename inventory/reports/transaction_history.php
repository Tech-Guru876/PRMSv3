<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$itemFilter = (int) ($_GET['item_id'] ?? 0);
$locationFilter = (int) ($_GET['location_id'] ?? 0);
$typeFilter = $_GET['type'] ?? '';
$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo = $_GET['date_to'] ?? date('Y-m-d');

$where = "st.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($itemFilter > 0) { $where .= " AND st.item_id = ?"; $params[] = $itemFilter; }
if ($locationFilter > 0) { $where .= " AND st.location_id = ?"; $params[] = $locationFilter; }
if ($typeFilter) { $where .= " AND st.transaction_type = ?"; $params[] = $typeFilter; }

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';
extract(getPaginationParams());

$total = $pdo->prepare("SELECT COUNT(*) FROM inv_transactions st WHERE $where");
$total->execute($params);
$totalRows = $total->fetchColumn();

$stmt = $pdo->prepare("
    SELECT st.*, i.item_code, i.item_name, l.location_code, u.full_name AS user_name
    FROM inv_transactions st
    JOIN inv_items i ON st.item_id = i.item_id
    LEFT JOIN inv_locations l ON st.location_id = l.location_id
    LEFT JOIN users u ON st.performed_by = u.user_id
    WHERE $where
    ORDER BY st.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code FROM inv_locations ORDER BY location_code")->fetchAll(PDO::FETCH_ASSOC);
$txnTypes = ['RECEIVE','ISSUE','TRANSFER_IN','TRANSFER_OUT','ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST','RETURN'];

$pdfUrl = '/inventory/reports/export_pdf.php?report=transaction_history&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clock-history"></i> Transaction History</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to" class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="item_id" class="form-select">
            <option value="">All Items</option>
            <?php foreach ($items as $it): ?>
            <option value="<?= $it['item_id'] ?>" <?= $itemFilter == $it['item_id'] ? 'selected' : '' ?>><?= htmlspecialchars($it['item_code']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="location_id" class="form-select">
            <option value="">All Locations</option>
            <?php foreach ($locations as $loc): ?>
            <option value="<?= $loc['location_id'] ?>" <?= $locationFilter == $loc['location_id'] ? 'selected' : '' ?>><?= htmlspecialchars($loc['location_code']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="type" class="form-select">
            <option value="">All Types</option>
            <?php foreach ($txnTypes as $t): ?>
            <option value="<?= $t ?>" <?= $typeFilter === $t ? 'selected' : '' ?>><?= str_replace('_', ' ', $t) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-search"></i> Filter</button></div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr><th>Date</th><th>Item</th><th>Location</th><th>Type</th><th class="text-end">Quantity</th><th>Reference</th><th>User</th><th>Notes</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No transactions found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($r['created_at'])) ?></td>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td>
                            <?php $tc = match($r['transaction_type']) {
                                'RECEIVE','TRANSFER_IN','ADJUSTMENT_GAIN','RETURN' => 'success',
                                'ISSUE','TRANSFER_OUT','ADJUSTMENT_LOSS','DISPOSAL' => 'danger',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $tc ?>"><?= str_replace('_', ' ', $r['transaction_type']) ?></span>
                        </td>
                        <td class="text-end fw-bold"><?= number_format($r['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars($r['reference_type'] . '#' . $r['reference_id']) ?></td>
                        <td><?= htmlspecialchars($r['user_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars(mb_substr($r['notes'] ?? '', 0, 50)) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
