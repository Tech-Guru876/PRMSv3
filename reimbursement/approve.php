<?php
/**
 * Reimbursement Approval Handler
 * Finance Officer verifies funds and approves/declines reimbursement requests
 */
$REQUIRE_PERMISSION = 'approve_reimbursement_request';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/notifications.php';

$request_id = isset($_POST['request_id']) ? (int)$_POST['request_id'] : 0;
$action = isset($_POST['action']) ? trim($_POST['action']) : '';

if ($request_id <= 0) {
    pop("Invalid reimbursement request reference.", "/reimbursement/list.php");
    exit;
}

if (!in_array($action, ['approve', 'decline'])) {
    pop("Invalid action specified.", "/reimbursement/view.php?request_id=".$request_id);
    exit;
}

/* ================================
   Verify User Role
================================ */
$userRole = $_SESSION['role_name'] ?? '';
if ($userRole !== 'Finance Officer') {
    pop(
        "Only Finance Officers can approve reimbursement requests.",
        "/reimbursement/view.php?request_id=".$request_id,
        2000,
        "error"
    );
    exit;
}

/* ================================
   Fetch Request
================================ */
$stmt = $pdo->prepare("
    SELECT r.*, b.branch_name, u.full_name as requestor_name, u.email as requestor_email
    FROM procurement_requests r
    LEFT JOIN branches b ON r.branch_id = b.branch_id
    LEFT JOIN users u ON r.created_by = u.user_id
    WHERE r.request_id = ? AND r.request_type = 'REIMBURSEMENT'
    LIMIT 1
");
$stmt->execute([$request_id]);
$request = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$request) {
    pop("Reimbursement request not found.", "/reimbursement/list.php");
    exit;
}

/* ================================
   Status Validation
================================ */
if (strtoupper($request['status']) !== 'SUBMITTED') {
    pop(
        "This request is not pending approval. Current status: " . $request['status'],
        "/reimbursement/view.php?request_id=".$request_id,
        2000,
        "error"
    );
    exit;
}

try {
    $pdo->beginTransaction();

    $newStatus = ($action === 'approve') ? 'FUNDS_VERIFIED' : 'DECLINED';
    $notes = isset($_POST['notes']) ? trim($_POST['notes']) : '';

    /* ================================
       Update Request Status
    ================================ */
    $update = $pdo->prepare("
        UPDATE procurement_requests
        SET status = ?,
            updated_at = NOW()
        WHERE request_id = ?
    ");
    $update->execute([$newStatus, $request_id]);

    /* ================================
       Update Approval Record
    ================================ */
    $approvalUpdate = $pdo->prepare("
        UPDATE request_approvals
        SET status = ?,
            approved_by = ?,
            approved_at = NOW(),
            notes = ?
        WHERE request_id = ?
          AND role = 'Finance Officer'
          AND status = 'pending'
    ");
    $approvalUpdate->execute([
        ($action === 'approve') ? 'approved' : 'declined',
        $_SESSION['user_id'],
        $notes,
        $request_id
    ]);

    /* ================================
       Record Status History
    ================================ */
    $historyStmt = $pdo->prepare("
        INSERT INTO reimbursement_status_history
        (request_id, old_status, new_status, changed_by, change_notes)
        VALUES (?, ?, ?, ?, ?)
    ");
    $historyStmt->execute([
        $request_id,
        $request['status'],
        $newStatus,
        $_SESSION['user_id'],
        $notes ?: (($action === 'approve') ? 'Funds verified by Finance' : 'Declined by Finance')
    ]);

    /* ================================
       Audit Log
    ================================ */
    logAudit(
        $pdo,
        'procurement_requests',
        $request_id,
        'STATUS_CHANGE',
        "Reimbursement Request: {$request['status']} → {$newStatus} by Finance Officer"
    );

    /* ================================
       Notify Requestor
    ================================ */
    if ($action === 'approve') {
        notifyRequestFinalized($request_id, $newStatus);
    } else {
        // Declined — include the decline reason
        notifyRequestDeclined($request_id, (int)$request['created_by'], $notes ?: 'Your reimbursement request was declined by Finance.');
    }

    $pdo->commit();

    /* ================================
       Redirect
    ================================ */
    $message = ($action === 'approve') 
        ? "Reimbursement request funds verified and approved successfully."
        : "Reimbursement request has been declined.";
    
    pop(
        $message,
        "/reimbursement/view.php?request_id=".$request_id,
        1500,
        ($action === 'approve') ? "success" : "warning"
    );

} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log("Reimbursement approval error: " . $e->getMessage());
    pop(
        "Error processing approval: " . extractDbMessage($e),
        "/reimbursement/view.php?request_id=".$request_id,
        2000,
        "error"
    );
}
