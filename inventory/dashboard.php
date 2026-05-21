<?php
$REQUIRE_PERMISSION = 'view_inventory';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

/* Check if inventory tables exist */
if (!inventoryTablesExist($pdo)) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
    ?>
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card border-warning shadow">
                    <div class="card-header bg-warning text-dark fw-bold">
                        <i class="bi bi-exclamation-triangle"></i> Inventory Module — Setup Required
                    </div>
                    <div class="card-body">
                        <p>The inventory management tables have not been created yet. A database administrator needs to run the migration script before this module can be used.</p>
                        <h6>Steps:</h6>
                        <ol>
                            <li>Locate the migration file: <code>migrations/019_inventory_management_system.sql</code></li>
                            <li>Run it against the database using phpMyAdmin, MySQL CLI, or your preferred tool:
                                <pre class="bg-light p-2 rounded mt-1 mb-2">mysql -u USERNAME -p DATABASE_NAME &lt; migrations/019_inventory_management_system.sql</pre>
                            </li>
                            <li>Refresh this page once the migration is complete.</li>
                        </ol>
                        <a href="/inventory/dashboard.php" class="btn btn-primary"><i class="bi bi-arrow-clockwise"></i> Refresh</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <?php
    require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php';
    exit;
}

/* Check if GoJ compliance tables exist (migration 019c) */
if (($_GET['missing'] ?? '') === 'compliance' || !inventoryComplianceTablesExist($pdo)) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
    ?>
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card border-warning shadow">
                    <div class="card-header bg-warning text-dark fw-bold">
                        <i class="bi bi-exclamation-triangle"></i> Inventory Module — Compliance Migration Required
                    </div>
                    <div class="card-body">
                        <p>The GoJ compliance tables (Recalls, Returns, Incidents, Quarantine, Write-Downs) have not been created yet. A database administrator needs to run the migration script before these pages can be used.</p>
                        <h6>Steps:</h6>
                        <ol>
                            <li>Locate the migration file: <code>migrations/019c_goj_compliance.sql</code></li>
                            <li>Run it against the database using phpMyAdmin, MySQL CLI, or your preferred tool:
                                <pre class="bg-light p-2 rounded mt-1 mb-2">mysql -u USERNAME -p DATABASE_NAME &lt; migrations/019c_goj_compliance.sql</pre>
                            </li>
                            <li>Alternatively, run all pending migrations via the deploy script:
                                <pre class="bg-light p-2 rounded mt-1 mb-2">bash deploy/deploy.sh --run-migrations</pre>
                            </li>
                            <li>Refresh this page once the migration is complete.</li>
                        </ol>
                        <a href="/inventory/dashboard.php" class="btn btn-primary"><i class="bi bi-arrow-clockwise"></i> Refresh</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <?php
    require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php';
    exit;
}

