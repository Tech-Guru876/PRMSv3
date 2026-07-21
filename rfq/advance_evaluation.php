<?php
/**
 * Advance Over-Threshold RFQ: EVALUATION_STAGE → COMMITTEE_RECOMMENDED
 * 
 * After committee evaluation completes (3+ members, majority vote, report uploaded),
 * the Procurement Officer submits the RFQ for GC Approval (SOP Step 10).
 * The Deputy Government Chemist must then approve before an award can be made.
 */
$REQUIRE_PERMISSION = 'start_rfq_evaluation';

require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';

$rfq_id = (int)($_GET['id'] ?? 0);
if (!$rfq_id) {
    pop('Invalid RFQ ID', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ and request data */
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

$currentStatus = $data['status'];
$estimatedValue = (float)($data['estimated_value'] ?? 0);
$isUnderThreshold = $estimatedValue <= getDirectProcurementThreshold($pdo);

/* Only for over-threshold RFQs in evaluation stage */
if ($isUnderThreshold) {
    pop('This action is only for over-threshold RFQs.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

if (!in_array($currentStatus, ['PROCUREMENT_STAGE', 'EVALUATION_STAGE', 'COMMITTEE_RECOMMENDED'])) {
    pop('RFQ is not in evaluation stage (current: '.$currentStatus.').', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Verify committee evaluation is complete */
$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_committee WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$committeeCount = (int)$stmt->fetchColumn();

if ($committeeCount < 3) {
    pop('Minimum 3 evaluation committee members required.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_reports WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$reportCount = (int)$stmt->fetchColumn();

if ($reportCount < 1) {
    pop('Evaluation report must be uploaded before advancing.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

$stmt = $pdo->prepare("
    SELECT rfq_vendor_id, COUNT(*) as votes
    FROM rfq_votes WHERE rfq_id = ?
    GROUP BY rfq_vendor_id ORDER BY votes DESC LIMIT 1
");
$stmt->execute([$rfq_id]);
$topVote = $stmt->fetch(PDO::FETCH_ASSOC);

$majorityMet = ($topVote && $topVote['votes'] > ($committeeCount / 2));
if (!$majorityMet) {
    pop('Committee must reach a majority vote before advancing.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Advance to COMMITTEE_RECOMMENDED and create pending GC approval */
$pdo->beginTransaction();
try {
    $pdo->prepare("
        UPDATE procurement_requests
        SET status = 'COMMITTEE_RECOMMENDED'
        WHERE request_id = ?
    ")->execute([$data['request_id']]);

    $pdo->prepare("
        UPDATE rfqs SET status = 'PUBLISHED' WHERE rfq_id = ?
    ")->execute([$rfq_id]);

    /* Create a pending GC approval entry so gc_approve.php can process it */
    // First check if there's already a pending GC approval for this request
    $existingGc = $pdo->prepare("
        SELECT COUNT(*) FROM request_approvals
        WHERE request_id = ? AND role = 'Deputy Government Chemist' AND status = 'pending'
    ");
    $existingGc->execute([$data['request_id']]);
    if ($existingGc->fetchColumn() == 0) {
        // Find the highest stage_order currently used
        $maxOrderStmt = $pdo->prepare("
            SELECT COALESCE(MAX(stage_order), 0) FROM request_approvals WHERE request_id = ?
        ");
        $maxOrderStmt->execute([$data['request_id']]);
        $nextOrder = (int)$maxOrderStmt->fetchColumn() + 1;

        $pdo->prepare("
            INSERT INTO request_approvals
            (entity_type, entity_id, request_id, role, stage_order, status)
            VALUES ('REQUEST', ?, ?, 'Deputy Government Chemist', ?, 'pending')
        ")->execute([$data['request_id'], $data['request_id'], $nextOrder]);
    }

    /* Audit log */
    $pdo->prepare("
        INSERT INTO audit_log
        (table_name, record_id, action, changed_by, change_date, notes)
        VALUES ('rfqs', ?, 'ADVANCE_EVALUATION', ?, NOW(), ?)
    ")->execute([
        $rfq_id,
        $_SESSION['user_id'],
        "Advanced over-threshold RFQ from $currentStatus to COMMITTEE_RECOMMENDED — pending GC approval (SOP Step 10)"
    ]);

    $pdo->commit();
    
    /* Notify Deputy Government Chemist that GC approval is needed */
    require_once $_SERVER['DOCUMENT_ROOT'].'/config/notifications.php';
    $dgcUsers = getUsersByRole('Deputy Government Chemist');
    foreach ($dgcUsers as $dgcUser) {
        if (!empty($dgcUser['email'])) {
            notifyApprovalNeeded($data['request_id'], 'GC_APPROVED', (int)$dgcUser['user_id']);
        }
    }
    
    pop('Committee evaluation complete. Submitted for GC Approval (SOP Step 10).', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'success');
} catch (Exception $e) {
    $pdo->rollBack();
    pop('Error: '.extractDbMessage($e), '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
}
exit;
