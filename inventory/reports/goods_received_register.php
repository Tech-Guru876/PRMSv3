<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';

$where  = "g.received_date BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo];
if ($statusF !== '') { $where .= " AND g.status = ?"; $params[] = $statusF; }

extract(getPaginationParams(25));

$rows = [];
$reportError = null;
try {
    $countStmt = $pdo->prepare("SELECT COUNT(DISTINCT g.grn_id) FROM inv_goods_received g WHERE $where");
    $countStmt->execute($params);
    $totalRows = (int) $countStmt->fetchColumn();

    $totalsStmt = $pdo->prepare("
        SELECT COALESCE(SUM(gi.quantity_received * gi.unit_cost), 0) AS grand_total
        FROM inv_goods_received g
        LEFT JOIN inv_grn_items gi ON g.grn_id = gi.grn_id
        WHERE $where
    ");
    $totalsStmt->execute($params);
    $grandTotal = (float) $totalsStmt->fetchColumn();

    $rowsStmt = $pdo->prepare("
        SELECT g.grn_id, g.grn_number, g.received_date, g.status,
               g.po_reference, g.is_donation, g.is_non_exchange_transaction,
               g.inspection_result, g.donor_source,
               COALESCE(v.vendor_name, g.donor_source, '-') AS supplier_display,
               u.full_name AS received_by_name,
               COUNT(gi.grn_item_id) AS line_count,
               SUM(gi.quantity_received * gi.unit_cost) AS total_value
        FROM inv_goods_received g
        LEFT JOIN users u ON g.received_by = u.user_id
        LEFT JOIN vendors v ON g.supplier_vendor_id = v.vendor_id
        LEFT JOIN inv_grn_items gi ON g.grn_id = gi.grn_id
        WHERE $where
        GROUP BY g.grn_id
        ORDER BY g.received_date DESC, g.grn_id DESC
        LIMIT $perPage OFFSET $offset
    ");
    $rowsStmt->execute($params);
    $rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $totalRows = 0; $grandTotal = 0;
    $reportError = 'Goods received data is temporarily unavailable.';
    error_log('goods_received_register report error: ' . $e->getMessage());
}

$pdfUrl = '/inventory/reports/export_pdf.php?report=goods_received&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-seam"></i> Goods Received Register</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<?php if ($reportError): ?>
<div class="alert alert-warning"><?= htmlspecialchars($reportError) ?></div>
<?php endif; ?>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="status" class="form-select">
            <option value="">All Statuses</option>
            <?php foreach (['DRAFT','RECEIVED','INSPECTED','ACCEPTED','PARTIAL','REJECTED','QUARANTINE','COMPLETED'] as $s): ?>
            <option value="<?= $s ?>" <?= $statusF === $s ? 'selected' : '' ?>><?= $s ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="alert alert-info mb-3">
    <strong><?= $totalRows ?></strong> GRNs &nbsp;|&nbsp;
    <strong>Total Received Value: $<?= number_format($grandTotal, 2) ?></strong>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>GRN #</th>
                        <th>Date</th>
                        <th>Supplier / Donor</th>
                        <th>PO Ref</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Inspection</th>
                        <th>Lines</th>
                        <th class="text-end">Value</th>
                        <th>Received By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="10" class="text-center text-muted py-4">No records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><a href="/inventory/receiving/view.php?id=<?= $r['grn_id'] ?>"><?= htmlspecialchars($r['grn_number']) ?></a></td>
                        <td><?= htmlspecialchars($r['received_date']) ?></td>
                        <td><?= htmlspecialchars($r['supplier_display'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['po_reference'] ?? '-') ?></td>
                        <td>
                            <?php if ($r['is_donation']): ?>
                                <span class="badge bg-info">Donation</span>
                            <?php elseif ($r['is_non_exchange_transaction']): ?>
                                <span class="badge bg-warning text-dark">Non-Exchange</span>
                            <?php else: ?>
                                <span class="badge bg-secondary">Purchase</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'ACCEPTED','COMPLETED' => 'success',
                                'REJECTED' => 'danger',
                                'QUARANTINE' => 'warning',
                                'PARTIAL'  => 'info',
                                default    => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= $r['status'] ?></span>
                        </td>
                        <td>
                            <?php $ic = match($r['inspection_result'] ?? 'PENDING') {
                                'PASS'        => 'success',
                                'FAIL'        => 'danger',
                                'CONDITIONAL' => 'warning',
                                default       => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $ic ?>"><?= $r['inspection_result'] ?? 'PENDING' ?></span>
                        </td>
                        <td class="text-center"><?= $r['line_count'] ?></td>
                        <td class="text-end">$<?= number_format($r['total_value'] ?? 0, 2) ?></td>
                        <td><?= htmlspecialchars($r['received_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if ($totalRows > 0): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="8" class="text-end fw-bold">Grand Total:</td>
                        <td class="text-end fw-bold">$<?= number_format($grandTotal, 2) ?></td>
                        <td></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
