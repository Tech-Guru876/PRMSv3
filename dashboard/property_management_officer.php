<?php
$REQUIRE_PERMISSION = 'view_inventory';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

/* ─── Check inventory tables ─────────────────────────────────────────── */
$invReady = inventoryTablesExist($pdo);

/* ─── KPI queries (only if tables exist) ─────────────────────────────── */
$stats = [
    'active_items' => 0, 'total_value' => 0, 'low_stock_count' => 0,
    'asset_items' => 0, 'serialized_items' => 0,
];
$pendingReqs = $pendingGrn = $pendingTransfers = $pendingAdj = $pendingDisp = 0;
$expiringCount = 0;
$recentTxns = $topAssets = $lifecycleStats = [];
$serialCount = 0;

if ($invReady) {
    $stats = $pdo->query("
        SELECT
            (SELECT COUNT(*) FROM inv_items WHERE item_status = 'ACTIVE') AS active_items,
            (SELECT COUNT(*) FROM inv_items i
               JOIN inv_categories c ON i.category_id = c.category_id
               WHERE c.category_code = 'ASSETS' AND i.item_status = 'ACTIVE') AS asset_items,
            (SELECT COUNT(*) FROM inv_items WHERE serial_number_flag = 1 AND item_status = 'ACTIVE') AS serialized_items,
            (SELECT COALESCE(SUM(sl.quantity_on_hand * sl.unit_cost), 0) FROM inv_stock sl) AS total_value,
            (SELECT COALESCE(SUM(sl.quantity_on_hand * sl.unit_cost), 0)
               FROM inv_stock sl
               JOIN inv_items i ON sl.item_id = i.item_id
               JOIN inv_categories c ON i.category_id = c.category_id
               WHERE c.category_code = 'ASSETS') AS asset_value,
            (SELECT COUNT(DISTINCT i2.item_id)
               FROM inv_items i2
               LEFT JOIN (SELECT item_id, SUM(quantity_on_hand) AS qty FROM inv_stock GROUP BY item_id) s
                 ON i2.item_id = s.item_id
               WHERE i2.item_status = 'ACTIVE'
                 AND i2.reorder_level > 0
                 AND COALESCE(s.qty, 0) <= i2.reorder_level) AS low_stock_count
    ")->fetch(PDO::FETCH_ASSOC);

    $pendingReqs      = $pdo->query("SELECT COUNT(*) FROM inv_requisitions WHERE status = 'SUBMITTED'")->fetchColumn();
    $pendingGrn       = $pdo->query("SELECT COUNT(*) FROM inv_goods_received WHERE status IN ('DRAFT','RECEIVED')")->fetchColumn();
    $pendingTransfers = $pdo->query("SELECT COUNT(*) FROM inv_transfers WHERE status = 'PENDING_APPROVAL'")->fetchColumn();
    $pendingAdj       = $pdo->query("SELECT COUNT(*) FROM inv_adjustments WHERE status = 'PENDING_APPROVAL'")->fetchColumn();
    $pendingDisp      = $pdo->query("SELECT COUNT(*) FROM inv_disposals WHERE status IN ('RECOMMENDED','PENDING_APPROVAL')")->fetchColumn();

    $expiringCount = $pdo->query("
        SELECT COUNT(DISTINCT s.item_id)
        FROM inv_stock s
        WHERE s.expiry_date IS NOT NULL
          AND s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
          AND s.quantity_on_hand > 0
    ")->fetchColumn();

    /* Serialized asset lifecycle stats (if table exists) */
    $snTableExists = $pdo->query("
        SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inv_serial_numbers'
    ")->fetchColumn();

    if ($snTableExists) {
        $serialCount = $pdo->query("SELECT COUNT(*) FROM inv_serial_numbers")->fetchColumn();

        $lifecycleStats = $pdo->query("
            SELECT lifecycle_status, COUNT(*) AS cnt
            FROM inv_serial_numbers
            GROUP BY lifecycle_status
            ORDER BY FIELD(lifecycle_status,
                'ORDERED','RECEIVED','ASSIGNED','IN_SERVICE',
                'UNDER_REPAIR','TRANSFERRED','DISPOSED','LOST_STOLEN')
        ")->fetchAll(PDO::FETCH_KEY_PAIR);

        /* Recently registered serial numbers */
        $recentSerials = $pdo->query("
            SELECT sn.serial_number, sn.dgc_asset_number, sn.lifecycle_status,
                   sn.po_number, sn.grn_number, sn.created_at,
                   i.item_code, i.item_name,
                   u.full_name AS issued_to
            FROM inv_serial_numbers sn
            JOIN inv_items i ON sn.item_id = i.item_id
            LEFT JOIN users u ON sn.issued_to_user_id = u.user_id
            ORDER BY sn.created_at DESC
            LIMIT 8
        ")->fetchAll(PDO::FETCH_ASSOC);
    }

    /* Recent transactions */
    $recentTxns = $pdo->query("
        SELECT st.transaction_type, st.quantity, st.created_at AS transaction_date,
               i.item_code, i.item_name, l.location_code, u.full_name
        FROM inv_transactions st
        JOIN inv_items i ON st.item_id = i.item_id
        LEFT JOIN inv_locations l ON st.location_id = l.location_id
        LEFT JOIN users u ON st.performed_by = u.user_id
        ORDER BY st.created_at DESC
        LIMIT 8
    ")->fetchAll(PDO::FETCH_ASSOC);

    /* Top asset items by value */
    $topAssets = $pdo->query("
        SELECT i.item_code, i.item_name, c.category_name,
               i.serial_number_flag,
               SUM(sl.quantity_on_hand) AS total_qty,
               SUM(sl.quantity_on_hand * sl.unit_cost) AS total_value
        FROM inv_stock sl
        JOIN inv_items i ON sl.item_id = i.item_id
        JOIN inv_categories c ON i.category_id = c.category_id
        WHERE c.category_code = 'ASSETS'
        GROUP BY i.item_id, i.item_code, i.item_name, c.category_name, i.serial_number_flag
        ORDER BY total_value DESC
        LIMIT 8
    ")->fetchAll(PDO::FETCH_ASSOC);
}

$totalPending = $pendingReqs + $pendingGrn + $pendingTransfers + $pendingAdj + $pendingDisp;

$lifecycleLabels = [
    'ORDERED'     => ['label' => 'Ordered',      'color' => 'info'],
    'RECEIVED'    => ['label' => 'Received',     'color' => 'primary'],
    'ASSIGNED'    => ['label' => 'Assigned',     'color' => 'success'],
    'IN_SERVICE'  => ['label' => 'In Service',   'color' => 'success'],
    'UNDER_REPAIR'=> ['label' => 'Under Repair', 'color' => 'warning'],
    'TRANSFERRED' => ['label' => 'Transferred',  'color' => 'secondary'],
    'DISPOSED'    => ['label' => 'Disposed',     'color' => 'dark'],
    'LOST_STOLEN' => ['label' => 'Lost/Stolen',  'color' => 'danger'],
];

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-building-gear"></i> Property Management Officer
        <small class="text-muted fs-6 ms-2">Dashboard</small>
    </h2>
    <div class="d-flex gap-2">
        <a href="/inventory/items/list.php" class="btn btn-outline-secondary btn-sm"><i class="bi bi-list-ul"></i> All Items</a>
        <a href="/inventory/reports/" class="btn btn-outline-dark btn-sm"><i class="bi bi-bar-chart"></i> Reports</a>
    </div>
</div>

<?php if (!$invReady): ?>
<div class="alert alert-warning">
    <i class="bi bi-exclamation-triangle"></i>
    <strong>Inventory module not yet set up.</strong>
    A database administrator needs to run
    <code>migrations/019_inventory_management_system.sql</code> before this module can be used.
</div>
<?php else: ?>

<!-- ── Primary KPIs ──────────────────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm bg-primary bg-opacity-10 h-100">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= number_format($stats['active_items']) ?></h3>
                <small class="text-muted">Active Inventory Items</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10 h-100">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= number_format($stats['asset_items']) ?></h3>
                <small class="text-muted">Asset Items</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm bg-success bg-opacity-10 h-100">
            <div class="card-body text-center py-4">
                <h3 class="mb-0">$<?= number_format($stats['asset_value'] ?? 0, 0) ?></h3>
                <small class="text-muted">Asset Value</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm bg-warning bg-opacity-10 h-100">
            <div class="card-body text-center py-4">
                <h3 class="mb-0"><?= number_format($stats['serialized_items']) ?></h3>
                <small class="text-muted">Serialized Items</small>
            </div>
        </div>
    </div>
</div>

<!-- ── Secondary KPIs ───────────────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center py-3">
                <h4 class="mb-0 text-danger"><?= $stats['low_stock_count'] ?></h4>
                <small class="text-muted">Low Stock Alerts</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center py-3">
                <h4 class="mb-0 text-warning"><?= $expiringCount ?></h4>
                <small class="text-muted">Expiring (90 days)</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center py-3">
                <h4 class="mb-0 text-primary"><?= $serialCount ?></h4>
                <small class="text-muted">Tracked Serials</small>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center py-3">
                <h4 class="mb-0 <?= $totalPending > 0 ? 'text-danger' : 'text-success' ?>"><?= $totalPending ?></h4>
                <small class="text-muted">Pending Actions</small>
            </div>
        </div>
    </div>
</div>

<!-- ── Pending Actions ───────────────────────────────────────────────── -->
<div class="card border-0 shadow-sm mb-4">
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
                <a href="/inventory/receiving/list.php" class="text-decoration-none">
                    <h4 class="text-info"><?= $pendingGrn ?></h4>
                    <small>GRNs Pending</small>
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
                    <h4 class="text-secondary"><?= $pendingAdj ?></h4>
                    <small>Adjustments</small>
                </a>
            </div>
            <div class="col">
                <a href="/inventory/disposal/list.php" class="text-decoration-none">
                    <h4 class="text-danger"><?= $pendingDisp ?></h4>
                    <small>Disposals</small>
                </a>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 mb-4">
    <!-- ── Quick Actions ────────────────────────────────────────────── -->
    <div class="col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-dark text-white"><i class="bi bi-lightning"></i> Quick Actions</div>
            <div class="card-body d-grid gap-2">
                <a href="/inventory/items/add.php" class="btn btn-outline-dark btn-sm"><i class="bi bi-plus-lg"></i> Add Item / Asset</a>
                <a href="/inventory/receiving/add.php" class="btn btn-outline-success btn-sm"><i class="bi bi-box-seam"></i> Record GRN</a>
                <a href="/inventory/issuing/add.php" class="btn btn-outline-info btn-sm"><i class="bi bi-box-arrow-right"></i> Issue Stock</a>
                <a href="/inventory/transfers/add.php" class="btn btn-outline-warning btn-sm"><i class="bi bi-arrow-left-right"></i> Transfer</a>
                <a href="/inventory/disposal/add.php" class="btn btn-outline-danger btn-sm"><i class="bi bi-trash3"></i> Disposal Request</a>
                <a href="/inventory/stocktake/add.php" class="btn btn-outline-secondary btn-sm"><i class="bi bi-clipboard-data"></i> Stock Count</a>
                <a href="/inventory/items/list.php?category=ASSETS" class="btn btn-outline-primary btn-sm"><i class="bi bi-building-gear"></i> View Assets</a>
            </div>
        </div>
    </div>

    <!-- ── Serial Number Lifecycle Status ───────────────────────────── -->
    <div class="col-md-9">
        <?php if (!empty($lifecycleStats)): ?>
        <div class="card border-0 shadow-sm mb-3">
            <div class="card-header bg-dark text-white"><i class="bi bi-diagram-3"></i> Asset Lifecycle Status</div>
            <div class="card-body">
                <div class="row g-2 text-center">
                    <?php foreach ($lifecycleLabels as $status => $meta): ?>
                    <div class="col">
                        <div class="p-2 rounded bg-<?= $meta['color'] ?> bg-opacity-10 border border-<?= $meta['color'] ?> border-opacity-25">
                            <h5 class="mb-0 text-<?= $meta['color'] ?>"><?= $lifecycleStats[$status] ?? 0 ?></h5>
                            <small class="text-muted"><?= $meta['label'] ?></small>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
                <!-- Lifecycle chain visualization -->
                <div class="mt-3 d-flex align-items-center flex-wrap gap-1 small text-muted">
                    <span class="badge bg-light text-dark border">PR #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">PO #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">Invoice #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-primary">Serial #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">GRN #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">DGC Asset #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">Issue Req #</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-light text-dark border">BOS</span>
                    <i class="bi bi-arrow-right"></i>
                    <span class="badge bg-danger">Disposed</span>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <!-- ── Top Assets by Value ───────────────────────────────────── -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-dark text-white"><i class="bi bi-trophy"></i> Top Assets by Value</div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th>Item</th>
                                <th>Category</th>
                                <th class="text-center">Serialized</th>
                                <th class="text-end">Qty</th>
                                <th class="text-end">Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($topAssets)): ?>
                            <tr><td colspan="5" class="text-center text-muted py-4">No assets recorded yet</td></tr>
                            <?php else: foreach ($topAssets as $ta): ?>
                            <tr>
                                <td>
                                    <code><?= htmlspecialchars($ta['item_code']) ?></code>
                                    <?= htmlspecialchars($ta['item_name']) ?>
                                </td>
                                <td><?= htmlspecialchars($ta['category_name']) ?></td>
                                <td class="text-center">
                                    <?= $ta['serial_number_flag']
                                        ? '<span class="badge bg-success">Yes</span>'
                                        : '<span class="badge bg-secondary">No</span>' ?>
                                </td>
                                <td class="text-end"><?= number_format($ta['total_qty'], 0) ?></td>
                                <td class="text-end fw-bold">$<?= number_format($ta['total_value'], 2) ?></td>
                            </tr>
                            <?php endforeach; endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ── Recent Serialized Assets ─────────────────────────────────────── -->
<?php if (!empty($recentSerials ?? [])): ?>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
        <span><i class="bi bi-upc-scan"></i> Recent Serial Number Registrations</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 small">
                <thead class="table-light">
                    <tr>
                        <th>Serial #</th>
                        <th>Item</th>
                        <th>DGC Asset #</th>
                        <th>PO #</th>
                        <th>GRN #</th>
                        <th>Issued To</th>
                        <th>Status</th>
                        <th>Registered</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($recentSerials as $rs):
                        $lbl = $lifecycleLabels[$rs['lifecycle_status']] ?? ['label' => $rs['lifecycle_status'], 'color' => 'secondary'];
                    ?>
                    <tr>
                        <td><code><?= htmlspecialchars($rs['serial_number']) ?></code></td>
                        <td>
                            <small class="text-muted"><?= htmlspecialchars($rs['item_code']) ?></small><br>
                            <?= htmlspecialchars($rs['item_name']) ?>
                        </td>
                        <td><?= htmlspecialchars($rs['dgc_asset_number'] ?? '—') ?></td>
                        <td><?= htmlspecialchars($rs['po_number'] ?? '—') ?></td>
                        <td><?= htmlspecialchars($rs['grn_number'] ?? '—') ?></td>
                        <td><?= htmlspecialchars($rs['issued_to'] ?? '—') ?></td>
                        <td><span class="badge bg-<?= $lbl['color'] ?>"><?= $lbl['label'] ?></span></td>
                        <td><?= date('Y-m-d', strtotime($rs['created_at'])) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- ── Recent Transactions ───────────────────────────────────────────── -->
<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white"><i class="bi bi-clock-history"></i> Recent Transactions</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 small">
                <thead class="table-light">
                    <tr>
                        <th>Date</th>
                        <th>Type</th>
                        <th>Item</th>
                        <th>Location</th>
                        <th class="text-end">Qty</th>
                        <th>By</th>
                    </tr>
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
                        <td><?= htmlspecialchars($t['location_code'] ?? '—') ?></td>
                        <td class="text-end fw-bold"><?= number_format($t['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars($t['full_name'] ?? '—') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
