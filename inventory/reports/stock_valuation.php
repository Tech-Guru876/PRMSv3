<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$locationFilter = (int) ($_GET['location_id'] ?? 0);
$categoryFilter = (int) ($_GET['category_id'] ?? 0);

$where = "sl.quantity_on_hand > 0";
$params = [];
if ($locationFilter > 0) { $where .= " AND sl.location_id = ?"; $params[] = $locationFilter; }
if ($categoryFilter > 0) { $where .= " AND i.category_id = ?"; $params[] = $categoryFilter; }

$stmt = $pdo->prepare("
    SELECT i.item_code, i.item_name, i.valuation_method, c.category_name,
           l.location_code, sl.quantity_on_hand, i.unit_cost,
           (sl.quantity_on_hand * i.unit_cost) AS total_value
    FROM inv_stock_levels sl
    JOIN inv_items i ON sl.item_id = i.item_id
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_locations l ON sl.location_id = l.location_id
    WHERE $where
    ORDER BY i.item_code, l.location_code
");
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$grandTotal = array_sum(array_column($rows, 'total_value'));

$locations = $pdo->query("SELECT location_id, location_code FROM inv_locations WHERE is_active=1 ORDER BY location_code")->fetchAll(PDO::FETCH_ASSOC);
$categories = $pdo->query("SELECT category_id, category_name FROM inv_categories ORDER BY category_name")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-currency-dollar"></i> Stock Valuation Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-3">
        <select name="location_id" class="form-select">
            <option value="">All Locations</option>
            <?php foreach ($locations as $loc): ?>
            <option value="<?= $loc['location_id'] ?>" <?= $locationFilter == $loc['location_id'] ? 'selected' : '' ?>><?= htmlspecialchars($loc['location_code']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-3">
        <select name="category_id" class="form-select">
            <option value="">All Categories</option>
            <?php foreach ($categories as $cat): ?>
            <option value="<?= $cat['category_id'] ?>" <?= $categoryFilter == $cat['category_id'] ? 'selected' : '' ?>><?= htmlspecialchars($cat['category_name']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="alert alert-info">
    <strong>Total Inventory Value:</strong> $<?= number_format($grandTotal, 2) ?>
    <span class="text-muted ms-3">(<?= count($rows) ?> line items)</span>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Item Code</th><th>Item Name</th><th>Category</th><th>Location</th><th>Method</th><th class="text-end">Qty</th><th class="text-end">Unit Cost</th><th class="text-end">Total Value</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($rows as $r): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['location_code']) ?></td>
                        <td><span class="badge bg-secondary"><?= $r['valuation_method'] ?></span></td>
                        <td class="text-end"><?= number_format($r['quantity_on_hand'], 2) ?></td>
                        <td class="text-end">$<?= number_format($r['unit_cost'] ?? 0, 2) ?></td>
                        <td class="text-end fw-bold">$<?= number_format($r['total_value'] ?? 0, 2) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
                <tfoot class="table-dark">
                    <tr><td colspan="7" class="text-end fw-bold">Grand Total:</td><td class="text-end fw-bold">$<?= number_format($grandTotal, 2) ?></td></tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
