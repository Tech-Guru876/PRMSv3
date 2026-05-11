<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');

// Supplier stats: orders, on-time, qty ordered vs received, acceptance rate
$rows = $pdo->prepare("
    SELECT
        COALESCE(v.vendor_name, g.supplier_name, 'Unknown Supplier') AS supplier_name,
        v.vendor_id,
        COUNT(DISTINCT g.grn_id)            AS grn_count,
        SUM(gi.quantity_ordered)            AS total_ordered,
        SUM(gi.quantity_received)           AS total_received,
        SUM(gi.quantity_accepted)           AS total_accepted,
        SUM(gi.quantity_rejected)           AS total_rejected,
        SUM(gi.quantity_damaged)            AS total_damaged,
        SUM(gi.quantity_short)              AS total_short,
        SUM(gi.quantity_received * gi.unit_cost) AS total_value,
        SUM(CASE WHEN g.inspection_result = 'PASS' THEN 1 ELSE 0 END) AS inspections_passed,
        COUNT(CASE WHEN g.inspection_result IS NOT NULL AND g.inspection_result != 'PENDING' THEN 1 END) AS inspections_total
    FROM inv_goods_received g
    LEFT JOIN inv_grn_items gi ON g.grn_id = gi.grn_id
    LEFT JOIN vendors v ON g.supplier_vendor_id = v.vendor_id
    WHERE g.received_date BETWEEN ? AND ?
      AND g.is_donation = 0
    GROUP BY v.vendor_id, COALESCE(v.vendor_name, g.supplier_name, 'Unknown Supplier')
    ORDER BY total_value DESC
");
$rows->execute([$dateFrom, $dateTo]);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-truck"></i> Supplier Performance Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Supplier</th>
                        <th class="text-end">GRNs</th>
                        <th class="text-end">Qty Ordered</th>
                        <th class="text-end">Qty Received</th>
                        <th class="text-end">Qty Accepted</th>
                        <th class="text-end">Qty Rejected</th>
                        <th class="text-end">Short Supply</th>
                        <th class="text-end">Acceptance %</th>
                        <th class="text-end">Inspection Pass %</th>
                        <th class="text-end">Total Value</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="10" class="text-center text-muted py-4">No supplier data in period</td></tr>
                    <?php else: foreach ($rows as $r):
                        $acceptPct = $r['total_received'] > 0
                            ? ($r['total_accepted'] / $r['total_received']) * 100
                            : 0;
                        $inspPct = $r['inspections_total'] > 0
                            ? ($r['inspections_passed'] / $r['inspections_total']) * 100
                            : null;
                    ?>
                    <tr>
                        <td>
                            <?php if ($r['vendor_id']): ?>
                                <a href="/vendors/view.php?id=<?= $r['vendor_id'] ?>"><?= htmlspecialchars($r['supplier_name']) ?></a>
                            <?php else: ?>
                                <?= htmlspecialchars($r['supplier_name']) ?>
                            <?php endif; ?>
                        </td>
                        <td class="text-end"><?= $r['grn_count'] ?></td>
                        <td class="text-end"><?= number_format($r['total_ordered'], 2) ?></td>
                        <td class="text-end"><?= number_format($r['total_received'], 2) ?></td>
                        <td class="text-end text-success"><?= number_format($r['total_accepted'], 2) ?></td>
                        <td class="text-end <?= $r['total_rejected'] > 0 ? 'text-danger fw-bold' : '' ?>">
                            <?= number_format($r['total_rejected'], 2) ?>
                        </td>
                        <td class="text-end <?= $r['total_short'] > 0 ? 'text-warning' : '' ?>">
                            <?= number_format($r['total_short'], 2) ?>
                        </td>
                        <td class="text-end">
                            <?php $ac = $acceptPct >= 95 ? 'success' : ($acceptPct >= 80 ? 'warning' : 'danger'); ?>
                            <span class="badge bg-<?= $ac ?>"><?= number_format($acceptPct, 1) ?>%</span>
                        </td>
                        <td class="text-end">
                            <?php if ($inspPct !== null): ?>
                            <?php $ic = $inspPct >= 95 ? 'success' : ($inspPct >= 80 ? 'warning' : 'danger'); ?>
                            <span class="badge bg-<?= $ic ?>"><?= number_format($inspPct, 1) ?>%</span>
                            <?php else: ?>
                            <span class="text-muted">N/A</span>
                            <?php endif; ?>
                        </td>
                        <td class="text-end fw-bold">$<?= number_format($r['total_value'], 2) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
