<?php
$REQUIRE_PERMISSION = 'conduct_stock_count';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);
$countTypes = ['FULL','CYCLE','SPOT','ANNUAL'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $countType  = $_POST['count_type']  ?? 'FULL';
        $locationId = (int) ($_POST['location_id'] ?? 0);
        $countDate  = $_POST['count_date'] ?? date('Y-m-d');
        $notes      = trim($_POST['notes'] ?? '');

        if ($locationId <= 0) throw new Exception("Location is required.");

        $countNumber = InventoryService::generateDocNumber($pdo, 'CNT', 'inv_stock_counts', 'count_number');

        $pdo->prepare("INSERT INTO inv_stock_counts
            (count_number, count_type, location_id, count_date, count_lead, notes, status, created_at)
            VALUES (?,?,?,?,?,?,?,NOW())")
            ->execute([$countNumber, $countType, $locationId, $countDate, $_SESSION['user_id'], $notes, 'IN_PROGRESS']);

        $countId = $pdo->lastInsertId();

        // Pre-populate with all items at selected location
        $stockItems = $pdo->prepare("
            SELECT sl.item_id, sl.quantity_on_hand
            FROM inv_stock sl
            WHERE sl.location_id = ? AND sl.quantity_on_hand > 0
        ");
        $stockItems->execute([$locationId]);

        $insertLine = $pdo->prepare("INSERT INTO inv_stock_count_items
            (count_id, item_id, system_quantity, counted_quantity, variance_quantity)
            VALUES (?,?,?,NULL,NULL)");

        $itemCount = 0;
        while ($si = $stockItems->fetch(PDO::FETCH_ASSOC)) {
            $insertLine->execute([$countId, $si['item_id'], $si['quantity_on_hand']]);
            $itemCount++;
        }

        if ($itemCount === 0) {
            throw new Exception("No stock items found at the selected location.");
        }

        logInventoryAudit($pdo, 'inv_stock_counts', $countId, 'CREATED', "Stock count $countNumber started ($itemCount items)");
        $pdo->commit();
        pop("Stock count $countNumber started with $itemCount items.", "/inventory/stocktake/view.php?id=$countId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clipboard-data"></i> New Stock Count</h2>
    <a href="/inventory/stocktake/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Count Setup</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Count Type <span class="text-danger">*</span></label>
                    <select name="count_type" class="form-select" required>
                        <?php foreach ($countTypes as $ct): ?>
                        <option value="<?= $ct ?>"><?= $ct ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Location <span class="text-danger">*</span></label>
                    <select name="location_id" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' - ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Count Date <span class="text-danger">*</span></label>
                    <input type="date" name="count_date" class="form-control" required value="<?= date('Y-m-d') ?>">
                </div>
                <div class="col-12">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>
        </div>
    </div>

    <div class="alert alert-info">
        <i class="bi bi-info-circle"></i> Starting a count will auto-populate the count sheet with all items at the selected location.
        You can then enter actual counted quantities from the count detail page.
    </div>

    <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-play-circle"></i> Start Count</button>
</form>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
