<?php
$REQUIRE_PERMISSION = 'manage_inventory_items';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$categories = getCategories($pdo);
$uoms = getUnitsOfMeasure($pdo);
$critClasses = getCriticalityClasses($pdo);
$acctClasses = getAccountingClasses($pdo);
$riskClasses = getRiskClasses($pdo);
$assetTypes = getAssetTypes($pdo);
$invTypes    = getInventoryTypes($pdo);

/* Handle POST */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $itemCode = trim($_POST['item_code'] ?? '') ?: generateItemCode($pdo);
        $itemName = trim($_POST['item_name'] ?? '');
        if (empty($itemName)) throw new Exception("Item name is required.");

        $categoryId = (int) ($_POST['category_id'] ?? 0);
        if ($categoryId <= 0) throw new Exception("Category is required.");

        $uomId = (int) ($_POST['uom_id'] ?? 0);
        if ($uomId <= 0) throw new Exception("Unit of measure is required.");

        // Check for duplicate item code
        $dup = $pdo->prepare("SELECT COUNT(*) FROM inv_items WHERE item_code = ?");
        $dup->execute([$itemCode]);
        if ($dup->fetchColumn() > 0) throw new Exception("Item code '$itemCode' already exists.");

        $stmt = $pdo->prepare("
            INSERT INTO inv_items (
                item_code, item_name, description, category_id, subcategory_id, uom_id,
                pack_size, barcode, manufacturer, brand, model, part_number,
                serial_number_flag, batch_lot_flag, expiry_date_flag, hazard_class_flag,
                storage_conditions, shelf_life_days, inspection_required, receiving_tolerance_pct,
                contract_reference, procurement_method,
                reorder_level, reorder_quantity, min_level, max_level, safety_stock,
                lead_time_days, economic_order_qty,
                standard_cost, last_cost, average_cost, valuation_method,
                funding_source, program_project_code, gl_account_code,
                criticality_id, acct_class_id, item_status, issue_policy,
                asset_inventory_boundary, item_domain, asset_type_id, inventory_type_id,
                created_by
            ) VALUES (
                ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?,
                ?, ?, ?, ?,
                ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?,
                ?, ?, ?, ?,
                ?, ?, ?,
                ?, ?, ?, ?,
                ?, ?, ?, ?,
                ?
            )
        ");

        $stmt->execute([
            $itemCode,
            $itemName,
            trim($_POST['description'] ?? ''),
            $categoryId,
            ($_POST['subcategory_id'] ?? null) ?: null,
            $uomId,
            (float) ($_POST['pack_size'] ?? 1),
            trim($_POST['barcode'] ?? '') ?: null,
            trim($_POST['manufacturer'] ?? '') ?: null,
            trim($_POST['brand'] ?? '') ?: null,
            trim($_POST['model'] ?? '') ?: null,
            trim($_POST['part_number'] ?? '') ?: null,
            isset($_POST['serial_number_flag']) ? 1 : 0,
            isset($_POST['batch_lot_flag']) ? 1 : 0,
            isset($_POST['expiry_date_flag']) ? 1 : 0,
            isset($_POST['hazard_class_flag']) ? 1 : 0,
            trim($_POST['storage_conditions'] ?? '') ?: null,
            ($_POST['shelf_life_days'] ?? null) ?: null,
            isset($_POST['inspection_required']) ? 1 : 0,
            (float) ($_POST['receiving_tolerance_pct'] ?? 0),
            trim($_POST['contract_reference'] ?? '') ?: null,
            trim($_POST['procurement_method'] ?? '') ?: null,
            (float) ($_POST['reorder_level'] ?? 0),
            (float) ($_POST['reorder_quantity'] ?? 0),
            (float) ($_POST['min_level'] ?? 0),
            (float) ($_POST['max_level'] ?? 0),
            (float) ($_POST['safety_stock'] ?? 0),
            (int) ($_POST['lead_time_days'] ?? 0),
            ($_POST['economic_order_qty'] ?? null) ?: null,
            (float) ($_POST['standard_cost'] ?? 0),
            (float) ($_POST['last_cost'] ?? 0),
            (float) ($_POST['average_cost'] ?? 0),
            $_POST['valuation_method'] ?? 'AVERAGE',
            trim($_POST['funding_source'] ?? '') ?: null,
            trim($_POST['program_project_code'] ?? '') ?: null,
            trim($_POST['gl_account_code'] ?? '') ?: null,
            ($_POST['criticality_id'] ?? null) ?: null,
            ($_POST['acct_class_id'] ?? null) ?: null,
            $_POST['item_status'] ?? 'ACTIVE',
            $_POST['issue_policy'] ?? 'UNRESTRICTED',
            isset($_POST['asset_inventory_boundary']) ? 1 : 0,
            $_POST['item_domain'] ?? 'INVENTORY',
            ($_POST['asset_type_id'] ?? null) ?: null,
            ($_POST['inventory_type_id'] ?? null) ?: null,
            $_SESSION['user_id'] ?? null,
        ]);

        $newItemId = (int) $pdo->lastInsertId();

        // Save risk classes
        if (!empty($_POST['risk_classes'])) {
            $rcStmt = $pdo->prepare("INSERT INTO inv_item_risk_classes (item_id, risk_class_id) VALUES (?, ?)");
            foreach ($_POST['risk_classes'] as $rcId) {
                $rcStmt->execute([$newItemId, (int) $rcId]);
            }
        }

        logInventoryAudit($pdo, 'inv_items', $newItemId, 'CREATE', "Item created: $itemCode - $itemName");

        $pdo->commit();
        pop("Item '$itemName' created successfully.", "/inventory/items/view.php?id=$newItemId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-plus-circle"></i> Add Inventory Item</h2>
    <a href="/inventory/items/list.php" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Back to Items
    </a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<form method="POST" class="needs-validation" novalidate>
    <!-- Basic Information -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-info-circle"></i> Basic Information</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Item Code</label>
                    <input type="text" name="item_code" class="form-control" placeholder="Auto-generated if blank"
                           value="<?= htmlspecialchars($_POST['item_code'] ?? '') ?>">
                    <small class="text-muted">Leave blank for auto-generation</small>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Item Name <span class="text-danger">*</span></label>
                    <input type="text" name="item_name" class="form-control" required
                           value="<?= htmlspecialchars($_POST['item_name'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Barcode / QR / GS1</label>
                    <input type="text" name="barcode" class="form-control"
                           value="<?= htmlspecialchars($_POST['barcode'] ?? '') ?>">
                </div>
                <div class="col-12">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="2"><?= htmlspecialchars($_POST['description'] ?? '') ?></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Category <span class="text-danger">*</span></label>
                    <select name="category_id" class="form-select" required>
                        <option value="">Select...</option>
                        <?php foreach ($categories as $cat): ?>
                        <option value="<?= $cat['category_id'] ?>" <?= ($_POST['category_id'] ?? '') == $cat['category_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cat['category_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Unit of Measure <span class="text-danger">*</span></label>
                    <select name="uom_id" class="form-select" required>
                        <option value="">Select...</option>
                        <?php foreach ($uoms as $u): ?>
                        <option value="<?= $u['uom_id'] ?>" <?= ($_POST['uom_id'] ?? '') == $u['uom_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($u['uom_name']) ?> (<?= $u['uom_code'] ?>)
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Pack Size / Conversion</label>
                    <input type="number" step="0.01" name="pack_size" class="form-control" value="<?= $_POST['pack_size'] ?? '1.00' ?>">
                </div>
                <!-- Domain classification (migration 024) -->
                <?php if (!empty($assetTypes) || !empty($invTypes)): ?>
                <div class="col-md-4">
                    <label class="form-label">Item Domain <span class="text-danger">*</span></label>
                    <select name="item_domain" id="itemDomain" class="form-select" required>
                        <option value="INVENTORY" <?= ($_POST['item_domain'] ?? 'INVENTORY') === 'INVENTORY' ? 'selected' : '' ?>>Inventory (Stock)</option>
                        <option value="ASSET"     <?= ($_POST['item_domain'] ?? '') === 'ASSET'     ? 'selected' : '' ?>>Asset (Fixed/Movable)</option>
                        <option value="BOTH"      <?= ($_POST['item_domain'] ?? '') === 'BOTH'      ? 'selected' : '' ?>>Both</option>
                    </select>
                </div>
                <div class="col-md-4" id="assetTypeGroup" style="<?= in_array($_POST['item_domain'] ?? 'INVENTORY', ['ASSET','BOTH']) ? '' : 'display:none' ?>">
                    <label class="form-label">Asset Type</label>
                    <select name="asset_type_id" class="form-select">
                        <option value="">— Select asset type —</option>
                        <?php foreach ($assetTypes as $at): ?>
                        <option value="<?= $at['asset_type_id'] ?>" <?= ($_POST['asset_type_id'] ?? '') == $at['asset_type_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($at['type_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4" id="invTypeGroup" style="<?= in_array($_POST['item_domain'] ?? 'INVENTORY', ['INVENTORY','BOTH']) ? '' : 'display:none' ?>">
                    <label class="form-label">Inventory Type</label>
                    <select name="inventory_type_id" class="form-select">
                        <option value="">— Select inventory type —</option>
                        <?php foreach ($invTypes as $it): ?>
                        <option value="<?= $it['inventory_type_id'] ?>" <?= ($_POST['inventory_type_id'] ?? '') == $it['inventory_type_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($it['type_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Product Details -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-tag"></i> Product Details</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Manufacturer</label>
                    <input type="text" name="manufacturer" class="form-control" value="<?= htmlspecialchars($_POST['manufacturer'] ?? '') ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Brand</label>
                    <input type="text" name="brand" class="form-control" value="<?= htmlspecialchars($_POST['brand'] ?? '') ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Model</label>
                    <input type="text" name="model" class="form-control" value="<?= htmlspecialchars($_POST['model'] ?? '') ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Part / Catalogue Number</label>
                    <input type="text" name="part_number" class="form-control" value="<?= htmlspecialchars($_POST['part_number'] ?? '') ?>">
                </div>
            </div>
        </div>
    </div>

    <!-- Tracking Flags -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-flag"></i> Tracking & Control Flags</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="serial_number_flag" id="snFlag" <?= isset($_POST['serial_number_flag']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="snFlag">Serial Number Tracking</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="batch_lot_flag" id="batchFlag" <?= isset($_POST['batch_lot_flag']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="batchFlag">Batch / Lot Tracking</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="expiry_date_flag" id="expFlag" <?= isset($_POST['expiry_date_flag']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="expFlag">Expiry Date Tracking</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="hazard_class_flag" id="hazFlag" <?= isset($_POST['hazard_class_flag']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="hazFlag">Hazardous Item</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="inspection_required" id="inspFlag" <?= isset($_POST['inspection_required']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="inspFlag">Inspection Required</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="asset_inventory_boundary" id="aibFlag" <?= isset($_POST['asset_inventory_boundary']) ? 'checked' : '' ?>>
                        <label class="form-check-label" for="aibFlag">Asset/Inventory Boundary</label>
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Shelf Life (days)</label>
                    <input type="number" name="shelf_life_days" class="form-control" value="<?= $_POST['shelf_life_days'] ?? '' ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Receiving Tolerance %</label>
                    <input type="number" step="0.01" name="receiving_tolerance_pct" class="form-control" value="<?= $_POST['receiving_tolerance_pct'] ?? '0' ?>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Storage Conditions</label>
                    <input type="text" name="storage_conditions" class="form-control" placeholder="e.g. 15-25°C, dry storage"
                           value="<?= htmlspecialchars($_POST['storage_conditions'] ?? '') ?>">
                </div>
            </div>
        </div>
    </div>

    <!-- Replenishment -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-arrow-repeat"></i> Replenishment Parameters</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-2">
                    <label class="form-label">Reorder Level</label>
                    <input type="number" step="0.01" name="reorder_level" class="form-control" value="<?= $_POST['reorder_level'] ?? '0' ?>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Reorder Quantity</label>
                    <input type="number" step="0.01" name="reorder_quantity" class="form-control" value="<?= $_POST['reorder_quantity'] ?? '0' ?>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Min Level</label>
                    <input type="number" step="0.01" name="min_level" class="form-control" value="<?= $_POST['min_level'] ?? '0' ?>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Max Level</label>
                    <input type="number" step="0.01" name="max_level" class="form-control" value="<?= $_POST['max_level'] ?? '0' ?>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Safety Stock</label>
                    <input type="number" step="0.01" name="safety_stock" class="form-control" value="<?= $_POST['safety_stock'] ?? '0' ?>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Lead Time (days)</label>
                    <input type="number" name="lead_time_days" class="form-control" value="<?= $_POST['lead_time_days'] ?? '0' ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Economic Order Qty</label>
                    <input type="number" step="0.01" name="economic_order_qty" class="form-control" value="<?= $_POST['economic_order_qty'] ?? '' ?>">
                </div>
            </div>
        </div>
    </div>

    <!-- Costing & Financial -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-currency-dollar"></i> Costing & Financial</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Standard Cost</label>
                    <input type="number" step="0.01" name="standard_cost" class="form-control" value="<?= $_POST['standard_cost'] ?? '0.00' ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Last Cost</label>
                    <input type="number" step="0.01" name="last_cost" class="form-control" value="<?= $_POST['last_cost'] ?? '0.00' ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Average Cost</label>
                    <input type="number" step="0.01" name="average_cost" class="form-control" value="<?= $_POST['average_cost'] ?? '0.00' ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Valuation Method</label>
                    <select name="valuation_method" class="form-select">
                        <option value="AVERAGE" <?= ($_POST['valuation_method'] ?? '') === 'AVERAGE' ? 'selected' : '' ?>>Weighted Average</option>
                        <option value="FIFO" <?= ($_POST['valuation_method'] ?? '') === 'FIFO' ? 'selected' : '' ?>>FIFO</option>
                        <option value="STANDARD" <?= ($_POST['valuation_method'] ?? '') === 'STANDARD' ? 'selected' : '' ?>>Standard Cost</option>
                        <option value="SPECIFIC" <?= ($_POST['valuation_method'] ?? '') === 'SPECIFIC' ? 'selected' : '' ?>>Specific Identification</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Funding Source</label>
                    <input type="text" name="funding_source" class="form-control" value="<?= htmlspecialchars($_POST['funding_source'] ?? '') ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Program / Project Code</label>
                    <input type="text" name="program_project_code" class="form-control" value="<?= htmlspecialchars($_POST['program_project_code'] ?? '') ?>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">GL / Account Code</label>
                    <input type="text" name="gl_account_code" class="form-control" value="<?= htmlspecialchars($_POST['gl_account_code'] ?? '') ?>">
                </div>
            </div>
        </div>
    </div>

    <!-- Classification -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-diagram-3"></i> Classification & Control</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Criticality</label>
                    <select name="criticality_id" class="form-select">
                        <option value="">None</option>
                        <?php foreach ($critClasses as $cc): ?>
                        <option value="<?= $cc['criticality_id'] ?>" <?= ($_POST['criticality_id'] ?? '') == $cc['criticality_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cc['criticality_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Accounting Class</label>
                    <select name="acct_class_id" class="form-select">
                        <option value="">None</option>
                        <?php foreach ($acctClasses as $ac): ?>
                        <option value="<?= $ac['acct_class_id'] ?>" <?= ($_POST['acct_class_id'] ?? '') == $ac['acct_class_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($ac['acct_class_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Item Status</label>
                    <select name="item_status" class="form-select">
                        <option value="ACTIVE">Active</option>
                        <option value="BLOCKED">Blocked</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Issue Policy</label>
                    <select name="issue_policy" class="form-select">
                        <option value="UNRESTRICTED">Unrestricted</option>
                        <option value="APPROVAL_REQUIRED">Approval Required</option>
                        <option value="CONTROLLED">Controlled Issue</option>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Risk & Control Classes</label>
                    <div class="row g-2">
                        <?php foreach ($riskClasses as $rc): ?>
                        <div class="col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="risk_classes[]"
                                       value="<?= $rc['risk_class_id'] ?>" id="rc<?= $rc['risk_class_id'] ?>"
                                       <?= in_array($rc['risk_class_id'], $_POST['risk_classes'] ?? []) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="rc<?= $rc['risk_class_id'] ?>">
                                    <?= htmlspecialchars($rc['risk_name']) ?>
                                </label>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Procurement -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-cart"></i> Procurement Reference</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Contract Reference</label>
                    <input type="text" name="contract_reference" class="form-control" value="<?= htmlspecialchars($_POST['contract_reference'] ?? '') ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Procurement Method</label>
                    <input type="text" name="procurement_method" class="form-control" placeholder="e.g. Direct, Competitive, Framework"
                           value="<?= htmlspecialchars($_POST['procurement_method'] ?? '') ?>">
                </div>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <a href="/inventory/items/list.php" class="btn btn-outline-secondary me-2">Cancel</a>
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="bi bi-check-circle"></i> Create Item
        </button>
    </div>
</form>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
<script>
(function () {
    var domainSel = document.getElementById('itemDomain');
    if (!domainSel) return;
    function toggleTypeGroups() {
        var v = domainSel.value;
        var ag = document.getElementById('assetTypeGroup');
        var ig = document.getElementById('invTypeGroup');
        if (ag) ag.style.display = (v === 'ASSET' || v === 'BOTH') ? '' : 'none';
        if (ig) ig.style.display = (v === 'INVENTORY' || v === 'BOTH') ? '' : 'none';
    }
    domainSel.addEventListener('change', toggleTypeGroups);
    toggleTypeGroups();
}());
</script>
