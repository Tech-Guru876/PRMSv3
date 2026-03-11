<?php
$REQUIRE_PERMISSION = 'dispose_stock';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);
$locations = $pdo->query("SELECT location_id, location_code, site_name FROM inv_locations WHERE is_active=1 ORDER BY site_name")->fetchAll(PDO::FETCH_ASSOC);

$disposalMethods = ['SALE','AUCTION','DONATION','DESTRUCTION','RECYCLING','TRADE_IN','RETURN_TO_SUPPLIER','CANNIBALIZATION'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $method    = $_POST['disposal_method']  ?? '';
        $reason    = trim($_POST['reason'] ?? '');
        $locationId = (int) ($_POST['location_id'] ?? 0);
        $notes     = trim($_POST['notes'] ?? '');

        if (empty($method)) throw new Exception("Disposal method is required.");
        if (empty($reason)) throw new Exception("Reason for disposal is required.");
        if ($locationId <= 0) throw new Exception("Location is required.");

        $itemIds    = $_POST['item_id']  ?? [];
        $qtys       = $_POST['quantity'] ?? [];
        $conditions = $_POST['condition'] ?? [];
        $values     = $_POST['estimated_value'] ?? [];
        if (empty($itemIds) || count(array_filter($itemIds)) === 0) throw new Exception("At least one item is required.");

        $dispNumber = InventoryService::generateDocNumber($pdo, 'DSP', 'inv_disposal_requests', 'disposal_number');

        $pdo->prepare("INSERT INTO inv_disposal_requests
            (disposal_number, disposal_method, reason, location_id, requested_by, notes, status, created_at)
            VALUES (?,?,?,?,?,?,?,NOW())")
            ->execute([$dispNumber, $method, $reason, $locationId, $_SESSION['user_id'], $notes, 'PENDING_SURVEY']);

        $dispId = $pdo->lastInsertId();

        $insertItem = $pdo->prepare("INSERT INTO inv_disposal_items
            (disposal_id, item_id, quantity, condition_description, estimated_value)
            VALUES (?,?,?,?,?)");

        for ($i = 0; $i < count($itemIds); $i++) {
            $iid = (int) ($itemIds[$i] ?? 0);
            if ($iid <= 0) continue;
            $qty = (float) ($qtys[$i] ?? 0);
            if ($qty <= 0) continue;

            $insertItem->execute([$dispId, $iid, $qty,
                $conditions[$i] ?? '', (float) ($values[$i] ?? 0)]);
        }

        logInventoryAudit($pdo, 'inv_disposal_requests', $dispId, 'CREATED', "Disposal request $dispNumber");
        $pdo->commit();
        pop("Disposal request $dispNumber submitted.", "/inventory/disposal/view.php?id=$dispId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = $e->getMessage();
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-trash3"></i> New Disposal Request</h2>
    <a href="/inventory/disposal/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Disposal Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Disposal Method <span class="text-danger">*</span></label>
                    <select name="disposal_method" class="form-select" required>
                        <option value="">-- Select --</option>
                        <?php foreach ($disposalMethods as $dm): ?>
                        <option value="<?= $dm ?>"><?= str_replace('_', ' ', $dm) ?></option>
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
                <div class="col-md-4">
                    <label class="form-label">Reason <span class="text-danger">*</span></label>
                    <input type="text" name="reason" class="form-control" required>
                </div>
                <div class="col-12">
                    <label class="form-label">Notes / Supporting Information</label>
                    <textarea name="notes" class="form-control" rows="2"></textarea>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <span><i class="bi bi-list-ol"></i> Items for Disposal</span>
            <button type="button" class="btn btn-sm btn-light" onclick="addDispRow()"><i class="bi bi-plus"></i> Add Row</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0">
                    <thead class="table-light">
                        <tr><th>Item <span class="text-danger">*</span></th><th>Quantity <span class="text-danger">*</span></th><th>Condition</th><th>Est. Value ($)</th><th></th></tr>
                    </thead>
                    <tbody id="dispBody">
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
                            <td><input type="text" name="condition[]" class="form-control form-control-sm" placeholder="Damaged, expired..."></td>
                            <td><input type="number" step="0.01" name="estimated_value[]" class="form-control form-control-sm text-end"></td>
                            <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()"><i class="bi bi-trash"></i></button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-send"></i> Submit for Survey</button>
</form>

<script>
function addDispRow() {
    const tbody = document.getElementById('dispBody');
    const row = tbody.querySelector('tr').cloneNode(true);
    row.querySelectorAll('input').forEach(i => i.value = '');
    row.querySelectorAll('select').forEach(s => s.selectedIndex = 0);
    tbody.appendChild(row);
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
