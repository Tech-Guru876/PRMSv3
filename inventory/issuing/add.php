<?php
$REQUIRE_PERMISSION = 'issue_stock';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name, issue_policy FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);
$users = $pdo->query("SELECT user_id, full_name FROM users WHERE status='active' ORDER BY full_name")->fetchAll(PDO::FETCH_ASSOC);
$departments = $pdo->query("SELECT branch_id, branch_name FROM branches ORDER BY branch_name")->fetchAll(PDO::FETCH_ASSOC);

/* Pre-fill from requisition */
$reqId = (int) ($_GET['requisition_id'] ?? 0);
$reqItems = [];
$reqData = null;
if ($reqId > 0) {
    $reqData = $pdo->prepare("SELECT * FROM inv_requisitions WHERE requisition_id = ? AND status = 'APPROVED'");
    $reqData->execute([$reqId]);
    $reqData = $reqData->fetch(PDO::FETCH_ASSOC);
    if ($reqData) {
        $ri = $pdo->prepare("SELECT ri.*, i.item_code, i.item_name FROM inv_requisition_items ri JOIN inv_items i ON ri.item_id = i.item_id WHERE ri.requisition_id = ?");
        $ri->execute([$reqId]);
        $reqItems = $ri->fetchAll(PDO::FETCH_ASSOC);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        // Enforce period controls
        requireOpenPeriod($pdo);

        $issueTo       = trim($_POST['issued_to_user_id'] ?? '');
        $issueToDept   = (int) ($_POST['issued_to_department_id'] ?? 0);
        $issueToProject = trim($_POST['issued_to_project'] ?? '');
        $fromLocation  = (int) ($_POST['from_location_id'] ?? 0);
        $costCentre    = trim($_POST['cost_centre'] ?? '');
        $reqNumber     = trim($_POST['requisition_number'] ?? '');
        $notes         = trim($_POST['notes'] ?? '');

        if ($fromLocation <= 0) throw new Exception("Source location is required.");
        if (empty($issueTo) && $issueToDept <= 0) throw new Exception("Issue to person or department is required.");

        // Enforce freeze controls
        requireLocationNotFrozen($pdo, $fromLocation);

        $itemIds  = $_POST['item_id'] ?? [];
        $qtys     = $_POST['qty_issued'] ?? [];

        if (empty($itemIds) || count(array_filter($itemIds)) === 0) {
            throw new Exception("At least one item is required.");
        }

        $issueNumber = InventoryService::generateDocNumber($pdo, 'SIV', 'inv_issues', 'issue_number');

        // Calculate total value for approval matrix
        $totalValue = 0;
        for ($i = 0; $i < count($itemIds); $i++) {
            $iid = (int) ($itemIds[$i] ?? 0);
            if ($iid <= 0) continue;
            $qi = (float) ($qtys[$i] ?? 0);
            if ($qi <= 0) continue;
            $itemData = getInventoryItem($pdo, $iid);
            $totalValue += $qi * (float) ($itemData['average_cost'] ?? 0);
        }

        // Issue goes to PENDING_APPROVAL (segregation of duties: issuer ≠ approver)
        $pdo->prepare("INSERT INTO inv_issues
            (issue_number, requisition_number, issued_to_user_id, issued_to_department_id,
             issued_to_project, issued_by, from_location_id, cost_centre, notes, status, created_at)
            VALUES (?,?,?,?,?,?,?,?,?,?,NOW())")
            ->execute([$issueNumber, $reqNumber, $issueTo ?: null, $issueToDept > 0 ? $issueToDept : null,
                $issueToProject ?: null, $_SESSION['user_id'], $fromLocation, $costCentre, $notes, 'PENDING_APPROVAL']);

        $issueId = $pdo->lastInsertId();

        $insertLine = $pdo->prepare("INSERT INTO inv_issue_items
            (issue_id, item_id, quantity_requested, quantity_issued, lot_number, batch_number, serial_number)
            VALUES (?,?,?,?,?,?,?)");

        for ($i = 0; $i < count($itemIds); $i++) {
            $iid = (int) ($itemIds[$i] ?? 0);
            if ($iid <= 0) continue;
            $qi = (float) ($qtys[$i] ?? 0);
            if ($qi <= 0) continue;

            // Check stock availability enforcing FEFO
            $stock = InventoryService::getStockLevel($pdo, $iid, $fromLocation);
            if ($stock < $qi) {
                $itemName = $pdo->query("SELECT item_name FROM inv_items WHERE item_id=" . (int)$iid)->fetchColumn();
                throw new Exception("Insufficient stock for $itemName. Available: $stock, Requested: $qi");
            }

            $insertLine->execute([$issueId, $iid, $qi, $qi,
                $_POST['lot_number'][$i] ?? null, $_POST['batch_number'][$i] ?? null, $_POST['serial_number'][$i] ?? null]);
        }

        // Create document control record
        createInvDocument($pdo, 'STOCK_ISSUE_VOUCHER', 'inv_issues', $issueId, "Issue $issueNumber created");

        // Create approval log entries from approval matrix
        $approvals = getRequiredApprovals($pdo, 'ISSUE', $totalValue);
        if (!empty($approvals)) {
            createApprovalLog($pdo, 'inv_issues', $issueId, $approvals);
        }

        // Update requisition fulfilled qty if linked
        if ($reqId > 0 && $reqData) {
            $pdo->prepare("UPDATE inv_requisitions SET status = 'FULFILLED' WHERE requisition_id = ?")->execute([$reqId]);
        }

        logInventoryAudit($pdo, 'inv_issues', $issueId, 'CREATED', "Stock issue $issueNumber created — pending approval");
        $pdo->commit();
        pop("Stock issue $issueNumber created. Awaiting approval.", "/inventory/issuing/view.php?id=$issueId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-arrow-right"></i> New Stock Issue</h2>
    <a href="/inventory/issuing/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST" id="issueForm">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Issue Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Requisition # (if applicable)</label>
                    <input type="text" name="requisition_number" class="form-control" value="<?= htmlspecialchars($reqData['requisition_number'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Issue To (Person)</label>
                    <select name="issued_to_user_id" class="form-select">
                        <option value="">-- Select --</option>
                        <?php foreach ($users as $u): ?>
                        <option value="<?= $u['user_id'] ?>" <?= ($reqData['requester_user_id'] ?? '') == $u['user_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($u['full_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Issue To (Department)</label>
                    <select name="issued_to_department_id" class="form-select">
                        <option value="">-- Select --</option>
                        <?php foreach ($departments as $d): ?>
                        <option value="<?= $d['branch_id'] ?>" <?= ($reqData['department_id'] ?? '') == $d['branch_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($d['branch_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Issue To (Project)</label>
                    <input type="text" name="issued_to_project" class="form-control">
                </div>
                <div class="col-md-4">
                    <label class="form-label">From Location <span class="text-danger">*</span></label>
                    <select name="from_location_id" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($locations as $loc): ?>
                        <option value="<?= $loc['location_id'] ?>"><?= htmlspecialchars($loc['location_code'] . ' - ' . $loc['site_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Cost Centre</label>
                    <input type="text" name="cost_centre" class="form-control" value="<?= htmlspecialchars($reqData['cost_centre'] ?? '') ?>">
                </div>
                <div class="col-12">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-list-ol"></i> Items to Issue</span>
            <button type="button" class="btn btn-sm btn-light" onclick="addIssueRow()"><i class="bi bi-plus"></i> Add Row</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0" id="issueTable">
                    <thead class="table-light">
                        <tr><th>Item <span class="text-danger">*</span></th><th>Lot #</th><th>Batch #</th><th>Serial #</th><th>Qty to Issue <span class="text-danger">*</span></th><th></th></tr>
                    </thead>
                    <tbody id="issueBody">
                        <?php if (!empty($reqItems)): foreach ($reqItems as $ri): ?>
                        <tr>
                            <td>
                                <select name="item_id[]" class="form-select form-select-sm" required>
                                    <option value="">--</option>
                                    <?php foreach ($items as $it): ?>
                                    <option value="<?= $it['item_id'] ?>" <?= $ri['item_id'] == $it['item_id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($it['item_code'] . ' - ' . $it['item_name']) ?>
                                    </option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td><input type="text" name="lot_number[]" class="form-control form-control-sm"></td>
                            <td><input type="text" name="batch_number[]" class="form-control form-control-sm"></td>
                            <td><input type="text" name="serial_number[]" class="form-control form-control-sm"></td>
                            <td><input type="number" step="0.01" name="qty_issued[]" class="form-control form-control-sm text-end" required value="<?= $ri['quantity_approved'] ?? $ri['quantity_requested'] ?>"></td>
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
                            <td><input type="number" step="0.01" name="qty_issued[]" class="form-control form-control-sm text-end" required></td>
                            <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()"><i class="bi bi-trash"></i></button></td>
                        </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <button type="submit" class="btn btn-success btn-lg"><i class="bi bi-check-circle"></i> Complete Issue</button>
</form>

<script>
function addIssueRow() {
    const tbody = document.getElementById('issueBody');
    const row = tbody.querySelector('tr').cloneNode(true);
    row.querySelectorAll('input').forEach(i => i.value = '');
    row.querySelectorAll('select').forEach(s => s.selectedIndex = 0);
    tbody.appendChild(row);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
