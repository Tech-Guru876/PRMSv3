<?php
$REQUIRE_PERMISSION = 'submit_stock_requisition';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE item_status = 'ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = getActiveLocations($pdo);
$branches = $pdo->query("SELECT branch_id, branch_name FROM branches ORDER BY branch_name")->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();
        $action = $_POST['action'] ?? 'draft';
        $reqNumber = generateRequisitionNumber($pdo);

        $stmt = $pdo->prepare("
            INSERT INTO inv_requisitions (requisition_number, requester_user_id, department_id, cost_centre,
                intended_use, destination_location_id, urgency, justification, emergency_reason_code, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $status = ($action === 'submit') ? 'SUBMITTED' : 'DRAFT';

        $stmt->execute([
            $reqNumber,
            $_SESSION['user_id'],
            ($_POST['department_id'] ?? null) ?: null,
            trim($_POST['cost_centre'] ?? '') ?: null,
            trim($_POST['intended_use'] ?? '') ?: null,
            ($_POST['destination_location_id'] ?? null) ?: null,
            $_POST['urgency'] ?? 'NORMAL',
            trim($_POST['justification'] ?? '') ?: null,
            trim($_POST['emergency_reason_code'] ?? '') ?: null,
            $status,
        ]);

        $reqId = (int) $pdo->lastInsertId();
        $duplicateFound = false;

        // Save items
        if (!empty($_POST['items'])) {
            $itemStmt = $pdo->prepare("
                INSERT INTO inv_requisition_items (requisition_id, item_id, quantity_requested, remarks, stock_available_at_request)
                VALUES (?, ?, ?, ?, ?)
            ");
            foreach ($_POST['items'] as $lineItem) {
                $liItemId = (int) ($lineItem['item_id'] ?? 0);
                $liQty = (float) ($lineItem['quantity'] ?? 0);
                if ($liItemId <= 0 || $liQty <= 0) continue;

                $available = getItemAvailableStock($pdo, $liItemId);

                // Duplicate check: same item requested in last 7 days by same user
                $dupCheck = $pdo->prepare("
                    SELECT COUNT(*) FROM inv_requisitions rq
                    JOIN inv_requisition_items ri ON rq.requisition_id = ri.requisition_id
                    WHERE rq.requester_user_id = ? AND ri.item_id = ?
                      AND rq.status NOT IN ('CANCELLED','REJECTED')
                      AND rq.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                      AND rq.requisition_id != ?
                ");
                $dupCheck->execute([$_SESSION['user_id'], $liItemId, $reqId]);
                if ($dupCheck->fetchColumn() > 0) $duplicateFound = true;

                $itemStmt->execute([
                    $reqId, $liItemId, $liQty,
                    trim($lineItem['remarks'] ?? '') ?: null,
                    $available,
                ]);
            }
        }

        if ($duplicateFound) {
            $pdo->prepare("UPDATE inv_requisitions SET is_duplicate_flagged = 1 WHERE requisition_id = ?")
                ->execute([$reqId]);
        }

        // Create document record
        createInvDocument($pdo, 'REQUISITION', 'inv_requisitions', $reqId);
        logInventoryAudit($pdo, 'inv_requisitions', $reqId, 'CREATE', "Requisition $reqNumber created ($status)");

        $pdo->commit();
        pop("Requisition $reqNumber created.", "/inventory/requisitions/view.php?id=$reqId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clipboard-plus"></i> New Stock Requisition</h2>
    <a href="/inventory/requisitions/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST" id="reqForm">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Requisition Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Department</label>
                    <select name="department_id" class="form-select">
                        <option value="">Select...</option>
                        <?php foreach ($branches as $b): ?>
                        <option value="<?= $b['branch_id'] ?>"><?= htmlspecialchars($b['branch_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Cost Centre</label>
                    <input type="text" name="cost_centre" class="form-control">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Urgency</label>
                    <select name="urgency" class="form-select">
                        <option value="NORMAL">Normal</option>
                        <option value="URGENT">Urgent</option>
                        <option value="EMERGENCY">Emergency</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Destination Location</label>
                    <select name="destination_location_id" class="form-select">
                        <option value="">Select...</option>
                        <?php foreach ($locations as $l): ?>
                        <option value="<?= $l['location_id'] ?>"><?= htmlspecialchars($l['location_code'] . ' - ' . ($l['building'] ?? '') . ' ' . ($l['room_storage_area'] ?? '')) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Intended Use</label>
                    <input type="text" name="intended_use" class="form-control" placeholder="Purpose of requisition">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Justification</label>
                    <input type="text" name="justification" class="form-control">
                </div>
                <div class="col-md-4" id="emergencyReasonDiv" style="display:none;">
                    <label class="form-label">Emergency Reason Code</label>
                    <input type="text" name="emergency_reason_code" class="form-control">
                </div>
            </div>
        </div>
    </div>

    <!-- Line Items -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-list-check"></i> Items Requested</span>
            <button type="button" class="btn btn-sm btn-light" id="addItemRow"><i class="bi bi-plus"></i> Add Item</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0" id="itemsTable">
                    <thead class="table-light">
                        <tr>
                            <th style="width:40%">Item</th>
                            <th style="width:15%">Available Stock</th>
                            <th style="width:15%">Quantity Required</th>
                            <th style="width:25%">Remarks</th>
                            <th style="width:5%"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <select name="items[0][item_id]" class="form-select item-select" required>
                                    <option value="">Select item...</option>
                                    <?php foreach ($items as $it): ?>
                                    <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' - ' . $it['item_name']) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><span class="stock-display text-muted">-</span></td>
                            <td><input type="number" step="0.01" min="0.01" name="items[0][quantity]" class="form-control" required></td>
                            <td><input type="text" name="items[0][remarks]" class="form-control"></td>
                            <td></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <button type="submit" name="action" value="draft" class="btn btn-outline-secondary btn-lg me-2">
            <i class="bi bi-save"></i> Save Draft
        </button>
        <button type="submit" name="action" value="submit" class="btn btn-primary btn-lg">
            <i class="bi bi-send"></i> Submit Requisition
        </button>
    </div>
</form>

<script>
let rowIdx = 1;
const itemOptions = <?= json_encode(array_map(fn($it) => ['id' => $it['item_id'], 'label' => $it['item_code'] . ' - ' . $it['item_name']], $items)) ?>;

document.getElementById('addItemRow').addEventListener('click', function() {
    const tbody = document.querySelector('#itemsTable tbody');
    const row = document.createElement('tr');
    let opts = '<option value="">Select item...</option>';
    itemOptions.forEach(it => { opts += `<option value="${it.id}">${it.label}</option>`; });
    row.innerHTML = `
        <td><select name="items[${rowIdx}][item_id]" class="form-select item-select" required>${opts}</select></td>
        <td><span class="stock-display text-muted">-</span></td>
        <td><input type="number" step="0.01" min="0.01" name="items[${rowIdx}][quantity]" class="form-control" required></td>
        <td><input type="text" name="items[${rowIdx}][remarks]" class="form-control"></td>
        <td><button type="button" class="btn btn-sm btn-danger removeRow">×</button></td>
    `;
    tbody.appendChild(row);
    rowIdx++;
});

document.addEventListener('click', function(e) {
    if (e.target.classList.contains('removeRow')) e.target.closest('tr').remove();
});

document.querySelector('[name="urgency"]').addEventListener('change', function() {
    document.getElementById('emergencyReasonDiv').style.display = this.value === 'EMERGENCY' ? 'block' : 'none';
});
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
