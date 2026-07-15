<?php
$REQUIRE_PERMISSION = 'import_inventory_assets';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$batchId = (int)($_GET['batch_id'] ?? 0);
if ($batchId <= 0) {
    http_response_code(400);
    exit('Missing batch_id.');
}

$stmt = $pdo->prepare("SELECT source_file_name FROM inv_import_batches WHERE batch_id = ?");
$stmt->execute([$batchId]);
$batch = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$batch) {
    http_response_code(404);
    exit('Import batch not found.');
}

$errors = $pdo->prepare("
    SELECT `row_number`, asset_code, field, message
    FROM inv_import_errors
    WHERE batch_id = ?
    ORDER BY `row_number` ASC, error_id ASC
");
$errors->execute([$batchId]);

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="import_errors_batch_' . $batchId . '.csv"');

$out = fopen('php://output', 'w');
fputcsv($out, ['Row Number', 'Asset Code', 'Field', 'Error Message'], ',', '"', '\\');
while ($row = $errors->fetch(PDO::FETCH_ASSOC)) {
    fputcsv($out, [$row['row_number'], $row['asset_code'], $row['field'], $row['message']], ',', '"', '\\');
}
fclose($out);
exit;
