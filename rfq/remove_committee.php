<?php
$REQUIRE_PERMISSION = 'manage_rfq_committee';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$rfq_id  = (int)($_GET['rfq_id'] ?? 0);
$user_id = (int)($_GET['user_id'] ?? 0);

if (!$rfq_id || !$user_id) {
    pop('Invalid request', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Prevent removal if report already exists */
$stmt = $pdo->prepare("
    SELECT COUNT(*) FROM rfq_evaluation_reports
    WHERE rfq_id = ?
");
$stmt->execute([$rfq_id]);

if ($stmt->fetchColumn() > 0) {
    pop('Cannot modify committee after evaluation report uploaded', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

try {
    $pdo->prepare("
        DELETE FROM rfq_evaluation_committee
        WHERE rfq_id = ? AND user_id = ?
    ")->execute([$rfq_id, $user_id]);

    logAudit($pdo, 'rfq_evaluation_committee', $rfq_id, 'DELETE', 'Committee member (user_id=' . $user_id . ') removed from RFQ');
} catch (Throwable $e) {
    pop(extractDbMessage($e), '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

header("Location: view.php?id=".$rfq_id);
exit;
