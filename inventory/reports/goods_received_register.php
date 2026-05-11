<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';

$where  = "g.received_date BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo];
if ($statusF !== '') { $where .= " AND g.status = ?"; $params[] = $statusF; }

$rows = $pdo->prepare("
    SELECT g.grn_id, g.grn_number, g.received_date, g.status,
           g.po_reference, g.supplier_name, g.is_donation, g.is_non_exchange_transaction,
           g.inspection_result, g.donor_source,
           u.full_name AS received_by_name,
           COUNT(gi.grn_item_id) AS line_count,
           SUM(gi.quantity_received * gi.unit_cost) AS total_value
    FROM inv_goods_received g
    LEFT JOIN users u ON g.received_by = u.user_id
    LEFT JOIN inv_grn_items gi ON g.grn_id = gi.grn_id
    WHERE $where
    GROUP BY g.grn_id
    ORDER BY g.received_date DESC, g.grn_id DESC
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$grandTotal = array_sum(array_column($rows, 'total_value'));

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-seam"></i> Goods Received Register</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

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
    <strong><?= count($rows) ?></strong> GRNs &nbsp;|&nbsp;
    <strong>Total Received Value: $<?= number_format($grandTotal, 2) ?></strong>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
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
                        <td><?= htmlspecialchars($r['supplier_name'] ?? $r['donor_source'] ?? '-') ?></td>
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
                <?php if (!empty($rows)): ?>
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

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
