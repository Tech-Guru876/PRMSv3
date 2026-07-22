<?php
$REQUIRE_PERMISSION = 'create_petty_cash_request';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/helper.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/workflow.php";

/* Get petty cash limit */
$pettyCashLimit = getPettyCashLimit($pdo);

/* ═══════════════════════════════════════════════════════
   Handle POST - Create Petty Cash Request
═══════════════════════════════════════════════════════ */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $branch_id = (int)($_POST['branch_id'] ?? 0);
        $requested_amount = (float)($_POST['requested_amount'] ?? 0);
        $purpose = trim($_POST['purpose'] ?? '');

        // Validation
        if ($branch_id <= 0) {
            throw new Exception("Branch selection is required.");
        }

        if ($requested_amount <= 0) {
            throw new Exception("Requested amount must be greater than zero.");
        }

        if ($requested_amount > $pettyCashLimit) {
            throw new Exception(sprintf(
                "Petty cash requests are limited to %s. Amount requested exceeds the limit.",
                number_format($pettyCashLimit, 2)
            ));
        }

        if (empty($purpose)) {
            throw new Exception("Purpose of petty cash request is required.");
        }

        $pdo->beginTransaction();

        // Generate request number
        $requestNumber = generateRequestNumber($pdo);

        /* Create petty cash request */
        $stmt = $pdo->prepare("
            INSERT INTO procurement_requests
            (branch_id, request_number, request_date, description, created_by, 
             status, request_type, estimated_value)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $result = $stmt->execute([
            $branch_id,
            $requestNumber,
            date('Y-m-d'),
            $purpose,
            $_SESSION['user_id'],
            'DRAFT',
            'PETTY_CASH',
            $requested_amount
        ]);

        if (!$result) {
            throw new Exception("Failed to insert request: " . implode(", ", $stmt->errorInfo()));
        }

        $requestId = (int)$pdo->lastInsertId();
        
        // Debug log
        error_log("Created petty cash request ID $requestId with request_type='PETTY_CASH'");

        /* Audit log */
        logAudit(
            $pdo,
            'procurement_requests',
            $requestId,
            'CREATE',
            'Petty cash request created'
        );

        $pdo->commit();

        modalPop(
            "Petty Cash Request Created",
            "Your petty cash request #{$requestNumber} has been created successfully for $" . number_format($requested_amount, 2) . ". It will now go through the approval workflow.",
            "/petty_cash/view.php?request_id={$requestId}",
            "success"
        );
        header("Location: /petty_cash/view.php?request_id={$requestId}");
        exit;

    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log("Petty cash creation error: " . $e->getMessage());
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
          <h3 class="section-title mb-1">💰 New Petty Cash Request</h3>
          <small class="text-muted">Department of Government Chemist - Request Petty Cash for Small Purchases (Max $<?= number_format($pettyCashLimit, 2) ?>)</small>
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
        <!-- Process Overview -->
        <div class="alert alert-info mb-4">
          <h5 class="mb-2">📋 Petty Cash Process Overview</h5>
          <ol class="mb-0">
            <li>You complete this form with your branch authorization</li>
            <li>Submit to Procurement (GC2) for endorsement</li>
            <li>Forward to Finance (GC10A) for authorization</li>
            <li>Finance disburses the cash</li>
            <li><strong>Within 24 hours:</strong> Purchase goods/services and return with invoice & change</li>
            <li>Procurement verifies the goods/services were properly obtained</li>
          </ol>
        </div>

        <!-- Step 1: Request Details -->
        <div class="card mb-4">
          <div class="card-header bg-light">
            <h5 class="mb-0">📋 Step 1: Request Details</h5>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Branch <span class="text-danger">*</span></label>
                <select name="branch_id" class="form-select" required>
                  <option value="">-- Select Your Branch --</option>
                  <?php foreach ($branches as $b): ?>
                    <option value="<?= $b['branch_id'] ?>"><?= htmlspecialchars($b['branch_name']) ?></option>
                  <?php endforeach; ?>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Requested Amount <span class="text-danger">*</span></label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" name="requested_amount" class="form-control" 
                         step="0.01" min="0" max="<?= $pettyCashLimit ?>" required 
                         placeholder="0.00" onchange="validateAmount()">
                </div>
                <small class="text-muted">Maximum: $<?= number_format($pettyCashLimit, 2) ?></small>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label fw-bold">Purpose of Petty Cash <span class="text-danger">*</span></label>
              <textarea name="purpose" class="form-control" rows="3" required 
                        placeholder="Describe what you need to purchase (e.g., office supplies, printing services, etc.)"></textarea>
            </div>
          </div>
        </div>

        <!-- Important Reminders -->
        <div class="card mb-4">
          <div class="card-header bg-light">
            <h5 class="mb-0">⚠️ Important Reminders</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-warning mb-0">
              <h6>24-Hour Accountability Rule:</h6>
              <ul class="mb-0">
                <li><strong>Purchase must be made within 24 hours</strong> of cash disbursement</li>
                <li><strong>Original invoice must be returned</strong> to Finance within 24 hours</li>
                <li><strong>Any change (balance) must be returned</strong> to Finance within 24 hours</li>
                <li><strong>Procurement must verify</strong> goods/services quality within 24 hours</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-success">
            <i class="bi bi-plus-circle"></i> Create Petty Cash Request
          </button>
          <a href="/petty_cash/list.php" class="btn btn-secondary">
            <i class="bi bi-arrow-left"></i> Cancel
          </a>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
function validateAmount() {
    const amount = parseFloat(document.querySelector('input[name="requested_amount"]').value) || 0;
    const limit = <?= $pettyCashLimit ?>;
    
    if (amount > limit) {
        alert(`amount $${amount.toFixed(2)} exceeds the petty cash limit of $${limit.toFixed(2)}`);
        document.querySelector('input[name="requested_amount"]').value = limit;
    }
}
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
