<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';
$methodF  = $_GET['method']    ?? '';

$where  = "d.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($statusF !== '') { $where .= " AND d.status = ?";           $params[] = $statusF; }
if ($methodF !== '') { $where .= " AND d.disposal_method = ?";  $params[] = $methodF; }

extract(getPaginationParams(25));

// Summary totals across all matching rows
$totalsStmt = $pdo->prepare("
    SELECT COUNT(*) AS total_records,
           COALESCE(SUM(d.total_write_off_value), 0) AS total_write_off,
           COALESCE(SUM(d.actual_proceeds), 0)        AS total_proceeds
    FROM inv_disposals d
    WHERE $where
");
$totalsStmt->execute($params);
$totals = $totalsStmt->fetch(PDO::FETCH_ASSOC);
$totalRecords  = (int)   ($totals['total_records']  ?? 0);
$totalWriteOff = (float) ($totals['total_write_off'] ?? 0);
$totalProceeds = (float) ($totals['total_proceeds']  ?? 0);

$rowsStmt = $pdo->prepare("
    SELECT d.disposal_id, d.disposal_number, d.disposal_method, d.reason,
           d.status, d.total_write_off_value, d.proceeds_amount, d.actual_proceeds,
           d.committee_review_required, d.created_at,
           ur.full_name AS requested_by_name,
           ua.full_name AS approved_by_name,
           l.location_code,
           COUNT(di.disp_item_id) AS line_count
    FROM inv_disposals d
    LEFT JOIN users ur ON d.requested_by = ur.user_id
    LEFT JOIN users ua ON d.approved_by  = ua.user_id
    LEFT JOIN inv_locations l ON d.location_id = l.location_id
    LEFT JOIN inv_disposal_items di ON d.disposal_id = di.disposal_id
    WHERE $where
    GROUP BY d.disposal_id
    ORDER BY d.created_at DESC
    LIMIT $perPage OFFSET $offset
");
$rowsStmt->execute($params);
$rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);

$pdfUrl = '/inventory/reports/export_pdf.php?report=disposal&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-trash3"></i> Disposal Register</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="status" class="form-select">
            <option value="">All Statuses</option>
            <?php foreach (['DRAFT','RECOMMENDED','PENDING_APPROVAL','APPROVED','COMMITTEE_REVIEW','COMPLETED','REJECTED','CANCELLED'] as $s): ?>
            <option value="<?= $s ?>" <?= $statusF === $s ? 'selected' : '' ?>><?= str_replace('_', ' ', $s) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="method" class="form-select">
            <option value="">All Methods</option>
            <?php foreach (['DESTRUCTION','AUCTION','TRANSFER','DONATION','RETURN_TO_SUPPLIER','SCRAP','SALE','RECYCLING','TRADE_IN','OTHER'] as $m): ?>
            <option value="<?= $m ?>" <?= $methodF === $m ? 'selected' : '' ?>><?= str_replace('_', ' ', $m) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalWriteOff, 2) ?></h4>
            <small class="text-muted">Total Write-Off Value</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalProceeds, 2) ?></h4>
            <small class="text-muted">Proceeds Recovered</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-secondary bg-opacity-10 text-center py-3">
            <h4><?= $totalRecords ?></h4>
            <small class="text-muted">Disposal Records</small>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>Disposal #</th>
                        <th>Date</th>
                        <th>Method</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Cmte?</th>
                        <th>Lines</th>
                        <th class="text-end">Write-Off</th>
                        <th class="text-end">Proceeds</th>
                        <th>Requested By</th>
                        <th>Approved By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="11" class="text-center text-muted py-4">No records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><a href="/inventory/disposal/view.php?id=<?= $r['disposal_id'] ?>"><?= htmlspecialchars($r['disposal_number']) ?></a></td>
                        <td><?= date('Y-m-d', strtotime($r['created_at'])) ?></td>
                        <td><span class="badge bg-secondary"><?= str_replace('_', ' ', $r['disposal_method']) ?></span></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'COMPLETED' => 'success',
                                'REJECTED','CANCELLED' => 'danger',
                                'APPROVED'  => 'primary',
                                'COMMITTEE_REVIEW' => 'warning',
                                default     => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $r['status']) ?></span>
                        </td>
                        <td class="text-center">
                            <?= $r['committee_review_required'] ? '<i class="bi bi-people text-warning"></i>' : '' ?>
                        </td>
                        <td class="text-center"><?= $r['line_count'] ?></td>
                        <td class="text-end text-danger">$<?= number_format($r['total_write_off_value'], 2) ?></td>
                        <td class="text-end text-success">$<?= number_format($r['actual_proceeds'] ?? $r['proceeds_amount'] ?? 0, 2) ?></td>
                        <td><?= htmlspecialchars($r['requested_by_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['approved_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if ($totalRecords > 0): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="7" class="text-end fw-bold">Totals:</td>
                        <td class="text-end fw-bold text-danger">$<?= number_format($totalWriteOff, 2) ?></td>
                        <td class="text-end fw-bold text-success">$<?= number_format($totalProceeds, 2) ?></td>
                        <td colspan="2"></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php renderShowingInfo($page, $perPage, $totalRecords); ?>
<?php renderPagination($totalRecords, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
