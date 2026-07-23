<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT']."/config/page_guard.php";
require_once $_SERVER['DOCUMENT_ROOT']."/config/db.php";

/* Validate input */
$user_id = $_POST['user_id'] ?? null;
$current = $_POST['current'] ?? null;

if (!ctype_digit((string)$user_id) || !in_array($current, ['0','1',0,1], true)) {
    pop("Invalid request.", "/users/list.php", 1500);
    exit;
}

/* Prevent self-disable */
if ((int)$user_id === (int)$_SESSION['user_id']) {
    pop("You cannot disable your own account.", "/users/list.php", 1500);
    exit;
}

$newStatus = $current ? 0 : 1;

/* Update status */
try {
$stmt = $pdo->prepare("
    UPDATE users
    SET is_active = ?
    WHERE user_id = ?
");
$stmt->execute([$newStatus, $user_id]);

/* Audit log */
$log = $pdo->prepare("
    INSERT INTO audit_log
    (table_name, record_id, action, changed_by, notes)
    VALUES ('users', ?, 'STATUS_TOGGLE', ?, ?)
");
$log->execute([
    $user_id,
    $_SESSION['user_id'],
    $newStatus ? 'User re-enabled' : 'User disabled'
]);

pop("User status updated.", "/users/list.php", 1200);
} catch (Throwable $e) {
    require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
    pop(extractDbMessage($e), "/users/list.php", 1500, 'error');
}
exit;
