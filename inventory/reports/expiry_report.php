<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$days = (int) ($_GET['days'] ?? 90);

extract(getPaginationParams(25));

$countStmt = $pdo->prepare("
    SELECT COUNT(*)
    FROM inv_stock s
    JOIN inv_items i ON s.item_id = i.item_id
    WHERE s.expiry_date IS NOT NULL
      AND s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
      AND s.quantity_on_hand > 0
");
$countStmt->execute([$days]);
$totalRows = (int) $countStmt->fetchColumn();

$rowsStmt = $pdo->prepare("
    SELECT i.item_id, i.item_code, i.item_name, c.category_name,
           s.location_id, l.location_code,
           s.expiry_date, s.batch_lot_number,
           s.quantity_on_hand,
           DATEDIFF(s.expiry_date, CURDATE()) AS days_to_expiry
    FROM inv_stock s
    JOIN inv_items i ON s.item_id = i.item_id
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_locations l ON s.location_id = l.location_id
    WHERE s.expiry_date IS NOT NULL
      AND s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
      AND s.quantity_on_hand > 0
    ORDER BY s.expiry_date ASC
    LIMIT $perPage OFFSET $offset
");
$rowsStmt->execute([$days]);
$rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);

// Counts for summary cards (across all matching rows, not just current page)
$summaryStmt = $pdo->prepare("
    SELECT
        SUM(CASE WHEN DATEDIFF(expiry_date, CURDATE()) <= 0 THEN 1 ELSE 0 END) AS expired_count,
        SUM(CASE WHEN DATEDIFF(expiry_date, CURDATE()) > 0 THEN 1 ELSE 0 END)  AS expiring_count
    FROM inv_stock s
    WHERE s.expiry_date IS NOT NULL
      AND s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
      AND s.quantity_on_hand > 0
");
$summaryStmt->execute([$days]);
$summary = $summaryStmt->fetch(PDO::FETCH_ASSOC);
$expiredCount  = (int) ($summary['expired_count']  ?? 0);
$expiringCount = (int) ($summary['expiring_count'] ?? 0);

$pdfUrl = '/inventory/reports/export_pdf.php?report=expiry&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-calendar-x"></i> Expiry Report</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-3">
        <select name="days" class="form-select" onchange="this.form.submit()">
            <?php foreach ([30,60,90,180,365] as $d): ?>
            <option value="<?= $d ?>" <?= $days == $d ? 'selected' : '' ?>>Next <?= $d ?> days</option>
            <?php endforeach; ?>
        </select>
    </div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-6"><div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3"><h4><?= $expiredCount ?></h4><small class="text-danger">Already Expired</small></div></div>
    <div class="col-md-6"><div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3"><h4><?= $expiringCount ?></h4><small class="text-warning">Expiring Soon</small></div></div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr><th>Item Code</th><th>Item Name</th><th>Category</th><th>Location</th><th>Lot/Batch</th><th>Expiry Date</th><th class="text-end">Days Left</th><th class="text-end">Qty</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> No expiring stock</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr class="<?= $r['days_to_expiry'] <= 0 ? 'table-danger' : ($r['days_to_expiry'] <= 30 ? 'table-warning' : '') ?>">
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['batch_lot_number'] ?? '-') ?></td>
                        <td><?= $r['expiry_date'] ?></td>
                        <td class="text-end fw-bold text-<?= $r['days_to_expiry'] <= 0 ? 'danger' : 'warning' ?>">
                            <?= $r['days_to_expiry'] <= 0 ? 'EXPIRED' : $r['days_to_expiry'] . 'd' ?>
                        </td>
                        <td class="text-end"><?= number_format($r['quantity_on_hand'] ?? 0, 2) ?></td>
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
