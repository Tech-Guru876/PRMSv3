<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');

$rows = $pdo->prepare("
    SELECT g.grn_id, g.grn_number, g.received_date, g.status,
           g.donor_source, g.donation_reference, g.fair_value_basis,
           g.inspection_result,
           u.full_name AS received_by_name,
           COUNT(gi.grn_item_id) AS line_count,
           SUM(gi.quantity_received * gi.unit_cost) AS total_fair_value
    FROM inv_goods_received g
    LEFT JOIN users u ON g.received_by = u.user_id
    LEFT JOIN inv_grn_items gi ON g.grn_id = gi.grn_id
    WHERE (g.is_donation = 1 OR g.is_non_exchange_transaction = 1)
      AND g.received_date BETWEEN ? AND ?
    GROUP BY g.grn_id
    ORDER BY g.received_date DESC
");
$rows->execute([$dateFrom, $dateTo]);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$totalValue = array_sum(array_column($rows, 'total_fair_value'));

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-gift"></i> Donation &amp; Non-Exchange Register</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<div class="alert alert-info">
    <i class="bi bi-info-circle"></i>
    Per <strong>IPSAS 12</strong>, non-exchange inventory is measured at <strong>fair value at acquisition date</strong>.
    All amounts below reflect the fair value recorded at receipt.
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10 text-center py-3">
            <h4><?= count($rows) ?></h4>
            <small class="text-muted">Donation Records</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalValue, 2) ?></h4>
            <small class="text-muted">Total Fair Value Received</small>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>GRN #</th>
                        <th>Date</th>
                        <th>Donor / Source</th>
                        <th>Donation Ref</th>
                        <th>Fair Value Basis</th>
                        <th>Status</th>
                        <th>Inspection</th>
                        <th>Lines</th>
                        <th class="text-end">Fair Value</th>
                        <th>Received By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="10" class="text-center text-muted py-4">No donation records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><a href="/inventory/receiving/view.php?id=<?= $r['grn_id'] ?>"><?= htmlspecialchars($r['grn_number']) ?></a></td>
                        <td><?= htmlspecialchars($r['received_date']) ?></td>
                        <td><?= htmlspecialchars($r['donor_source'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['donation_reference'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['fair_value_basis'] ?? '-') ?></td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'ACCEPTED','COMPLETED' => 'success',
                                'REJECTED'             => 'danger',
                                'QUARANTINE'           => 'warning',
                                default                => 'secondary'
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
                        <td class="text-end fw-bold">$<?= number_format($r['total_fair_value'] ?? 0, 2) ?></td>
                        <td><?= htmlspecialchars($r['received_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if (!empty($rows)): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="8" class="text-end fw-bold">Total Fair Value:</td>
                        <td class="text-end fw-bold">$<?= number_format($totalValue, 2) ?></td>
                        <td></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
