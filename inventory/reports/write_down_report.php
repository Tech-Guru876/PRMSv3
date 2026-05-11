<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';
$showOnly = $_GET['show'] ?? 'all'; // all | write_downs | reversals

$where  = "wd.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($statusF !== '') { $where .= " AND wd.status = ?"; $params[] = $statusF; }
if ($showOnly === 'reversals') { $where .= " AND wd.reversal_id IS NOT NULL"; }
if ($showOnly === 'write_downs') { $where .= " AND wd.reversal_id IS NULL"; }

$rows = $pdo->prepare("
    SELECT wd.write_down_id, wd.write_down_number, wd.reason,
           wd.original_cost, wd.nrv_value, wd.write_down_amount, wd.status,
           wd.reversal_id, wd.created_at, wd.approved_at,
           i.item_code, i.item_name,
           l.location_code,
           ur.full_name AS requested_by_name,
           ua.full_name AS approved_by_name
    FROM inv_write_downs wd
    JOIN inv_items i ON wd.item_id = i.item_id
    LEFT JOIN inv_locations l ON wd.location_id = l.location_id
    LEFT JOIN users ur ON wd.requested_by = ur.user_id
    LEFT JOIN users ua ON wd.approved_by  = ua.user_id
    WHERE $where
    ORDER BY wd.created_at DESC
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$totalWriteDown = array_sum(array_column(array_filter($rows, fn($r) => !$r['reversal_id']), 'write_down_amount'));
$totalReversed  = array_sum(array_column(array_filter($rows, fn($r) => (bool)$r['reversal_id']), 'write_down_amount'));

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-down-circle"></i> Write-Down &amp; Reversal Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<div class="alert alert-info">
    <i class="bi bi-info-circle"></i>
    Per <strong>IPSAS 12</strong>, inventories are measured at the lower of cost and NRV.
    Write-downs to NRV must be approved, and prior write-downs may be reversed if NRV improves.
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="status" class="form-select">
            <option value="">All Statuses</option>
            <?php foreach (['DRAFT','PENDING_APPROVAL','APPROVED','REVERSED','CANCELLED'] as $s): ?>
            <option value="<?= $s ?>" <?= $statusF === $s ? 'selected' : '' ?>><?= $s ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="show" class="form-select">
            <option value="all"         <?= $showOnly === 'all'         ? 'selected' : '' ?>>All</option>
            <option value="write_downs" <?= $showOnly === 'write_downs' ? 'selected' : '' ?>>Write-Downs Only</option>
            <option value="reversals"   <?= $showOnly === 'reversals'   ? 'selected' : '' ?>>Reversals Only</option>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalWriteDown, 2) ?></h4>
            <small class="text-muted">Total Write-Downs</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalReversed, 2) ?></h4>
            <small class="text-muted">Reversals</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalWriteDown - $totalReversed, 2) ?></h4>
            <small class="text-muted">Net Write-Down</small>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Write-Down #</th>
                        <th>Date</th>
                        <th>Item</th>
                        <th>Location</th>
                        <th>Reason</th>
                        <th class="text-end">Original Cost</th>
                        <th class="text-end">NRV</th>
                        <th class="text-end">Write-Down</th>
                        <th>Status</th>
                        <th>Type</th>
                        <th>Approved By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="11" class="text-center text-muted py-4">No records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr class="<?= $r['reversal_id'] ? 'table-success' : '' ?>">
                        <td><a href="/inventory/writedowns/view.php?id=<?= $r['write_down_id'] ?>"><?= htmlspecialchars($r['write_down_number']) ?></a></td>
                        <td><?= date('Y-m-d', strtotime($r['created_at'])) ?></td>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td><span class="badge bg-secondary"><?= str_replace('_', ' ', $r['reason']) ?></span></td>
                        <td class="text-end">$<?= number_format($r['original_cost'], 2) ?></td>
                        <td class="text-end">$<?= number_format($r['nrv_value'], 2) ?></td>
                        <td class="text-end fw-bold <?= $r['reversal_id'] ? 'text-success' : 'text-danger' ?>">
                            <?= $r['reversal_id'] ? '+' : '-' ?>$<?= number_format($r['write_down_amount'], 2) ?>
                        </td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'APPROVED'  => 'success',
                                'REVERSED'  => 'info',
                                'CANCELLED' => 'danger',
                                'PENDING_APPROVAL' => 'warning',
                                default     => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= $r['status'] ?></span>
                        </td>
                        <td>
                            <?= $r['reversal_id']
                                ? '<span class="badge bg-success">Reversal</span>'
                                : '<span class="badge bg-danger">Write-Down</span>' ?>
                        </td>
                        <td><?= htmlspecialchars($r['approved_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
