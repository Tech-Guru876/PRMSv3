<?php
/**
 * Inventory Service — core helpers for the inventory module.
 * Provides number generation, stock queries, segregation checks, and document control.
 */

require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/audit.php';

/* ================================================================
   NUMBER GENERATORS
================================================================ */

function generateInventoryNumber(PDO $pdo, string $prefix, string $table, string $column): string
{
    $stmt = $pdo->prepare("
        SELECT $column FROM $table
        WHERE $column LIKE :prefix
        ORDER BY LENGTH($column) DESC, $column DESC
        LIMIT 1
    ");
    $stmt->execute([':prefix' => $prefix . '%']);
    $last = $stmt->fetchColumn();

    if ($last) {
        $num = (int) preg_replace('/[^0-9]/', '', substr($last, strlen($prefix)));
        return $prefix . str_pad($num + 1, 5, '0', STR_PAD_LEFT);
    }
    return $prefix . '00001';
}

function generateItemCode(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'ITM-', 'inv_items', 'item_code');
}

function generateRequisitionNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'SRQ-', 'inv_requisitions', 'requisition_number');
}

function generateGRNNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'GRN-', 'inv_goods_received', 'grn_number');
}

function generateIssueNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'ISS-', 'inv_issues', 'issue_number');
}

function generateTransferNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'TRF-', 'inv_transfers', 'transfer_number');
}

function generateAdjustmentNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'ADJ-', 'inv_adjustments', 'adjustment_number');
}

function generateDisposalNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'DSP-', 'inv_disposals', 'disposal_number');
}

function generateCountNumber(PDO $pdo): string {
    return generateInventoryNumber($pdo, 'CNT-', 'inv_stock_counts', 'count_number');
}

function generateDocumentNumber(PDO $pdo, string $docType): string {
    $prefixes = [
        'REQUISITION' => 'DOC-REQ-',
        'GOODS_RECEIVED_NOTE' => 'DOC-GRN-',
        'STOCK_ISSUE_VOUCHER' => 'DOC-ISS-',
        'TRANSFER_NOTE' => 'DOC-TRF-',
        'ADJUSTMENT_NOTE' => 'DOC-ADJ-',
        'DISPOSAL_FORM' => 'DOC-DSP-',
        'STOCK_COUNT_SHEET' => 'DOC-CNT-',
    ];
    $prefix = $prefixes[$docType] ?? 'DOC-';
    return generateInventoryNumber($pdo, $prefix, 'inv_documents', 'document_number');
}

/* ================================================================
   STOCK QUERIES
================================================================ */

/**
 * Get total available quantity for an item across all active locations.
 */
