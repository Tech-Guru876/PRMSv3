<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';
$showOnly = $_GET['show'] ?? 'all'; // all | write_downs | reversals

$where  = "wd.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($statusF !== '') { $where .= " AND wd.status = ?"; $params[] = $statusF; }
if ($showOnly === 'reversals') { $where .= " AND wd.reversal_id IS NOT NULL"; }
if ($showOnly === 'write_downs') { $where .= " AND wd.reversal_id IS NULL"; }

extract(getPaginationParams(25));

$rows = [];
$reportError = null;
try {
    $countStmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM inv_write_downs wd
        JOIN inv_items i ON wd.item_id = i.item_id
        WHERE $where
    ");
    $countStmt->execute($params);
    $totalRows = (int) $countStmt->fetchColumn();

    // Summary totals (across all matching rows)
    $totalsStmt = $pdo->prepare("
        SELECT
            SUM(CASE WHEN wd.reversal_id IS NULL THEN wd.write_down_amount ELSE 0 END) AS total_write_down,
            SUM(CASE WHEN wd.reversal_id IS NOT NULL THEN wd.write_down_amount ELSE 0 END) AS total_reversed
        FROM inv_write_downs wd
        JOIN inv_items i ON wd.item_id = i.item_id
        WHERE $where
    ");
    $totalsStmt->execute($params);
    $totals = $totalsStmt->fetch(PDO::FETCH_ASSOC);
    $totalWriteDown = (float) ($totals['total_write_down'] ?? 0);
    $totalReversed  = (float) ($totals['total_reversed']  ?? 0);

    $rowsStmt = $pdo->prepare("
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
        LIMIT $perPage OFFSET $offset
    ");
    $rowsStmt->execute($params);
    $rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $totalRows = 0; $totalWriteDown = 0; $totalReversed = 0;
    $reportError = 'Write-down data is temporarily unavailable.';
    error_log('write_down_report error: ' . $e->getMessage());
}

$pdfUrl = '/inventory/reports/export_pdf.php?report=write_down&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-down-circle"></i> Write-Down &amp; Reversal Report</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<?php if ($reportError): ?>
<div class="alert alert-warning"><?= htmlspecialchars($reportError) ?></div>
<?php endif; ?>

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
                <thead class="table-dark">
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

<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
