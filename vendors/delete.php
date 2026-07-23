<?php
$REQUIRE_PERMISSION = 'manage_vendors';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$id = (int)($_GET['id'] ?? 0);

if ($id <= 0) {
    pop('Invalid vendor ID', '/vendors/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch vendor */
$stmt = $pdo->prepare("SELECT vendor_id, vendor_name FROM vendors WHERE vendor_id = ?");
$stmt->execute([$id]);
$vendor = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$vendor) {
    pop('Vendor not found', '/vendors/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Block deletion if vendor is linked to any RFQ */
$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_vendors WHERE vendor_id = ?");
$stmt->execute([$id]);

if ($stmt->fetchColumn() > 0) {
    pop('Cannot delete vendor — they are linked to one or more RFQs. Set them to Inactive instead.', '/vendors/view.php?id='.$id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Delete vendor */
try {
    $pdo->prepare("DELETE FROM vendors WHERE vendor_id = ?")->execute([$id]);
    logAudit($pdo, 'vendors', $id, 'DELETE', 'Vendor "' . $vendor['vendor_name'] . '" deleted from master list');
    $_SESSION['popup_success'] = htmlspecialchars($vendor['vendor_name']) . ' has been deleted';
} catch (Throwable $e) {
    $_SESSION['popup_error'] = extractDbMessage($e);
}
header("Location: /vendors/list.php");
exit;
