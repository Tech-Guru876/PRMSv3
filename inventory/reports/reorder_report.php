<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$rows = $pdo->query("
    SELECT i.item_id, i.item_code, i.item_name, i.reorder_point, i.reorder_quantity,
           c.category_name, i.criticality_level,
           COALESCE(SUM(sl.quantity_on_hand), 0) AS total_stock,
           i.reorder_point - COALESCE(SUM(sl.quantity_on_hand), 0) AS shortfall
    FROM inv_items i
    LEFT JOIN inv_stock_levels sl ON i.item_id = sl.item_id
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    WHERE i.status = 'ACTIVE' AND i.reorder_point > 0
    GROUP BY i.item_id
    HAVING total_stock <= i.reorder_point
    ORDER BY shortfall DESC, i.criticality_level DESC
")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-exclamation-triangle"></i> Reorder Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<div class="alert alert-warning">
    <strong><?= count($rows) ?></strong> item(s) at or below reorder point.
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Item Code</th><th>Item Name</th><th>Category</th><th>Criticality</th><th class="text-end">Current Stock</th><th class="text-end">Reorder Point</th><th class="text-end">Reorder Qty</th><th class="text-end">Shortfall</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> All items above reorder levels</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr class="<?= $r['total_stock'] <= 0 ? 'table-danger' : 'table-warning' ?>">
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><a href="/inventory/items/view.php?id=<?= $r['item_id'] ?>"><?= htmlspecialchars($r['item_name']) ?></a></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><span class="badge bg-<?= in_array($r['criticality_level'], ['CRITICAL','VITAL']) ? 'danger' : 'secondary' ?>"><?= $r['criticality_level'] ?></span></td>
                        <td class="text-end fw-bold"><?= number_format($r['total_stock'], 2) ?></td>
                        <td class="text-end"><?= number_format($r['reorder_point'], 2) ?></td>
                        <td class="text-end"><?= number_format($r['reorder_quantity'], 2) ?></td>
                        <td class="text-end text-danger fw-bold"><?= number_format($r['shortfall'], 2) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
