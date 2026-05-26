<?php
$REQUIRE_PERMISSION = 'view_pmo_dashboard';
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
$assetRegistryRows = [];
$assetRegistryReady = false;
$serialCount = 0;

if ($invReady) {
    /* ─── Check whether item_domain column exists (migration 024) ─────── */
    $domainReady = (int) $pdo->query("
        SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'inv_items'
          AND COLUMN_NAME = 'item_domain'
    ")->fetchColumn() > 0;

    $assetFilter = $domainReady
        ? "i.item_domain IN ('ASSET','BOTH')"
        : "EXISTS (SELECT 1 FROM inv_categories c WHERE c.category_id = i.category_id AND c.category_code = 'ASSETS')";

    $stats = $pdo->query("
        SELECT
            (SELECT COUNT(*) FROM inv_items WHERE item_status = 'ACTIVE') AS active_items,
            (SELECT COUNT(*) FROM inv_items i
               WHERE $assetFilter AND i.item_status = 'ACTIVE') AS asset_items,
            (SELECT COUNT(*) FROM inv_items WHERE serial_number_flag = 1 AND item_status = 'ACTIVE') AS serialized_items,
            (SELECT COALESCE(SUM(sl.quantity_on_hand * sl.unit_cost), 0) FROM inv_stock sl) AS total_value,
            (SELECT COALESCE(SUM(sl.quantity_on_hand * sl.unit_cost), 0)
               FROM inv_stock sl
               JOIN inv_items i ON sl.item_id = i.item_id
               WHERE $assetFilter) AS asset_value,
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

        $assetRegistryColumns = [
            'asset_status',
            'condition_last_updated_at',
            'next_condition_review_due_date',
            'purchase_value',
            'current_book_value',
            'depreciation_last_updated_at',
            'next_depreciation_review_due_date',
        ];
        $assetColsPlaceholders = implode(',', array_fill(0, count($assetRegistryColumns), '?'));
        $assetColsStmt = $pdo->prepare("
            SELECT COLUMN_NAME
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'inv_serial_numbers'
              AND COLUMN_NAME IN ($assetColsPlaceholders)
        ");
        $assetColsStmt->execute($assetRegistryColumns);
        $availableAssetColumns = $assetColsStmt->fetchAll(PDO::FETCH_COLUMN);
        $movementTableExists = (int) $pdo->query("
            SELECT COUNT(*)
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'inv_asset_movements'
        ")->fetchColumn();
        $assetRegistryReady = ($movementTableExists > 0) && (count($availableAssetColumns) === count($assetRegistryColumns));

        if ($assetRegistryReady) {
            $assetRegistryRows = $pdo->query("
                SELECT
                    sn.serial_id,
                    sn.serial_number,
                    sn.dgc_asset_number,
                    sn.purchase_req_number,
                    sn.po_number,
                    sn.invoice_number,
                    sn.grn_number,
                    sn.asset_status,
                    sn.current_condition,
                    sn.condition_last_updated_at,
                    sn.next_condition_review_due_date,
                    sn.purchase_value,
                    sn.current_book_value,
                    sn.depreciation_last_updated_at,
                    sn.next_depreciation_review_due_date,
                    sn.bos_number,
                    i.item_code,
                    i.item_name,
                    CONCAT_WS(' / ', l.building, l.room_storage_area) AS room_register,
                    COALESCE(mv.move_count, 0) AS move_count,
                    mv.last_moved_at
                FROM inv_serial_numbers sn
                JOIN inv_items i ON sn.item_id = i.item_id
                LEFT JOIN inv_locations l ON sn.location_id = l.location_id
                LEFT JOIN (
                    SELECT serial_id, COUNT(*) AS move_count, MAX(moved_at) AS last_moved_at
                    FROM inv_asset_movements
                    GROUP BY serial_id
                ) mv ON mv.serial_id = sn.serial_id
                ORDER BY sn.created_at DESC
                LIMIT 12
            ")->fetchAll(PDO::FETCH_ASSOC);
        }
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
        WHERE $assetFilter
        GROUP BY i.item_id, i.item_code, i.item_name, c.category_name, i.serial_number_flag
        ORDER BY total_value DESC
        LIMIT 8
    ")->fetchAll(PDO::FETCH_ASSOC);
}

$totalPending = $pendingReqs + $pendingGrn + $pendingTransfers + $pendingAdj + $pendingDisp;

/* ─── Workplace procurement request tracking ───────────────────────── */
// Status display metadata (single source of truth used by both count filter and HTML)
$procStatusLabels = [
    'DRAFT'             => ['label' => 'Draft',            'color' => 'secondary', 'pending' => false],
    'SUBMITTED'         => ['label' => 'Submitted',        'color' => 'info',      'pending' => true],
    'PENDING_HOD'       => ['label' => 'Pending HOD',      'color' => 'warning',   'pending' => true],
    'PENDING_FINANCE'   => ['label' => 'Pending Finance',  'color' => 'warning',   'pending' => true],
    'PENDING_COMMITTEE' => ['label' => 'Pending Committee','color' => 'warning',   'pending' => true],
    'PENDING_DGC'       => ['label' => 'Pending DGC',      'color' => 'warning',   'pending' => true],
    'APPROVED'          => ['label' => 'Approved',         'color' => 'success',   'pending' => false],
    'DECLINED'          => ['label' => 'Declined',         'color' => 'danger',    'pending' => false],
    'CANCELLED'         => ['label' => 'Cancelled',        'color' => 'dark',      'pending' => false],
];
$procPendingStatuses = array_keys(array_filter($procStatusLabels, fn($m) => $m['pending']));

// Status counts for all procurement requests visible to this role
$procStatusCounts = $pdo->query("
    SELECT status, COUNT(*) AS cnt
    FROM procurement_requests
    WHERE request_type NOT IN ('REIMBURSEMENT','PETTY_CASH')
    GROUP BY status
")->fetchAll(PDO::FETCH_KEY_PAIR);

// Recent / active procurement requests (last 20)
$recentProcurement = $pdo->query("
    SELECT pr.request_id, pr.request_number, pr.description, pr.status,
           pr.estimated_value, pr.currency, pr.created_at,
           u.full_name AS requestor_name
    FROM procurement_requests pr
    LEFT JOIN users u ON pr.created_by = u.user_id
    WHERE pr.request_type NOT IN ('REIMBURSEMENT','PETTY_CASH')
    ORDER BY pr.created_at DESC
    LIMIT 20
")->fetchAll(PDO::FETCH_ASSOC);

// Pending-approval total derived from the same labels array
$procPendingTotal = array_sum(
    array_intersect_key($procStatusCounts, array_flip($procPendingStatuses))
);

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

$assetStatusLabels = [
    'NEW' => ['label' => 'New', 'color' => 'primary'],
    'LIKE_NEW' => ['label' => 'Like New', 'color' => 'info'],
    'USED' => ['label' => 'Used', 'color' => 'secondary'],
    'POOR' => ['label' => 'Poor', 'color' => 'warning'],
    'DAMAGED' => ['label' => 'Damaged', 'color' => 'danger'],
    'GOOD' => ['label' => 'Good', 'color' => 'success'],
    'REPAIRED' => ['label' => 'Repaired', 'color' => 'warning'],
    'SERVICED' => ['label' => 'Serviced', 'color' => 'success'],
    'TO_BE_DISPOSED' => ['label' => 'To Be Disposed', 'color' => 'dark'],
    'BOARD_OF_SURVEY_ITEM' => ['label' => 'Board of Survey', 'color' => 'dark'],
    'DONATED' => ['label' => 'Donated', 'color' => 'secondary'],
    'SOLD' => ['label' => 'Sold', 'color' => 'secondary'],
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
                <a href="/inventory/items/list.php?domain=ASSET" class="btn btn-outline-primary btn-sm"><i class="bi bi-building-gear"></i> View Assets</a>
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

<!-- ── Procurement → Asset → Room Registry ────────────────────────────── -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-dark text-white">
        <i class="bi bi-diagram-3-fill"></i> Procurement → Asset → Room Registry Placement
    </div>
    <div class="card-body p-0">
        <?php if (!$assetRegistryReady): ?>
            <div class="alert alert-info m-3 mb-0">
                Run migration <code>migrations/2026_05_26_asset_room_registry_and_movement.sql</code> to enable room registry placement, movement history, and 6–12 month condition/depreciation review tracking.
            </div>
        <?php else: ?>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 small">
                <thead class="table-light">
                    <tr>
                        <th>Asset</th>
                        <th>Procurement Chain</th>
                        <th>Room Register</th>
                        <th>Movement</th>
                        <th>Condition Review</th>
                        <th>Depreciation Review</th>
                        <th>Status</th>
                        <th>BOS</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($assetRegistryRows)): ?>
                        <tr><td colspan="8" class="text-center text-muted py-4">No serialized assets available.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($assetRegistryRows as $ar):
                        $assetStatus = $assetStatusLabels[$ar['asset_status'] ?? ''] ?? ['label' => ($ar['asset_status'] ?? 'Unknown'), 'color' => 'secondary'];
                        $conditionDue = '-';
                        if (!empty($ar['next_condition_review_due_date'])) {
                            $conditionDue = date('Y-m-d', strtotime($ar['next_condition_review_due_date']));
                        }
                        $deprDue = '-';
                        if (!empty($ar['next_depreciation_review_due_date'])) {
                            $deprDue = date('Y-m-d', strtotime($ar['next_depreciation_review_due_date']));
                        }
                        $condClass = 'secondary';
                        if (!empty($ar['next_condition_review_due_date'])) {
                            $condClass = (strtotime($ar['next_condition_review_due_date']) < strtotime('today')) ? 'danger' : ((strtotime($ar['next_condition_review_due_date']) <= strtotime('+180 days')) ? 'warning' : 'success');
                        }
                        $deprClass = 'secondary';
                        if (!empty($ar['next_depreciation_review_due_date'])) {
                            $deprClass = (strtotime($ar['next_depreciation_review_due_date']) < strtotime('today')) ? 'danger' : ((strtotime($ar['next_depreciation_review_due_date']) <= strtotime('+180 days')) ? 'warning' : 'success');
                        }
                    ?>
                    <tr>
                        <td>
                            <code><?= htmlspecialchars($ar['serial_number']) ?></code><br>
                            <small class="text-muted"><?= htmlspecialchars($ar['item_code']) ?></small> <?= htmlspecialchars($ar['item_name']) ?><br>
                            <small class="text-muted">DGC Asset: <?= htmlspecialchars($ar['dgc_asset_number'] ?? '—') ?></small>
                        </td>
                        <td>
                            <small>PR: <strong><?= htmlspecialchars($ar['purchase_req_number'] ?? '—') ?></strong></small><br>
                            <small>PO: <strong><?= htmlspecialchars($ar['po_number'] ?? '—') ?></strong></small><br>
                            <small>Invoice: <strong><?= htmlspecialchars($ar['invoice_number'] ?? '—') ?></strong></small><br>
                            <small>GRN: <strong><?= htmlspecialchars($ar['grn_number'] ?? '—') ?></strong></small>
                        </td>
                        <td><?= htmlspecialchars($ar['room_register'] ?: 'Unassigned') ?></td>
                        <td>
                            <span class="badge bg-secondary"><?= (int) $ar['move_count'] ?> move(s)</span><br>
                            <small class="text-muted"><?= !empty($ar['last_moved_at']) ? date('Y-m-d', strtotime($ar['last_moved_at'])) : 'No movement logged' ?></small>
                        </td>
                        <td>
                            <span class="badge bg-<?= $condClass ?>"><?= htmlspecialchars($ar['current_condition'] ?: 'Not set') ?></span><br>
                            <small class="text-muted">Due: <?= $conditionDue ?></small>
                        </td>
                        <td>
                            <small>Value: $<?= number_format((float) ($ar['current_book_value'] ?? 0), 2) ?></small><br>
                            <small class="text-muted">Bought: $<?= number_format((float) ($ar['purchase_value'] ?? 0), 2) ?></small><br>
                            <span class="badge bg-<?= $deprClass ?>">Due: <?= $deprDue ?></span>
                        </td>
                        <td><span class="badge bg-<?= $assetStatus['color'] ?>"><?= htmlspecialchars($assetStatus['label']) ?></span></td>
                        <td><?= htmlspecialchars($ar['bos_number'] ?? '—') ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php endif; ?>
    </div>
</div>

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

<!-- ── Workplace Procurement Requests ────────────────────────────────── -->
<div class="mt-5">
    <h4 class="fw-bold border-bottom pb-2 mb-3">
        <i class="bi bi-briefcase me-2"></i>Workplace Procurement Requests
    </h4>

    <!-- Status summary pills -->
    <div class="row g-2 mb-4">
        <?php foreach ($procStatusLabels as $st => $meta):
            $cnt = (int)($procStatusCounts[$st] ?? 0);
            if ($cnt === 0) continue;
        ?>
        <div class="col-auto">
            <a href="/procurement/list.php?status=<?= urlencode($st) ?>" class="text-decoration-none">
                <div class="card border-0 shadow-sm text-center px-3 py-2 bg-<?= $meta['color'] ?> bg-opacity-10 border-<?= $meta['color'] ?> border-opacity-25">
                    <div class="fw-bold text-<?= $meta['color'] ?> fs-5"><?= $cnt ?></div>
                    <small class="text-muted"><?= $meta['label'] ?></small>
                </div>
            </a>
        </div>
        <?php endforeach; ?>

        <div class="col-auto ms-auto d-flex align-items-center">
            <a href="/procurement/list.php" class="btn btn-outline-dark btn-sm">
                <i class="bi bi-list-ul me-1"></i>View All Requests
            </a>
        </div>
    </div>

    <!-- Recent requests table -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-clock-history me-1"></i> Recent Requests (Last 20)</span>
            <span class="badge bg-warning text-dark">
                <?= $procPendingTotal ?> Pending Action
            </span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 small">
                    <thead class="table-light">
                        <tr>
                            <th>Ref #</th>
                            <th>Description</th>
                            <th>Requested By</th>
                            <th class="text-end">Amount</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentProcurement)): ?>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                No procurement requests found.
                            </td>
                        </tr>
                        <?php else: foreach ($recentProcurement as $pr):
                            $stMeta = $procStatusLabels[$pr['status']] ?? ['label' => $pr['status'], 'color' => 'secondary'];
                        ?>
                        <tr>
                            <td>
                                <a href="/procurement/view.php?id=<?= $pr['request_id'] ?>" class="text-decoration-none fw-medium">
                                    <?= htmlspecialchars($pr['request_number'] ?? '#' . $pr['request_id']) ?>
                                </a>
                            </td>
                            <td class="text-truncate" style="max-width:240px">
                                <?= htmlspecialchars($pr['description'] ?? '—') ?>
                            </td>
                            <td><?= htmlspecialchars($pr['requestor_name'] ?? '—') ?></td>
                            <td class="text-end fw-semibold">
                                <?php if ($pr['estimated_value']): ?>
                                    <?= htmlspecialchars($pr['currency'] ?? 'JMD') ?>
                                    <?= number_format((float)$pr['estimated_value'], 2) ?>
                                <?php else: ?>
                                    —
                                <?php endif; ?>
                            </td>
                            <td>
                                <span class="badge bg-<?= $stMeta['color'] ?>">
                                    <?= $stMeta['label'] ?>
                                </span>
                            </td>
                            <td><?= date('Y-m-d', strtotime($pr['created_at'])) ?></td>
                            <td>
                                <a href="/procurement/view.php?id=<?= $pr['request_id'] ?>" class="btn btn-sm btn-outline-secondary">
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
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
