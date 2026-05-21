<?php
$REQUIRE_PERMISSION = 'manage_returns';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);

// GRNs for linking
$grns = $pdo->query("SELECT grn_id, grn_number, supplier_name FROM inv_goods_received ORDER BY grn_id DESC LIMIT 200")->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $returnType = $_POST['return_type'] ?? 'DEFECTIVE';
        $grnId = (int) ($_POST['grn_id'] ?? 0) ?: null;
        $supplierName = trim($_POST['supplier_name'] ?? '');
        $fromLocationId = (int) ($_POST['from_location_id'] ?? 0) ?: null;
        $reason = trim($_POST['reason'] ?? '');
        $rmaNumber = trim($_POST['rma_number'] ?? '') ?: null;
        $debitNoteNumber = trim($_POST['debit_note_number'] ?? '') ?: null;
        $notes = trim($_POST['notes'] ?? '') ?: null;

        if (empty($reason)) throw new Exception("Reason is required.");
        if (empty($supplierName)) throw new Exception("Supplier name is required.");
        if (!in_array($returnType, ['DEFECTIVE','WRONG_ITEM','EXCESS','WARRANTY','OTHER'])) {
            throw new Exception("Invalid return type.");
        }

        // Get supplier vendor ID from GRN if linked
        $supplierVendorId = null;
        if ($grnId) {
            $grnData = $pdo->prepare("SELECT supplier_vendor_id, supplier_name FROM inv_goods_received WHERE grn_id = ?");
            $grnData->execute([$grnId]);
            $grnData = $grnData->fetch(PDO::FETCH_ASSOC);
            if ($grnData) {
                $supplierVendorId = $grnData['supplier_vendor_id'];
                if (empty($supplierName)) $supplierName = $grnData['supplier_name'];
            }
        }

        $returnNumber = generateReturnNumber($pdo);

        // Parse line items
        $lineItems = $_POST['line_item_id'] ?? [];
        $lineQtys = $_POST['line_quantity'] ?? [];
        $lineBatches = $_POST['line_batch'] ?? [];
        $lineSerials = $_POST['line_serial'] ?? [];
        $lineReasons = $_POST['line_reason'] ?? [];
        $lineCosts = $_POST['line_unit_cost'] ?? [];

        if (empty($lineItems)) throw new Exception("At least one line item is required.");

        $pdo->prepare("INSERT INTO inv_returns
            (return_number, grn_id, supplier_vendor_id, supplier_name, reason, return_type,
             status, requested_by, debit_note_number, rma_number, from_location_id, notes)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")
            ->execute([$returnNumber, $grnId, $supplierVendorId, $supplierName, $reason, $returnType,
                'DRAFT', $_SESSION['user_id'], $debitNoteNumber, $rmaNumber, $fromLocationId, $notes]);
        $returnId = (int) $pdo->lastInsertId();

        $lineInsert = $pdo->prepare("INSERT INTO inv_return_items (return_id, item_id, quantity, batch_lot_number, serial_number, reason, unit_cost) VALUES (?,?,?,?,?,?,?)");
        foreach ($lineItems as $idx => $itemId) {
            $itemId = (int) $itemId;
            $qty = (float) ($lineQtys[$idx] ?? 0);
            if ($itemId <= 0 || $qty <= 0) continue;
            $lineInsert->execute([
                $returnId, $itemId, $qty,
                trim($lineBatches[$idx] ?? '') ?: null,
                trim($lineSerials[$idx] ?? '') ?: null,
                trim($lineReasons[$idx] ?? '') ?: null,
                (float) ($lineCosts[$idx] ?? 0)
            ]);
        }

        logInventoryAudit($pdo, 'inv_returns', $returnId, 'CREATED', "Return $returnNumber created");

        $pdo->commit();
        pop("Return $returnNumber created.", "/inventory/returns/view.php?id=$returnId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-return-left"></i> New Return to Supplier</h2>
    <a href="/inventory/returns/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <form method="POST" id="returnForm">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Return Type *</label>
                    <select name="return_type" class="form-select" required>
                        <option value="DEFECTIVE">Defective</option>
                        <option value="WRONG_ITEM">Wrong Item</option>
                        <option value="EXCESS">Excess</option>
                        <option value="WARRANTY">Warranty</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Link to GRN</label>
                    <select name="grn_id" class="form-select" id="grnSelect">
                        <option value="">None</option>
                        <?php foreach ($grns as $g): ?>
                        <option value="<?= $g['grn_id'] ?>" data-supplier="<?= htmlspecialchars($g['supplier_name']) ?>"><?= htmlspecialchars($g['grn_number'] . ' — ' . $g['supplier_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Supplier Name *</label>
                    <input type="text" name="supplier_name" id="supplierName" class="form-control" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">From Location</label>
                    <select name="from_location_id" class="form-select">
                        <option value="">Select location...</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' — ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">RMA Number</label>
                    <input type="text" name="rma_number" class="form-control" placeholder="Return Merchandise Authorization">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Debit Note Number</label>
                    <input type="text" name="debit_note_number" class="form-control">
                </div>
                <div class="col-12">
                    <label class="form-label">Return Reason *</label>
                    <textarea name="reason" class="form-control" rows="3" required></textarea>
                </div>
                <div class="col-12">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>

            <hr>
            <h5>Line Items</h5>
            <div id="lineItems">
                <div class="row g-2 mb-2 line-row">
                    <div class="col-md-3">
                        <select name="line_item_id[]" class="form-select form-select-sm" required>
                            <option value="">Item...</option>
                            <?php foreach ($items as $it): ?>
                            <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' — ' . $it['item_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-2"><input type="number" step="0.01" min="0.01" name="line_quantity[]" class="form-control form-control-sm" placeholder="Qty" required></div>
                    <div class="col-md-2"><input type="number" step="0.01" name="line_unit_cost[]" class="form-control form-control-sm" placeholder="Unit cost"></div>
                    <div class="col-md-2"><input type="text" name="line_batch[]" class="form-control form-control-sm" placeholder="Batch/Lot"></div>
                    <div class="col-md-1"><input type="text" name="line_serial[]" class="form-control form-control-sm" placeholder="Serial"></div>
                    <div class="col-md-2"><input type="text" name="line_reason[]" class="form-control form-control-sm" placeholder="Reason"></div>
                </div>
            </div>
            <button type="button" class="btn btn-sm btn-outline-secondary mb-3" onclick="addLine()"><i class="bi bi-plus"></i> Add Line</button>

            <div class="mt-3">
                <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-save"></i> Create Return</button>
            </div>
        </form>
    </div>
</div>

<script>
document.getElementById('grnSelect').addEventListener('change', function() {
    const opt = this.options[this.selectedIndex];
    if (opt.dataset.supplier) document.getElementById('supplierName').value = opt.dataset.supplier;
});

function addLine() {
    const container = document.getElementById('lineItems');
    const first = container.querySelector('.line-row');
    const clone = first.cloneNode(true);
    clone.querySelectorAll('input, select').forEach(el => el.value = '');
    container.appendChild(clone);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
