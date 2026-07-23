<?php
$REQUIRE_PERMISSION = 'vote_rfq';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$rfq_id = (int)($_GET['rfq_id'] ?? 0);
$rfq_vendor_id = (int)($_GET['rfq_vendor_id'] ?? 0);
$user_id = $_SESSION['user_id'];

if (!$rfq_id || !$rfq_vendor_id) {
    pop('Invalid vote', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Prevent duplicate vote */
$stmt = $pdo->prepare("
    SELECT COUNT(*) FROM rfq_votes
    WHERE rfq_id = ? AND user_id = ?
");
$stmt->execute([$rfq_id, $user_id]);

if ($stmt->fetchColumn() > 0) {
    pop('You have already voted', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'warning');
    exit;
}

/* Ensure user is committee member */
$stmt = $pdo->prepare("
    SELECT COUNT(*) FROM rfq_evaluation_committee
    WHERE rfq_id = ? AND user_id = ?
");
$stmt->execute([$rfq_id, $user_id]);

if ($stmt->fetchColumn() == 0) {
    pop('Only committee members may vote', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}


try {
$stmt = $pdo->prepare("
    INSERT INTO rfq_votes (rfq_id, user_id, rfq_vendor_id)
    VALUES (?, ?, ?)
");
$stmt->execute([$rfq_id, $user_id, $rfq_vendor_id]);

logAudit($pdo, 'rfq_votes', $rfq_id, 'CREATE', 'Vote cast for vendor (rfq_vendor_id=' . $rfq_vendor_id . ')');
} catch (Throwable $e) {
    pop(extractDbMessage($e), '/rfq/view.php?id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

header("Location: view.php?id=".$rfq_id);
exit;
