<?php
/**
 * Send RFQ emails to vendors for a specific RFQ
 * Can send to all vendors or resend to specific vendors
 */

$REQUIRE_PERMISSION = 'add_rfq_vendor';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/services/RFQService.php';

$rfq_id = (int)($_GET['rfq_id'] ?? $_POST['rfq_id'] ?? 0);

if ($rfq_id <= 0) {
    pop('Invalid RFQ', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ */
$stmt = $pdo->prepare("
    SELECT rfq_id, rfq_number, status
    FROM rfqs
    WHERE rfq_id = ?
");
$stmt->execute([$rfq_id]);
$rfq = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$rfq) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $rfqService = new RFQService($pdo);

        if (!$rfqService->autoEmailEnabled()) {
            $_SESSION['popup_error'] = "RFQ auto-email distribution is disabled. An administrator can enable it under Admin → Settings.";
            header("Location: view.php?id=" . $rfq_id);
            exit;
        }

        // Send to all vendors
        $results = $rfqService->sendRFQToAllVendors($rfq_id);

        // Audit
        $auditNote = "RFQ emails sent - Total: {$results['total']}, Sent: {$results['sent']}, Failed: {$results['failed']}";
        if (!empty($results['errors'])) {
            $auditNote .= " - Errors: " . implode("; ", $results['errors']);
        }

        $pdo->prepare("
            INSERT INTO audit_log
            (table_name, record_id, action, changed_by, change_date, notes)
            VALUES ('rfqs', ?, 'UPDATE', ?, NOW(), ?)
        ")->execute([
            $rfq_id,
            $_SESSION['user_id'],
            $auditNote
        ]);

        // Show result
        if ($results['sent'] > 0) {
            $message = "{$results['sent']} RFQ email(s) sent successfully";
            if ($results['failed'] > 0) {
                $message .= " ({$results['failed']} failed)";
            }
            $_SESSION['popup_success'] = $message;
        } else {
            $_SESSION['popup_error'] = "Failed to send RFQ emails. " . implode("; ", $results['errors'] ?? ["Unknown error"]);
        }

        header("Location: view.php?id=" . $rfq_id);
        exit;

    } catch (Throwable $e) {
        $_SESSION['popup_error'] = "Error sending RFQ emails: " . $e->getMessage();
        header("Location: view.php?id=" . $rfq_id);
        exit;
    }
}

// GET request - show confirmation
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="container mt-4">
    <div class="alert alert-warning" role="alert">
        <i class="bi bi-exclamation-triangle me-2"></i>
        <strong>Send RFQ Notifications</strong>
        <p class="mt-2 mb-0">
            This will send the RFQ details to all vendors registered for <strong><?= htmlspecialchars($rfq['rfq_number']) ?></strong>.
        </p>
    </div>

    <form method="POST" class="mt-4">
        <input type="hidden" name="rfq_id" value="<?= $rfq_id ?>">
        
        <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-send me-2"></i>Send RFQ Emails
            </button>
            <a href="view.php?id=<?= $rfq_id ?>" class="btn btn-secondary">
                <i class="bi bi-arrow-left me-2"></i>Cancel
            </a>
        </div>
    </form>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
