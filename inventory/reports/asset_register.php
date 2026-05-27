<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$categoryFilter = (int) ($_GET['category_id'] ?? 0);
$assetTypeFilter = (int) ($_GET['asset_type_id'] ?? 0);

$domainReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'inv_items'
      AND COLUMN_NAME = 'item_domain'
")->fetchColumn() > 0;

$assetTypeReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'inv_items'
      AND COLUMN_NAME = 'asset_type_id'
")->fetchColumn() > 0;

$assetTypesTableReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'asset_types'
")->fetchColumn() > 0;

$serialTableReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'inv_serial_numbers'
")->fetchColumn() > 0;

$assetFilter = $domainReady
    ? "i.item_domain IN ('ASSET','BOTH')"
    : "EXISTS (
        SELECT 1
        FROM inv_categories c2
        WHERE c2.category_id = i.category_id
          AND c2.category_code = 'ASSETS'
    )";

$where = "i.item_status = 'ACTIVE' AND $assetFilter";
$params = [];
if ($categoryFilter > 0) {
    $where .= " AND i.category_id = ?";
    $params[] = $categoryFilter;
}
if ($assetTypeReady && $assetTypeFilter > 0) {
    $where .= " AND i.asset_type_id = ?";
    $params[] = $assetTypeFilter;
}

$assetTypeJoin = ($assetTypeReady && $assetTypesTableReady)
    ? "LEFT JOIN asset_types at ON i.asset_type_id = at.asset_type_id"
    : "";
$assetTypeSelect = ($assetTypeReady && $assetTypesTableReady)
    ? "at.type_name AS asset_type_name,"
    : "NULL AS asset_type_name,";

$serialJoin = $serialTableReady
    ? "LEFT JOIN (
            SELECT item_id, COUNT(*) AS serial_count
            FROM inv_serial_numbers
            GROUP BY item_id
        ) sn ON sn.item_id = i.item_id"
    : "";
$serialSelect = $serialTableReady ? "COALESCE(sn.serial_count, 0)" : "0";

$stmt = $pdo->prepare("
    SELECT
        i.item_id, i.item_code, i.item_name, i.item_status, i.serial_number_flag,
        c.category_name,
        $assetTypeSelect
        COALESCE(st.total_qty, 0) AS total_qty,
        COALESCE(st.total_value, 0) AS total_value,
        $serialSelect AS serial_count
    FROM inv_items i
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    $assetTypeJoin
    LEFT JOIN (
        SELECT
            item_id,
            SUM(quantity_on_hand) AS total_qty,
            SUM(quantity_on_hand * unit_cost) AS total_value
        FROM inv_stock
        GROUP BY item_id
    ) st ON st.item_id = i.item_id
    $serialJoin
    WHERE $where
    ORDER BY total_value DESC, i.item_name ASC
");
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$categories = $pdo->query("
    SELECT DISTINCT c.category_id, c.category_name
    FROM inv_items i
    JOIN inv_categories c ON i.category_id = c.category_id
    WHERE i.item_status = 'ACTIVE' AND $assetFilter
    ORDER BY c.category_name
")->fetchAll(PDO::FETCH_ASSOC);

$assetTypes = [];
if ($assetTypeReady && $assetTypesTableReady) {
    $assetTypes = $pdo->query("
        SELECT asset_type_id, type_name
        FROM asset_types
        WHERE is_active = 1
        ORDER BY sort_order, type_name
    ")->fetchAll(PDO::FETCH_ASSOC);
}

$totalAssetItems = count($rows);
$totalAssetQty = array_sum(array_map(static fn($r) => (float) $r['total_qty'], $rows));
$totalAssetValue = array_sum(array_map(static fn($r) => (float) $r['total_value'], $rows));
$serializedItems = count(array_filter($rows, static fn($r) => (int) $r['serial_number_flag'] === 1));

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-building"></i> Asset Register Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-3">
    <div class="col-md-4">
        <select name="category_id" class="form-select">
            <option value="">All Asset Categories</option>
            <?php foreach ($categories as $cat): ?>
            <option value="<?= $cat['category_id'] ?>" <?= $categoryFilter === (int) $cat['category_id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($cat['category_name']) ?>
            </option>
            <?php endforeach; ?>
        </select>
    </div>
    <?php if ($assetTypeReady && $assetTypesTableReady): ?>
    <div class="col-md-4">
        <select name="asset_type_id" class="form-select">
            <option value="">All Asset Types</option>
            <?php foreach ($assetTypes as $at): ?>
            <option value="<?= $at['asset_type_id'] ?>" <?= $assetTypeFilter === (int) $at['asset_type_id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($at['type_name']) ?>
            </option>
            <?php endforeach; ?>
        </select>
    </div>
    <?php endif; ?>
    <div class="col-md-2">
        <button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button>
    </div>
    <div class="col-md-2">
        <a href="/inventory/reports/asset_register.php" class="btn btn-outline-secondary w-100">Reset</a>
    </div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-primary bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0"><?= number_format($totalAssetItems) ?></h4>
                <small class="text-muted">Asset Items</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0"><?= number_format($totalAssetQty, 2) ?></h4>
                <small class="text-muted">Quantity on Hand</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0">$<?= number_format($totalAssetValue, 2) ?></h4>
                <small class="text-muted">Current Stock Value</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0"><?= number_format($serializedItems) ?></h4>
                <small class="text-muted">Serialized Item Types</small>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Item</th>
                        <th>Category</th>
                        <th>Asset Type</th>
                        <th class="text-center">Serialized</th>
                        <th class="text-end">Serial Units</th>
                        <th class="text-end">Qty on Hand</th>
                        <th class="text-end">Value</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No assets found for the selected filters.</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td>
                            <code><?= htmlspecialchars($r['item_code']) ?></code><br>
                            <?= htmlspecialchars($r['item_name']) ?>
                        </td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['asset_type_name'] ?? '-') ?></td>
                        <td class="text-center">
                            <?= (int) $r['serial_number_flag'] === 1
                                ? '<span class="badge bg-success">Yes</span>'
                                : '<span class="badge bg-secondary">No</span>' ?>
                        </td>
                        <td class="text-end"><?= number_format((float) $r['serial_count']) ?></td>
                        <td class="text-end"><?= number_format((float) $r['total_qty'], 2) ?></td>
                        <td class="text-end fw-bold">$<?= number_format((float) $r['total_value'], 2) ?></td>
                        <td class="text-end">
                            <a href="/inventory/items/view.php?id=<?= (int) $r['item_id'] ?>" class="btn btn-sm btn-outline-secondary">
                                <i class="bi bi-eye"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
