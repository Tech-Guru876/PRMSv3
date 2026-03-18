<?php
$REQUIRE_PERMISSION = 'create_commitment';  // Finance Officers & Procurement Officers
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/helper.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/workflow.php";

// Allow Finance Officers AND Procurement Officers
$allowedCommitmentRoles = ['Finance Officer', 'Procurement Officer', 'Admin', 'SuperAdmin'];
if (!in_array(($_SESSION['role'] ?? ''), $allowedCommitmentRoles)) {
    pop("Only Finance and Procurement Officers can manage commitments.", "/procurement/list.php", 2500, "warning");
    exit;
}

$userRole = $_SESSION['role'] ?? '';
$isFinance = in_array($userRole, ['Finance Officer', 'Admin', 'SuperAdmin']);
$isProcurement = in_array($userRole, ['Procurement Officer', 'Admin', 'SuperAdmin']);

$request_id = isset($_GET['request_id']) ? (int)$_GET['request_id'] : 0;
if ($request_id <= 0) {
    pop("Invalid Request", "/procurement/list.php", 2500, "warning");
    exit;
}

/* ===== Get Request & Quote Details ===== */
$stmt = $pdo->prepare("
    SELECT 
        pr.request_id,
        pr.request_number,
        pr.status,
        pr.estimated_value,
        pr.currency,
        pr.usd_rate,
        pr.requires_rfq,
        rq.quote_id,
        rq.quote_amount,
        rq.gct_amount,
        rq.validity_days,
        rq.currency AS quote_currency,
        rq.usd_rate AS quote_usd_rate,
        rv.vendor_name
    FROM procurement_requests pr
    LEFT JOIN rfqs rf ON pr.request_id = rf.request_id
    LEFT JOIN rfq_quotes rq ON rq.is_selected = 1 
        AND rq.rfq_vendor_id IN (SELECT rfq_vendor_id FROM rfq_vendors WHERE rfq_id = rf.rfq_id)
    LEFT JOIN rfq_vendors rv ON rv.rfq_vendor_id = rq.rfq_vendor_id
    WHERE pr.request_id = ?
");
$stmt->execute([$request_id]);
$request = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$request) {
    pop("Request not found", "/procurement/list.php", 2500, "warning");
    exit;
}

// Check if funds already verified but commitment not yet uploaded
$existingCommitment = null;
$fundsVerified = false;
$checkStmt = $pdo->prepare("SELECT * FROM commitments WHERE request_id = ? AND commitment_type = 'ORIGINAL'");
$checkStmt->execute([$request_id]);
$existingCommitment = $checkStmt->fetch(PDO::FETCH_ASSOC);

// Determine current step based on request status and existing commitment
$currentStep = 'verify_funds'; // Step 1: Finance verifies funds
$requestStatus = strtoupper($request['status']);
if ($requestStatus === 'FUNDS_VERIFIED') {
    $currentStep = 'fill_commitment'; // Step 2: Procurement fills commitment form
} elseif ($requestStatus === 'COMMITMENTS_PENDING') {
    $currentStep = 'upload_commitment'; // Step 3: Finance uploads commitment document
}
if ($existingCommitment && !empty($existingCommitment['document_path']) && $existingCommitment['status'] === 'closed') {
    $currentStep = 'completed'; // Already done
}

// Role access control per step
if ($currentStep === 'verify_funds' && !$isFinance) {
    pop("Funds have not been verified yet. Finance Officers must verify funds first.", "/procurement/view.php?id=" . $request_id, 2500, "warning");
    exit;
}
if ($currentStep === 'fill_commitment' && !$isProcurement) {
    pop("Funds have been verified. Procurement Officers need to fill out the commitment form.", "/procurement/view.php?id=" . $request_id, 2500, "warning");
    exit;
}
if ($currentStep === 'upload_commitment' && !$isFinance) {
    pop("Commitment form submitted. Finance Officers need to upload the commitment document.", "/procurement/view.php?id=" . $request_id, 2500, "warning");
    exit;
}

// Verify request is in correct status for commitment creation
$allowedStatuses = ['QUOTE_APPROVED', 'COMMITMENT_REVIEW_PENDING', 'AWARDED', 'FUNDS_VERIFIED', 'COMMITMENTS_PENDING', 'HOD_APPROVED', 'GC_APPROVED', 'DIRECTOR_APPROVED'];
if (!in_array(strtoupper($request['status']), $allowedStatuses)) {
    pop(
        "This request is not ready for commitment creation. Current status: " . $request['status'],
        "/procurement/view.php?id=" . $request_id,
        2500,
        "warning"
    );
    exit;
}

