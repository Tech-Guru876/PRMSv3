<?php
$REQUIRE_PERMISSION = 'start_rfq_evaluation';

require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';

$rfq_id = (int)($_GET['id'] ?? 0);
if (!$rfq_id) {
    pop('Invalid RFQ ID', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$stmt = $pdo->prepare("
    SELECT r.request_id, pr.status, pr.estimated_value
    FROM rfqs r
    JOIN procurement_requests pr ON r.request_id = pr.request_id
    WHERE r.rfq_id = ?
");
$stmt->execute([$rfq_id]);
$data = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$data) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$request = ['status' => $data['status']];
$estimatedValue = (float)($data['estimated_value'] ?? 0);

// UPDATED: Check if this is under-threshold RFQ (skip committee evaluation)
$directThreshold = getDirectProcurementThreshold($pdo);
if ($estimatedValue <= $directThreshold) {
    // Under-threshold: Skip evaluation stage and go directly to quote review
    // No committee required for under-threshold
    enforceTransition($request, 'QUOTE_REVIEW_PENDING');
    
    try {
    $pdo->prepare("
        UPDATE procurement_requests
        SET status = 'QUOTE_REVIEW_PENDING'
        WHERE request_id = ?
    ")->execute([$data['request_id']]);

    // Also update RFQ status to PUBLISHED
    $pdo->prepare("UPDATE rfqs SET status = 'PUBLISHED' WHERE rfq_id = ?")->execute([$rfq_id]);
    } catch (Throwable $e) {
        require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
        pop(extractDbMessage($e), '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    // Notify quote reviewers (Requestor, HOD, Procurement)
    require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
    notifyQuoteReviewReady($data['request_id'], $rfq_id);
    
    pop('Under-threshold RFQ moved to quote review (no committee evaluation required).', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'success');
    exit;
}

// Over-threshold: Requires committee evaluation
enforceTransition($request, 'EVALUATION_STAGE');

/* SOP Step 7: Ensure ≥3 evaluation committee members before starting evaluation */
$committeeStmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_committee WHERE rfq_id = ?");
$committeeStmt->execute([$rfq_id]);
$committeeCount = $committeeStmt->fetchColumn();
if ($committeeCount < 3) {
    pop('Minimum 3 evaluation committee members required to start evaluation (SOP Step 7).', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

try {
$pdo->prepare("
    UPDATE procurement_requests
    SET status = 'EVALUATION_STAGE'
    WHERE request_id = ?
")->execute([$data['request_id']]);

// Also update RFQ status to EVALUATION
$pdo->prepare("UPDATE rfqs SET status = 'EVALUATION' WHERE rfq_id = ?")->execute([$rfq_id]);
} catch (Throwable $e) {
    require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
    pop(extractDbMessage($e), '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

// Notify evaluation committee members
require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
notifyEvaluationStarted($rfq_id);

header("Location: /rfq/view.php?id=".$rfq_id);
exit;

