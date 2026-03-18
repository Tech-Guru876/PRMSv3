<?php
$REQUIRE_PERMISSION = 'submit_request';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT']."/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$id = $_GET['id'] ?? null;

try {
    if (!$id || !is_numeric($id)) {
        throw new Exception("Invalid request.");
    }

    $stmt = $pdo->prepare("
        SELECT created_by, status, request_number, estimated_value, request_type, branch_id
        FROM procurement_requests
        WHERE request_id = ?
    ");
    $stmt->execute([$id]);
    $request = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$request) {
        throw new Exception("Request not found.");
    }

    // Only the creator can resubmit their declined request
    if ($request['created_by'] != $_SESSION['user_id']) {
        throw new Exception("You are not allowed to resubmit this request.");
    }

    // Only DECLINED requests can be resubmitted
    if (strtoupper($request['status']) !== 'DECLINED') {
        throw new Exception("Only declined requests can be resubmitted.");
    }

    // Start transaction
    $pdo->beginTransaction();

    // Clean up old approval chain entries from the declined submission
    $pdo->prepare("
        DELETE FROM request_approvals
        WHERE request_id = ?
    ")->execute([$id]);

    // Reset request to DRAFT status and clear decline reason
    $pdo->prepare("
        UPDATE procurement_requests
        SET status = 'DRAFT',
            approved_by = NULL,
            approved_at = NULL,
            decline_reason = NULL
        WHERE request_id = ?
    ")->execute([$id]);

    // Audit log for resubmission reset
    logAudit(
        $pdo,
        'procurement_requests',
        $id,
        'STATUS_CHANGE',
        'Declined → Draft (Resubmitted by ' . ($_SESSION['full_name'] ?? 'Unknown') . ')'
    );

    logRequestTimeline(
        $pdo,
        $id,
        'RESUBMITTED',
        'Request resubmitted after decline by ' . ($_SESSION['full_name'] ?? 'Unknown')
    );

    $pdo->commit();

    // Notify the approver that a declined request has been resubmitted
    require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
    notifyRequestResubmitted($id);

    pop(
        "Request reset to Draft. You may edit and submit again.",
        "/procurement/edit.php?id=" . $id,
        2000,
        "success"
    );

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    
    pop(
        "Error: " . $e->getMessage(),
        "/procurement/view.php?id=" . $id,
        2500,
        "error"
    );
    exit;
}
?>