function getItemAvailableStock(PDO $pdo, int $itemId): float
{
    $stmt = $pdo->prepare("
        SELECT COALESCE(SUM(quantity_available), 0)
        FROM inv_stock
        WHERE item_id = ? AND stock_status = 'USABLE'
    ");
    $stmt->execute([$itemId]);
    return (float) $stmt->fetchColumn();
}

/**
 * Get stock by item and location.
 */
function getStockAtLocation(PDO $pdo, int $itemId, int $locationId): array
{
    $stmt = $pdo->prepare("
        SELECT s.*, i.item_name, i.item_code, l.location_code
        FROM inv_stock s
        JOIN inv_items i ON s.item_id = i.item_id
        JOIN inv_locations l ON s.location_id = l.location_id
        WHERE s.item_id = ? AND s.location_id = ? AND s.stock_status = 'USABLE'
        ORDER BY s.expiry_date ASC, s.received_date ASC
    ");
    $stmt->execute([$itemId, $locationId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Check if item is below reorder level.
 */
function isItemBelowReorderLevel(PDO $pdo, int $itemId): bool
{
    $item = getInventoryItem($pdo, $itemId);
    if (!$item) return false;
    $available = getItemAvailableStock($pdo, $itemId);
    return $available <= (float) $item['reorder_level'];
}

/**
 * Get a single inventory item.
 */
function getInventoryItem(PDO $pdo, int $itemId): ?array
{
    $stmt = $pdo->prepare("
        SELECT i.*, c.category_name, u.uom_code, u.uom_name,
               cr.criticality_name, ac.acct_class_name
        FROM inv_items i
        LEFT JOIN inv_categories c ON i.category_id = c.category_id
        LEFT JOIN inv_units_of_measure u ON i.uom_id = u.uom_id
        LEFT JOIN inv_criticality_classes cr ON i.criticality_id = cr.criticality_id
        LEFT JOIN inv_accounting_classes ac ON i.acct_class_id = ac.acct_class_id
        WHERE i.item_id = ?
    ");
    $stmt->execute([$itemId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

/**
 * Get risk classes for an item.
 */
function getItemRiskClasses(PDO $pdo, int $itemId): array
{
    $stmt = $pdo->prepare("
        SELECT r.* FROM inv_risk_classes r
        JOIN inv_item_risk_classes irc ON r.risk_class_id = irc.risk_class_id
        WHERE irc.item_id = ?
        ORDER BY r.sort_order
    ");
    $stmt->execute([$itemId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/* ================================================================
   STOCK MOVEMENT RECORDING
================================================================ */

/**
 * Record an immutable stock transaction.
 */
function recordStockTransaction(PDO $pdo, array $data): int
{
    $stmt = $pdo->prepare("
        INSERT INTO inv_transactions
        (transaction_type, item_id, stock_id, location_id, quantity, unit_cost, total_cost,
         balance_after, reference_type, reference_id, reference_number,
         batch_lot_number, serial_number, expiry_date, performed_by, notes)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $data['transaction_type'],
        $data['item_id'],
        $data['stock_id'] ?? null,
        $data['location_id'] ?? null,
        $data['quantity'],
        $data['unit_cost'] ?? 0,
        $data['total_cost'] ?? 0,
        $data['balance_after'] ?? null,
        $data['reference_type'] ?? null,
        $data['reference_id'] ?? null,
        $data['reference_number'] ?? null,
        $data['batch_lot_number'] ?? null,
        $data['serial_number'] ?? null,
        $data['expiry_date'] ?? null,
        $_SESSION['user_id'] ?? null,
        $data['notes'] ?? null,
    ]);
    return (int) $pdo->lastInsertId();
}

/**
 * Increase stock at a location (receiving, adjustment gain, transfer in).
 */
function increaseStock(PDO $pdo, int $itemId, int $locationId, float $qty, array $extra = []): int
{
    // Try to find existing stock record matching batch/serial
    $batchLot = $extra['batch_lot_number'] ?? null;
    $serial = $extra['serial_number'] ?? null;
    $expiry = $extra['expiry_date'] ?? null;
    $unitCost = $extra['unit_cost'] ?? 0;

    $where = "item_id = ? AND location_id = ? AND stock_status = 'USABLE'";
    $params = [$itemId, $locationId];

    if ($batchLot) {
        $where .= " AND batch_lot_number = ?";
        $params[] = $batchLot;
    } else {
        $where .= " AND (batch_lot_number IS NULL OR batch_lot_number = '')";
    }

    if ($serial) {
        $where .= " AND serial_number = ?";
        $params[] = $serial;
    } else {
        $where .= " AND (serial_number IS NULL OR serial_number = '')";
    }

    $stmt = $pdo->prepare("SELECT stock_id, quantity_on_hand FROM inv_stock WHERE $where LIMIT 1");
    $stmt->execute($params);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        $newQty = (float) $existing['quantity_on_hand'] + $qty;
        $pdo->prepare("UPDATE inv_stock SET quantity_on_hand = ?, unit_cost = ?, expiry_date = COALESCE(?, expiry_date) WHERE stock_id = ?")
            ->execute([$newQty, $unitCost, $expiry, $existing['stock_id']]);
        return (int) $existing['stock_id'];
    }

    // Create new stock record
    $stmt = $pdo->prepare("
        INSERT INTO inv_stock (item_id, location_id, batch_lot_number, serial_number, expiry_date,
                               quantity_on_hand, unit_cost, stock_status, received_date)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'USABLE', CURDATE())
    ");
    $stmt->execute([$itemId, $locationId, $batchLot, $serial, $expiry, $qty, $unitCost]);
    return (int) $pdo->lastInsertId();
}

/**
 * Decrease stock at a location (issuing, adjustment loss, transfer out).
 * Uses FEFO/FIFO ordering.
 */
function decreaseStock(PDO $pdo, int $itemId, int $locationId, float $qty): array
{
    $stmt = $pdo->prepare("
        SELECT stock_id, quantity_on_hand, unit_cost, batch_lot_number, serial_number, expiry_date
        FROM inv_stock
        WHERE item_id = ? AND location_id = ? AND stock_status = 'USABLE' AND quantity_available > 0
        ORDER BY expiry_date ASC, received_date ASC
    ");
    $stmt->execute([$itemId, $locationId]);
    $batches = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $remaining = $qty;
    $consumed = [];

    foreach ($batches as $batch) {
        if ($remaining <= 0) break;
        $take = min($remaining, (float) $batch['quantity_on_hand']);
        $newQty = (float) $batch['quantity_on_hand'] - $take;

        $pdo->prepare("UPDATE inv_stock SET quantity_on_hand = ? WHERE stock_id = ?")
            ->execute([$newQty, $batch['stock_id']]);

        $consumed[] = [
            'stock_id' => $batch['stock_id'],
            'quantity' => $take,
            'unit_cost' => $batch['unit_cost'],
            'batch_lot_number' => $batch['batch_lot_number'],
            'serial_number' => $batch['serial_number'],
        ];
        $remaining -= $take;
    }

    return $consumed;
}

/**
 * Update the average cost of an item after receiving.
 */
function updateAverageCost(PDO $pdo, int $itemId): void
{
    $stmt = $pdo->prepare("
        SELECT COALESCE(SUM(quantity_on_hand * unit_cost), 0) AS total_value,
               COALESCE(SUM(quantity_on_hand), 0) AS total_qty
        FROM inv_stock
        WHERE item_id = ? AND stock_status = 'USABLE'
    ");
    $stmt->execute([$itemId]);
    $r = $stmt->fetch(PDO::FETCH_ASSOC);

    $avgCost = ((float) $r['total_qty'] > 0)
        ? (float) $r['total_value'] / (float) $r['total_qty']
        : 0;

    $pdo->prepare("UPDATE inv_items SET average_cost = ? WHERE item_id = ?")
        ->execute([round($avgCost, 2), $itemId]);
}

/* ================================================================
   SEGREGATION OF DUTIES CHECKS
================================================================ */

/**
 * Check if current user has a specific inventory role.
 */
function hasInvRole(PDO $pdo, string $roleCode, ?int $locationId = null): bool
{
    // Admin/SuperAdmin bypass
    if (in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'])) return true;

    $sql = "
        SELECT COUNT(*) FROM inv_user_roles ur
        JOIN inv_roles r ON ur.inv_role_id = r.inv_role_id
        WHERE ur.user_id = ? AND r.role_code = ? AND ur.is_active = 1
          AND (ur.effective_from IS NULL OR ur.effective_from <= CURDATE())
          AND (ur.effective_to IS NULL OR ur.effective_to >= CURDATE())
    ";
    $params = [$_SESSION['user_id'], $roleCode];

    if ($locationId) {
        $sql .= " AND (ur.location_id IS NULL OR ur.location_id = ?)";
        $params[] = $locationId;
    }

    // Also check delegations
    $delSql = "
        SELECT COUNT(*) FROM inv_delegations d
        JOIN inv_roles r ON d.inv_role_id = r.inv_role_id
        WHERE d.delegate_user_id = ? AND r.role_code = ? AND d.is_active = 1
          AND d.effective_from <= NOW() AND d.effective_to >= NOW()
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $directCount = (int) $stmt->fetchColumn();

    $stmt2 = $pdo->prepare($delSql);
    $stmt2->execute([$_SESSION['user_id'], $roleCode]);
    $delCount = (int) $stmt2->fetchColumn();

    return ($directCount + $delCount) > 0;
}

/**
 * Enforce that the current user did NOT perform a conflicting action on the same transaction.
 * Implements segregation of duties: same user cannot request+approve+receive+issue for same stock.
 */
function checkSegregation(PDO $pdo, string $referenceType, int $referenceId, string $conflictAction): bool
{
    $stmt = $pdo->prepare("
        SELECT COUNT(*) FROM inv_transactions
        WHERE reference_type = ? AND reference_id = ? AND performed_by = ?
          AND transaction_type = ?
    ");
    $stmt->execute([$referenceType, $referenceId, $_SESSION['user_id'], $conflictAction]);
    return (int) $stmt->fetchColumn() === 0; // true = no conflict
}

/* ================================================================
   DOCUMENT CONTROL
================================================================ */

/**
 * Create an inventory document record.
 */
function createInvDocument(PDO $pdo, string $docType, string $refTable, int $refId, ?string $notes = null): int
{
    $docNumber = generateDocumentNumber($pdo, $docType);
    $stmt = $pdo->prepare("
        INSERT INTO inv_documents (document_number, document_type, reference_table, reference_id,
                                   status, created_by, notes)
        VALUES (?, ?, ?, ?, 'DRAFT', ?, ?)
    ");
    $stmt->execute([$docNumber, $docType, $refTable, $refId, $_SESSION['user_id'] ?? null, $notes]);
    return (int) $pdo->lastInsertId();
}

/**
 * Lock a document after approval (no further edits).
 */
function lockDocument(PDO $pdo, int $documentId): void
{
    $pdo->prepare("
        UPDATE inv_documents SET is_locked = 1, status = 'APPROVED',
               approved_by = ?, approved_at = NOW()
        WHERE document_id = ? AND is_locked = 0
    ")->execute([$_SESSION['user_id'] ?? null, $documentId]);
}

/* ================================================================
   LOOKUP HELPERS
================================================================ */

function getCategories(PDO $pdo, bool $activeOnly = true): array
{
    $where = $activeOnly ? "WHERE is_active = 1" : "";
    return $pdo->query("SELECT * FROM inv_categories $where ORDER BY sort_order, category_name")->fetchAll(PDO::FETCH_ASSOC);
}

function getCriticalityClasses(PDO $pdo): array
{
    return $pdo->query("SELECT * FROM inv_criticality_classes ORDER BY sort_order")->fetchAll(PDO::FETCH_ASSOC);
}

function getRiskClasses(PDO $pdo): array
{
    return $pdo->query("SELECT * FROM inv_risk_classes ORDER BY sort_order")->fetchAll(PDO::FETCH_ASSOC);
}

function getAccountingClasses(PDO $pdo): array
{
    return $pdo->query("SELECT * FROM inv_accounting_classes ORDER BY sort_order")->fetchAll(PDO::FETCH_ASSOC);
}

function getUnitsOfMeasure(PDO $pdo): array
{
    return $pdo->query("SELECT * FROM inv_units_of_measure WHERE is_active = 1 ORDER BY uom_name")->fetchAll(PDO::FETCH_ASSOC);
}

function getActiveLocations(PDO $pdo): array
{
    return $pdo->query("
        SELECT l.*, u.full_name AS custodian_name
        FROM inv_locations l
        LEFT JOIN users u ON l.custodian_user_id = u.user_id
        WHERE l.is_active = 1
        ORDER BY l.site_campus, l.building, l.floor, l.room_storage_area
    ")->fetchAll(PDO::FETCH_ASSOC);
}

function getInvRoles(PDO $pdo): array
{
    return $pdo->query("SELECT * FROM inv_roles ORDER BY role_name")->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Inventory audit log helper.
 */
function logInventoryAudit(PDO $pdo, string $table, ?int $recordId, string $action, ?string $notes = null): void
{
    logAudit($pdo, $table, $recordId, $action, $notes);
}
