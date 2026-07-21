<?php
/**
 * Upload Document for a Procurement Request
 * Handles signed POs, signed commitments, and other documents per request
 */
$REQUIRE_PERMISSION = 'view_request';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /procurement/list.php');
    exit;
}

$request_id = (int)($_POST['request_id'] ?? 0);
if ($request_id <= 0) {
    pop("Invalid request.", "/procurement/list.php", 2500, "warning");
    exit;
}

// Verify request exists
$stmt = $pdo->prepare("SELECT request_id, request_number FROM procurement_requests WHERE request_id = ?");
$stmt->execute([$request_id]);
$request = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$request) {
    pop("Request not found.", "/procurement/list.php", 2500, "warning");
    exit;
}

try {
    // Validate document type
    $documentType = $_POST['document_type'] ?? 'OTHER';
    if (!in_array($documentType, ['SIGNED_PO', 'SIGNED_COMMITMENT', 'MEMO', 'OTHER'])) {
        throw new Exception("Invalid document type.");
    }

    $notes = trim($_POST['notes'] ?? '');
    if (strlen($notes) > 255) {
        throw new Exception("Notes must not exceed 255 characters.");
    }

    // Validate file upload
    if (!isset($_FILES['document_file']) || $_FILES['document_file']['error'] === UPLOAD_ERR_NO_FILE) {
        throw new Exception("Please select a file to upload.");
    }

    $file = $_FILES['document_file'];
    if ($file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception("File upload failed. Please try again.");
    }

    // Validate file type
    $allowedTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ];

    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, $allowedTypes)) {
        throw new Exception("Invalid file type. Only PDF, Word, and Excel files are allowed.");
    }

    // Validate file size (50MB max)
    if ($file['size'] > 50 * 1024 * 1024) {
        throw new Exception("File size exceeds 50 MB limit.");
    }

    // Save file
    $uploadDir = $_SERVER['DOCUMENT_ROOT'] . '/uploads/request_documents/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $safeFilename = strtoupper($documentType) . '_' . $request_id . '_' . time() . '_' . uniqid() . '.' . $ext;
    $uploadPath = $uploadDir . $safeFilename;

    if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
        throw new Exception("Failed to save document.");
    }

    $documentPath = '/uploads/request_documents/' . $safeFilename;
    $originalName = $file['name'];

    // Insert into request_documents table
    $stmt = $pdo->prepare("
        INSERT INTO request_documents (request_id, document_type, document_name, document_path, uploaded_by, notes)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $request_id,
        $documentType,
        $originalName,
        $documentPath,
        $_SESSION['user_id'],
        !empty($notes) ? $notes : null
    ]);

    $typeLabels = [
        'SIGNED_PO' => 'Signed PO',
        'SIGNED_COMMITMENT' => 'Signed Commitment',
        'MEMO' => 'Supporting Memo',
        'OTHER' => 'Document'
    ];
    $typeLabel = $typeLabels[$documentType] ?? 'Document';

    logAudit($pdo, 'request_documents', $pdo->lastInsertId(), 'CREATE',
            "$typeLabel uploaded for request {$request['request_number']}");
    logRequestTimeline($pdo, $request_id, 'DOCUMENT_UPLOADED',
                      "$typeLabel uploaded: $originalName");

    pop(
        "$typeLabel uploaded successfully.",
        "/procurement/view.php?id=" . $request_id,
        2500,
        "success"
    );

} catch (Exception $e) {
    pop(extractDbMessage($e), "/procurement/view.php?id=" . $request_id, 2500, "error");
}