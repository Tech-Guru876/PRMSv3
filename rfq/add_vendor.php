<?php
$REQUIRE_PERMISSION = 'add_rfq_vendor';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/services/RFQService.php';


$rfq_id = (int)($_GET['rfq_id'] ?? 0);

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

if ($rfq['status'] === 'AWARDED') {
    pop('RFQ already awarded. Vendors cannot be added.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

//
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $vendor_id = (int)($_POST['vendor_id'] ?? 0);

    if (!$vendor_id) {
        pop('Vendor selection required', '/rfq/add_vendor.php?rfq_id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    /* Check blacklist */
    $stmt = $pdo->prepare("
        SELECT vendor_name, status 
        FROM vendors 
        WHERE vendor_id = ?
    ");
    $stmt->execute([$vendor_id]);
    $vendor = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$vendor) {
        pop('Vendor not found', '/rfq/add_vendor.php?rfq_id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    if ($vendor['status'] !== 'ACTIVE') {
        pop('Vendor is blacklisted', '/rfq/add_vendor.php?rfq_id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    /* Prevent duplicate */
    $stmt = $pdo->prepare("
        SELECT rfq_vendor_id
        FROM rfq_vendors
        WHERE rfq_id = ?
        AND vendor_id = ?
    ");
    $stmt->execute([$rfq_id, $vendor_id]);

    if ($stmt->fetch()) {
        pop('Vendor already added to this RFQ', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'warning');
        exit;
    }

    /* Insert */
    try {
    $stmt = $pdo->prepare("
        INSERT INTO rfq_vendors
        (rfq_id, vendor_id, response_status, created_at)
        VALUES (?, ?, 'PENDING', NOW())
    ");
    $stmt->execute([$rfq_id, $vendor_id]);

    $rfq_vendor_id = $pdo->lastInsertId();

    /* Fetch vendor email for notification */
    $vendorStmt = $pdo->prepare("SELECT email FROM vendors WHERE vendor_id = ?");
    $vendorStmt->execute([$vendor_id]);
    $vendorEmail = $vendorStmt->fetchColumn();

    /* Send RFQ email to vendor */
    $rfqService = new RFQService($pdo);
    $emailSent = false;
    if ($vendorEmail) {
        $emailSent = $rfqService->sendRFQToVendor($rfq_id, $vendor_id, $vendorEmail);
    }

    /* Audit */
    $auditNote = "Vendor '{$vendor['vendor_name']}' added to RFQ {$rfq['rfq_number']}";
    if ($emailSent) {
        $auditNote .= " - RFQ notification email sent to {$vendorEmail}";
    } elseif ($vendorEmail) {
        $auditNote .= " - Email notification failed for {$vendorEmail}";
    } else {
        $auditNote .= " - No email address on file";
    }

    $pdo->prepare("
        INSERT INTO audit_log
        (table_name, record_id, action, changed_by, change_date, notes)
        VALUES ('rfq_vendors', ?, 'CREATE', ?, NOW(), ?)
    ")->execute([
        $rfq_vendor_id,
        $_SESSION['user_id'],
        $auditNote
    ]);

    /* Show notification */
    $message = "Vendor '{$vendor['vendor_name']}' added to RFQ successfully.";
    if ($emailSent) {
        $message .= " RFQ notification sent to {$vendorEmail}.";
    }
    
    $_SESSION['popup_success'] = $message;
    } catch (Throwable $e) {
        require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
        $_SESSION['popup_error'] = extractDbMessage($e);
    }
    header("Location: view.php?id=" . $rfq_id);
    exit;
}

?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/header.php"; ?>

<h4 class="section-title">Add Vendor to RFQ <?= htmlspecialchars($rfq['rfq_number']) ?></h4>

<div class="card mt-3">
<div class="card-body">

<form method="POST">
    
    

<div class="mb-3">
<label class="form-label">Select Vendor</label>
<select name="vendor_id" class="form-control" required id="vendorSelect">
    <option value="">-- Select Vendor --</option>
    <?php
    $vendorsList = $pdo->query("
        SELECT vendor_id, vendor_name, email
        FROM vendors
        WHERE status = 'ACTIVE'
        ORDER BY vendor_name ASC
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($vendorsList as $v) {
        echo "<option value='{$v['vendor_id']}' 
                data-email='{$v['email']}'>
                {$v['vendor_name']}
              </option>";
    }
    ?>
</select>
</div>

<div class="mb-3">
<label class="form-label">Vendor Email</label>
<input type="text" id="vendorEmail" class="form-control" readonly>
</div>

<script>
document.getElementById('vendorSelect').addEventListener('change', function() {
    let selected = this.options[this.selectedIndex];
    document.getElementById('vendorEmail').value = selected.dataset.email || '';
});
</script>



<button type="submit" class="btn btn-success">
Add Vendor
</button>

<a href="view.php?id=<?= $rfq_id ?>" class="btn btn-secondary">
Cancel
</a>

</form>

</div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
