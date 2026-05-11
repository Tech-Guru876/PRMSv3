<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom  = $_GET['date_from'] ?? date('Y-m-01');
$dateTo    = $_GET['date_to']   ?? date('Y-m-d');
$reasonF   = $_GET['reason_code'] ?? '';

// Loss adjustments + incident losses
$adjWhere  = "a.adjustment_type = 'LOSS' AND a.status = 'COMPLETED' AND a.created_at BETWEEN ? AND ?";
$adjParams = [$dateFrom, $dateTo . ' 23:59:59'];
if ($reasonF !== '') { $adjWhere .= " AND a.reason_code = ?"; $adjParams[] = $reasonF; }

$adjustments = $pdo->prepare("
    SELECT a.adjustment_id, a.adjustment_number, a.reason_code, a.reason_detail,
           a.total_value_impact, a.created_at,
           u.full_name AS requested_by_name,
           l.location_code
    FROM inv_adjustments a
    LEFT JOIN users u ON a.requested_by = u.user_id
    LEFT JOIN inv_locations l ON a.location_id = l.location_id
    WHERE $adjWhere
    ORDER BY a.created_at DESC
");
$adjustments->execute($adjParams);
$adjustments = $adjustments->fetchAll(PDO::FETCH_ASSOC);

$incWhere  = "i.incident_date BETWEEN ? AND ?";
$incParams = [$dateFrom, $dateTo];

$incidents = $pdo->prepare("
    SELECT i.incident_id, i.incident_number, i.incident_type,
           i.total_estimated_loss, i.incident_date, i.status,
           u.full_name AS reported_by_name,
           l.location_code
    FROM inv_incidents i
    LEFT JOIN users u ON i.reported_by = u.user_id
    LEFT JOIN inv_locations l ON i.location_id = l.location_id
    WHERE $incWhere
    ORDER BY i.incident_date DESC
");
$incidents->execute($incParams);
$incidents = $incidents->fetchAll(PDO::FETCH_ASSOC);

$totalAdjLoss = array_sum(array_column($adjustments, 'total_value_impact'));
$totalIncLoss = array_sum(array_column($incidents, 'total_estimated_loss'));
$grandTotal   = $totalAdjLoss + $totalIncLoss;

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-exclamation-diamond"></i> Shrinkage &amp; Loss Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="reason_code" class="form-select">
            <option value="">All Reasons</option>
            <?php foreach (['DAMAGE','EXPIRY','COUNT_VARIANCE','BREAKAGE','THEFT','ADMIN_CORRECTION','OTHER'] as $rc): ?>
            <option value="<?= $rc ?>" <?= $reasonF === $rc ? 'selected' : '' ?>><?= str_replace('_', ' ', $rc) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalAdjLoss, 2) ?></h4>
            <small class="text-muted">Adjustment Losses</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalIncLoss, 2) ?></h4>
            <small class="text-muted">Incident Losses</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-dark bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($grandTotal, 2) ?></h4>
            <small class="text-muted">Total Shrinkage</small>
        </div>
    </div>
</div>

<!-- Loss Adjustments -->
<h5 class="mb-2"><i class="bi bi-sliders"></i> Stock Adjustment Losses</h5>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr><th>Adjustment #</th><th>Date</th><th>Reason</th><th>Location</th><th class="text-end">Value Impact</th><th>Requested By</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($adjustments)): ?>
                    <tr><td colspan="6" class="text-center text-muted py-3">No adjustment losses in period</td></tr>
                    <?php else: foreach ($adjustments as $a): ?>
                    <tr>
                        <td><a href="/inventory/adjustments/view.php?id=<?= $a['adjustment_id'] ?>"><?= htmlspecialchars($a['adjustment_number']) ?></a></td>
                        <td><?= date('Y-m-d', strtotime($a['created_at'])) ?></td>
                        <td><span class="badge bg-warning text-dark"><?= str_replace('_', ' ', $a['reason_code']) ?></span></td>
                        <td><?= htmlspecialchars($a['location_code'] ?? '-') ?></td>
                        <td class="text-end text-danger fw-bold">($<?= number_format(abs($a['total_value_impact']), 2) ?>)</td>
                        <td><?= htmlspecialchars($a['requested_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Incidents -->
<h5 class="mb-2"><i class="bi bi-shield-exclamation"></i> Incident / Loss Reports</h5>
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr><th>Incident #</th><th>Date</th><th>Type</th><th>Location</th><th class="text-end">Est. Loss</th><th>Status</th><th>Reported By</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($incidents)): ?>
                    <tr><td colspan="7" class="text-center text-muted py-3">No incidents in period</td></tr>
                    <?php else: foreach ($incidents as $inc): ?>
                    <tr>
                        <td><a href="/inventory/incidents/view.php?id=<?= $inc['incident_id'] ?>"><?= htmlspecialchars($inc['incident_number']) ?></a></td>
                        <td><?= htmlspecialchars($inc['incident_date']) ?></td>
                        <td><span class="badge bg-danger"><?= str_replace('_', ' ', $inc['incident_type']) ?></span></td>
                        <td><?= htmlspecialchars($inc['location_code'] ?? '-') ?></td>
                        <td class="text-end text-danger fw-bold">($<?= number_format($inc['total_estimated_loss'], 2) ?>)</td>
                        <td>
                            <?php $sc = match($inc['status']) {
                                'CLOSED','RESOLVED' => 'success',
                                'UNDER_INVESTIGATION' => 'warning',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $inc['status']) ?></span>
                        </td>
                        <td><?= htmlspecialchars($inc['reported_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
