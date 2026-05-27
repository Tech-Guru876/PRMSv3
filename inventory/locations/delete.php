<?php
$REQUIRE_PERMISSION = 'delete_inventory_locations';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$redirectPath = '/inventory/locations/list.php';
$referer = $_SERVER['HTTP_REFERER'] ?? '';
if ($referer !== '') {
    $parsedReferer = parse_url($referer);
    $refererHost = $parsedReferer['host'] ?? '';
    $refererPath = $parsedReferer['path'] ?? '';
    $refererQuery = isset($parsedReferer['query']) ? '?' . $parsedReferer['query'] : '';

    if (
        ($refererHost === '' || $refererHost === ($_SERVER['HTTP_HOST'] ?? '')) &&
        $refererPath !== '' &&
        str_starts_with($refererPath, '/') &&
        $refererPath !== '/inventory/locations/delete.php'
    ) {
        $redirectPath = $refererPath . $refererQuery;
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    pop('Invalid request method.', $redirectPath, 1500, 'warning');
    exit;
}

$locationId = (int) ($_POST['location_id'] ?? 0);
if ($locationId <= 0) {
    pop('Invalid location selected.', $redirectPath, 1500, 'warning');
    exit;
}

$stmt = $pdo->prepare("SELECT location_id, location_code FROM inv_locations WHERE location_id = ?");
$stmt->execute([$locationId]);
$location = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$location) {
    pop('Location not found.', $redirectPath, 1500, 'warning');
    exit;
}

try {
    $pdo->beginTransaction();

    $pdo->prepare("DELETE FROM inv_locations WHERE location_id = ?")->execute([$locationId]);

    logInventoryAudit($pdo, 'inv_locations', $locationId, 'DELETE', "Location deleted: {$location['location_code']}");
    $pdo->commit();

    pop("Location '{$location['location_code']}' deleted successfully.", $redirectPath, 1500, 'success');
    exit;
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    error_log('Inventory location delete failed: ' . $e->getMessage());
    pop('This location cannot be deleted because it is linked to stock or transaction records.', $redirectPath, 2200, 'error');
    exit;
}
