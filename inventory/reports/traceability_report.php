<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$searchBatch  = trim($_GET['batch']  ?? '');
$searchSerial = trim($_GET['serial'] ?? '');
$itemId       = (int) ($_GET['item_id'] ?? 0);

$allRows = [];
$rows    = [];
$summary = null;

if ($searchBatch !== '' || $searchSerial !== '' || $itemId > 0) {
    $where  = "1=1";
    $params = [];
    if ($searchBatch !== '')  { $where .= " AND t.batch_lot_number = ?";  $params[] = $searchBatch; }
    if ($searchSerial !== '') { $where .= " AND t.serial_number = ?";     $params[] = $searchSerial; }
    if ($itemId > 0)          { $where .= " AND t.item_id = ?";           $params[] = $itemId; }

    $stmt = $pdo->prepare("
        SELECT t.transaction_id, t.transaction_type, t.quantity, t.unit_cost,
               t.batch_lot_number, t.serial_number, t.expiry_date,
               t.reference_number, t.reference_type, t.created_at,
               i.item_code, i.item_name,
               l.location_code,
               u.full_name AS user_name
        FROM inv_transactions t
        JOIN inv_items i ON t.item_id = i.item_id
        LEFT JOIN inv_locations l ON t.location_id = l.location_id
        LEFT JOIN users u ON t.performed_by = u.user_id
        WHERE $where
        ORDER BY t.created_at ASC
    ");
    $stmt->execute($params);
    $allRows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($allRows)) {
        $summary = [
            'item_code' => $allRows[0]['item_code'],
            'item_name' => $allRows[0]['item_name'],
            'total_in'  => array_sum(array_column(array_filter($allRows, fn($r) => in_array($r['transaction_type'], ['RECEIVE','TRANSFER_IN','ADJUSTMENT_GAIN','RETURN'])), 'quantity')),
            'total_out' => array_sum(array_column(array_filter($allRows, fn($r) => in_array($r['transaction_type'], ['ISSUE','TRANSFER_OUT','ADJUSTMENT_LOSS','DISPOSAL'])), 'quantity')),
        ];
    }
}

// Pagination (only active when search was performed)
extract(getPaginationParams(25));
$totalRows = count($allRows);
$rows      = array_slice($allRows, $offset, $perPage);

$items = $pdo->query("
    SELECT item_id, item_code, item_name
    FROM inv_items
    WHERE (batch_lot_flag = 1 OR serial_number_flag = 1) AND item_status = 'ACTIVE'
    ORDER BY item_code
")->fetchAll(PDO::FETCH_ASSOC);

$pdfUrl = '/inventory/reports/export_pdf.php?report=traceability_report&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-upc-scan"></i> Batch / Serial Traceability Report</h2>
    <div class="d-flex gap-2">
        <?php if ($totalRows > 0): ?>
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <?php endif; ?>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<div class="alert alert-info">
    <i class="bi bi-info-circle"></i>
    Trace a specific batch/lot number or serial number from receipt to consumption.
    Supports recall and withdrawal capability.
</div>

<form class="row g-2 mb-4">
    <div class="col-md-3">
        <input type="text" name="batch" class="form-control" placeholder="Batch / Lot Number"
               value="<?= htmlspecialchars($searchBatch) ?>">
    </div>
    <div class="col-md-3">
        <input type="text" name="serial" class="form-control" placeholder="Serial Number"
               value="<?= htmlspecialchars($searchSerial) ?>">
    </div>
    <div class="col-md-3">
        <select name="item_id" class="form-select">
            <option value="">Filter by Item (optional)</option>
            <?php foreach ($items as $it): ?>
            <option value="<?= $it['item_id'] ?>" <?= $itemId == $it['item_id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($it['item_code'] . ' — ' . $it['item_name']) ?>
            </option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-search"></i> Trace</button></div>
</form>

<?php if ($summary !== null): ?>
<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10 text-center py-3">
            <strong><?= htmlspecialchars($summary['item_code']) ?></strong>
            <small class="d-block text-muted"><?= htmlspecialchars($summary['item_name']) ?></small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10 text-center py-3">
            <h4><?= number_format($summary['total_in'], 2) ?></h4>
            <small class="text-muted">Total Received</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3">
            <h4><?= number_format($summary['total_out'], 2) ?></h4>
            <small class="text-muted">Total Consumed / Transferred</small>
        </div>
    </div>
</div>
<?php endif; ?>

<?php if ($searchBatch !== '' || $searchSerial !== '' || $itemId > 0): ?>
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>Timestamp</th>
                        <th>Type</th>
                        <th>Item</th>
                        <th>Batch / Lot</th>
                        <th>Serial</th>
                        <th>Expiry</th>
                        <th>Location</th>
                        <th>Reference</th>
                        <th class="text-end">Qty</th>
                        <th>By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="10" class="text-center text-muted py-4">No matching transactions found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($r['created_at'])) ?></td>
                        <td>
                            <?php $tc = match(true) {
                                in_array($r['transaction_type'], ['RECEIVE','TRANSFER_IN','ADJUSTMENT_GAIN','RETURN']) => 'success',
                                in_array($r['transaction_type'], ['ISSUE','TRANSFER_OUT','ADJUSTMENT_LOSS','DISPOSAL']) => 'danger',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $tc ?>"><?= str_replace('_', ' ', $r['transaction_type']) ?></span>
                        </td>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['batch_lot_number'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['serial_number'] ?? '-') ?></td>
                        <td><?= $r['expiry_date'] ? htmlspecialchars($r['expiry_date']) : '-' ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['reference_type'] ?? '') ?> <?= htmlspecialchars($r['reference_number'] ?? '-') ?></td>
                        <td class="text-end fw-bold"><?= number_format($r['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars($r['user_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php else: ?>
<div class="alert alert-light border text-center py-5">
    <i class="bi bi-upc-scan display-4 text-muted d-block mb-2"></i>
    Enter a batch/lot number or serial number above to trace the full movement history.
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
