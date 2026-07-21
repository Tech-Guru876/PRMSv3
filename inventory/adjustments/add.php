<?php
$REQUIRE_PERMISSION = 'adjust_stock';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);

$reasonCodes = ['DAMAGE','EXPIRY','THEFT','COUNTING_ERROR','SYSTEM_ERROR','OBSOLESCENCE','QUALITY_ISSUE','NATURAL_LOSS','FOUND_SURPLUS','OTHER'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $adjType    = $_POST['adjustment_type'] ?? 'LOSS';
        $locationId = (int) ($_POST['location_id'] ?? 0);
        $reasonCode = $_POST['reason_code'] ?? '';
        $description = trim($_POST['description'] ?? '');
        $notes      = trim($_POST['notes'] ?? '');

        if ($locationId <= 0) throw new Exception("Location is required.");
        if (empty($reasonCode)) throw new Exception("Reason code is required.");

        $itemIds = $_POST['item_id'] ?? [];
        $qtys    = $_POST['quantity'] ?? [];
        if (empty($itemIds) || count(array_filter($itemIds)) === 0) throw new Exception("At least one item is required.");

        $adjNumber = InventoryService::generateDocNumber($pdo, 'ADJ', 'inv_adjustments', 'adjustment_number');

        $pdo->prepare("INSERT INTO inv_adjustments
            (adjustment_number, adjustment_type, location_id, reason_code, reason_detail, notes,
             requested_by, status, created_at)
            VALUES (?,?,?,?,?,?,?,?,NOW())")
            ->execute([$adjNumber, $adjType, $locationId, $reasonCode, $description, $notes,
                $_SESSION['user_id'], 'PENDING_APPROVAL']);

        $adjId = $pdo->lastInsertId();

        $insertItem = $pdo->prepare("INSERT INTO inv_adjustment_items
            (adjustment_id, item_id, quantity_system, quantity_actual, quantity_variance)
            VALUES (?,?,?,?,?)");

        for ($i = 0; $i < count($itemIds); $i++) {
            $iid = (int) ($itemIds[$i] ?? 0);
            if ($iid <= 0) continue;
            $qty = (float) ($qtys[$i] ?? 0);
            if ($qty <= 0) continue;

            $systemQty = InventoryService::getStockLevel($pdo, $iid, $locationId);
            $actualQty = $adjType === 'GAIN' ? $systemQty + $qty : $systemQty - $qty;
            $variance  = $actualQty - $systemQty;

            $insertItem->execute([$adjId, $iid, $systemQty, $actualQty, $variance]);
        }

        logInventoryAudit($pdo, 'inv_adjustments', $adjId, 'CREATED', "Adjustment $adjNumber ($adjType) - $reasonCode");
        $pdo->commit();
        pop("Adjustment $adjNumber submitted for approval.", "/inventory/adjustments/view.php?id=$adjId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-sliders"></i> New Stock Adjustment</h2>
    <a href="/inventory/adjustments/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Adjustment Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Adjustment Type <span class="text-danger">*</span></label>
                    <select name="adjustment_type" class="form-select" required>
                        <option value="LOSS">Loss (Decrease)</option>
                        <option value="GAIN">Gain (Increase)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Location <span class="text-danger">*</span></label>
                    <select name="location_id" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' - ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Reason Code <span class="text-danger">*</span></label>
                    <select name="reason_code" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($reasonCodes as $rc): ?>
                        <option value="<?= $rc ?>"><?= str_replace('_', ' ', $rc) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Description</label>
                    <input type="text" name="description" class="form-control">
                </div>
                <div class="col-12">
                    <label class="form-label">Notes / Investigation Details</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-list-ol"></i> Items</span>
            <button type="button" class="btn btn-sm btn-light" onclick="addAdjRow()"><i class="bi bi-plus"></i> Add Row</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0">
                    <thead class="table-light">
                        <tr><th>Item <span class="text-danger">*</span></th><th>Adjustment Quantity <span class="text-danger">*</span></th><th></th></tr>
                    </thead>
                    <tbody id="adjBody">
                        <tr>
                            <td>
                                <select name="item_id[]" class="form-select form-select-sm" required>
                                    <option value="">--</option>
                                    <?php foreach ($items as $it): ?>
                                    <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' - ' . $it['item_name']) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><input type="number" step="0.01" name="quantity[]" class="form-control form-control-sm text-end" required></td>
                            <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()"><i class="bi bi-trash"></i></button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-send"></i> Submit for Approval</button>
</form>

<script>
function addAdjRow() {
    const tbody = document.getElementById('adjBody');
    const row = tbody.querySelector('tr').cloneNode(true);
    row.querySelectorAll('input').forEach(i => i.value = '');
    row.querySelectorAll('select').forEach(s => s.selectedIndex = 0);
    tbody.appendChild(row);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
