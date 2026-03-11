<?php
$REQUIRE_PERMISSION = 'view_inventory';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$itemId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if ($itemId <= 0) { pop("Invalid item ID.", "/inventory/items/list.php", 1800, 'warning'); exit; }

$item = getInventoryItem($pdo, $itemId);
if (!$item) { pop("Item not found.", "/inventory/items/list.php", 1800, 'warning'); exit; }

$riskClasses = getItemRiskClasses($pdo, $itemId);

// Stock at each location
$stockStmt = $pdo->prepare("
    SELECT s.*, l.location_code, l.building, l.room_storage_area, l.bin_shelf_rack
    FROM inv_stock s
    JOIN inv_locations l ON s.location_id = l.location_id
    WHERE s.item_id = ?
    ORDER BY l.location_code, s.expiry_date
");
$stockStmt->execute([$itemId]);
$stockRecords = $stockStmt->fetchAll(PDO::FETCH_ASSOC);

$totalOnHand = array_sum(array_column($stockRecords, 'quantity_on_hand'));
$totalAvailable = array_sum(array_column($stockRecords, 'quantity_available'));
$totalValue = 0;
foreach ($stockRecords as $sr) {
    $totalValue += (float) $sr['quantity_on_hand'] * (float) $sr['unit_cost'];
}

// Recent transactions
$txnStmt = $pdo->prepare("
    SELECT t.*, u.full_name AS performed_by_name
    FROM inv_transactions t
    LEFT JOIN users u ON t.performed_by = u.user_id
    WHERE t.item_id = ?
    ORDER BY t.created_at DESC
    LIMIT 20
");
$txnStmt->execute([$itemId]);
$transactions = $txnStmt->fetchAll(PDO::FETCH_ASSOC);

// Suppliers
$supStmt = $pdo->prepare("
    SELECT iss.*, v.vendor_name
    FROM inv_item_suppliers iss
    JOIN vendors v ON iss.vendor_id = v.vendor_id
    WHERE iss.item_id = ?
");
$supStmt->execute([$itemId]);
$suppliers = $supStmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>
        <i class="bi bi-box-seam"></i>
        <?= htmlspecialchars($item['item_name']) ?>
        <small class="text-muted ms-2"><?= htmlspecialchars($item['item_code']) ?></small>
    </h2>
    <div>
        <?php if (has_permission('manage_inventory_items')): ?>
        <a href="/inventory/items/edit.php?id=<?= $itemId ?>" class="btn btn-outline-primary">
            <i class="bi bi-pencil"></i> Edit
        </a>
        <?php endif; ?>
        <a href="/inventory/items/list.php" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Back
        </a>
    </div>
</div>

<!-- Status and KPIs -->
<div class="row g-3 mb-4">
    <div class="col-md-2">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body">
                <?php
                $statusColors = ['ACTIVE' => 'success', 'BLOCKED' => 'secondary', 'OBSOLETE' => 'dark',
                                 'QUARANTINED' => 'warning', 'DISPOSAL' => 'danger'];
                $sc = $statusColors[$item['item_status']] ?? 'secondary';
                ?>
                <span class="badge bg-<?= $sc ?> fs-6"><?= $item['item_status'] ?></span>
                <div class="text-muted small mt-1">Status</div>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body">
                <div class="fs-4 fw-bold text-primary"><?= number_format($totalOnHand, 0) ?></div>
                <small class="text-muted">On Hand (<?= htmlspecialchars($item['uom_code']) ?>)</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body">
                <div class="fs-4 fw-bold <?= $totalAvailable <= ($item['reorder_level'] ?? 0) ? 'text-danger' : 'text-success' ?>">
                    <?= number_format($totalAvailable, 0) ?>
                </div>
                <small class="text-muted">Available</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body">
                <div class="fs-4 fw-bold text-dark">$<?= number_format($totalValue, 2) ?></div>
                <small class="text-muted">Total Value</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body">
                <div class="fs-4 fw-bold">$<?= number_format($item['average_cost'], 2) ?></div>
                <small class="text-muted">Avg Cost (<?= $item['valuation_method'] ?>)</small>
            </div>
        </div>
    </div>
</div>

<!-- Tabs -->
<ul class="nav nav-tabs mb-3" role="tablist">
    <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#details">Details</a></li>
    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#stock">Stock Levels</a></li>
    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#transactions">Transactions</a></li>
    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#replenishment">Replenishment</a></li>
    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#suppliers">Suppliers</a></li>
</ul>

<div class="tab-content">
    <!-- Details Tab -->
    <div class="tab-pane fade show active" id="details">
        <div class="row g-4">
            <div class="col-md-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light fw-bold">Product Information</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <tr><th class="w-40">Category</th><td><?= htmlspecialchars($item['category_name'] ?? '-') ?></td></tr>
                            <tr><th>UOM</th><td><?= htmlspecialchars($item['uom_name'] ?? '-') ?> (<?= $item['uom_code'] ?>)</td></tr>
                            <tr><th>Pack Size</th><td><?= $item['pack_size'] ?></td></tr>
                            <tr><th>Barcode</th><td><?= htmlspecialchars($item['barcode'] ?? '-') ?></td></tr>
                            <tr><th>Manufacturer</th><td><?= htmlspecialchars($item['manufacturer'] ?? '-') ?></td></tr>
                            <tr><th>Brand</th><td><?= htmlspecialchars($item['brand'] ?? '-') ?></td></tr>
                            <tr><th>Model</th><td><?= htmlspecialchars($item['model'] ?? '-') ?></td></tr>
                            <tr><th>Part Number</th><td><?= htmlspecialchars($item['part_number'] ?? '-') ?></td></tr>
                            <tr><th>Description</th><td><?= nl2br(htmlspecialchars($item['description'] ?? '-')) ?></td></tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card border-0 shadow-sm mb-3">
                    <div class="card-header bg-light fw-bold">Tracking & Control</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <tr><th>Serial Tracking</th><td><?= $item['serial_number_flag'] ? '✅ Yes' : '❌ No' ?></td></tr>
                            <tr><th>Batch/Lot Tracking</th><td><?= $item['batch_lot_flag'] ? '✅ Yes' : '❌ No' ?></td></tr>
                            <tr><th>Expiry Tracking</th><td><?= $item['expiry_date_flag'] ? '✅ Yes' : '❌ No' ?></td></tr>
                            <tr><th>Hazardous</th><td><?= $item['hazard_class_flag'] ? '⚠️ Yes' : '❌ No' ?></td></tr>
                            <tr><th>Inspection Required</th><td><?= $item['inspection_required'] ? '✅ Yes' : '❌ No' ?></td></tr>
                            <tr><th>Receiving Tolerance</th><td><?= $item['receiving_tolerance_pct'] ?>%</td></tr>
                            <tr><th>Shelf Life</th><td><?= $item['shelf_life_days'] ? $item['shelf_life_days'] . ' days' : '-' ?></td></tr>
                            <tr><th>Storage Conditions</th><td><?= htmlspecialchars($item['storage_conditions'] ?? '-') ?></td></tr>
                            <tr><th>Issue Policy</th><td><span class="badge bg-<?= $item['issue_policy'] === 'CONTROLLED' ? 'danger' : ($item['issue_policy'] === 'APPROVAL_REQUIRED' ? 'warning' : 'success') ?>"><?= $item['issue_policy'] ?></span></td></tr>
                        </table>
                    </div>
                </div>
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light fw-bold">Classification</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <tr><th>Criticality</th><td><?= htmlspecialchars($item['criticality_name'] ?? '-') ?></td></tr>
                            <tr><th>Accounting Class</th><td><?= htmlspecialchars($item['acct_class_name'] ?? '-') ?></td></tr>
                            <tr>
                                <th>Risk Classes</th>
                                <td>
                                    <?php if (empty($riskClasses)): ?>
                                        <span class="text-muted">None</span>
                                    <?php else: ?>
                                        <?php foreach ($riskClasses as $rc): ?>
                                            <span class="badge bg-outline-dark border me-1"><?= htmlspecialchars($rc['risk_name']) ?></span>
                                        <?php endforeach; ?>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <tr><th>GL Account</th><td><?= htmlspecialchars($item['gl_account_code'] ?? '-') ?></td></tr>
                            <tr><th>Funding Source</th><td><?= htmlspecialchars($item['funding_source'] ?? '-') ?></td></tr>
                            <tr><th>Program/Project</th><td><?= htmlspecialchars($item['program_project_code'] ?? '-') ?></td></tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Stock Levels Tab -->
    <div class="tab-pane fade" id="stock">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th>Location</th>
                                <th>Building / Room</th>
                                <th>Bin/Shelf</th>
                                <th>Batch/Lot</th>
                                <th>Serial</th>
                                <th>Expiry</th>
                                <th class="text-end">On Hand</th>
                                <th class="text-end">Reserved</th>
                                <th class="text-end">Available</th>
                                <th class="text-end">Unit Cost</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($stockRecords)): ?>
                            <tr><td colspan="11" class="text-center text-muted py-4">No stock records.</td></tr>
                            <?php endif; ?>
                            <?php foreach ($stockRecords as $sr): ?>
                            <tr>
                                <td><code><?= htmlspecialchars($sr['location_code']) ?></code></td>
                                <td><?= htmlspecialchars(($sr['building'] ?? '') . ' / ' . ($sr['room_storage_area'] ?? '')) ?></td>
                                <td><?= htmlspecialchars($sr['bin_shelf_rack'] ?? '-') ?></td>
                                <td><?= htmlspecialchars($sr['batch_lot_number'] ?? '-') ?></td>
                                <td><?= htmlspecialchars($sr['serial_number'] ?? '-') ?></td>
                                <td>
                                    <?php if ($sr['expiry_date']): ?>
                                        <?php $expDate = new DateTime($sr['expiry_date']); $now = new DateTime(); ?>
                                        <span class="<?= $expDate < $now ? 'text-danger fw-bold' : ($expDate->diff($now)->days < 30 ? 'text-warning' : '') ?>">
                                            <?= $sr['expiry_date'] ?>
                                        </span>
                                    <?php else: ?>-<?php endif; ?>
                                </td>
                                <td class="text-end"><?= number_format($sr['quantity_on_hand'], 2) ?></td>
                                <td class="text-end"><?= number_format($sr['quantity_reserved'], 2) ?></td>
                                <td class="text-end fw-bold"><?= number_format($sr['quantity_available'], 2) ?></td>
                                <td class="text-end">$<?= number_format($sr['unit_cost'], 2) ?></td>
                                <td><span class="badge bg-<?= $sr['stock_status'] === 'USABLE' ? 'success' : 'warning' ?>"><?= $sr['stock_status'] ?></span></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Transactions Tab -->
    <div class="tab-pane fade" id="transactions">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Reference</th>
                                <th class="text-end">Qty</th>
                                <th class="text-end">Unit Cost</th>
                                <th class="text-end">Total</th>
                                <th class="text-end">Balance</th>
                                <th>By</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($transactions)): ?>
                            <tr><td colspan="8" class="text-center text-muted py-4">No transactions recorded.</td></tr>
                            <?php endif; ?>
                            <?php foreach ($transactions as $txn): ?>
                            <?php
                            $isPositive = in_array($txn['transaction_type'], ['RECEIVE', 'TRANSFER_IN', 'ADJUSTMENT_GAIN', 'RETURN']);
                            ?>
                            <tr>
                                <td><?= date('Y-m-d H:i', strtotime($txn['created_at'])) ?></td>
                                <td>
                                    <span class="badge bg-<?= $isPositive ? 'success' : 'danger' ?>">
                                        <?= str_replace('_', ' ', $txn['transaction_type']) ?>
                                    </span>
                                </td>
                                <td><?= htmlspecialchars($txn['reference_number'] ?? '-') ?></td>
                                <td class="text-end <?= $isPositive ? 'text-success' : 'text-danger' ?>">
                                    <?= $isPositive ? '+' : '-' ?><?= number_format(abs($txn['quantity']), 2) ?>
                                </td>
                                <td class="text-end">$<?= number_format($txn['unit_cost'], 2) ?></td>
                                <td class="text-end">$<?= number_format($txn['total_cost'], 2) ?></td>
                                <td class="text-end fw-bold"><?= $txn['balance_after'] !== null ? number_format($txn['balance_after'], 2) : '-' ?></td>
                                <td><?= htmlspecialchars($txn['performed_by_name'] ?? '-') ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Replenishment Tab -->
    <div class="tab-pane fade" id="replenishment">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <table class="table table-sm">
                            <tr><th>Reorder Level</th><td><?= number_format($item['reorder_level'], 2) ?></td></tr>
                            <tr><th>Reorder Quantity</th><td><?= number_format($item['reorder_quantity'], 2) ?></td></tr>
                            <tr><th>Min Level</th><td><?= number_format($item['min_level'], 2) ?></td></tr>
                            <tr><th>Max Level</th><td><?= number_format($item['max_level'], 2) ?></td></tr>
                        </table>
                    </div>
                    <div class="col-md-4">
                        <table class="table table-sm">
                            <tr><th>Safety Stock</th><td><?= number_format($item['safety_stock'], 2) ?></td></tr>
                            <tr><th>Lead Time</th><td><?= $item['lead_time_days'] ?> days</td></tr>
                            <tr><th>EOQ</th><td><?= $item['economic_order_qty'] ? number_format($item['economic_order_qty'], 2) : '-' ?></td></tr>
                        </table>
                    </div>
                    <div class="col-md-4">
                        <?php
                        $belowReorder = $totalAvailable <= (float) $item['reorder_level'] && (float) $item['reorder_level'] > 0;
                        ?>
                        <?php if ($belowReorder): ?>
                        <div class="alert alert-warning">
                            <strong>⚠️ Below Reorder Level</strong><br>
                            Available: <?= number_format($totalAvailable, 0) ?> <?= $item['uom_code'] ?><br>
                            Reorder Level: <?= number_format($item['reorder_level'], 0) ?> <?= $item['uom_code'] ?>
                        </div>
                        <?php else: ?>
                        <div class="alert alert-success">
                            <strong>✅ Stock OK</strong><br>
                            Available stock is above reorder level.
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Suppliers Tab -->
    <div class="tab-pane fade" id="suppliers">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0">
                    <thead class="table-dark">
                        <tr><th>Supplier</th><th>Primary</th><th>Last Supply Date</th><th class="text-end">Last Price</th></tr>
                    </thead>
                    <tbody>
                        <?php if (empty($suppliers)): ?>
                        <tr><td colspan="4" class="text-center text-muted py-4">No suppliers linked.</td></tr>
                        <?php endif; ?>
                        <?php foreach ($suppliers as $sup): ?>
                        <tr>
                            <td><?= htmlspecialchars($sup['vendor_name']) ?></td>
                            <td><?= $sup['is_primary'] ? '⭐ Primary' : '' ?></td>
                            <td><?= $sup['last_supply_date'] ?? '-' ?></td>
                            <td class="text-end"><?= $sup['last_price'] ? '$' . number_format($sup['last_price'], 2) : '-' ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
