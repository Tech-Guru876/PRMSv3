<?php
$REQUIRE_PERMISSION = 'manage_incidents';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name, unit_of_measure FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $incidentType = $_POST['incident_type'] ?? 'OTHER';
        $incidentDate = $_POST['incident_date'] ?? date('Y-m-d');
        $locationId = (int) ($_POST['location_id'] ?? 0) ?: null;
        $description = trim($_POST['description'] ?? '');
        $policeRef = trim($_POST['police_reference'] ?? '') ?: null;
        $insuranceRef = trim($_POST['insurance_reference'] ?? '') ?: null;
        $insuranceClaim = (float) ($_POST['insurance_claim_amount'] ?? 0) ?: null;
        $notes = trim($_POST['notes'] ?? '') ?: null;

        if (empty($description)) throw new Exception("Description is required.");
        $validTypes = ['THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER'];
        if (!in_array($incidentType, $validTypes)) throw new Exception("Invalid incident type.");

        $incidentNumber = generateIncidentNumber($pdo);

        // Parse line items
        $lineItemIds = $_POST['line_item_id'] ?? [];
        $lineQtys = $_POST['line_quantity'] ?? [];
        $lineCosts = $_POST['line_unit_cost'] ?? [];
        $lineBatches = $_POST['line_batch'] ?? [];
        $lineSerials = $_POST['line_serial'] ?? [];
        $lineNotes = $_POST['line_notes'] ?? [];

        $totalLoss = 0;
        $validLines = [];
        foreach ($lineItemIds as $idx => $itemId) {
            $itemId = (int) $itemId;
            $qty = (float) ($lineQtys[$idx] ?? 0);
            $cost = (float) ($lineCosts[$idx] ?? 0);
            if ($itemId <= 0 || $qty <= 0) continue;
            $lineTotal = $qty * $cost;
            $totalLoss += $lineTotal;
            $validLines[] = [
                'item_id' => $itemId,
                'quantity_lost' => $qty,
                'unit_cost' => $cost,
                'total_value' => $lineTotal,
                'batch_lot_number' => trim($lineBatches[$idx] ?? '') ?: null,
                'serial_number' => trim($lineSerials[$idx] ?? '') ?: null,
                'condition_notes' => trim($lineNotes[$idx] ?? '') ?: null,
            ];
        }

        $pdo->prepare("INSERT INTO inv_incidents
            (incident_number, incident_type, incident_date, location_id, description, status,
             reported_by, police_reference, insurance_reference, insurance_claim_amount,
             total_estimated_loss, notes)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")
            ->execute([$incidentNumber, $incidentType, $incidentDate, $locationId, $description,
                'REPORTED', $_SESSION['user_id'], $policeRef, $insuranceRef, $insuranceClaim,
                $totalLoss, $notes]);
        $incidentId = (int) $pdo->lastInsertId();

        $lineInsert = $pdo->prepare("INSERT INTO inv_incident_items (incident_id, item_id, quantity_lost, unit_cost, total_value, batch_lot_number, serial_number, condition_notes) VALUES (?,?,?,?,?,?,?,?)");
        foreach ($validLines as $line) {
            $lineInsert->execute([$incidentId, $line['item_id'], $line['quantity_lost'], $line['unit_cost'], $line['total_value'], $line['batch_lot_number'], $line['serial_number'], $line['condition_notes']]);
        }

        logInventoryAudit($pdo, 'inv_incidents', $incidentId, 'REPORTED', "Incident $incidentNumber reported: $incidentType");

        $pdo->commit();
        pop("Incident $incidentNumber reported.", "/inventory/incidents/view.php?id=$incidentId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-exclamation-triangle"></i> Report Incident / Loss</h2>
    <a href="/inventory/incidents/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <form method="POST" id="incidentForm">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Incident Type *</label>
                    <select name="incident_type" class="form-select" required>
                        <?php foreach (['THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER'] as $t): ?>
                        <option value="<?= $t ?>"><?= $t ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Incident Date *</label>
                    <input type="date" name="incident_date" class="form-control" value="<?= date('Y-m-d') ?>" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Location</label>
                    <select name="location_id" class="form-select">
                        <option value="">Select location...</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' — ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Description *</label>
                    <textarea name="description" class="form-control" rows="4" required placeholder="Describe the incident in detail..."></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Police Reference</label>
                    <input type="text" name="police_reference" class="form-control" placeholder="e.g. JCF-2024-xxxxx">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Insurance Reference</label>
                    <input type="text" name="insurance_reference" class="form-control">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Insurance Claim Amount</label>
                    <input type="number" step="0.01" name="insurance_claim_amount" class="form-control" placeholder="$0.00">
                </div>
                <div class="col-12">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>

            <hr>
            <h5>Affected Items</h5>
            <div id="lineItems">
                <div class="row g-2 mb-2 line-row">
                    <div class="col-md-3">
                        <select name="line_item_id[]" class="form-select form-select-sm">
                            <option value="">Item...</option>
                            <?php foreach ($items as $it): ?>
                            <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' — ' . $it['item_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-1"><input type="number" step="0.01" name="line_quantity[]" class="form-control form-control-sm" placeholder="Qty"></div>
                    <div class="col-md-2"><input type="number" step="0.01" name="line_unit_cost[]" class="form-control form-control-sm" placeholder="Unit cost"></div>
                    <div class="col-md-2"><input type="text" name="line_batch[]" class="form-control form-control-sm" placeholder="Batch/Lot"></div>
                    <div class="col-md-1"><input type="text" name="line_serial[]" class="form-control form-control-sm" placeholder="Serial"></div>
                    <div class="col-md-3"><input type="text" name="line_notes[]" class="form-control form-control-sm" placeholder="Condition notes"></div>
                </div>
            </div>
            <button type="button" class="btn btn-sm btn-outline-secondary mb-3" onclick="addLine()"><i class="bi bi-plus"></i> Add Line</button>

            <div class="mt-3">
                <button type="submit" class="btn btn-danger btn-lg"><i class="bi bi-exclamation-triangle"></i> Report Incident</button>
            </div>
        </form>
    </div>
</div>

<script>
function addLine() {
    const container = document.getElementById('lineItems');
    const first = container.querySelector('.line-row');
    const clone = first.cloneNode(true);
    clone.querySelectorAll('input, select').forEach(el => el.value = '');
    container.appendChild(clone);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
