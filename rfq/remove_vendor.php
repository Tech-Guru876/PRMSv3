<?php
$REQUIRE_PERMISSION = 'add_rfq_vendor';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$rfq_id    = (int)($_GET['rfq_id'] ?? 0);
$vendor_id = (int)($_GET['vendor_id'] ?? 0);

if (!$rfq_id || !$vendor_id) {
    pop('Invalid request', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ */
$stmt = $pdo->prepare("SELECT rfq_id, rfq_number, status FROM rfqs WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$rfq = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$rfq) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

if ($rfq['status'] === 'AWARDED') {
    pop('Cannot remove vendors from an awarded RFQ', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Check vendor exists on this RFQ */
$stmt = $pdo->prepare("
    SELECT rv.rfq_vendor_id, v.vendor_name
    FROM rfq_vendors rv
    JOIN vendors v ON rv.vendor_id = v.vendor_id
    WHERE rv.rfq_id = ? AND rv.rfq_vendor_id = ?
");
$stmt->execute([$rfq_id, $vendor_id]);
$vendor = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$vendor) {
    pop('Vendor not found on this RFQ', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Prevent removal if vendor already submitted a quote */
$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_quotes WHERE rfq_vendor_id = ?");
$stmt->execute([$vendor_id]);

if ($stmt->fetchColumn() > 0) {
    pop('Cannot remove a vendor that has already submitted a quote', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Delete vendor from RFQ */
try {
    $pdo->prepare("DELETE FROM rfq_vendors WHERE rfq_id = ? AND rfq_vendor_id = ?")->execute([$rfq_id, $vendor_id]);
    logAudit($pdo, 'rfq_vendors', $rfq_id, 'DELETE', 'Vendor "' . $vendor['vendor_name'] . '" (rfq_vendor_id=' . $vendor_id . ') removed from RFQ');
    $_SESSION['popup_success'] = htmlspecialchars($vendor['vendor_name']) . ' removed from RFQ';
} catch (Throwable $e) {
    $_SESSION['popup_error'] = extractDbMessage($e);
}
header("Location: view.php?id=" . $rfq_id);
exit;
