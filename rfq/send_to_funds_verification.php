<?php
/**
 * Send Request to Accounts for Funds Verification
 * ===============================================
 * After Procurement uploads vendor quotations, Procurement can either:
 *   Option A: Award the quotation/vendor (rfq/award.php), or
 *   Option B: Send directly to Accounts for Funds Verification (this action).
 *
 * This transitions the request to QUOTE_APPROVED so Finance/Accounts can
 * verify funds and create the commitment.
 */
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';

$rfq_id = (int)($_GET['rfq_id'] ?? 0);
$quote_id = (int)($_GET['quote_id'] ?? 0);

if (!$rfq_id) {
    pop('Invalid RFQ', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

// Only Procurement (or admins) may choose this path
$allowedRoles = ['Procurement Officer', 'Admin', 'SuperAdmin'];
if (!in_array($_SESSION['role_name'] ?? '', $allowedRoles, true)) {
    pop('Only Procurement Officers can send requests for funds verification.', '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ + request */
$stmt = $pdo->prepare("
    SELECT r.rfq_id, r.rfq_number, r.request_id, pr.status AS request_status, pr.request_number
    FROM rfqs r
    JOIN procurement_requests pr ON r.request_id = pr.request_id
    WHERE r.rfq_id = ?
");
$stmt->execute([$rfq_id]);
$rfq = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$rfq) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

if ($rfq['request_status'] !== 'QUOTE_REVIEW_PENDING') {
    pop('Requests can only be sent for funds verification during the quote review stage.', '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Ensure at least one quote has been uploaded */
$quoteCountStmt = $pdo->prepare("
    SELECT COUNT(*)
    FROM rfq_quotes q
    JOIN rfq_vendors rv ON q.rfq_vendor_id = rv.rfq_vendor_id
    WHERE rv.rfq_id = ?
");
$quoteCountStmt->execute([$rfq_id]);
if ((int)$quoteCountStmt->fetchColumn() === 0) {
    pop('At least one vendor quotation must be uploaded before sending for funds verification.', '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

try {
    $pdo->beginTransaction();

    /* Optionally mark a preferred quote as selected */
    $vendorName = null;
    $quoteAmount = 0.0;
    if ($quote_id) {
        $quoteStmt = $pdo->prepare("
            SELECT q.quote_id, q.quote_amount, v.vendor_name
            FROM rfq_quotes q
            JOIN rfq_vendors rv ON q.rfq_vendor_id = rv.rfq_vendor_id
            JOIN vendors v ON rv.vendor_id = v.vendor_id
            WHERE q.quote_id = ? AND rv.rfq_id = ?
        ");
        $quoteStmt->execute([$quote_id, $rfq_id]);
        $quote = $quoteStmt->fetch(PDO::FETCH_ASSOC);
        if ($quote) {
            $pdo->prepare("UPDATE rfq_quotes SET is_selected = 1 WHERE quote_id = ?")->execute([$quote_id]);
            $pdo->prepare("
                UPDATE rfq_quotes SET is_selected = 0
                WHERE quote_id != ? AND rfq_vendor_id IN (SELECT rfq_vendor_id FROM rfq_vendors WHERE rfq_id = ?)
            ")->execute([$quote_id, $rfq_id]);
            $vendorName = $quote['vendor_name'];
            $quoteAmount = (float)$quote['quote_amount'];
        }
    }

    /* Transition to QUOTE_APPROVED — routes to Accounts/Finance for funds verification */
    $pdo->prepare("
        UPDATE procurement_requests
        SET status = 'QUOTE_APPROVED'
        WHERE request_id = ?
    ")->execute([$rfq['request_id']]);

    logAudit(
        $pdo,
        'procurement_requests',
        (int)$rfq['request_id'],
        'STATUS_CHANGE',
        'Sent directly to Accounts for funds verification by Procurement (' . ($_SESSION['full_name'] ?? 'Unknown') . ')'
        . ($vendorName ? " — Preferred vendor: $vendorName" : '')
    );

    logRequestTimeline(
        $pdo,
        (int)$rfq['request_id'],
        'SENT_FOR_FUNDS_VERIFICATION',
        'Procurement sent request to Accounts for funds verification'
        . ($vendorName ? " (preferred vendor: $vendorName)" : '')
    );

    $pdo->commit();

    /* Notify Finance that funds verification / commitment is needed */
    require_once $_SERVER['DOCUMENT_ROOT'] . "/config/notifications.php";
    notifyFinanceCommitmentNeeded((int)$rfq['request_id'], $vendorName ?? 'To be determined', $quoteAmount);

    pop('Request sent to Accounts for funds verification.', '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'success');
    exit;

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    pop('Error sending for funds verification: ' . $e->getMessage(), '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}
