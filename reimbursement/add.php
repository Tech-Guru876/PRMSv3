<?php
$REQUIRE_PERMISSION = 'create_reimbursement_request';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/helper.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/workflow.php";

/* ═══════════════════════════════════════════════════════
   Handle POST - Create Reimbursement Request
═══════════════════════════════════════════════════════ */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $branch_id = (int)($_POST['branch_id'] ?? 0);
        $request_date = trim($_POST['request_date'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $estimated_value = (float)($_POST['estimated_value'] ?? 0);
        $invoice_amount = (float)($_POST['invoice_amount'] ?? 0);

        // Validation
        if ($branch_id <= 0) {
            throw new Exception("Branch selection is required.");
        }

        if (empty($request_date)) {
            throw new Exception("Request date is required.");
        }

        if ($invoice_amount <= 0) {
            throw new Exception("Invoice amount must be greater than zero.");
        }

        if (empty($_POST['pre_authorization_date']) || empty($_POST['pre_authorization_amount'])) {
            throw new Exception("Prior authorization is required for reimbursement requests.");
        }

        $preAuthDate = trim($_POST['pre_authorization_date']);
        $preAuthAmount = (float)($_POST['pre_authorization_amount'] ?? 0);

        if ($preAuthAmount <= 0) {
            throw new Exception("Pre-authorization amount must be greater than zero.");
        }

        // Check: Invoice amount should not exceed pre-authorization amount
        if ($invoice_amount > $preAuthAmount) {
            throw new Exception(sprintf(
                "Invoice amount (%s) exceeds pre-authorization amount (%s).",
                number_format($invoice_amount, 2),
                number_format($preAuthAmount, 2)
            ));
        }

        $pdo->beginTransaction();

        // Generate request number
        $requestNumber = generateRequestNumber($pdo);

        /* Create reimbursement request */
        $stmt = $pdo->prepare("
            INSERT INTO procurement_requests
            (branch_id, request_number, request_date, description, created_by, 
             status, request_type, estimated_value)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $stmt->execute([
            $branch_id,
            $requestNumber,
            $request_date,
            $description,
            $_SESSION['user_id'],
            'DRAFT',
            'REIMBURSEMENT',
            $invoice_amount
        ]);

        $requestId = (int)$pdo->lastInsertId();

        /* Create pre-authorization record */
        $authStmt = $pdo->prepare("
            INSERT INTO pre_authorizations
            (request_id, authorized_by, authorization_date, authorization_amount, authorization_notes)
            VALUES (?, ?, ?, ?, ?)
        ");

        $authStmt->execute([
            $requestId,
            $_SESSION['user_id'],
            $preAuthDate,
            $preAuthAmount,
            "Pre-authorization for reimbursement request"
        ]);

        /* Audit log */
        logAudit(
            $pdo,
            'procurement_requests',
            $requestId,
            'CREATE',
            'Reimbursement request created'
        );

        logAudit(
            $pdo,
            'pre_authorizations',
            (int)$pdo->lastInsertId(),
            'CREATE',
            'Pre-authorization created for reimbursement'
        );

        $pdo->commit();

        modalPop(
            "Reimbursement Request Created",
            "Your reimbursement request #{$requestNumber} has been created successfully. You can now submit it for processing.",
            "/reimbursement/view.php?request_id={$requestId}",
            "success"
        );
        header("Location: /reimbursement/view.php?request_id={$requestId}");
        exit;

    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log("Reimbursement creation error: " . $e->getMessage());
        $_SESSION['error'] = extractDbMessage($e);
    }
}

/* Fetch branches */
$branches = $pdo->query("SELECT branch_id, branch_name FROM branches WHERE is_active = 1 ORDER BY branch_name")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/header.php";
?>

<div class="container mt-4">
  <div class="card shadow-sm">
    <div class="card-body">
      <div class="d-flex align-items-center mb-4">
        <img src="/logo/cropped-Logo.png" alt="Logo" style="height:36px;width:auto;" class="me-3">
        <div>
          <h3 class="section-title mb-1">💵 New Reimbursement Request</h3>
          <small class="text-muted">Department of Government Chemist - Submit Prior Authorization & Invoice Details</small>
        </div>
      </div>

      <?php if (!empty($_SESSION['error'])): ?>
        <div class="alert alert-danger alert-dismissible fade show">
          <strong>Error:</strong> <?= htmlspecialchars($_SESSION['error']) ?>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php unset($_SESSION['error']); ?>
      <?php endif; ?>

      <form method="post" class="needs-validation">
        <!-- Step 1: Request Information -->
        <div class="card mb-4">
          <div class="card-header bg-light">
            <h5 class="mb-0">📋 Step 1: Request Information</h5>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Branch <span class="text-danger">*</span></label>
                <select name="branch_id" class="form-select" required>
                  <option value="">-- Select Branch --</option>
                  <?php foreach ($branches as $b): ?>
                    <option value="<?= $b['branch_id'] ?>"><?= htmlspecialchars($b['branch_name']) ?></option>
                  <?php endforeach; ?>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Request Date <span class="text-danger">*</span></label>
                <input type="date" name="request_date" class="form-control" required 
                       value="<?= date('Y-m-d') ?>">
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label fw-bold">Purpose/Description <span class="text-danger">*</span></label>
              <textarea name="description" class="form-control" rows="3" required 
                        placeholder="Describe what goods/services were purchased and why..."></textarea>
            </div>
          </div>
        </div>

        <!-- Step 2: Prior Authorization -->
        <div class="card mb-4">
          <div class="card-header bg-light">
            <h5 class="mb-0">✅ Step 2: Prior Authorization (From Branch Head)</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-info">
              <strong>Important:</strong> Prior authorization must be obtained BEFORE you purchase goods/services.
              This authorization confirms that the expenditure is approved and funds are available.
            </div>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Authorization Date <span class="text-danger">*</span></label>
                <input type="date" name="pre_authorization_date" class="form-control" required>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Authorized Amount <span class="text-danger">*</span></label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" name="pre_authorization_amount" class="form-control" 
                         step="0.01" min="0" required placeholder="0.00"
                         onchange="updateInvoiceMaxAmount()">
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Step 3: Invoice Details -->
        <div class="card mb-4">
          <div class="card-header bg-light">
            <h5 class="mb-0">📄 Step 3: Invoice Details</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-warning">
              <strong>Note:</strong> After approval, you will submit a copy of this invoice to Procurement at GC2, 
              and then the original invoice to Finance at GC10A.
            </div>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Invoice Amount <span class="text-danger">*</span></label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" id="invoice_amount" name="invoice_amount" class="form-control" 
                         step="0.01" min="0" required placeholder="0.00">
                </div>
                <small class="text-muted">Must not exceed the authorized amount</small>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Estimated Total Value</label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" name="estimated_value" class="form-control" 
                         step="0.01" min="0" placeholder="0.00">
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-success">
            <i class="bi bi-plus-circle"></i> Create Reimbursement Request
          </button>
          <a href="/reimbursement/list.php" class="btn btn-secondary">
            <i class="bi bi-arrow-left"></i> Cancel
          </a>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
function updateInvoiceMaxAmount() {
    const preAuthAmount = parseFloat(document.querySelector('input[name="pre_authorization_amount"]').value) || 0;
    const invoiceInput = document.getElementById('invoice_amount');
    invoiceInput.max = preAuthAmount;
    
    if (invoiceInput.value > preAuthAmount && preAuthAmount > 0) {
        invoiceInput.value = preAuthAmount;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const preAuthInput = document.querySelector('input[name="pre_authorization_amount"]');
    preAuthInput.addEventListener('change', updateInvoiceMaxAmount);
});
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
