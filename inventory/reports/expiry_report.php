<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$days = (int) ($_GET['days'] ?? 90);

$rows = $pdo->prepare("
    SELECT i.item_id, i.item_code, i.item_name, c.category_name,
           sl.location_id, l.location_code,
           st.expiry_date, st.lot_number, st.batch_number,
           sl.quantity_on_hand,
           DATEDIFF(st.expiry_date, CURDATE()) AS days_to_expiry
    FROM inv_stock_transactions st
    JOIN inv_items i ON st.item_id = i.item_id
    LEFT JOIN inv_categories c ON i.category_id = c.category_id
    LEFT JOIN inv_stock_levels sl ON st.item_id = sl.item_id AND st.location_id = sl.location_id
    LEFT JOIN inv_locations l ON st.location_id = l.location_id
    WHERE st.expiry_date IS NOT NULL
      AND st.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
      AND sl.quantity_on_hand > 0
    GROUP BY i.item_id, st.location_id, st.expiry_date, st.lot_number, st.batch_number
    ORDER BY st.expiry_date ASC
");
$rows->execute([$days]);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$expired = array_filter($rows, fn($r) => $r['days_to_expiry'] <= 0);
$expiring = array_filter($rows, fn($r) => $r['days_to_expiry'] > 0);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-calendar-x"></i> Expiry Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
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
    <div class="col-md-6"><div class="card border-0 shadow-sm bg-danger bg-opacity-10 text-center py-3"><h4><?= count($expired) ?></h4><small class="text-danger">Already Expired</small></div></div>
    <div class="col-md-6"><div class="card border-0 shadow-sm bg-warning bg-opacity-10 text-center py-3"><h4><?= count($expiring) ?></h4><small class="text-warning">Expiring Soon</small></div></div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
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
                        <td><?= htmlspecialchars(($r['lot_number'] ?? '') . '/' . ($r['batch_number'] ?? '')) ?></td>
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

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