// Calculate JMD amount for commitment if currency is USD
$requestCurrency = normalizeCurrency($request['currency'] ?? 'JMD');
$requestUsdRate = (float)($request['usd_rate'] ?? 0);
$quoteForCommitment = (float)($request['quote_amount'] ?? $request['estimated_value']);
$quoteCurrency = normalizeCurrency($request['quote_currency'] ?? $requestCurrency);
$quoteUsdRate = (float)($request['quote_usd_rate'] ?? $requestUsdRate);

// Get system USD rate as fallback
$sysRateStmt = $pdo->prepare("SELECT config_value FROM system_config WHERE config_key = 'usd_to_jmd_rate'");
$sysRateStmt->execute();
$systemUsdRate = (float)($sysRateStmt->fetchColumn() ?: 155.00);

// Auto-convert to JMD if quote/request is in USD
$commitmentDefaultAmount = $quoteForCommitment;
if ($quoteCurrency === 'USD' || $requestCurrency === 'USD') {
    $rateToUse = $quoteUsdRate > 0 ? $quoteUsdRate : ($requestUsdRate > 0 ? $requestUsdRate : $systemUsdRate);
    $commitmentDefaultAmount = $quoteForCommitment * $rateToUse;
}

/* ===== Handle POST ===== */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? null;
    
    try {
        if ($action === 'decline') {
            /* ===== DECLINE COMMITMENT ===== */
            $declineReason = trim($_POST['decline_reason'] ?? '');
            
            if (empty($declineReason) || strlen($declineReason) < 10) {
                throw new Exception("Please provide a detailed reason for declining (minimum 10 characters).");
            }
            
            if (strlen($declineReason) > 1000) {
                throw new Exception("Reason must not exceed 1000 characters.");
            }
            
            $pdo->beginTransaction();
            
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'COMMITMENT_DECLINED'
                WHERE request_id = ?
            ")->execute([$request_id]);
            
            logAudit($pdo, 'procurement_requests', $request_id, 'COMMITMENT_DECLINED', 
                     "Finance declined - Reason: " . substr($declineReason, 0, 100));
            
            logRequestTimeline($pdo, $request_id, 'COMMITMENT_DECLINED',
                              "Finance Officer: Funds not available. Reason: $declineReason");
            
            $pdo->commit();
            
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyCommitmentAction($request_id, '', 'DECLINED', 'Finance Officer declined commitment. Reason: ' . $declineReason);
            
            pop(
                "Commitment declined. The request has been returned to the requestor for revision.",
                "/procurement/view.php?id=" . $request_id,
                2500,
                "success"
            );
            exit;
            
        } elseif ($action === 'verify_funds') {
            /* ===== STEP 1: VERIFY FUNDS (Finance) ===== */
            if (!$isFinance) {
                throw new Exception("Only Finance Officers can verify funds.");
            }
            
            $pdo->beginTransaction();
            
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'FUNDS_VERIFIED', funds_available = 1,
                    finance_reviewed_by = ?, finance_reviewed_at = NOW()
                WHERE request_id = ?
            ")->execute([$_SESSION['user_id'], $request_id]);
            
            logAudit($pdo, 'procurement_requests', $request_id, 'FUNDS_VERIFIED',
                    "Funds verified by Finance Officer");
            logRequestTimeline($pdo, $request_id, 'FUNDS_VERIFIED',
                              "Finance Officer verified funds are available. Procurement Officer to fill commitment form.");
            
            $pdo->commit();

            // Notify Procurement Officers to fill commitment form
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyProcurementCommitmentFormNeeded($request_id);
            
            pop(
                "Funds verified successfully. Procurement has been notified to fill out the commitment form.",
                "/procurement/view.php?id=" . $request_id,
                2500,
                "success"
            );
            exit;
            
        } elseif ($action === 'submit_commitment_form') {
            /* ===== STEP 2: PROCUREMENT SUBMITS COMMITMENT FORM ===== */
            if (!$isProcurement) {
                throw new Exception("Only Procurement Officers can submit the commitment form.");
            }
            
            $commitmentDate  = trim($_POST['commitment_date'] ?? '');
            $commitmentTotal = $_POST['commitment_total'] ?? null;
            $gfmsNumber      = trim($_POST['gfms_commitment_number'] ?? '');
            
            if (empty($commitmentDate)) {
                throw new Exception("Commitment date is required.");
            }
            
            if (empty($commitmentTotal) || (float)$commitmentTotal <= 0) {
                throw new Exception("Commitment amount must be greater than zero.");
            }
            
            // Validate GFMS number if provided
            if (!empty($gfmsNumber)) {
                $checkGfms = $pdo->prepare("SELECT commitment_id FROM commitments WHERE gfms_commitment_number = ? LIMIT 1");
                $checkGfms->execute([$gfmsNumber]);
                if ($checkGfms->fetchColumn()) {
                    throw new Exception("This GFMS Commitment Number already exists in the system.");
                }
                if (!preg_match('/^[a-zA-Z0-9\-\/\.]+$/', $gfmsNumber)) {
                    throw new Exception("Invalid GFMS number format.");
                }
                if (strlen($gfmsNumber) > 50) {
                    throw new Exception("GFMS number too long (max 50 chars).");
                }
            }
            
            // Handle optional commitment form upload
            $formDocPath = null;
            if (isset($_FILES['commitment_form_doc']) && $_FILES['commitment_form_doc']['error'] === UPLOAD_ERR_OK) {
                $file = $_FILES['commitment_form_doc'];
                
                $allowedTypes = ['application/pdf', 'application/msword',
                                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                'application/vnd.ms-excel',
                                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                'image/jpeg', 'image/png'];
                
                $finfo = finfo_open(FILEINFO_MIME_TYPE);
                $mimeType = finfo_file($finfo, $file['tmp_name']);
                finfo_close($finfo);
                
                if (!in_array($mimeType, $allowedTypes)) {
                    throw new Exception("Invalid file type. Only PDF, Word, Excel, JPEG and PNG files are allowed.");
                }
                if ($file['size'] > 50 * 1024 * 1024) {
                    throw new Exception("File size exceeds 50 MB limit.");
                }
                
                $uploadDir = $_SERVER['DOCUMENT_ROOT'] . '/uploads/commitments/';
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }
                $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
                $safeFilename = 'COMMIT_FORM_' . time() . '_' . uniqid() . '.' . $ext;
                $uploadPath = $uploadDir . $safeFilename;
                if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
                    throw new Exception("Failed to save commitment form document.");
                }
                $formDocPath = '/uploads/commitments/' . $safeFilename;
            }
            
            // Generate commitment number
            $commitmentNumber = generateCommitmentNumber($pdo);
            
            $pdo->beginTransaction();
            
            // Create commitment record (pending Finance to create & upload)
            $stmt = $pdo->prepare("
                INSERT INTO commitments
                (request_id, commitment_number, commitment_date, commitment_total, gfms_commitment_number, document_path, status, commitment_type)
                VALUES (?, ?, ?, ?, ?, ?, 'open', 'ORIGINAL')
            ");
            $stmt->execute([
                $request_id,
                $commitmentNumber,
                $commitmentDate,
                (float)$commitmentTotal,
                !empty($gfmsNumber) ? $gfmsNumber : null,
                $formDocPath
            ]);
            
            $commitment_id = $pdo->lastInsertId();
            
            // Update request status
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'COMMITMENTS_PENDING'
                WHERE request_id = ?
            ")->execute([$request_id]);
            
            $formNote = $formDocPath ? ' (form document attached)' : ' (paper form submitted)';
            logAudit($pdo, 'commitments', $commitment_id, 'CREATE',
                    "Commitment form submitted by Procurement Officer" . $formNote);
            logRequestTimeline($pdo, $request_id, 'COMMITMENTS_PENDING',
                              "Procurement Officer submitted commitment form $commitmentNumber{$formNote}. Awaiting Finance to create commitment.");
            
            $pdo->commit();
            
            // Notify Finance Officers to create commitment
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyFinanceCommitmentUploadNeeded($request_id, $commitmentNumber);
            
            pop(
                "Commitment form submitted successfully. Finance has been notified to create the commitment.",
                "/procurement/view.php?id=" . $request_id,
                2500,
                "success"
            );
            exit;
            
        } elseif ($action === 'upload_commitment') {
            /* ===== STEP 3: FINANCE CREATES COMMITMENT & UPLOADS DOCUMENT ===== */
            if (!$isFinance) {
                throw new Exception("Only Finance Officers can create commitments.");
            }
            
            $commitmentDate  = trim($_POST['commitment_date'] ?? '');
            $commitmentTotal = $_POST['commitment_total'] ?? null;
            $gfmsNumber      = trim($_POST['gfms_commitment_number'] ?? '');
            
            if (empty($commitmentDate)) {
                throw new Exception("Commitment date is required.");
            }
            
            if (empty($commitmentTotal) || (float)$commitmentTotal <= 0) {
                throw new Exception("Commitment amount must be greater than zero.");
            }
            
            // Validate GFMS number if provided
            if (!empty($gfmsNumber)) {
                $excludeId = $existingCommitment['commitment_id'] ?? 0;
                $checkGfms = $pdo->prepare("SELECT commitment_id FROM commitments WHERE gfms_commitment_number = ? AND commitment_id != ? LIMIT 1");
                $checkGfms->execute([$gfmsNumber, $excludeId]);
                if ($checkGfms->fetchColumn()) {
                    throw new Exception("This GFMS Commitment Number already exists in the system.");
                }
                if (!preg_match('/^[a-zA-Z0-9\-\/\.]+$/', $gfmsNumber)) {
                    throw new Exception("Invalid GFMS number format.");
                }
                if (strlen($gfmsNumber) > 50) {
                    throw new Exception("GFMS number too long (max 50 chars).");
                }
            }
            
            // Handle document upload (REQUIRED)
            $documentPath = null;
            if (!isset($_FILES['commitment_document']) || $_FILES['commitment_document']['error'] === UPLOAD_ERR_NO_FILE) {
                throw new Exception("Commitment document from GFMS is required.");
            }
            
            $file = $_FILES['commitment_document'];
            
            if ($file['error'] !== UPLOAD_ERR_OK) {
                throw new Exception("File upload failed. Please try again.");
            }
            
            $allowedTypes = ['application/pdf', 'application/msword', 
                            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                            'application/vnd.ms-excel',
                            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
            
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mimeType = finfo_file($finfo, $file['tmp_name']);
            finfo_close($finfo);
            
            if (!in_array($mimeType, $allowedTypes)) {
                throw new Exception("Invalid file type. Only PDF, Word, and Excel files are allowed.");
            }
            
            if ($file['size'] > 50 * 1024 * 1024) {
                throw new Exception("File size exceeds 50 MB limit.");
            }
            
            // Save file
            $uploadDir = $_SERVER['DOCUMENT_ROOT'] . '/uploads/commitments/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            
            $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
            $safeFilename = 'COMMITMENT_' . time() . '_' . uniqid() . '.' . $ext;
            $uploadPath = $uploadDir . $safeFilename;
            
            if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
                throw new Exception("Failed to save commitment document.");
            }
            
            $documentPath = '/uploads/commitments/' . $safeFilename;
            
            $pdo->beginTransaction();
            
            if ($existingCommitment) {
                // Update existing commitment record from Procurement's form
                $stmt = $pdo->prepare("
                    UPDATE commitments
                    SET commitment_date = ?, commitment_total = ?, gfms_commitment_number = ?,
                        document_path = ?, status = 'closed', approved_at = NOW()
                    WHERE commitment_id = ?
                ");
                $stmt->execute([
                    $commitmentDate,
                    (float)$commitmentTotal,
                    !empty($gfmsNumber) ? $gfmsNumber : null,
                    $documentPath,
                    $existingCommitment['commitment_id']
                ]);
                $commitmentNumber = $existingCommitment['commitment_number'];
                $commitment_id = $existingCommitment['commitment_id'];
            } else {
                // Create new commitment record (Finance creating directly)
                $commitmentNumber = generateCommitmentNumber($pdo);
                $stmt = $pdo->prepare("
                    INSERT INTO commitments
                    (request_id, commitment_number, commitment_date, commitment_total, gfms_commitment_number, document_path, status, approved_at, commitment_type)
                    VALUES (?, ?, ?, ?, ?, ?, 'closed', NOW(), 'ORIGINAL')
                ");
                $stmt->execute([
                    $request_id,
                    $commitmentNumber,
                    $commitmentDate,
                    (float)$commitmentTotal,
                    !empty($gfmsNumber) ? $gfmsNumber : null,
                    $documentPath
                ]);
                $commitment_id = $pdo->lastInsertId();
            }
            
            // Update request status to COMMITMENT_APPROVED
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'COMMITMENT_APPROVED'
                WHERE request_id = ?
            ")->execute([$request_id]);
            
            logAudit($pdo, 'commitments', $commitment_id, $existingCommitment ? 'UPDATE' : 'CREATE',
                    "Commitment created and document uploaded by Finance Officer");
            
            logRequestTimeline($pdo, $request_id, 'COMMITMENT_APPROVED',
                              "Finance Officer created commitment $commitmentNumber and uploaded document. Ready for PO creation.");
            
            $pdo->commit();
            
            // Notify about commitment creation — email Procurement Officers
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyCommitmentAction($request_id, $commitmentNumber, 'APPROVED', 'Funds verified and commitment created from GFMS. Ready for PO creation.');
            notifyProcurementOfCommitment($request_id, $commitmentNumber);
            
            pop(
                "Commitment created and document uploaded successfully. Procurement has been notified. Request moves to PO creation stage.",
                "/commitments/view.php?commitment_id=" . $commitment_id,
                2500,
                "success"
            );
            exit;
            
        } else {
            throw new Exception("Invalid action.");
        }
        
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        pop($e->getMessage(), "/commitments/add.php?request_id=" . $request_id, 2500, "error");
        exit;
    }
}

