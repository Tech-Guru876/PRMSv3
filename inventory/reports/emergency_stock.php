<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

// Emergency / contingency items are tagged with risk class EMERG_RESERVE
$locationF = (int) ($_GET['location_id'] ?? 0);

$stockLocFilter = '';
$params = [];
if ($locationF > 0) {
    $stockLocFilter = " AND s.location_id = ?";
    $params[]       = $locationF;
}

extract(getPaginationParams(25));

$rows = [];
$locations = [];
$reportError = null;
try {
    $countStmt = $pdo->prepare("
        SELECT COUNT(*) FROM (
            SELECT i.item_id, l.location_id
            FROM inv_items i
            JOIN inv_item_risk_classes irc ON i.item_id = irc.item_id
            JOIN inv_risk_classes rc ON irc.risk_class_id = rc.risk_class_id
            LEFT JOIN inv_stock s ON i.item_id = s.item_id
                AND s.stock_status = 'USABLE'
                $stockLocFilter
            LEFT JOIN inv_locations l ON s.location_id = l.location_id
            WHERE rc.risk_code = 'EMERG_RESERVE'
              AND i.item_status = 'ACTIVE'
            GROUP BY i.item_id, l.location_id
        ) cnt_sub
    ");
    $countStmt->execute($params);
    $totalRows = (int) $countStmt->fetchColumn();

    $totalsStmt = $pdo->prepare("
        SELECT COALESCE(SUM(stock_val), 0)
        FROM (
            SELECT COALESCE(SUM(s.quantity_on_hand * s.unit_cost), 0) AS stock_val
            FROM inv_items i
            JOIN inv_item_risk_classes irc ON i.item_id = irc.item_id
            JOIN inv_risk_classes rc ON irc.risk_class_id = rc.risk_class_id
            LEFT JOIN inv_stock s ON i.item_id = s.item_id
                AND s.stock_status = 'USABLE'
                $stockLocFilter
            WHERE rc.risk_code = 'EMERG_RESERVE'
              AND i.item_status = 'ACTIVE'
            GROUP BY i.item_id
        ) vals
    ");
    $totalsStmt->execute($params);
    $totalValue = (float) $totalsStmt->fetchColumn();

    $rowsStmt = $pdo->prepare("
        SELECT i.item_id, i.item_code, i.item_name, i.min_level, i.max_level,
               i.safety_stock, i.reorder_level,
               c.category_name, u.uom_code,
               l.location_code,
               COALESCE(SUM(s.quantity_on_hand), 0) AS qty_on_hand,
               COALESCE(SUM(s.quantity_on_hand * s.unit_cost), 0) AS stock_value,
               cr.criticality_name
        FROM inv_items i
        JOIN inv_item_risk_classes irc ON i.item_id = irc.item_id
        JOIN inv_risk_classes rc ON irc.risk_class_id = rc.risk_class_id
        LEFT JOIN inv_categories c ON i.category_id = c.category_id
        LEFT JOIN inv_units_of_measure u ON i.uom_id = u.uom_id
        LEFT JOIN inv_criticality_classes cr ON i.criticality_id = cr.criticality_id
        LEFT JOIN inv_stock s ON i.item_id = s.item_id
            AND s.stock_status = 'USABLE'
            $stockLocFilter
        LEFT JOIN inv_locations l ON s.location_id = l.location_id
        WHERE rc.risk_code = 'EMERG_RESERVE'
          AND i.item_status = 'ACTIVE'
        GROUP BY i.item_id, l.location_id
        ORDER BY COALESCE(qty_on_hand / NULLIF(i.safety_stock, 0), 0) ASC, i.item_code
        LIMIT $perPage OFFSET $offset
    ");
    $rowsStmt->execute($params);
    $rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);
    $locations = $pdo->query("SELECT location_id, location_code FROM inv_locations WHERE is_active=1 ORDER BY location_code")->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $totalRows = 0; $totalValue = 0;
    $reportError = 'Emergency stock data is temporarily unavailable.';
    error_log('emergency_stock report error: ' . $e->getMessage());
}

$pdfUrl = '/inventory/reports/export_pdf.php?report=emergency_stock&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-shield-fill-check"></i> Emergency &amp; Contingency Stock Report</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<?php if ($reportError): ?>
<div class="alert alert-warning"><?= htmlspecialchars($reportError) ?></div>
<?php endif; ?>

<div class="alert alert-warning">
    <i class="bi bi-exclamation-triangle"></i>
    Shows items tagged as <strong>Emergency Reserve / Contingency Stock</strong>.
    Items below safety stock level are highlighted.
    Total reserve value: <strong>$<?= number_format($totalValue, 2) ?></strong>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-3">
        <select name="location_id" class="form-select">
            <option value="">All Locations</option>
            <?php foreach ($locations as $loc): ?>
            <option value="<?= $loc['location_id'] ?>" <?= $locationF == $loc['location_id'] ? 'selected' : '' ?>><?= htmlspecialchars($loc['location_code']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-dark">
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>Criticality</th>
                        <th>Location</th>
                        <th>UOM</th>
                        <th class="text-end">Safety Stock</th>
                        <th class="text-end">Min Level</th>
                        <th class="text-end">Qty on Hand</th>
                        <th class="text-end">Value</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="11" class="text-center text-muted py-4">No emergency reserve items found</td></tr>
                    <?php else: foreach ($rows as $r):
                        $belowSafety = $r['qty_on_hand'] < $r['safety_stock'];
                        $belowMin    = $r['qty_on_hand'] < $r['min_level'];
                    ?>
                    <tr class="<?= $belowMin ? 'table-danger' : ($belowSafety ? 'table-warning' : '') ?>">
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['category_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['criticality_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? 'All') ?></td>
                        <td><?= htmlspecialchars($r['uom_code'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($r['safety_stock'], 2) ?></td>
                        <td class="text-end"><?= number_format($r['min_level'], 2) ?></td>
                        <td class="text-end fw-bold <?= $belowMin ? 'text-danger' : ($belowSafety ? 'text-warning' : 'text-success') ?>">
                            <?= number_format($r['qty_on_hand'], 2) ?>
                        </td>
                        <td class="text-end">$<?= number_format($r['stock_value'], 2) ?></td>
                        <td>
                            <?php if ($belowMin): ?>
                                <span class="badge bg-danger">CRITICAL LOW</span>
                            <?php elseif ($belowSafety): ?>
                                <span class="badge bg-warning text-dark">Below Safety</span>
                            <?php else: ?>
                                <span class="badge bg-success">Adequate</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if ($totalRows > 0): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="9" class="text-end fw-bold">Total Reserve Value:</td>
                        <td class="text-end fw-bold">$<?= number_format($totalValue, 2) ?></td>
                        <td></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
