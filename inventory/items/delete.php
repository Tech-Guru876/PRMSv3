<?php
$REQUIRE_PERMISSION = 'delete_inventory_items';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    pop('Invalid request method.', '/inventory/items/list.php', 1500, 'warning');
    exit;
}

$itemId = (int) ($_POST['item_id'] ?? 0);
if ($itemId <= 0) {
    pop('Invalid item selected.', '/inventory/items/list.php', 1500, 'warning');
    exit;
}

$stmt = $pdo->prepare("SELECT item_id, item_code, item_name FROM inv_items WHERE item_id = ?");
$stmt->execute([$itemId]);
$item = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$item) {
    pop('Inventory item not found.', '/inventory/items/list.php', 1500, 'warning');
    exit;
}

try {
    $pdo->beginTransaction();

    $pdo->prepare("DELETE FROM inv_items WHERE item_id = ?")->execute([$itemId]);

    logInventoryAudit($pdo, 'inv_items', $itemId, 'DELETE', "Item deleted: {$item['item_code']} - {$item['item_name']}");
    $pdo->commit();

    pop("Item '{$item['item_name']}' deleted successfully.", '/inventory/items/list.php', 1500, 'success');
    exit;
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    error_log('Inventory item delete failed: ' . $e->getMessage());
    pop('This item cannot be deleted because it is linked to stock or transaction records.', '/inventory/items/list.php', 2200, 'error');
    exit;
}
