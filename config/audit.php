<?php
if (!function_exists('logAudit')) {
function logAudit(
    PDO $pdo,
    string $table,
    ?int $recordId,
    string $action,
    ?string $notes = null
): void {
    $stmt = $pdo->prepare("
        INSERT INTO audit_log
        (table_name, record_id, action, changed_by, notes, change_date)
        VALUES (?, ?, ?, ?, ?, NOW())
    ");

    $stmt->execute([
        $table,
        $recordId,
        strtoupper($action),
        $_SESSION['full_name'] ?? null,
        $notes
    ]);
}
}
