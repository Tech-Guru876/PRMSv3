<?php
function policyViolation($pdo, $action, $notes = '') {

    // Log to audit trail
    $stmt = $pdo->prepare("
        INSERT INTO audit_log
        (table_name, action, changed_by, notes)
        VALUES ('POLICY', ?, ?, ?)
    ");

    $stmt->execute([
        $action,
        $_SESSION['user_id'] ?? null,
        $notes
    ]);

    // Set friendly error message
    $_SESSION['error'] = $notes ?: 'Action not permitted by policy.';

    // Redirect back safely — validate referer is a local path to prevent open redirect
    $referer = $_SERVER['HTTP_REFERER'] ?? '';
    $parsedHost = parse_url($referer, PHP_URL_HOST);
    $isLocal = empty($parsedHost) || $parsedHost === ($_SERVER['HTTP_HOST'] ?? '');
    $safeRedirect = ($isLocal && !empty($referer)) ? $referer : '/dashboard/index.php';
    header("Location: " . $safeRedirect);
    exit;
}

function assertEditableRequest(array $request)
{
    if (strtoupper($request['status']) !== 'DRAFT') {
        pop(
            "This request is locked and can no longer be modified.",
            "/procurement/view.php?id=" . $request['request_id']
        );
        exit;
    }
}