/* KPI Queries */
$stats = $pdo->query("SELECT
    (SELECT COUNT(*) FROM inv_items WHERE item_status='ACTIVE') AS active_items,
    (SELECT COUNT(*) FROM inv_locations WHERE is_active=1) AS active_locations,
    (SELECT COALESCE(SUM(sl.quantity_on_hand * sl.unit_cost), 0) FROM inv_stock sl) AS total_value,
    (SELECT COUNT(DISTINCT i2.item_id) FROM inv_items i2 LEFT JOIN (SELECT item_id, SUM(quantity_on_hand) AS qty FROM inv_stock GROUP BY item_id) s ON i2.item_id = s.item_id WHERE i2.item_status='ACTIVE' AND i2.reorder_level > 0 AND COALESCE(s.qty,0) <= i2.reorder_level) AS low_stock_count
")->fetch(PDO::FETCH_ASSOC);

$pendingReqs = $pdo->query("SELECT COUNT(*) FROM inv_requisitions WHERE status='SUBMITTED'")->fetchColumn();
$pendingGrn = $pdo->query("SELECT COUNT(*) FROM inv_goods_received WHERE status IN ('DRAFT','RECEIVED')")->fetchColumn();
$pendingTransfers = $pdo->query("SELECT COUNT(*) FROM inv_transfers WHERE status='PENDING_APPROVAL'")->fetchColumn();
$pendingAdj = $pdo->query("SELECT COUNT(*) FROM inv_adjustments WHERE status='PENDING_APPROVAL'")->fetchColumn();
$pendingDisp = $pdo->query("SELECT COUNT(*) FROM inv_disposals WHERE status IN ('RECOMMENDED','PENDING_APPROVAL')")->fetchColumn();

/* Expiring soon */
$expiringCount = $pdo->query("
    SELECT COUNT(DISTINCT s.item_id)
    FROM inv_stock s
    WHERE s.expiry_date IS NOT NULL
      AND s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
      AND s.quantity_on_hand > 0
")->fetchColumn();

/* Recent transactions */
$recentTxns = $pdo->query("
    SELECT st.transaction_type, st.quantity, st.created_at AS transaction_date,
           i.item_code, i.item_name, l.location_code, u.full_name
    FROM inv_transactions st
    JOIN inv_items i ON st.item_id = i.item_id
    LEFT JOIN inv_locations l ON st.location_id = l.location_id
    LEFT JOIN users u ON st.performed_by = u.user_id
    ORDER BY st.created_at DESC
    LIMIT 10
")->fetchAll(PDO::FETCH_ASSOC);

/* Top items by value */
$topItems = $pdo->query("
    SELECT i.item_code, i.item_name,
           SUM(sl.quantity_on_hand) AS total_qty,
           SUM(sl.quantity_on_hand * sl.unit_cost) AS total_value
    FROM inv_stock sl
    JOIN inv_items i ON sl.item_id = i.item_id
    GROUP BY i.item_id, i.item_code, i.item_name
    ORDER BY total_value DESC
    LIMIT 10
")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-boxes"></i> Inventory Dashboard</h2>
    <div>
        <a href="/inventory/reports/" class="btn btn-outline-dark"><i class="bi bi-bar-chart"></i> Reports</a>
    </div>
</div>

<!-- Primary KPIs -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-primary bg-opacity-10">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= number_format($stats['active_items']) ?></h3>
                <small class="text-muted">Active Items</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10">
            <div class="card-body text-center py-4">
                <h3 class="mb-0">$<?= number_format($stats['total_value'], 0) ?></h3>
                <small class="text-muted">Total Inventory Value</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= $stats['low_stock_count'] ?></h3>
                <small class="text-muted">Low Stock Alerts</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-danger bg-opacity-10">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= $expiringCount ?></h3>
                <small class="text-muted">Expiring (90 days)</small>
            </div>
        </div>
    </div>
</div>

<!-- Pending Actions -->
<div class="row g-3 mb-4">
    <div class="col-12">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-dark text-white"><i class="bi bi-bell"></i> Pending Actions</div>
            <div class="card-body">
                <div class="row g-3 text-center">
                    <div class="col">
                        <a href="/inventory/requisitions/list.php?status=SUBMITTED" class="text-decoration-none">
                            <h4 class="text-warning"><?= $pendingReqs ?></h4>
                            <small>Requisitions</small>
                        </a>
                    </div>
                    <div class="col">
                        <a href="/inventory/receiving/list.php?status=INSPECTION" class="text-decoration-none">
                            <h4 class="text-info"><?= $pendingGrn ?></h4>
                            <small>GRNs</small>
                        </a>
                    </div>
                    <div class="col">
                        <a href="/inventory/transfers/list.php?status=PENDING_APPROVAL" class="text-decoration-none">
                            <h4 class="text-primary"><?= $pendingTransfers ?></h4>
                            <small>Transfers</small>
                        </a>
                    </div>
                    <div class="col">
                        <a href="/inventory/adjustments/list.php?status=PENDING_APPROVAL" class="text-decoration-none">
                            <h4 class="text-danger"><?= $pendingAdj ?></h4>
                            <small>Adjustments</small>
                        </a>
                    </div>
                    <div class="col">
                        <a href="/inventory/disposal/list.php?status=PENDING_APPROVAL" class="text-decoration-none">
                            <h4 class="text-secondary"><?= $pendingDisp ?></h4>
                            <small>Disposals</small>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 mb-4">
    <!-- Quick Actions -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-dark text-white"><i class="bi bi-lightning"></i> Quick Actions</div>
            <div class="card-body d-grid gap-2">
                <a href="/inventory/requisitions/add.php" class="btn btn-outline-primary"><i class="bi bi-clipboard-plus"></i> New Requisition</a>
                <a href="/inventory/receiving/add.php" class="btn btn-outline-success"><i class="bi bi-box-seam"></i> New GRN</a>
                <a href="/inventory/issuing/add.php" class="btn btn-outline-info"><i class="bi bi-box-arrow-right"></i> Issue Stock</a>
                <a href="/inventory/transfers/add.php" class="btn btn-outline-warning"><i class="bi bi-arrow-left-right"></i> Transfer Stock</a>
                <a href="/inventory/stocktake/add.php" class="btn btn-outline-secondary"><i class="bi bi-clipboard-data"></i> Start Stock Count</a>
                <a href="/inventory/items/add.php" class="btn btn-outline-dark"><i class="bi bi-plus-lg"></i> Add New Item</a>
            </div>
        </div>
    </div>

    <!-- Top Items by Value -->
    <div class="col-md-8">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-dark text-white"><i class="bi bi-trophy"></i> Top Items by Value</div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>Item</th><th class="text-end">Qty</th><th class="text-end">Value</th></tr>
                        </thead>
                        <tbody>
                            <?php foreach ($topItems as $ti): ?>
                            <tr>
                                <td><code><?= htmlspecialchars($ti['item_code']) ?></code> <?= htmlspecialchars($ti['item_name']) ?></td>
                                <td class="text-end"><?= number_format($ti['total_qty'], 0) ?></td>
                                <td class="text-end fw-bold">$<?= number_format($ti['total_value'], 2) ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Transactions -->
<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white"><i class="bi bi-clock-history"></i> Recent Transactions</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Date</th><th>Type</th><th>Item</th><th>Location</th><th class="text-end">Qty</th><th>By</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($recentTxns)): ?>
                    <tr><td colspan="6" class="text-center text-muted py-4">No recent transactions</td></tr>
                    <?php else: foreach ($recentTxns as $t): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($t['transaction_date'])) ?></td>
                        <td>
                            <?php $tc = match($t['transaction_type']) {
                                'RECEIPT','TRANSFER_IN','ADJUSTMENT_IN','RETURN' => 'success',
                                'ISSUE','TRANSFER_OUT','ADJUSTMENT_OUT','DISPOSAL' => 'danger',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $tc ?>"><?= str_replace('_', ' ', $t['transaction_type']) ?></span>
                        </td>
                        <td><code><?= htmlspecialchars($t['item_code']) ?></code> <?= htmlspecialchars($t['item_name']) ?></td>
                        <td><?= htmlspecialchars($t['location_code'] ?? '-') ?></td>
                        <td class="text-end fw-bold"><?= number_format($t['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars($t['full_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
