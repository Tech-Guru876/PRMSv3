<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

// Items with no outbound movement (ISSUE or TRANSFER_OUT) in the past N days
$days       = (int) ($_GET['days'] ?? 180);
$categoryF  = (int) ($_GET['category_id'] ?? 0);
$statusF    = $_GET['item_status'] ?? 'ACTIVE';

$catWhere   = '';
$baseParams = [$days, $statusF !== '' ? $statusF : 'ACTIVE'];

if ($categoryF > 0) {
    $catWhere   = " AND i.category_id = ?";
    $baseParams[] = $categoryF;
}

extract(getPaginationParams(25));

$countStmt = $pdo->prepare("
    SELECT COUNT(*) FROM (
        SELECT i.item_id
        FROM inv_items i
        LEFT JOIN inv_stock s ON i.item_id = s.item_id AND s.quantity_on_hand > 0
        LEFT JOIN (
            SELECT item_id, MAX(created_at) AS last_movement
            FROM inv_transactions
            WHERE transaction_type IN ('ISSUE','TRANSFER_OUT')
            GROUP BY item_id
        ) t ON i.item_id = t.item_id
        WHERE (t.last_movement IS NULL OR t.last_movement < DATE_SUB(CURDATE(), INTERVAL ? DAY))
          AND i.item_status = ?
          $catWhere
        GROUP BY i.item_id
        HAVING COALESCE(SUM(s.quantity_on_hand), 0) > 0
    ) sub
");
$countStmt->execute($baseParams);
$totalRows = (int) $countStmt->fetchColumn();

$totalsStmt = $pdo->prepare("
    SELECT COALESCE(SUM(total_val), 0) FROM (
        SELECT COALESCE(SUM(s.quantity_on_hand * s.unit_cost), 0) AS total_val
        FROM inv_items i
        LEFT JOIN inv_stock s ON i.item_id = s.item_id AND s.quantity_on_hand > 0
        LEFT JOIN (
            SELECT item_id, MAX(created_at) AS last_movement
            FROM inv_transactions
            WHERE transaction_type IN ('ISSUE','TRANSFER_OUT')
            GROUP BY item_id
        ) t ON i.item_id = t.item_id
        WHERE (t.last_movement IS NULL OR t.last_movement < DATE_SUB(CURDATE(), INTERVAL ? DAY))
          AND i.item_status = ?
          $catWhere
        GROUP BY i.item_id
        HAVING COALESCE(SUM(s.quantity_on_hand), 0) > 0
    ) vals
");
$totalsStmt->execute($baseParams);
$totalValue = (float) $totalsStmt->fetchColumn();

$rowsStmt = $pdo->prepare("
    SELECT i.item_id, i.item_code, i.item_name, i.item_status,
           c.category_name,
           u.uom_code,
           COALESCE(SUM(s.quantity_on_hand), 0) AS qty_on_hand,
           COALESCE(SUM(s.quantity_on_hand * s.unit_cost), 0) AS stock_value,
           MAX(t.last_movement) AS last_movement_date,
           DATEDIFF(CURDATE(), MAX(t.last_movement)) AS days_since_movement
    FROM inv_items i
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_units_of_measure u ON i.uom_id = u.uom_id
    LEFT JOIN inv_stock s ON i.item_id = s.item_id AND s.quantity_on_hand > 0
    LEFT JOIN (
        SELECT item_id, MAX(created_at) AS last_movement
        FROM inv_transactions
        WHERE transaction_type IN ('ISSUE','TRANSFER_OUT')
        GROUP BY item_id
    ) t ON i.item_id = t.item_id
    WHERE (t.last_movement IS NULL OR t.last_movement < DATE_SUB(CURDATE(), INTERVAL ? DAY))
      AND i.item_status = ?
      $catWhere
    GROUP BY i.item_id
    HAVING qty_on_hand > 0
    ORDER BY days_since_movement DESC, stock_value DESC
    LIMIT $perPage OFFSET $offset
");
$rowsStmt->execute($baseParams);
$rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);

$categories = $pdo->query("SELECT category_id, category_name FROM inv_categories ORDER BY category_name")->fetchAll(PDO::FETCH_ASSOC);

$pdfUrl = '/inventory/reports/export_pdf.php?report=slow_moving&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-hourglass-split"></i> Slow-Moving / Non-Moving Stock</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2">
        <select name="days" class="form-select">
            <?php foreach ([30, 60, 90, 180, 270, 365] as $d): ?>
            <option value="<?= $d ?>" <?= $days === $d ? 'selected' : '' ?>>No movement &gt; <?= $d ?> days</option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-3">
        <select name="category_id" class="form-select">
            <option value="">All Categories</option>
            <?php foreach ($categories as $cat): ?>
            <option value="<?= $cat['category_id'] ?>" <?= $categoryF == $cat['category_id'] ? 'selected' : '' ?>><?= htmlspecialchars($cat['category_name']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3">
            <h4><?= $totalRows ?></h4>
            <small class="text-muted">Slow-Moving Items</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($totalValue, 0) ?></h4>
            <small class="text-muted">Dormant Stock Value</small>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>UOM</th>
                        <th class="text-end">Qty on Hand</th>
                        <th class="text-end">Stock Value</th>
                        <th>Last Movement</th>
                        <th class="text-end">Days Dormant</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> No slow-moving stock found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <?php $danger = ($r['days_since_movement'] === null || $r['days_since_movement'] > 365); ?>
                    <tr class="<?= $danger ? 'table-warning' : '' ?>">
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['uom_code'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($r['qty_on_hand'], 2) ?></td>
                        <td class="text-end fw-bold">$<?= number_format($r['stock_value'], 2) ?></td>
                        <td><?= $r['last_movement_date'] ? htmlspecialchars($r['last_movement_date']) : '<span class="text-danger">Never issued</span>' ?></td>
                        <td class="text-end <?= $danger ? 'text-danger fw-bold' : 'text-warning' ?>">
                            <?= $r['days_since_movement'] !== null ? $r['days_since_movement'] . 'd' : 'N/A' ?>
                        </td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if ($totalRows > 0): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="5" class="text-end fw-bold">Total Dormant Value:</td>
                        <td class="text-end fw-bold">$<?= number_format($totalValue, 2) ?></td>
                        <td colspan="2"></td>
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
