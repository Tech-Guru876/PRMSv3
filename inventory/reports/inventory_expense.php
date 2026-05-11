<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom  = $_GET['date_from']  ?? date('Y-m-01');
$dateTo    = $_GET['date_to']    ?? date('Y-m-d');
$categoryF = (int) ($_GET['category_id'] ?? 0);

$where  = "t.transaction_type = 'ISSUE' AND t.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($categoryF > 0) { $where .= " AND i.category_id = ?"; $params[] = $categoryF; }

$rows = $pdo->prepare("
    SELECT i.item_code, i.item_name, c.category_name, u.uom_code,
           i.gl_account_code, i.program_project_code,
           SUM(t.quantity)                AS total_qty_issued,
           SUM(t.quantity * t.unit_cost)  AS total_cost,
           COUNT(DISTINCT t.transaction_id) AS transaction_count
    FROM inv_transactions t
    JOIN inv_items i ON t.item_id = i.item_id
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_units_of_measure u ON i.uom_id = u.uom_id
    WHERE $where
    GROUP BY i.item_id
    ORDER BY total_cost DESC
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$grandTotal   = array_sum(array_column($rows, 'total_cost'));
$totalQty     = array_sum(array_column($rows, 'total_qty_issued'));

// Summary by category
$catSummary = [];
foreach ($rows as $r) {
    $cat = $r['category_name'] ?? 'Uncategorised';
    $catSummary[$cat] = ($catSummary[$cat] ?? 0) + $r['total_cost'];
}
arsort($catSummary);

$categories = $pdo->query("SELECT category_id, category_name FROM inv_categories ORDER BY category_name")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-receipt-cutoff"></i> Inventory Expense Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<div class="alert alert-info">
    <i class="bi bi-info-circle"></i>
    Per <strong>IPSAS 12 §34</strong>, inventories are recognised as an expense in the period in which the related revenue is recognised, or when sold, exchanged, or distributed.
    This report shows the cost of all stock issued (consumed) in the selected period.
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
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
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3">
            <h4>$<?= number_format($grandTotal, 2) ?></h4>
            <small class="text-muted">Total Inventory Expense</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10 text-center py-3">
            <h4><?= count($rows) ?></h4>
            <small class="text-muted">Item Lines</small>
        </div>
    </div>
</div>

<!-- Category Summary -->
<?php if (!empty($catSummary)): ?>
<h5 class="mb-2">Expense by Category</h5>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-sm align-middle mb-0">
                <thead class="table-light"><tr><th>Category</th><th class="text-end">Expense</th><th class="text-end">% of Total</th></tr></thead>
                <tbody>
                    <?php foreach ($catSummary as $catName => $catVal): ?>
                    <tr>
                        <td><?= htmlspecialchars($catName) ?></td>
                        <td class="text-end">$<?= number_format($catVal, 2) ?></td>
                        <td class="text-end"><?= $grandTotal > 0 ? number_format(($catVal / $grandTotal) * 100, 1) : '0.0' ?>%</td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- Detail -->
<h5 class="mb-2">Item Detail</h5>
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
                        <th>GL Code</th>
                        <th>Programme / Project</th>
                        <th class="text-end">Qty Issued</th>
                        <th class="text-end">Transactions</th>
                        <th class="text-end">Total Expense</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="9" class="text-center text-muted py-4">No issues in period</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['uom_code'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['gl_account_code'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['program_project_code'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($r['total_qty_issued'], 2) ?></td>
                        <td class="text-end"><?= $r['transaction_count'] ?></td>
                        <td class="text-end fw-bold">$<?= number_format($r['total_cost'], 2) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if (!empty($rows)): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="8" class="text-end fw-bold">Total Inventory Expense:</td>
                        <td class="text-end fw-bold">$<?= number_format($grandTotal, 2) ?></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
