<?php
$REQUIRE_PERMISSION = 'receive_goods';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$grnId = (int) ($_GET['id'] ?? 0);
if ($grnId <= 0) { pop("Invalid GRN.", "/inventory/receiving/list.php", 1800, 'warning'); exit; }

$grn = $pdo->prepare("
    SELECT g.*, u.full_name AS receiver_name, l.location_code, l.site_name,
           iu.full_name AS inspector_name
    FROM inv_goods_received g
    JOIN users u ON g.received_by = u.user_id
    LEFT JOIN inv_locations l ON g.receiving_location_id = l.location_id
    LEFT JOIN users iu ON g.inspected_by = iu.user_id
    WHERE g.grn_id = ?
");
$grn->execute([$grnId]);
$grn = $grn->fetch(PDO::FETCH_ASSOC);
if (!$grn) { pop("GRN not found.", "/inventory/receiving/list.php", 1800, 'warning'); exit; }

$lineItems = $pdo->prepare("
    SELECT gi.*, i.item_code, i.item_name, um.uom_code, i.inspection_required
    FROM inv_grn_items gi
    JOIN inv_items i ON gi.item_id = i.item_id
    LEFT JOIN inv_units_of_measure um ON i.uom_id = um.uom_id
    WHERE gi.grn_id = ?
");
$lineItems->execute([$grnId]);
$lineItems = $lineItems->fetchAll(PDO::FETCH_ASSOC);

/* Handle inspection and acceptance actions */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    try {
        $pdo->beginTransaction();

        if ($action === 'inspect' && has_permission('inspect_goods') && in_array($grn['status'], ['DRAFT', 'RECEIVED', 'INSPECTION'])) {
            // Update line-item inspection results
            $inspResults = $_POST['inspection_status'] ?? [];
            $inspNotes = $_POST['inspection_notes'] ?? [];
            $updateInsp = $pdo->prepare("UPDATE inv_grn_items SET inspection_status = ?, quality_notes = ? WHERE grn_item_id = ?");

            foreach ($inspResults as $itemId => $result) {
                if (in_array($result, ['PASS', 'FAIL', 'CONDITIONAL'])) {
                    $updateInsp->execute([$result, $inspNotes[$itemId] ?? null, (int) $itemId]);
                }
            }

            // Check if any items require quarantine (FAIL status)
            $inspNote = trim($_POST['overall_inspection_notes'] ?? '');
            $allPass = !in_array('FAIL', $inspResults);
            $overallResult = $allPass ? 'PASS' : 'CONDITIONAL';

            $pdo->prepare("UPDATE inv_goods_received SET
                inspected_by = ?, inspection_date = CURDATE(), inspection_result = ?,
                inspection_notes = ?, status = ?
                WHERE grn_id = ?")
                ->execute([$_SESSION['user_id'], $overallResult, $inspNote,
                    $allPass ? 'INSPECTED' : 'QUARANTINE', $grnId]);

            logInventoryAudit($pdo, 'inv_goods_received', $grnId, 'INSPECTED', "Inspection completed: $overallResult");

        } elseif ($action === 'accept' && in_array($grn['status'], ['INSPECTED', 'RECEIVED'])) {
            // Accept goods — move stock into inventory
            requireOpenPeriod($pdo);

            foreach ($lineItems as $li) {
                $acceptedQty = (float) $li['quantity_accepted'];
                if ($acceptedQty <= 0) $acceptedQty = (float) $li['quantity_received'];

                if ($acceptedQty > 0) {
                    increaseStock($pdo, $li['item_id'], $grn['receiving_location_id'], $acceptedQty, [
                        'batch_lot_number' => $li['batch_lot_number'],
                        'serial_number' => $li['serial_number'],
                        'expiry_date' => $li['expiry_date'],
                        'unit_cost' => $li['unit_cost'],
                    ]);
                    updateAverageCost($pdo, $li['item_id']);
                    recordStockTransaction($pdo, [
                        'transaction_type' => 'RECEIVE',
                        'item_id' => $li['item_id'],
                        'location_id' => $grn['receiving_location_id'],
                        'quantity' => $acceptedQty,
                        'unit_cost' => $li['unit_cost'],
                        'total_cost' => $acceptedQty * $li['unit_cost'],
                        'reference_type' => 'inv_goods_received',
                        'reference_id' => $grnId,
                        'reference_number' => $grn['grn_number'],
                        'batch_lot_number' => $li['batch_lot_number'],
                        'serial_number' => $li['serial_number'],
                        'expiry_date' => $li['expiry_date'],
                        'notes' => "GRN accepted",
                    ]);
                }
            }

            $pdo->prepare("UPDATE inv_goods_received SET status = 'COMPLETED' WHERE grn_id = ?")->execute([$grnId]);

            // Create and lock GRN document
            createAndLockDocument($pdo, 'GOODS_RECEIVED_NOTE', 'inv_goods_received', $grnId, "GRN " . $grn['grn_number'] . " accepted");

            logInventoryAudit($pdo, 'inv_goods_received', $grnId, 'ACCEPTED', "GRN accepted and stock recorded");
        }

        $pdo->commit();
        pop("GRN updated.", "/inventory/receiving/view.php?id=$grnId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-seam"></i> GRN <?= htmlspecialchars($grn['grn_number']) ?></h2>
    <div>
        <?php if (in_array($grn['status'], ['DRAFT','INSPECTION'])): ?>
        <a href="/inventory/receiving/add.php?id=<?= $grnId ?>" class="btn btn-outline-primary"><i class="bi bi-pencil"></i> Edit</a>
        <?php endif; ?>
        <a href="/inventory/receiving/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
    </div>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <div class="row g-3">
            <div class="col-md-3"><strong>GRN #:</strong> <?= htmlspecialchars($grn['grn_number']) ?></div>
            <div class="col-md-3"><strong>PO #:</strong> <?= htmlspecialchars($grn['po_reference'] ?: '-') ?></div>
            <div class="col-md-3"><strong>Supplier:</strong> <?= htmlspecialchars($grn['supplier_name']) ?></div>
            <div class="col-md-3"><strong>Status:</strong>
                <?php $sc = match($grn['status']) { 'COMPLETED' => 'success', 'INSPECTION' => 'warning', 'QUARANTINE' => 'danger', 'DRAFT' => 'secondary', default => 'light' }; ?>
                <span class="badge bg-<?= $sc ?>"><?= $grn['status'] ?></span>
            </div>
            <div class="col-md-3"><strong>Received Date:</strong> <?= $grn['received_date'] ?></div>
            <div class="col-md-3"><strong>Received By:</strong> <?= htmlspecialchars($grn['receiver_name']) ?></div>
            <div class="col-md-3"><strong>Location:</strong> <?= htmlspecialchars($grn['location_code'] . ' - ' . $grn['site_name']) ?></div>
            <div class="col-md-3"><strong>Delivery Note:</strong> <?= htmlspecialchars($grn['delivery_note_number'] ?: '-') ?></div>
            <?php if ($grn['invoice_number']): ?>
            <div class="col-md-3"><strong>Invoice #:</strong> <?= htmlspecialchars($grn['invoice_number']) ?></div>
            <?php endif; ?>
            <?php if ($grn['is_non_exchange_transaction']): ?>
            <div class="col-md-3"><span class="badge bg-info">Non-Exchange Transaction</span></div>
            <?php endif; ?>
            <?php if ($grn['donor_source']): ?>
            <div class="col-md-6"><strong>Donor:</strong> <?= htmlspecialchars($grn['donor_source']) ?></div>
            <?php endif; ?>
            <?php if ($grn['notes']): ?>
            <div class="col-12"><strong>Notes:</strong> <?= nl2br(htmlspecialchars($grn['notes'])) ?></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white"><i class="bi bi-list-ol"></i> Received Items</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Item Code</th><th>Item Name</th><th>Lot</th><th>Batch</th><th>Serial</th>
                        <th>Expiry</th><th class="text-end">Qty Recv</th><th class="text-end">Accepted</th>
                        <th class="text-end">Rejected</th><th class="text-end">Unit Cost</th><th>Condition</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($lineItems as $li): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($li['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($li['item_name']) ?></td>
                        <td><?= htmlspecialchars($li['lot_number'] ?: '-') ?></td>
                        <td><?= htmlspecialchars($li['batch_number'] ?: '-') ?></td>
                        <td><?= htmlspecialchars($li['serial_number'] ?: '-') ?></td>
                        <td><?= $li['expiry_date'] ?: '-' ?></td>
                        <td class="text-end fw-bold"><?= number_format($li['quantity_received'], 2) ?> <?= $li['uom_code'] ?></td>
                        <td class="text-end text-success"><?= number_format($li['quantity_accepted'], 2) ?></td>
                        <td class="text-end text-danger"><?= number_format($li['quantity_rejected'], 2) ?></td>
                        <td class="text-end">$<?= number_format($li['unit_cost'] ?? 0, 2) ?></td>
                        <td>
                            <?php $cc = match($li['condition_on_receipt']) { 'GOOD' => 'success', 'DAMAGED' => 'warning', 'REJECTED' => 'danger', default => 'secondary' }; ?>
                            <span class="badge bg-<?= $cc ?>"><?= $li['condition_on_receipt'] ?></span>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Inspection Section -->
<?php if (in_array($grn['status'], ['DRAFT', 'RECEIVED', 'INSPECTION']) && has_permission('inspect_goods')): ?>
<div class="card border-0 shadow-sm mt-4">
    <div class="card-header bg-warning text-dark"><i class="bi bi-search"></i> Quality Inspection</div>
    <div class="card-body">
        <form method="POST">
            <div class="table-responsive mb-3">
                <table class="table table-sm align-middle">
                    <thead class="table-light">
                        <tr><th>Item</th><th>Qty Received</th><th>Inspection Result</th><th>Notes</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach ($lineItems as $li): ?>
                        <tr>
                            <td><code><?= htmlspecialchars($li['item_code']) ?></code> <?= htmlspecialchars($li['item_name']) ?></td>
                            <td><?= number_format($li['quantity_received'], 2) ?></td>
                            <td>
                                <select name="inspection_status[<?= $li['grn_item_id'] ?>]" class="form-select form-select-sm">
                                    <option value="PASS" <?= $li['inspection_status'] === 'PASS' ? 'selected' : '' ?>>Pass</option>
                                    <option value="CONDITIONAL" <?= $li['inspection_status'] === 'CONDITIONAL' ? 'selected' : '' ?>>Conditional</option>
                                    <option value="FAIL" <?= $li['inspection_status'] === 'FAIL' ? 'selected' : '' ?>>Fail</option>
                                </select>
                            </td>
                            <td><input type="text" name="inspection_notes[<?= $li['grn_item_id'] ?>]" class="form-control form-control-sm" value="<?= htmlspecialchars($li['quality_notes'] ?? '') ?>" placeholder="Notes..."></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            <div class="mb-3">
                <label class="form-label">Overall Inspection Notes</label>
                <textarea name="overall_inspection_notes" class="form-control" rows="2"><?= htmlspecialchars($grn['inspection_notes'] ?? '') ?></textarea>
            </div>
            <button type="submit" name="action" value="inspect" class="btn btn-warning btn-lg">
                <i class="bi bi-clipboard-check"></i> Complete Inspection
            </button>
        </form>
    </div>
</div>
<?php endif; ?>

<?php if ($grn['inspected_by']): ?>
<div class="card border-0 shadow-sm mt-4">
    <div class="card-body">
        <div class="row g-3">
            <div class="col-md-3"><strong>Inspected By:</strong> <?= htmlspecialchars($grn['inspector_name']) ?></div>
            <div class="col-md-3"><strong>Inspection Date:</strong> <?= $grn['inspection_date'] ?></div>
            <div class="col-md-3"><strong>Result:</strong>
                <?php $ic = match($grn['inspection_result']) { 'PASS' => 'success', 'CONDITIONAL' => 'warning', 'FAIL' => 'danger', default => 'secondary' }; ?>
                <span class="badge bg-<?= $ic ?>"><?= $grn['inspection_result'] ?></span>
            </div>
            <?php if ($grn['inspection_notes']): ?>
            <div class="col-12"><strong>Notes:</strong> <?= htmlspecialchars($grn['inspection_notes']) ?></div>
            <?php endif; ?>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- Accept Goods -->
<?php if (in_array($grn['status'], ['INSPECTED', 'RECEIVED']) && has_permission('receive_goods')): ?>
<div class="mt-4">
    <form method="POST">
        <button type="submit" name="action" value="accept" class="btn btn-success btn-lg">
            <i class="bi bi-check-circle"></i> Accept Goods & Record Stock
        </button>
        <small class="text-muted ms-2">This will add accepted quantities to inventory and lock the GRN document.</small>
    </form>
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
