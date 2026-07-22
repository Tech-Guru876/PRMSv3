<?php
/**
 * po/receive_to_inventory.php
 *
 * Creates a Draft GRN pre-populated from the selected Purchase Order
 * and redirects the user to the GRN edit form to complete receiving.
 *
 * Workflow:
 *  1. User clicks "Receive to Inventory" on the PO view page.
 *  2. This page validates the request and creates the Draft GRN.
 *  3. User is redirected to /inventory/receiving/add.php?id=<grnId>
 *     to fill in received quantities, lot numbers, etc.
 */

$REQUIRE_PERMISSION = 'receive_goods';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/ProcurementInventoryBridge.php';

$poId = (int) ($_GET['po_id'] ?? 0);

if ($poId <= 0) {
    pop("Invalid Purchase Order ID.", "/po/list.php", 1800, 'danger');
    exit;
}

// Validate PO exists
$po = $pdo->prepare("SELECT po_id, po_number, status FROM purchase_orders WHERE po_id = ?");
$po->execute([$poId]);
$poRow = $po->fetch(PDO::FETCH_ASSOC);

if (!$poRow) {
    pop("Purchase Order not found.", "/po/list.php", 1800, 'danger');
    exit;
}

// Check whether a GRN already exists for this PO
$existingGrns = ProcurementInventoryBridge::getGrnsForPo($pdo, $poId);

if (count($existingGrns) > 0) {
    // If there is already at least one GRN, redirect to the latest one
    $latest = $existingGrns[0];
    if (in_array($latest['status'], ['DRAFT', 'INSPECTION'])) {
        pop(
            "A draft GRN ({$latest['grn_number']}) already exists for this PO. Redirecting to edit it.",
            "/inventory/receiving/add.php?id={$latest['grn_id']}",
            2000,
            'info'
        );
        exit;
    }
}

// Determine a default receiving location (first active location)
$defaultLocation = $pdo->query(
    "SELECT location_id FROM inv_locations WHERE is_active = 1 ORDER BY location_id LIMIT 1"
)->fetchColumn();

if (!$defaultLocation) {
    pop(
        "No active inventory locations found. Please set up at least one location before receiving goods.",
        "/po/view.php?po_id=$poId",
        2500,
        'warning'
    );
    exit;
}

// Verify inventory tables exist
if (!inventoryTablesExist($pdo)) {
    pop(
        "The inventory module has not been set up yet. Please run migration 019_inventory_management_system.sql first.",
        "/po/view.php?po_id=$poId",
        2500,
        'warning'
    );
    exit;
}

try {
    $grnId = ProcurementInventoryBridge::createGrnFromPo(
        $pdo,
        $poId,
        (int) $defaultLocation,
        (int) $_SESSION['user_id']
    );

    pop(
        "Draft GRN created from PO {$poRow['po_number']}. Please verify quantities and complete receiving.",
        "/inventory/receiving/add.php?id=$grnId",
        2000,
        'success'
    );
} catch (RuntimeException $e) {
    pop(extractDbMessage($e), "/po/view.php?po_id=$poId", 2500, 'warning');
} catch (Throwable $e) {
    error_log("GRN creation from PO failed: " . $e->getMessage());
    pop("An unexpected error occurred while creating the GRN.", "/po/view.php?po_id=$poId", 2500, 'danger');
}
exit;
