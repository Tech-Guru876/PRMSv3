<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo = $_GET['date_to'] ?? date('Y-m-d');
$serialFilter = (int) ($_GET['serial_id'] ?? 0);
$statusFilter = trim($_GET['status'] ?? '');

$serialTableReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'inv_serial_numbers'
")->fetchColumn() > 0;

$movementTableReady = (int) $pdo->query("
    SELECT COUNT(*)
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'inv_asset_movements'
")->fetchColumn() > 0;

$rows = [];
$serialOptions = [];
$totalMoves = 0;
$distinctAssets = 0;
$totalRows = 0;

if ($serialTableReady) {
    $serialOptions = $pdo->query("
        SELECT
            sn.serial_id,
            sn.serial_number,
            sn.dgc_asset_number,
            i.item_code,
            i.item_name
        FROM inv_serial_numbers sn
        JOIN inv_items i ON sn.item_id = i.item_id
        ORDER BY sn.created_at DESC
        LIMIT 500
    ")->fetchAll(PDO::FETCH_ASSOC);
}

if ($serialTableReady && $movementTableReady) {
    $where = "m.moved_at BETWEEN ? AND ?";
    $params = [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'];
    if ($serialFilter > 0) {
        $where .= " AND m.serial_id = ?";
        $params[] = $serialFilter;
    }
    if ($statusFilter !== '') {
        $where .= " AND sn.lifecycle_status = ?";
        $params[] = $statusFilter;
    }

    extract(getPaginationParams(25));

    $countStmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM inv_asset_movements m
        JOIN inv_serial_numbers sn ON m.serial_id = sn.serial_id
        WHERE $where
    ");
    $countStmt->execute($params);
    $totalRows = (int) $countStmt->fetchColumn();

    // Aggregate summary (not paginated)
    $summaryStmt = $pdo->prepare("
        SELECT COUNT(*) AS total_moves, COUNT(DISTINCT m.serial_id) AS distinct_assets
        FROM inv_asset_movements m
        JOIN inv_serial_numbers sn ON m.serial_id = sn.serial_id
        WHERE $where
    ");
    $summaryStmt->execute($params);
    $summary = $summaryStmt->fetch(PDO::FETCH_ASSOC);
    $totalMoves    = (int) ($summary['total_moves']     ?? 0);
    $distinctAssets = (int) ($summary['distinct_assets'] ?? 0);

    $stmt = $pdo->prepare("
        SELECT
            m.movement_id, m.moved_at, m.movement_reason, m.notes,
            sn.serial_id, sn.serial_number, sn.dgc_asset_number, sn.lifecycle_status,
            i.item_id, i.item_code, i.item_name,
            fl.location_code AS from_location_code,
            tl.location_code AS to_location_code,
            u.full_name AS moved_by_name
        FROM inv_asset_movements m
        JOIN inv_serial_numbers sn ON m.serial_id = sn.serial_id
        JOIN inv_items i ON sn.item_id = i.item_id
        LEFT JOIN inv_locations fl ON m.from_location_id = fl.location_id
        LEFT JOIN inv_locations tl ON m.to_location_id = tl.location_id
        LEFT JOIN users u ON m.moved_by = u.user_id
        WHERE $where
        ORDER BY m.moved_at DESC
        LIMIT $perPage OFFSET $offset
    ");
    $stmt->execute($params);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
} else {
    extract(getPaginationParams(25));
}

$statusOptions = ['ORDERED','RECEIVED','ASSIGNED','IN_SERVICE','UNDER_REPAIR','TRANSFERRED','DISPOSED','LOST_STOLEN'];

$pdfUrl = '/inventory/reports/export_pdf.php?report=asset_movement&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-left-right"></i> Asset Movement Register</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<?php if (!$serialTableReady): ?>
<div class="alert alert-warning">
    Serialized asset tracking is not available. Run migration <code>migrations/022_assets_category_serial_tracking.sql</code> first.
</div>
<?php elseif (!$movementTableReady): ?>
<div class="alert alert-info">
    Asset movement history is not available yet. Run migration <code>migrations/2026_05_26_asset_room_registry_and_movement.sql</code> to enable this report.
</div>
<?php else: ?>

<form class="row g-2 mb-3">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to" class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-4">
        <select name="serial_id" class="form-select">
            <option value="">All Serialized Assets</option>
            <?php foreach ($serialOptions as $opt): ?>
            <option value="<?= (int) $opt['serial_id'] ?>" <?= $serialFilter === (int) $opt['serial_id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($opt['serial_number'] . ' — ' . $opt['item_code'] . ' ' . $opt['item_name']) ?>
            </option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="status" class="form-select">
            <option value="">All Lifecycle Statuses</option>
            <?php foreach ($statusOptions as $st): ?>
            <option value="<?= $st ?>" <?= $statusFilter === $st ? 'selected' : '' ?>><?= str_replace('_', ' ', $st) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-1"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i></button></div>
    <div class="col-md-1"><a href="/inventory/reports/asset_movement_register.php" class="btn btn-outline-secondary w-100">Reset</a></div>
</form>

<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-primary bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0"><?= number_format($totalMoves) ?></h4>
                <small class="text-muted">Movement Entries</small>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm bg-info bg-opacity-10">
            <div class="card-body text-center">
                <h4 class="mb-0"><?= number_format($distinctAssets) ?></h4>
                <small class="text-muted">Assets Moved</small>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card border-0 shadow-sm bg-light">
            <div class="card-body py-3">
                <small class="text-muted">
                    Showing movements from <strong><?= htmlspecialchars($dateFrom) ?></strong> to
                    <strong><?= htmlspecialchars($dateTo) ?></strong>.
                </small>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>Moved At</th>
                        <th>Asset</th>
                        <th>Item</th>
                        <th>From</th>
                        <th>To</th>
                        <th>Status</th>
                        <th>Reason</th>
                        <th>By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No movement records found for the selected filters.</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($r['moved_at'])) ?></td>
                        <td>
                            <code><?= htmlspecialchars($r['serial_number']) ?></code><br>
                            <small class="text-muted">DGC: <?= htmlspecialchars($r['dgc_asset_number'] ?? '—') ?></small>
                        </td>
                        <td>
                            <a href="/inventory/items/view.php?id=<?= (int) $r['item_id'] ?>" class="text-decoration-none">
                                <code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?>
                            </a>
                        </td>
                        <td><?= htmlspecialchars($r['from_location_code'] ?? '—') ?></td>
                        <td><?= htmlspecialchars($r['to_location_code'] ?? '—') ?></td>
                        <td><span class="badge bg-secondary"><?= htmlspecialchars(str_replace('_', ' ', $r['lifecycle_status'])) ?></span></td>
                        <td>
                            <?= htmlspecialchars($r['movement_reason'] ?? '—') ?>
                            <?php if (!empty($r['notes'])): ?>
                            <br><small class="text-muted"><?= htmlspecialchars(mb_substr($r['notes'], 0, 70)) ?></small>
                            <?php endif; ?>
                        </td>
                        <td><?= htmlspecialchars($r['moved_by_name'] ?? '—') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
