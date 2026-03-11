<?php
$REQUIRE_PERMISSION = 'conduct_stock_count';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$countId = (int) ($_GET['id'] ?? 0);
if ($countId <= 0) { pop("Invalid count.", "/inventory/stocktake/list.php", 1800, 'warning'); exit; }

$count = $pdo->prepare("
    SELECT sc.*, u.full_name AS lead_name, l.location_code, l.site_name
    FROM inv_stock_counts sc
    LEFT JOIN users u ON sc.count_lead = u.user_id
    LEFT JOIN inv_locations l ON sc.location_id = l.location_id
    WHERE sc.count_id = ?
");
$count->execute([$countId]);
$count = $count->fetch(PDO::FETCH_ASSOC);
if (!$count) { pop("Stock count not found.", "/inventory/stocktake/list.php", 1800, 'warning'); exit; }

$lineItems = $pdo->prepare("
    SELECT sci.*, i.item_code, i.item_name, um.uom_code
    FROM inv_stock_count_items sci
    JOIN inv_items i ON sci.item_id = i.item_id
    LEFT JOIN inv_units_of_measure um ON i.uom_id = um.uom_id
    WHERE sci.count_id = ?
    ORDER BY i.item_code
");
$lineItems->execute([$countId]);
$lineItems = $lineItems->fetchAll(PDO::FETCH_ASSOC);

/* Handle count submissions */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    try {
        $pdo->beginTransaction();

        if ($action === 'save_counts' && $count['status'] === 'IN_PROGRESS') {
            $counted = $_POST['counted_qty'] ?? [];
            $updateLine = $pdo->prepare("UPDATE inv_stock_count_items SET counted_quantity = ?, variance_quantity = ? - system_quantity WHERE count_item_id = ?");
            foreach ($counted as $lineId => $qty) {
                $qty = $qty !== '' ? (float) $qty : null;
                if ($qty !== null) {
                    $updateLine->execute([$qty, $qty, (int) $lineId]);
                }
            }
            logInventoryAudit($pdo, 'inv_stock_counts', $countId, 'COUNTS_SAVED', "Count data saved");

        } elseif ($action === 'complete' && $count['status'] === 'IN_PROGRESS') {
            // Verify all items counted
            $uncounted = $pdo->prepare("SELECT COUNT(*) FROM inv_stock_count_items WHERE count_id = ? AND counted_quantity IS NULL");
            $uncounted->execute([$countId]);
            if ($uncounted->fetchColumn() > 0) {
                throw new Exception("All items must be counted before completing.");
            }

            $pdo->prepare("UPDATE inv_stock_counts SET status = 'COMPLETED', completed_at = NOW() WHERE count_id = ?")
                ->execute([$countId]);
            logInventoryAudit($pdo, 'inv_stock_counts', $countId, 'COMPLETED', "Stock count completed");
        }

        $pdo->commit();
        pop("Count updated.", "/inventory/stocktake/view.php?id=$countId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clipboard-data"></i> Count <?= htmlspecialchars($count['count_number']) ?></h2>
    <a href="/inventory/stocktake/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <div class="row g-3">
            <div class="col-md-3"><strong>Count #:</strong> <?= htmlspecialchars($count['count_number']) ?></div>
            <div class="col-md-3"><strong>Type:</strong> <span class="badge bg-info"><?= $count['count_type'] ?></span></div>
            <div class="col-md-3"><strong>Status:</strong>
                <?php $sc = match($count['status']) { 'COMPLETED' => 'success', 'IN_PROGRESS' => 'warning', 'PLANNED' => 'info', default => 'secondary' }; ?>
                <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $count['status']) ?></span>
            </div>
            <div class="col-md-3"><strong>Date:</strong> <?= $count['count_date'] ?></div>
            <div class="col-md-3"><strong>Location:</strong> <?= htmlspecialchars($count['location_code'] . ' - ' . $count['site_name']) ?></div>
            <div class="col-md-3"><strong>Count Lead:</strong> <?= htmlspecialchars($count['lead_name']) ?></div>
            <?php if ($count['notes']): ?>
            <div class="col-12"><strong>Notes:</strong> <?= nl2br(htmlspecialchars($count['notes'])) ?></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Variance Summary -->
<?php
$totalItems = count($lineItems);
$countedItems = count(array_filter($lineItems, fn($li) => $li['counted_quantity'] !== null));
$varianceItems = count(array_filter($lineItems, fn($li) => $li['variance_quantity'] != 0 && $li['variance_quantity'] !== null));
?>
<div class="row g-3 mb-4">
    <div class="col-md-4"><div class="card border-0 shadow-sm text-center py-3"><h4><?= $totalItems ?></h4><small class="text-muted">Total Items</small></div></div>
    <div class="col-md-4"><div class="card border-0 shadow-sm text-center py-3 bg-<?= $countedItems === $totalItems ? 'success' : 'warning' ?> bg-opacity-10"><h4><?= $countedItems ?>/<?= $totalItems ?></h4><small class="text-muted">Counted</small></div></div>
    <div class="col-md-4"><div class="card border-0 shadow-sm text-center py-3 bg-<?= $varianceItems > 0 ? 'danger' : 'success' ?> bg-opacity-10"><h4><?= $varianceItems ?></h4><small class="text-muted">Variances</small></div></div>
</div>

<form method="POST">
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-dark text-white"><i class="bi bi-list-ol"></i> Count Sheet</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Item Code</th><th>Item Name</th><th>UOM</th><th class="text-end">System Qty</th>
                        <th class="text-end">Counted Qty</th><th class="text-end">Variance</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($lineItems as $li): ?>
                    <tr class="<?= ($li['variance_quantity'] ?? 0) != 0 ? 'table-warning' : '' ?>">
                        <td><code><?= htmlspecialchars($li['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($li['item_name']) ?></td>
                        <td><?= htmlspecialchars($li['uom_code'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($li['system_quantity'], 2) ?></td>
                        <td class="text-end">
                            <?php if ($count['status'] === 'IN_PROGRESS'): ?>
                            <input type="number" step="0.01" name="counted_qty[<?= $li['count_item_id'] ?>]"
                                   class="form-control form-control-sm text-end" style="width:100px;display:inline"
                                   value="<?= $li['counted_quantity'] ?? '' ?>" min="0">
                            <?php else: ?>
                            <?= $li['counted_quantity'] !== null ? number_format($li['counted_quantity'], 2) : '<span class="text-muted">-</span>' ?>
                            <?php endif; ?>
                        </td>
                        <td class="text-end fw-bold text-<?= ($li['variance_quantity'] ?? 0) < 0 ? 'danger' : (($li['variance_quantity'] ?? 0) > 0 ? 'success' : 'muted') ?>">
                            <?= $li['variance_quantity'] !== null ? (($li['variance_quantity'] >= 0 ? '+' : '') . number_format($li['variance_quantity'], 2)) : '-' ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php if ($count['status'] === 'IN_PROGRESS'): ?>
<div class="d-flex gap-2">
    <button type="submit" name="action" value="save_counts" class="btn btn-primary btn-lg"><i class="bi bi-save"></i> Save Counts</button>
    <button type="submit" name="action" value="complete" class="btn btn-success btn-lg"><i class="bi bi-check-circle"></i> Complete Count</button>
</div>
<?php endif; ?>
</form>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
