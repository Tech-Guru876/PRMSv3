<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$categoryF = (int) ($_GET['category_id'] ?? 0);

$where  = "i.item_status = 'OBSOLETE'";
$params = [];
if ($categoryF > 0) { $where .= " AND i.category_id = ?"; $params[] = $categoryF; }

$rows = $pdo->prepare("
    SELECT i.item_id, i.item_code, i.item_name, i.item_status, i.updated_at AS status_changed_at,
           c.category_name, u.uom_code,
           COALESCE(SUM(s.quantity_on_hand), 0)               AS qty_on_hand,
           COALESCE(SUM(s.quantity_on_hand * s.unit_cost), 0) AS stock_value,
           MAX(t.created_at)                                   AS last_movement_date
    FROM inv_items i
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_units_of_measure u ON i.uom_id = u.uom_id
    LEFT JOIN inv_stock s ON i.item_id = s.item_id
    LEFT JOIN inv_transactions t ON i.item_id = t.item_id
    WHERE $where
    GROUP BY i.item_id
    ORDER BY stock_value DESC, i.item_name ASC
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$totalValue  = array_sum(array_column($rows, 'stock_value'));
$categories  = $pdo->query("SELECT category_id, category_name FROM inv_categories ORDER BY category_name")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-archive"></i> Obsolete Stock Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<div class="alert alert-warning">
    <i class="bi bi-info-circle"></i>
    Lists all items with status <strong>OBSOLETE</strong>. Items should be reviewed for disposal.
    Total obsolete stock value: <strong>$<?= number_format($totalValue, 2) ?></strong>
</div>

<form class="row g-2 mb-4">
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

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>UOM</th>
                        <th class="text-end">Qty on Hand</th>
                        <th class="text-end">Carrying Value</th>
                        <th>Last Movement</th>
                        <th>Status Changed</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="9" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> No obsolete items</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr class="<?= $r['qty_on_hand'] > 0 ? 'table-warning' : '' ?>">
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['uom_code'] ?? '-') ?></td>
                        <td class="text-end <?= $r['qty_on_hand'] > 0 ? 'fw-bold text-danger' : '' ?>">
                            <?= number_format($r['qty_on_hand'], 2) ?>
                        </td>
                        <td class="text-end fw-bold">$<?= number_format($r['stock_value'], 2) ?></td>
                        <td><?= $r['last_movement_date'] ? date('Y-m-d', strtotime($r['last_movement_date'])) : '<span class="text-muted">None</span>' ?></td>
                        <td><?= $r['status_changed_at'] ? date('Y-m-d', strtotime($r['status_changed_at'])) : '-' ?></td>
                        <td>
                            <?php if ($r['qty_on_hand'] > 0): ?>
                            <a href="/inventory/disposal/add.php?item_id=<?= $r['item_id'] ?>" class="btn btn-sm btn-outline-danger">
                                <i class="bi bi-trash3"></i> Dispose
                            </a>
                            <?php else: ?>
                            <span class="text-muted">—</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if (!empty($rows)): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="5" class="text-end fw-bold">Total Obsolete Value:</td>
                        <td class="text-end fw-bold">$<?= number_format($totalValue, 2) ?></td>
                        <td colspan="3"></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
