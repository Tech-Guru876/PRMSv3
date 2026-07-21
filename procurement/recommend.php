<?php
$REQUIRE_PERMISSION = 'approve_request';

require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';

$id = (int)($_GET['id'] ?? 0);
if (!$id) {
    pop('Invalid request ID', '/procurement/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM procurement_requests WHERE request_id = ?");
$stmt->execute([$id]);
$request = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$request) {
    pop('Request not found', '/procurement/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

enforceTransition($request, 'COMMITTEE_RECOMMENDED');

/* SOP Step 7: Ensure ≥3 evaluation committee members */
$rfqStmt = $pdo->prepare("SELECT rfq_id FROM rfqs WHERE request_id = ?");
$rfqStmt->execute([$id]);
$rfqRow = $rfqStmt->fetch(PDO::FETCH_ASSOC);

if (!$rfqRow) {
    pop('No RFQ found for this request. RFQ is required before recommendation.', '/procurement/view.php?id='.$id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$committeeStmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_committee WHERE rfq_id = ?");
$committeeStmt->execute([$rfqRow['rfq_id']]);
if ($committeeStmt->fetchColumn() < 3) {
    pop('Minimum 3 evaluation committee members required before recommendation (SOP Step 7).', '/rfq/view.php?id='.$rfqRow['rfq_id'], POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* SOP Step 8: Evaluation report must be uploaded before recommendation */
$reportStmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_reports WHERE rfq_id = ?");
$reportStmt->execute([$rfqRow['rfq_id']]);
if ($reportStmt->fetchColumn() == 0) {
    pop('Evaluation report must be uploaded before committee recommendation (SOP Step 8).', '/rfq/view.php?id='.$rfqRow['rfq_id'], POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$stmt = $pdo->prepare("
    UPDATE procurement_requests
    SET status = 'COMMITTEE_RECOMMENDED'
    WHERE request_id = ?
");
try {
    $stmt->execute([$id]);
} catch (Throwable $e) {
    pop(extractDbMessage($e), '/procurement/view.php?id='.$id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

logAudit($pdo, 'procurement_requests', $id, 'STATUS_CHANGE', 'Committee Recommended — Status changed to COMMITTEE_RECOMMENDED');
logRequestTimeline($pdo, $id, 'COMMITTEE_RECOMMENDED', 'Committee recommendation by ' . ($_SESSION['full_name'] ?? 'Unknown'));

header("Location: view.php?id=".$id);
exit;