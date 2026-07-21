<?php
$REQUIRE_PERMISSION = 'manage_write_downs';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name, unit_cost FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $itemId = (int) ($_POST['item_id'] ?? 0);
        $locationId = (int) ($_POST['location_id'] ?? 0) ?: null;
        $reason = $_POST['reason'] ?? 'NRV_DECLINE';
        $originalCost = (float) ($_POST['original_cost'] ?? 0);
        $nrvValue = (float) ($_POST['nrv_value'] ?? 0);
        $notes = trim($_POST['notes'] ?? '') ?: null;

        if ($itemId <= 0) throw new Exception("Item is required.");
        $validReasons = ['NRV_DECLINE','OBSOLESCENCE','DAMAGE','EXPIRY','OTHER'];
        if (!in_array($reason, $validReasons)) throw new Exception("Invalid reason.");
        if ($originalCost <= 0) throw new Exception("Original cost must be greater than 0.");
        if ($nrvValue < 0) throw new Exception("NRV cannot be negative.");
        if ($nrvValue >= $originalCost) throw new Exception("NRV must be less than original cost for a write-down.");

        $writeDownAmount = $originalCost - $nrvValue;
        $wdNumber = generateWriteDownNumber($pdo);

        $pdo->prepare("INSERT INTO inv_write_downs
            (write_down_number, item_id, location_id, reason, original_cost, nrv_value, write_down_amount,
             status, requested_by, notes)
            VALUES (?,?,?,?,?,?,?,?,?,?)")
            ->execute([$wdNumber, $itemId, $locationId, $reason, $originalCost, $nrvValue, $writeDownAmount,
                'DRAFT', $_SESSION['user_id'], $notes]);
        $wdId = (int) $pdo->lastInsertId();

        logInventoryAudit($pdo, 'inv_write_downs', $wdId, 'CREATED', "Write-down $wdNumber: \$$writeDownAmount ($reason)");

        $pdo->commit();
        pop("Write-down $wdNumber created.", "/inventory/writedowns/view.php?id=$wdId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-graph-down-arrow"></i> New Write-Down (NRV)</h2>
    <a href="/inventory/writedowns/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="alert alert-info">
    <strong>IPSAS 12 — Lower of Cost and NRV:</strong> Inventories shall be measured at the lower of cost and net realisable value, except where held for distribution at no charge or for a nominal charge.
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body">
        <form method="POST">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Item *</label>
                    <select name="item_id" class="form-select" required id="itemSelect">
                        <option value="">Select item...</option>
                        <?php foreach ($items as $it): ?>
                        <option value="<?= $it['item_id'] ?>" data-cost="<?= $it['unit_cost'] ?>"><?= htmlspecialchars($it['item_code'] . ' — ' . $it['item_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Location</label>
                    <select name="location_id" class="form-select">
                        <option value="">All locations (item-level)</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' — ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Reason *</label>
                    <select name="reason" class="form-select" required>
                        <option value="NRV_DECLINE">NRV Decline</option>
                        <option value="OBSOLESCENCE">Obsolescence</option>
                        <option value="DAMAGE">Damage</option>
                        <option value="EXPIRY">Expiry</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Original (Carrying) Cost *</label>
                    <input type="number" step="0.01" min="0.01" name="original_cost" id="originalCost" class="form-control" required oninput="calcWriteDown()">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Net Realisable Value (NRV) *</label>
                    <input type="number" step="0.01" min="0" name="nrv_value" id="nrvValue" class="form-control" required oninput="calcWriteDown()">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Write-Down Amount</label>
                    <input type="text" id="writeDownDisplay" class="form-control fw-bold text-danger" readonly>
                </div>
                <div class="col-12">
                    <label class="form-label">Notes / Justification</label>
                    <textarea name="notes" class="form-control" rows="3" placeholder="Provide details and supporting evidence for this write-down..."></textarea>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-save"></i> Create Write-Down</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
document.getElementById('itemSelect').addEventListener('change', function() {
    const opt = this.options[this.selectedIndex];
    if (opt.dataset.cost) document.getElementById('originalCost').value = parseFloat(opt.dataset.cost).toFixed(2);
    calcWriteDown();
});
function calcWriteDown() {
    const cost = parseFloat(document.getElementById('originalCost').value) || 0;
    const nrv = parseFloat(document.getElementById('nrvValue').value) || 0;
    const wd = Math.max(0, cost - nrv);
    document.getElementById('writeDownDisplay').value = '$' + wd.toFixed(2);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
