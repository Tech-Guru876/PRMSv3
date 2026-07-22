<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT']."/config/page_guard.php";
require_once $_SERVER['DOCUMENT_ROOT']."/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT']."/config/helper.php";

/* ================================
   Validate input
================================ */
$user_id = $_POST['user_id'] ?? null;
$new_role_id = $_POST['role_id'] ?? null;

if (!ctype_digit((string)$user_id) || !ctype_digit((string)$new_role_id)) {
    pop("Invalid role update request.", "/users/list.php", 1500, "error");
    exit;
}

$user_id = (int)$user_id;
$new_role_id = (int)$new_role_id;

/* ================================
   Prevent self-role change
================================ */
if ($user_id === (int)$_SESSION['user_id']) {
    pop("You cannot change your own role.", "/users/list.php", 1500, "warning");
    exit;
}

/* ================================
   Validate role exists
================================ */
$stmt = $pdo->prepare("SELECT name FROM roles WHERE id = ?");
$stmt->execute([$new_role_id]);
$role = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$role) {
    pop("Selected role does not exist.", "/users/list.php", 1500, "error");
    exit;
}

/* ================================
   Update role_id
================================ */
$stmt = $pdo->prepare("
    UPDATE users
    SET role_id = ?
    WHERE user_id = ?
");
$stmt->execute([$new_role_id, $user_id]);

/* ================================
   Sync user_roles table (ensure primary role is also in user_roles)
================================ */
try {
    $pdo->prepare("
        INSERT IGNORE INTO user_roles (user_id, role_id, assigned_by)
        VALUES (?, ?, ?)
    ")->execute([$user_id, $new_role_id, $_SESSION['user_id'] ?? null]);
} catch (Throwable $e) {
    // user_roles table may not exist yet
    error_log('user_roles sync: ' . $e->getMessage());
}

/* ================================
   Audit log
================================ */
logAudit(
    $pdo,
    'users',
    $user_id,
    'ROLE_CHANGE',
    "Role updated to {$role['name']}"
);

pop("User role updated successfully.", "/users/list.php", 1200, "success");
exit;