/* ===== Render Page ===== */
require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/header.php";
?>

<div class="container mt-4">
    <div class="row mb-4">
        <div class="col-lg-10">
            <h3 class="section-title">💰 Commitment Workflow</h3>
            <p class="text-muted">
                <?php if ($isFinance && $currentStep === 'verify_funds'): ?>
                    Step 1: Verify funds availability
                <?php elseif ($isProcurement && $currentStep === 'fill_commitment'): ?>
                    Step 2: Fill out commitment form and submit to Finance
                <?php elseif ($isFinance && $currentStep === 'upload_commitment'): ?>
                    Step 3: Create commitment and upload document from GFMS
                <?php else: ?>
                    Funds verification and commitment creation
                <?php endif; ?>
            </p>
        </div>
    </div>

    <!-- Step Progress Indicator -->
    <div class="card mb-4 border-0 shadow-sm">
        <div class="card-body">
            <div class="d-flex justify-content-center gap-4">
                <div class="text-center">
                    <?php
                    $step1Done = in_array($currentStep, ['fill_commitment', 'upload_commitment', 'completed']);
                    $step1Active = $currentStep === 'verify_funds';
                    ?>
                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-2 <?= $step1Active ? 'bg-primary text-white' : ($step1Done ? 'bg-success text-white' : 'bg-light text-muted') ?>" style="width:48px;height:48px;font-size:1.2rem;font-weight:bold;">1</div>
                    <div class="small fw-bold">Verify Funds</div>
                    <div class="small text-muted">Finance</div>
                </div>
                <div class="d-flex align-items-center mb-4"><i class="bi bi-arrow-right fs-4 text-muted"></i></div>
                <div class="text-center">
                    <?php
                    $step2Done = in_array($currentStep, ['upload_commitment', 'completed']);
                    $step2Active = $currentStep === 'fill_commitment';
                    ?>
                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-2 <?= $step2Active ? 'bg-primary text-white' : ($step2Done ? 'bg-success text-white' : 'bg-light text-muted') ?>" style="width:48px;height:48px;font-size:1.2rem;font-weight:bold;">2</div>
                    <div class="small fw-bold">Commitment Form</div>
                    <div class="small text-muted">Procurement</div>
                </div>
                <div class="d-flex align-items-center mb-4"><i class="bi bi-arrow-right fs-4 text-muted"></i></div>
                <div class="text-center">
                    <?php
                    $step3Done = $currentStep === 'completed';
                    $step3Active = $currentStep === 'upload_commitment';
                    ?>
                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-2 <?= $step3Active ? 'bg-primary text-white' : ($step3Done ? 'bg-success text-white' : 'bg-light text-muted') ?>" style="width:48px;height:48px;font-size:1.2rem;font-weight:bold;">3</div>
                    <div class="small fw-bold">Create Commitment</div>
                    <div class="small text-muted">Finance</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Request & Quote Details Card -->
    <div class="card mb-4 border-start border-info border-3">
        <div class="card-header bg-info text-white">
            <h5 class="mb-0">📋 Request & Selected Quote Details</h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Request Number</small>
                        <h6 class="fw-bold text-primary"><?= htmlspecialchars($request['request_number']) ?></h6>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Request Amount</small>
                        <h6 class="fw-bold text-success">
                            <?= $requestCurrency ?> <?= number_format((float)$request['estimated_value'], 2) ?>
                            <?php if ($requestCurrency === 'USD' && $requestUsdRate > 0): ?>
                                <small class="text-muted">(≈ JMD <?= number_format((float)$request['estimated_value'] * $requestUsdRate, 2) ?>)</small>
                            <?php endif; ?>
                        </h6>
                    </div>
                </div>
                <?php if (!empty($request['vendor_name'])): ?>
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Selected Vendor</small>
                        <h6 class="fw-bold"><?= htmlspecialchars($request['vendor_name']) ?></h6>
                    </div>
                </div>
                <?php endif; ?>
                <?php if (!empty($request['quote_amount'])): ?>
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Quote Amount</small>
                        <h6 class="fw-bold text-success">
                            <?= ($quoteCurrency ?? 'JMD') ?> <?= number_format((float)$request['quote_amount'], 2) ?>
                            <?php if (($quoteCurrency ?? 'JMD') === 'USD'): ?>
                                <small class="text-muted">(≈ JMD <?= number_format($commitmentDefaultAmount, 2) ?>)</small>
                            <?php endif; ?>
                        </h6>
                    </div>
                </div>
                <?php endif; ?>
                <?php if (!empty($request['gct_amount'])): ?>
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">GCT Amount</small>
                        <h6><?= ($quoteCurrency ?? 'JMD') ?> <?= number_format((float)$request['gct_amount'], 2) ?></h6>
                    </div>
                </div>
                <?php endif; ?>
                <?php if (!empty($request['validity_days'])): ?>
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Quote Validity</small>
                        <h6><?= (int)$request['validity_days'] ?> days</h6>
                    </div>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <?php if ($currentStep === 'completed'): ?>
        <!-- Already completed -->
        <div class="alert alert-success">
            <i class="bi bi-check-circle me-2"></i>
            <strong>Commitment already created.</strong> 
            <a href="/commitments/view.php?commitment_id=<?= $existingCommitment['commitment_id'] ?>" class="alert-link">View Commitment</a>
        </div>
    <?php elseif ($currentStep === 'verify_funds'): ?>
        <!-- STEP 1: VERIFY FUNDS (Finance) -->
        <div class="card border-success mb-4">
            <div class="card-header bg-success text-white">
                <h5 class="mb-0">✅ Step 1: Verify Funds Availability</h5>
            </div>
            <div class="card-body">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    Confirm that sufficient funds are available in the appropriate cost center for this request.
                    Once verified, Procurement will be notified to fill out the commitment form.
                </div>
                
                <div class="d-flex gap-2">
                    <form method="post" class="flex-grow-1">
                        <input type="hidden" name="action" value="verify_funds">
                        <button type="submit" class="btn btn-success btn-lg w-100" onclick="return confirm('Confirm that funds are available for this request?')">
                            <i class="bi bi-check-circle me-1"></i> Verify Funds Available
                        </button>
                    </form>
                </div>
                
                <hr>
                
                <!-- Decline Option -->
                <div class="mt-3">
                    <h6 class="text-danger"><i class="bi bi-x-circle me-1"></i> Or Decline</h6>
                    <form method="post">
                        <input type="hidden" name="action" value="decline">
                        <div class="mb-3">
                            <textarea name="decline_reason" class="form-control" rows="4" 
                                      placeholder="Explain why funds cannot be committed..." minlength="10" maxlength="1000" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-danger">
                            <i class="bi bi-x-circle me-1"></i> Decline & Return Request
                        </button>
                    </form>
                </div>
            </div>
        </div>
    <?php elseif ($currentStep === 'fill_commitment'): ?>
        <!-- STEP 2: PROCUREMENT FILLS COMMITMENT FORM -->
        <div class="card border-warning mb-4">
            <div class="card-header bg-warning text-dark">
                <h5 class="mb-0">📝 Step 2: Submit Commitment Form</h5>
            </div>
            <div class="card-body">
                <div class="alert alert-success mb-4">
                    <i class="bi bi-check-circle me-2"></i>
                    <strong>Funds verified by Finance!</strong> Please fill out the commitment details below and submit to Finance. You can also attach a scanned copy of the paper commitment form (optional).
                </div>

                <form method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="submit_commitment_form">
                    
                    <!-- Commitment Date -->
                    <div class="mb-4">
                        <label for="commitment_date" class="form-label">
                            <i class="bi bi-calendar-event"></i>
                            <span class="text-danger">*</span> Commitment Date
                        </label>
                        <input type="date" id="commitment_date" name="commitment_date"
                               class="form-control form-control-lg"
                               value="<?= date('Y-m-d') ?>" required>
                    </div>

                    <!-- Commitment Amount (always in JMD) -->
                    <div class="mb-4">
                        <label for="commitment_total" class="form-label">
                            <i class="bi bi-currency-dollar"></i>
                            <span class="text-danger">*</span> Commitment Amount (JMD)
                        </label>
                        <div class="input-group">
                            <span class="input-group-text">JMD</span>
                            <input type="number" id="commitment_total" name="commitment_total"
                                   class="form-control form-control-lg" step="0.01" placeholder="0.00"
                                   value="<?= htmlspecialchars(number_format($commitmentDefaultAmount, 2, '.', '')) ?>"
                                   required>
                        </div>
                        <?php if ($quoteCurrency === 'USD' || $requestCurrency === 'USD'): ?>
                        <small class="text-info d-block mt-2">
                            <i class="bi bi-info-circle"></i>
                            Auto-converted from USD to JMD using rate: 1 USD = <?= number_format($rateToUse ?? $systemUsdRate, 2) ?> JMD
                        </small>
                        <?php else: ?>
                        <small class="text-muted d-block mt-2">Amount being committed (in JMD)</small>
                        <?php endif; ?>
                    </div>

                    <!-- GFMS Number -->
                    <div class="mb-4">
                        <label for="gfms_commitment_number" class="form-label">
                            <i class="bi bi-bank"></i> GFMS Commitment Number (Optional)
                        </label>
                        <input type="text" id="gfms_commitment_number" name="gfms_commitment_number"
                               class="form-control form-control-lg" placeholder="e.g., GC/2026/CM/00001" maxlength="50">
                    </div>

                    <!-- Optional: Upload scanned commitment form -->
                    <div class="mb-4">
                        <label for="commitment_form_doc" class="form-label">
                            <i class="bi bi-paperclip"></i> Attach Commitment Form (Optional)
                        </label>
                        <input type="file" id="commitment_form_doc" name="commitment_form_doc"
                               class="form-control" accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png">
                        <small class="text-muted d-block mt-2">
                            Optional: Upload a scanned copy of the paper commitment form (PDF, Word, Excel, JPEG, PNG). Max 50 MB.
                        </small>
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-warning btn-lg text-dark" onclick="return confirm('Submit this commitment form to Finance?')">
                            <i class="bi bi-send me-1"></i> Submit Commitment Form to Finance
                        </button>
                        <a href="/procurement/view.php?id=<?= $request_id ?>" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
    <?php else: ?>
        <!-- STEP 3: FINANCE CREATES COMMITMENT & UPLOADS DOCUMENT -->
        <div class="card border-primary mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">📄 Step 3: Create Commitment & Upload Document</h5>
            </div>
            <div class="card-body">
                <div class="alert alert-success mb-4">
                    <i class="bi bi-check-circle me-2"></i>
                    <strong>Commitment form received from Procurement!</strong> Review the details, create the commitment in GFMS, and upload the commitment document.
                </div>

                <?php if ($existingCommitment): ?>
                <div class="alert alert-info mb-4">
                    <h6 class="fw-bold mb-2"><i class="bi bi-clipboard-data me-1"></i> Commitment Details from Procurement</h6>
                    <div class="row">
                        <div class="col-md-4">
                            <small class="text-muted d-block">Commitment Number</small>
                            <strong><?= htmlspecialchars($existingCommitment['commitment_number']) ?></strong>
                        </div>
                        <div class="col-md-4">
                            <small class="text-muted d-block">Commitment Date</small>
                            <strong><?= htmlspecialchars($existingCommitment['commitment_date']) ?></strong>
                        </div>
                        <div class="col-md-4">
                            <small class="text-muted d-block">Commitment Amount</small>
                            <strong>JMD <?= number_format((float)$existingCommitment['commitment_total'], 2) ?></strong>
                        </div>
                        <?php if (!empty($existingCommitment['gfms_commitment_number'])): ?>
                        <div class="col-md-4 mt-2">
                            <small class="text-muted d-block">GFMS Number</small>
                            <strong><?= htmlspecialchars($existingCommitment['gfms_commitment_number']) ?></strong>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($existingCommitment['document_path'])): ?>
                        <div class="col-md-4 mt-2">
                            <small class="text-muted d-block">Attached Form</small>
                            <a href="<?= htmlspecialchars($existingCommitment['document_path']) ?>" target="_blank" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-file-earmark me-1"></i>View
                            </a>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
                <?php endif; ?>

                <form method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="upload_commitment">
                    
                    <!-- Commitment Date (pre-filled from Procurement, can be adjusted) -->
                    <div class="mb-4">
                        <label for="commitment_date" class="form-label">
                            <i class="bi bi-calendar-event"></i>
                            <span class="text-danger">*</span> Commitment Date
                        </label>
                        <input type="date" id="commitment_date" name="commitment_date"
                               class="form-control form-control-lg"
                               value="<?= htmlspecialchars($existingCommitment['commitment_date'] ?? date('Y-m-d')) ?>" required>
                    </div>

                    <!-- Commitment Amount (pre-filled from Procurement, can be adjusted) -->
                    <div class="mb-4">
                        <label for="commitment_total" class="form-label">
                            <i class="bi bi-currency-dollar"></i>
                            <span class="text-danger">*</span> Commitment Amount (JMD)
                        </label>
                        <div class="input-group">
                            <span class="input-group-text">JMD</span>
                            <input type="number" id="commitment_total" name="commitment_total"
                                   class="form-control form-control-lg" step="0.01" placeholder="0.00"
                                   value="<?= htmlspecialchars(number_format((float)($existingCommitment['commitment_total'] ?? $commitmentDefaultAmount), 2, '.', '')) ?>"
                                   required>
                        </div>
                        <small class="text-muted d-block mt-2">Pre-filled from Procurement's submission. You may adjust if needed.</small>
                    </div>

                    <!-- GFMS Number (pre-filled from Procurement, can be adjusted) -->
                    <div class="mb-4">
                        <label for="gfms_commitment_number" class="form-label">
                            <i class="bi bi-bank"></i> GFMS Commitment Number
                        </label>
                        <input type="text" id="gfms_commitment_number" name="gfms_commitment_number"
                               class="form-control form-control-lg" placeholder="e.g., GC/2026/CM/00001" maxlength="50"
                               value="<?= htmlspecialchars($existingCommitment['gfms_commitment_number'] ?? '') ?>">
                    </div>

                    <!-- Commitment Document Upload -->
                    <div class="mb-4">
                        <label for="commitment_document" class="form-label">
                            <i class="bi bi-file-pdf text-danger"></i>
                            <span class="text-danger">*</span> Commitment Document from GFMS
                        </label>
                        <input type="file" id="commitment_document" name="commitment_document"
                               class="form-control form-control-lg" accept=".pdf,.doc,.docx,.xls,.xlsx" required>
                        <small class="text-muted d-block mt-2">
                            <strong>Required:</strong> Upload the commitment document from GFMS (PDF, DOC, DOCX, XLS, XLSX). Max 50 MB.
                        </small>
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <i class="bi bi-cloud-upload me-1"></i> Create Commitment & Upload Document
                        </button>
                        <a href="/procurement/view.php?id=<?= $request_id ?>" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
    <?php endif; ?>

    <!-- Information -->
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <i class="bi bi-lightbulb"></i>
        <strong>Commitment Workflow:</strong>
        <ul class="mb-0 ms-3 mt-2">
            <li><strong>Step 1 (Finance):</strong> Verify that sufficient funds are available</li>
            <li><strong>Step 2 (Procurement):</strong> Fill out the commitment form (paper) and submit details to Finance. Optionally attach a scanned copy.</li>
            <li><strong>Step 3 (Finance):</strong> Create the commitment in GFMS and upload the commitment document</li>
            <li><strong>After creation:</strong> Procurement will be notified automatically to create the PO</li>
        </ul>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
