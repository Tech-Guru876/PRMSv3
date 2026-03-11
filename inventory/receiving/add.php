<?php
$REQUIRE_PERMISSION = 'receive_goods';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$editId = (int) ($_GET['id'] ?? 0);
$isEdit = $editId > 0;
$grn = null;
$grnItems = [];

if ($isEdit) {
    $grn = $pdo->prepare("SELECT * FROM inv_goods_received_notes WHERE grn_id = ?");
    $grn->execute([$editId]);
    $grn = $grn->fetch(PDO::FETCH_ASSOC);
    if (!$grn || !in_array($grn['status'], ['DRAFT','INSPECTION'])) {
        pop("Cannot edit completed/cancelled GRN.", "/inventory/receiving/list.php", 1800, 'warning');
        exit;
    }
    $gi = $pdo->prepare("SELECT * FROM inv_grn_items WHERE grn_id = ?");
    $gi->execute([$editId]);
    $grnItems = $gi->fetchAll(PDO::FETCH_ASSOC);
}

/* Items list for selection */
$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name, location_code")->fetchAll(PDO::FETCH_ASSOC);

/* Handle POST */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $poNumber       = trim($_POST['po_number'] ?? '');
        $supplierName   = trim($_POST['supplier_name'] ?? '');
        $deliveryNote   = trim($_POST['delivery_note_number'] ?? '');
        $invoiceNo      = trim($_POST['invoice_number'] ?? '');
        $receivedDate   = $_POST['received_date'] ?? date('Y-m-d');
        $locationId     = (int) ($_POST['receiving_location_id'] ?? 0);
        $donorInfo      = trim($_POST['donor_info'] ?? '');
        $isNonExchange  = isset($_POST['is_non_exchange_transaction']) ? 1 : 0;
        $notes          = trim($_POST['notes'] ?? '');
        $statusAction   = $_POST['status_action'] ?? 'DRAFT';

        if (empty($supplierName)) throw new Exception("Supplier name is required.");
        if ($locationId <= 0) throw new Exception("Receiving location is required.");

        $itemIds   = $_POST['item_id']   ?? [];
        $qtys      = $_POST['qty_received'] ?? [];
        $lots      = $_POST['lot_number'] ?? [];
        $batches   = $_POST['batch_number'] ?? [];
        $serials   = $_POST['serial_number'] ?? [];
        $expiries  = $_POST['expiry_date'] ?? [];
        $unitCosts = $_POST['unit_cost'] ?? [];
        $conditions = $_POST['condition_on_receipt'] ?? [];

        if (empty($itemIds) || count(array_filter($itemIds)) === 0) {
            throw new Exception("At least one item must be added.");
        }

        if ($isEdit) {
            $pdo->prepare("UPDATE inv_goods_received_notes SET
                po_number=?, supplier_name=?, delivery_note_number=?, invoice_number=?,
                received_date=?, receiving_location_id=?, donor_info=?, is_non_exchange_transaction=?,
                notes=?, status=?, updated_at=NOW()
                WHERE grn_id=?")
                ->execute([$poNumber, $supplierName, $deliveryNote, $invoiceNo,
                    $receivedDate, $locationId, $donorInfo, $isNonExchange,
                    $notes, $statusAction, $editId]);
            $grnId = $editId;
            $pdo->prepare("DELETE FROM inv_grn_items WHERE grn_id = ?")->execute([$grnId]);
        } else {
            $grnNumber = InventoryService::generateDocNumber($pdo, 'GRN', 'inv_goods_received_notes', 'grn_number');
            $pdo->prepare("INSERT INTO inv_goods_received_notes
                (grn_number, po_number, supplier_name, delivery_note_number, invoice_number,
                 received_date, received_by, receiving_location_id, donor_info,
                 is_non_exchange_transaction, notes, status, created_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,NOW())")
                ->execute([$grnNumber, $poNumber, $supplierName, $deliveryNote, $invoiceNo,
                    $receivedDate, $_SESSION['user_id'], $locationId, $donorInfo,
                    $isNonExchange, $notes, $statusAction]);
            $grnId = $pdo->lastInsertId();
        }

        // Insert line items
        $insertItem = $pdo->prepare("INSERT INTO inv_grn_items
            (grn_id, item_id, quantity_expected, quantity_received, quantity_accepted, quantity_rejected,
             lot_number, batch_number, serial_number, expiry_date, unit_cost, condition_on_receipt)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");

        for ($i = 0; $i < count($itemIds); $i++) {
            $iid = (int) ($itemIds[$i] ?? 0);
            if ($iid <= 0) continue;
            $qr = (float) ($qtys[$i] ?? 0);
            if ($qr <= 0) continue;
            $uc = (float) ($unitCosts[$i] ?? 0);
            $cond = $conditions[$i] ?? 'GOOD';
            $qa = $cond === 'GOOD' ? $qr : 0;
            $qrej = $cond === 'REJECTED' ? $qr : 0;
            $exp = !empty($expiries[$i]) ? $expiries[$i] : null;

            $insertItem->execute([
                $grnId, $iid, $qr, $qr, $qa, $qrej,
                $lots[$i] ?? null, $batches[$i] ?? null, $serials[$i] ?? null,
                $exp, $uc, $cond
            ]);
        }

        // If completing, update stock levels
        if ($statusAction === 'COMPLETED') {
            foreach ($itemIds as $idx => $iid) {
                $iid = (int) $iid;
                if ($iid <= 0) continue;
                $qr = (float) ($qtys[$idx] ?? 0);
                $cond = $conditions[$idx] ?? 'GOOD';
                if ($qr <= 0 || $cond === 'REJECTED') continue;

                InventoryService::updateStockLevel($pdo, $iid, $locationId, $qr, 'add');
                InventoryService::recordTransaction($pdo, $iid, $locationId, 'RECEIPT', $qr, $grnId, 'inv_goods_received_notes',
                    "GRN receipt from $supplierName", $_SESSION['user_id'],
                    $lots[$idx] ?? null, $batches[$idx] ?? null, $serials[$idx] ?? null,
                    !empty($expiries[$idx]) ? $expiries[$idx] : null);
            }
        }

        logInventoryAudit($pdo, 'inv_goods_received_notes', $grnId, $isEdit ? 'UPDATED' : 'CREATED', "GRN $statusAction");
        $pdo->commit();
        pop($isEdit ? "GRN updated." : "GRN created.", "/inventory/receiving/view.php?id=$grnId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-seam"></i> <?= $isEdit ? 'Edit' : 'New' ?> Goods Received Note</h2>
    <a href="/inventory/receiving/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST" id="grnForm">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> GRN Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">PO Number</label>
                    <input type="text" name="po_number" class="form-control" value="<?= htmlspecialchars($grn['po_number'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Supplier Name <span class="text-danger">*</span></label>
                    <input type="text" name="supplier_name" class="form-control" required value="<?= htmlspecialchars($grn['supplier_name'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Delivery Note #</label>
                    <input type="text" name="delivery_note_number" class="form-control" value="<?= htmlspecialchars($grn['delivery_note_number'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Invoice #</label>
                    <input type="text" name="invoice_number" class="form-control" value="<?= htmlspecialchars($grn['invoice_number'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Received Date <span class="text-danger">*</span></label>
                    <input type="date" name="received_date" class="form-control" required value="<?= htmlspecialchars($grn['received_date'] ?? date('Y-m-d')) ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Receiving Location <span class="text-danger">*</span></label>
                    <select name="receiving_location_id" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>" <?= ($grn['receiving_location_id'] ?? '') == $loc['location_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($loc['location_code'] . ' - ' . $loc['site_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Donor Information (for non-exchange transactions)</label>
                    <input type="text" name="donor_info" class="form-control" value="<?= htmlspecialchars($grn['donor_info'] ?? '') ?>">
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="is_non_exchange_transaction" id="nonExch" <?= ($grn['is_non_exchange_transaction'] ?? 0) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="nonExch">Non-Exchange Transaction</label>
                    </div>
                </div>
                <div class="col-12">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2"><?= htmlspecialchars($grn['notes'] ?? '') ?></textarea>
                </div>
            </div>
        </div>
    </div>

    <!-- Line Items -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-list-ol"></i> Received Items</span>
            <button type="button" class="btn btn-sm btn-light" onclick="addRow()"><i class="bi bi-plus"></i> Add Row</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0" id="itemsTable">
                    <thead class="table-light">
                        <tr>
                            <th>Item <span class="text-danger">*</span></th>
                            <th>Lot #</th>
                            <th>Batch #</th>
                            <th>Serial #</th>
                            <th>Expiry</th>
                            <th>Qty Received <span class="text-danger">*</span></th>
                            <th>Unit Cost</th>
                            <th>Condition</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="itemsBody">
                        <?php if ($isEdit && !empty($grnItems)): foreach ($grnItems as $idx => $gi): ?>
                        <tr>
                            <td>
                                <select name="item_id[]" class="form-select form-select-sm" required>
                                    <option value="">--</option>
                                    <?php foreach ($items as $it): ?>
                                    <option value="<?= $it['item_id'] ?>" <?= $gi['item_id'] == $it['item_id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($it['item_code'] . ' - ' . $it['item_name']) ?>
                                    </option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><input type="text" name="lot_number[]" class="form-control form-control-sm" value="<?= htmlspecialchars($gi['lot_number'] ?? '') ?>"></td>
                            <td><input type="text" name="batch_number[]" class="form-control form-control-sm" value="<?= htmlspecialchars($gi['batch_number'] ?? '') ?>"></td>
                            <td><input type="text" name="serial_number[]" class="form-control form-control-sm" value="<?= htmlspecialchars($gi['serial_number'] ?? '') ?>"></td>
                            <td><input type="date" name="expiry_date[]" class="form-control form-control-sm" value="<?= $gi['expiry_date'] ?? '' ?>"></td>
                            <td><input type="number" step="0.01" name="qty_received[]" class="form-control form-control-sm text-end" required value="<?= $gi['quantity_received'] ?>"></td>
                            <td><input type="number" step="0.01" name="unit_cost[]" class="form-control form-control-sm text-end" value="<?= $gi['unit_cost'] ?? '' ?>"></td>
                            <td>
                                <select name="condition_on_receipt[]" class="form-select form-select-sm">
                                    <?php foreach (['GOOD','DAMAGED','QUARANTINE','REJECTED'] as $c): ?>
                                    <option value="<?= $c ?>" <?= ($gi['condition_on_receipt'] ?? '') === $c ? 'selected' : '' ?>><?= $c ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()"><i class="bi bi-trash"></i></button></td>
                        </tr>
                        <?php endforeach; else: ?>
                        <tr>
                            <td>
                                <select name="item_id[]" class="form-select form-select-sm" required>
                                    <option value="">--</option>
                                    <?php foreach ($items as $it): ?>
                                    <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' - ' . $it['item_name']) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><input type="text" name="lot_number[]" class="form-control form-control-sm"></td>
                            <td><input type="text" name="batch_number[]" class="form-control form-control-sm"></td>
                            <td><input type="text" name="serial_number[]" class="form-control form-control-sm"></td>
                            <td><input type="date" name="expiry_date[]" class="form-control form-control-sm"></td>
                            <td><input type="number" step="0.01" name="qty_received[]" class="form-control form-control-sm text-end" required></td>
                            <td><input type="number" step="0.01" name="unit_cost[]" class="form-control form-control-sm text-end"></td>
                            <td>
                                <select name="condition_on_receipt[]" class="form-select form-select-sm">
                                    <option value="GOOD">GOOD</option>
                                    <option value="DAMAGED">DAMAGED</option>
                                    <option value="QUARANTINE">QUARANTINE</option>
                                    <option value="REJECTED">REJECTED</option>
                                </select>
                            </td>
                            <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()"><i class="bi bi-trash"></i></button></td>
                        </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="d-flex gap-2">
        <button type="submit" name="status_action" value="DRAFT" class="btn btn-secondary"><i class="bi bi-save"></i> Save as Draft</button>
        <button type="submit" name="status_action" value="INSPECTION" class="btn btn-warning"><i class="bi bi-search"></i> Save & Send for Inspection</button>
        <button type="submit" name="status_action" value="COMPLETED" class="btn btn-success"><i class="bi bi-check-circle"></i> Complete & Update Stock</button>
    </div>
</form>

<script>
function addRow() {
    const tbody = document.getElementById('itemsBody');
    const row = tbody.querySelector('tr').cloneNode(true);
    row.querySelectorAll('input').forEach(i => i.value = '');
    row.querySelectorAll('select').forEach(s => s.selectedIndex = 0);
    tbody.appendChild(row);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
