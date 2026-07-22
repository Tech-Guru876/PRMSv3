<?php
$REQUIRE_PERMISSION = 'manage_inventory_items';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$itemId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if ($itemId <= 0) { pop("Invalid item ID.", "/inventory/items/list.php", 1800, 'warning'); exit; }

$item = getInventoryItem($pdo, $itemId);
if (!$item) { pop("Item not found.", "/inventory/items/list.php", 1800, 'warning'); exit; }

$categories = getCategories($pdo);
$uoms = getUnitsOfMeasure($pdo);
$critClasses = getCriticalityClasses($pdo);
$acctClasses = getAccountingClasses($pdo);
$riskClasses = getRiskClasses($pdo);
$itemRiskIds = array_column(getItemRiskClasses($pdo, $itemId), 'risk_class_id');
$assetTypes  = getAssetTypes($pdo);
$invTypes    = getInventoryTypes($pdo);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $itemName = trim($_POST['item_name'] ?? '');
        if (empty($itemName)) throw new Exception("Item name is required.");

        /* ── Asset Code Tag editing (permission-gated) ── */
        $newItemCode = null;
        $oldItemCode = $item['item_code'];
        if (has_permission('edit_asset_code') && isset($_POST['item_code'])) {
            $newItemCode = trim($_POST['item_code']);
            if ($newItemCode === '') throw new Exception("Item Code (Asset Code Tag) cannot be empty.");
            if (strlen($newItemCode) > 50) throw new Exception("Item Code must be 50 characters or less.");

            // Uniqueness check (exclude current item)
            if ($newItemCode !== $oldItemCode) {
                $dupChk = $pdo->prepare("SELECT COUNT(*) FROM inv_items WHERE item_code = ? AND item_id != ?");
                $dupChk->execute([$newItemCode, $itemId]);
                if ($dupChk->fetchColumn() > 0) {
                    throw new Exception("Item Code '{$newItemCode}' is already in use by another item.");
                }
            }
        }

        $stmt = $pdo->prepare("
            UPDATE inv_items SET
                item_name = ?, description = ?, category_id = ?, subcategory_id = ?, uom_id = ?,
                pack_size = ?, barcode = ?, manufacturer = ?, brand = ?, model = ?, part_number = ?,
                serial_number_flag = ?, batch_lot_flag = ?, expiry_date_flag = ?, hazard_class_flag = ?,
                storage_conditions = ?, shelf_life_days = ?, inspection_required = ?, receiving_tolerance_pct = ?,
                contract_reference = ?, procurement_method = ?,
                reorder_level = ?, reorder_quantity = ?, min_level = ?, max_level = ?, safety_stock = ?,
                lead_time_days = ?, economic_order_qty = ?,
                standard_cost = ?, valuation_method = ?,
                funding_source = ?, program_project_code = ?, gl_account_code = ?,
                criticality_id = ?, acct_class_id = ?, item_status = ?, issue_policy = ?,
                asset_inventory_boundary = ?, item_domain = ?, asset_type_id = ?, inventory_type_id = ?,
                updated_by = ?
                <?= ($newItemCode !== null && $newItemCode !== $oldItemCode) ? ', item_code = ?' : '' ?>
            WHERE item_id = ?
        ");

        $params = [
            $itemName,
            trim($_POST['description'] ?? ''),
            (int) $_POST['category_id'],
            ($_POST['subcategory_id'] ?? null) ?: null,
            (int) $_POST['uom_id'],
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
        ];

        if ($newItemCode !== null && $newItemCode !== $oldItemCode) {
            $params[] = $newItemCode;
        }
        $params[] = $itemId;

        $stmt->execute($params);

        // Update risk classes
        $pdo->prepare("DELETE FROM inv_item_risk_classes WHERE item_id = ?")->execute([$itemId]);
        if (!empty($_POST['risk_classes'])) {
            $rcStmt = $pdo->prepare("INSERT INTO inv_item_risk_classes (item_id, risk_class_id) VALUES (?, ?)");
            foreach ($_POST['risk_classes'] as $rcId) {
                $rcStmt->execute([$itemId, (int) $rcId]);
            }
        }

        /* ── Sync asset_code in inv_asset_details if item_code changed ── */
        if ($newItemCode !== null && $newItemCode !== $oldItemCode) {
            try {
                $pdo->prepare("UPDATE inv_asset_details SET asset_code = ? WHERE item_id = ?")
                    ->execute([$newItemCode, $itemId]);
            } catch (Throwable $e) {
                // Table may not have a row for this item — that's fine
            }

            logInventoryAudit($pdo, 'inv_items', $itemId, 'UPDATE',
                "Asset Code changed: '{$oldItemCode}' → '{$newItemCode}'");
        }

        logInventoryAudit($pdo, 'inv_items', $itemId, 'UPDATE', "Item updated: " . ($newItemCode ?? $oldItemCode));
        $pdo->commit();
        pop("Item updated successfully.", "/inventory/items/view.php?id=$itemId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

// Use item data as defaults
$f = $item;

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-pencil-square"></i> Edit Item: <?= htmlspecialchars($item['item_code']) ?></h2>
    <a href="/inventory/items/view.php?id=<?= $itemId ?>" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Back to Item
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
                    <label class="form-label">Item Code (Asset Code Tag)</label>
                    <?php if (has_permission('edit_asset_code')): ?>
                    <input type="text" name="item_code" class="form-control" required maxlength="50"
                           value="<?= htmlspecialchars($f['item_code']) ?>">
                    <small class="text-muted">Editable — must be unique</small>
                    <?php else: ?>
                    <input type="text" class="form-control" value="<?= htmlspecialchars($f['item_code']) ?>" disabled>
                    <?php endif; ?>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Item Name <span class="text-danger">*</span></label>
                    <input type="text" name="item_name" class="form-control" required value="<?= htmlspecialchars($f['item_name']) ?>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Barcode / QR / GS1</label>
                    <input type="text" name="barcode" class="form-control" value="<?= htmlspecialchars($f['barcode'] ?? '') ?>">
                </div>
                <div class="col-12">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="2"><?= htmlspecialchars($f['description'] ?? '') ?></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Category <span class="text-danger">*</span></label>
                    <select name="category_id" class="form-select" required>
                        <option value="">Select...</option>
                        <?php foreach ($categories as $cat): ?>
                        <option value="<?= $cat['category_id'] ?>" <?= $f['category_id'] == $cat['category_id'] ? 'selected' : '' ?>>
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
                        <option value="<?= $u['uom_id'] ?>" <?= $f['uom_id'] == $u['uom_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($u['uom_name']) ?> (<?= $u['uom_code'] ?>)
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Pack Size</label>
                    <input type="number" step="0.01" name="pack_size" class="form-control" value="<?= $f['pack_size'] ?>">
                </div>
                <!-- Domain classification (migration 024) -->
                <?php if (!empty($assetTypes) || !empty($invTypes)): ?>
                <div class="col-md-4">
                    <label class="form-label">Item Domain <span class="text-danger">*</span></label>
                    <select name="item_domain" id="itemDomain" class="form-select" required>
                        <option value="INVENTORY" <?= ($f['item_domain'] ?? 'INVENTORY') === 'INVENTORY' ? 'selected' : '' ?>>Inventory (Stock)</option>
                        <option value="ASSET"     <?= ($f['item_domain'] ?? '') === 'ASSET'     ? 'selected' : '' ?>>Asset (Fixed/Movable)</option>
                        <option value="BOTH"      <?= ($f['item_domain'] ?? '') === 'BOTH'      ? 'selected' : '' ?>>Both</option>
                    </select>
                </div>
                <div class="col-md-4" id="assetTypeGroup" style="<?= in_array($f['item_domain'] ?? 'INVENTORY', ['ASSET','BOTH']) ? '' : 'display:none' ?>">
                    <label class="form-label">Asset Type</label>
                    <select name="asset_type_id" class="form-select">
                        <option value="">— Select asset type —</option>
                        <?php foreach ($assetTypes as $at): ?>
                        <option value="<?= $at['asset_type_id'] ?>" <?= ($f['asset_type_id'] ?? '') == $at['asset_type_id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($at['type_name']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4" id="invTypeGroup" style="<?= in_array($f['item_domain'] ?? 'INVENTORY', ['INVENTORY','BOTH']) ? '' : 'display:none' ?>">
                    <label class="form-label">Inventory Type</label>
                    <select name="inventory_type_id" class="form-select">
                        <option value="">— Select inventory type —</option>
                        <?php foreach ($invTypes as $it): ?>
                        <option value="<?= $it['inventory_type_id'] ?>" <?= ($f['inventory_type_id'] ?? '') == $it['inventory_type_id'] ? 'selected' : '' ?>>
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
                <div class="col-md-3"><label class="form-label">Manufacturer</label><input type="text" name="manufacturer" class="form-control" value="<?= htmlspecialchars($f['manufacturer'] ?? '') ?>"></div>
                <div class="col-md-3"><label class="form-label">Brand</label><input type="text" name="brand" class="form-control" value="<?= htmlspecialchars($f['brand'] ?? '') ?>"></div>
                <div class="col-md-3"><label class="form-label">Model</label><input type="text" name="model" class="form-control" value="<?= htmlspecialchars($f['model'] ?? '') ?>"></div>
                <div class="col-md-3"><label class="form-label">Part Number</label><input type="text" name="part_number" class="form-control" value="<?= htmlspecialchars($f['part_number'] ?? '') ?>"></div>
            </div>
        </div>
    </div>

    <!-- Tracking Flags -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-flag"></i> Tracking & Control</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="serial_number_flag" <?= $f['serial_number_flag'] ? 'checked' : '' ?>><label class="form-check-label">Serial Number Tracking</label></div></div>
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="batch_lot_flag" <?= $f['batch_lot_flag'] ? 'checked' : '' ?>><label class="form-check-label">Batch / Lot Tracking</label></div></div>
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="expiry_date_flag" <?= $f['expiry_date_flag'] ? 'checked' : '' ?>><label class="form-check-label">Expiry Date Tracking</label></div></div>
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="hazard_class_flag" <?= $f['hazard_class_flag'] ? 'checked' : '' ?>><label class="form-check-label">Hazardous Item</label></div></div>
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="inspection_required" <?= $f['inspection_required'] ? 'checked' : '' ?>><label class="form-check-label">Inspection Required</label></div></div>
                <div class="col-md-3"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="asset_inventory_boundary" <?= $f['asset_inventory_boundary'] ? 'checked' : '' ?>><label class="form-check-label">Asset/Inventory Boundary</label></div></div>
                <div class="col-md-3"><label class="form-label">Shelf Life (days)</label><input type="number" name="shelf_life_days" class="form-control" value="<?= $f['shelf_life_days'] ?? '' ?>"></div>
                <div class="col-md-3"><label class="form-label">Receiving Tolerance %</label><input type="number" step="0.01" name="receiving_tolerance_pct" class="form-control" value="<?= $f['receiving_tolerance_pct'] ?>"></div>
                <div class="col-md-6"><label class="form-label">Storage Conditions</label><input type="text" name="storage_conditions" class="form-control" value="<?= htmlspecialchars($f['storage_conditions'] ?? '') ?>"></div>
            </div>
        </div>
    </div>

    <!-- Replenishment -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-arrow-repeat"></i> Replenishment</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-2"><label class="form-label">Reorder Level</label><input type="number" step="0.01" name="reorder_level" class="form-control" value="<?= $f['reorder_level'] ?>"></div>
                <div class="col-md-2"><label class="form-label">Reorder Qty</label><input type="number" step="0.01" name="reorder_quantity" class="form-control" value="<?= $f['reorder_quantity'] ?>"></div>
                <div class="col-md-2"><label class="form-label">Min</label><input type="number" step="0.01" name="min_level" class="form-control" value="<?= $f['min_level'] ?>"></div>
                <div class="col-md-2"><label class="form-label">Max</label><input type="number" step="0.01" name="max_level" class="form-control" value="<?= $f['max_level'] ?>"></div>
                <div class="col-md-2"><label class="form-label">Safety Stock</label><input type="number" step="0.01" name="safety_stock" class="form-control" value="<?= $f['safety_stock'] ?>"></div>
                <div class="col-md-2"><label class="form-label">Lead Time (days)</label><input type="number" name="lead_time_days" class="form-control" value="<?= $f['lead_time_days'] ?>"></div>
                <div class="col-md-3"><label class="form-label">EOQ</label><input type="number" step="0.01" name="economic_order_qty" class="form-control" value="<?= $f['economic_order_qty'] ?? '' ?>"></div>
            </div>
        </div>
    </div>

    <!-- Costing -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-currency-dollar"></i> Costing & Financial</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3"><label class="form-label">Standard Cost</label><input type="number" step="0.01" name="standard_cost" class="form-control" value="<?= $f['standard_cost'] ?>"></div>
                <div class="col-md-3"><label class="form-label">Valuation Method</label>
                    <select name="valuation_method" class="form-select">
                        <?php foreach (['AVERAGE', 'FIFO', 'STANDARD', 'SPECIFIC'] as $vm): ?>
                        <option value="<?= $vm ?>" <?= $f['valuation_method'] === $vm ? 'selected' : '' ?>><?= $vm ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3"><label class="form-label">Funding Source</label><input type="text" name="funding_source" class="form-control" value="<?= htmlspecialchars($f['funding_source'] ?? '') ?>"></div>
                <div class="col-md-3"><label class="form-label">Program/Project Code</label><input type="text" name="program_project_code" class="form-control" value="<?= htmlspecialchars($f['program_project_code'] ?? '') ?>"></div>
                <div class="col-md-3"><label class="form-label">GL Account Code</label><input type="text" name="gl_account_code" class="form-control" value="<?= htmlspecialchars($f['gl_account_code'] ?? '') ?>"></div>
            </div>
        </div>
    </div>

    <!-- Classification -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-dark text-white"><i class="bi bi-diagram-3"></i> Classification</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Criticality</label>
                    <select name="criticality_id" class="form-select">
                        <option value="">None</option>
                        <?php foreach ($critClasses as $cc): ?>
                        <option value="<?= $cc['criticality_id'] ?>" <?= $f['criticality_id'] == $cc['criticality_id'] ? 'selected' : '' ?>><?= htmlspecialchars($cc['criticality_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Accounting Class</label>
                    <select name="acct_class_id" class="form-select">
                        <option value="">None</option>
                        <?php foreach ($acctClasses as $ac): ?>
                        <option value="<?= $ac['acct_class_id'] ?>" <?= $f['acct_class_id'] == $ac['acct_class_id'] ? 'selected' : '' ?>><?= htmlspecialchars($ac['acct_class_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Status</label>
                    <select name="item_status" class="form-select">
                        <?php foreach (['ACTIVE','BLOCKED','OBSOLETE','QUARANTINED','DISPOSAL'] as $st): ?>
                        <option value="<?= $st ?>" <?= $f['item_status'] === $st ? 'selected' : '' ?>><?= $st ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Issue Policy</label>
                    <select name="issue_policy" class="form-select">
                        <?php foreach (['UNRESTRICTED','APPROVAL_REQUIRED','CONTROLLED'] as $ip): ?>
                        <option value="<?= $ip ?>" <?= $f['issue_policy'] === $ip ? 'selected' : '' ?>><?= $ip ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Risk & Control Classes</label>
                    <div class="row g-2">
                        <?php foreach ($riskClasses as $rc): ?>
                        <div class="col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="risk_classes[]" value="<?= $rc['risk_class_id'] ?>"
                                       <?= in_array($rc['risk_class_id'], $itemRiskIds) ? 'checked' : '' ?>>
                                <label class="form-check-label"><?= htmlspecialchars($rc['risk_name']) ?></label>
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
        <div class="card-header bg-dark text-white"><i class="bi bi-cart"></i> Procurement</div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4"><label class="form-label">Contract Reference</label><input type="text" name="contract_reference" class="form-control" value="<?= htmlspecialchars($f['contract_reference'] ?? '') ?>"></div>
                <div class="col-md-4"><label class="form-label">Procurement Method</label><input type="text" name="procurement_method" class="form-control" value="<?= htmlspecialchars($f['procurement_method'] ?? '') ?>"></div>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <a href="/inventory/items/view.php?id=<?= $itemId ?>" class="btn btn-outline-secondary me-2">Cancel</a>
        <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-check-circle"></i> Save Changes</button>
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