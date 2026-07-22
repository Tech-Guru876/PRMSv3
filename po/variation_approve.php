<?php
// ==================================
// Approve / Reject PO Variations
// ==================================

date_default_timezone_set('America/Jamaica');

$REQUIRE_PERMISSION = 'approve_po_adjustment';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';

$user_id = $_SESSION['user_id'];
$current_role = $_SESSION['role'];
$variation_id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($variation_id <= 0) {
    modalPop('Error', 'Invalid variation reference.', '/po/list.php', 'error');
    exit;
}

/* ==================================
   Fetch Variation + PO + Request
================================== */
$stmt = $pdo->prepare("
    SELECT
        v.*,
        po.po_number,
        po.po_total,
        po.commitment_id AS original_commitment_id,
        c.request_id,
        u.full_name AS requested_by_name,
        pr.currency
    FROM po_variations v
    JOIN purchase_orders po ON v.po_id = po.po_id
    JOIN commitments c ON po.commitment_id = c.commitment_id
    JOIN procurement_requests pr ON c.request_id = pr.request_id
    JOIN users u ON v.requested_by = u.user_id
    WHERE v.variation_id = ?
    LIMIT 1
");
$stmt->execute([$variation_id]);
$variation = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$variation) {
    modalPop('Error', 'PO Variation not found.', '/po/list.php', 'error');
    exit;
}

$vCurrency = 'JMD'; // PO/variation amounts are always stored in JMD

if ($variation['status'] !== 'PENDING') {
    modalPop(
        'Not Allowed',
        'This PO Variation has already been processed.',
        "/po/view.php?po_id=" . (int)$variation['po_id'],
        'warning'
    );
    exit;
}

/* ==================================
   HARD BLOCK: Supplementary Commitment Required
================================== */

if (empty($variation['commitment_id'])) {
    modalPop(
        "A supplementary commitment must be created before approving this PO variation.",
        "/po/view.php?po_id=".$variation['po_id'],
        "error"
    );
    exit;
}

$stmt = $pdo->prepare("
    SELECT status
    FROM commitments
    WHERE commitment_id = ?
      AND commitment_type = 'SUPPLEMENTARY'
");
$stmt->execute([$variation['commitment_id']]);
$supp = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$supp || $supp['status'] !== 'closed') {
    modalPop(
        "Supplementary commitment must be fully approved before approving this PO variation.",
        "/commitments/view.php?commitment_id=".$variation['commitment_id'],
        "error"
    );
    exit;
}

/* ==================================
   Handle POST
================================== */

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $action = $_POST['action'] ?? '';

    try {

        $pdo->beginTransaction();

        /* ==========================
           APPROVE
        ========================== */
        if ($action === 'approve') {

            $pdo->prepare("
                UPDATE po_variations
                SET status='APPROVED',
                    approved_by=?,
                    approved_at=NOW()
                WHERE variation_id=?
            ")->execute([$user_id, $variation_id]);

            logAudit(
                $pdo,
                'po_variations',
                $variation_id,
                'APPROVE',
                "Approved by {$current_role}"
            );

            logRequestTimeline(
                $pdo,
                $variation['request_id'],
                'PO_VARIATION_APPROVED',
                "PO {$variation['po_number']} variation approved ({$vCurrency} ".number_format($variation['variation_amount'],2).")"
            );

            /* Update PO total */
            $pdo->prepare("
                UPDATE purchase_orders
                SET po_total = po_total + ?
                WHERE po_id = ?
            ")->execute([
                $variation['variation_amount'],
                $variation['po_id']
            ]);

            logAudit(
                $pdo,
                'purchase_orders',
                $variation['po_id'],
                'UPDATE_TOTAL',
                "PO total increased by {$vCurrency} ".number_format($variation['variation_amount'],2)
            );

            /* Clear PO warnings */
            $pdo->prepare("
                DELETE FROM po_warnings
                WHERE po_id = ?
                  AND warning_type = 'PO_LIMIT_ATTEMPT'
            ")->execute([$variation['po_id']]);

            $pdo->commit();

            /* Notify about PO variation approval */
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyPOVariation($variation['request_id'], $variation['po_number'], 'APPROVED', (float)$variation['variation_amount']);

            modalPop(
                'Variation Approved',
                'PO total has been updated successfully.',
                "/po/view.php?po_id=" . (int)$variation['po_id'],
                'success'
            );
            exit;
        }

        /* ==========================
           REJECT
        ========================== */
        elseif ($action === 'reject') {

            $reason = trim($_POST['rejection_reason'] ?? '');

            if (empty($reason)) {
                modalPop(
                    "Rejection Reason Required",
                    "You must provide a reason for rejection.",
                    "/po/view.php?po_id=" . (int)$variation['po_id'],
                    "warning"
                );
                exit;
            }

            $pdo->prepare("
                UPDATE po_variations
                SET status='REJECTED',
                    approved_by=?,
                    approved_at=NOW()
                WHERE variation_id=?
            ")->execute([$user_id, $variation_id]);

            logAudit(
                $pdo,
                'po_variations',
                $variation_id,
                'REJECT',
                "Rejected by {$current_role} - {$reason}"
            );

            logRequestTimeline(
                $pdo,
                $variation['request_id'],
                'PO_VARIATION_REJECTED',
                "PO {$variation['po_number']} variation rejected: {$reason}"
            );

            $pdo->commit();

            /* Notify about PO variation rejection */
            require_once $_SERVER['DOCUMENT_ROOT']."/config/notifications.php";
            notifyPOVariation($variation['request_id'], $variation['po_number'], 'REJECTED', (float)$variation['variation_amount'], $reason);

            modalPop(
                'Variation Rejected',
                'PO variation request has been rejected.',
                "/po/view.php?po_id=" . (int)$variation['po_id'],
                'warning'
            );
            exit;
        }

        throw new Exception('Invalid action.');

    } catch (Throwable $e) {

        $pdo->rollBack();

        modalPop(
            'Error',
            'Failed to process variation: ' . extractDbMessage($e),
            "/po/view.php?po_id=" . (int)$variation['po_id'],
            'error'
        );
        exit;
    }
}

/* ==================================
   Render Page
================================== */
require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/header.php";

$newPoTotal = (float)$variation['po_total'] + (float)$variation['variation_amount'];
?>

<div class="container mt-4">
    <div class="row mb-4">
        <div class="col-lg-8">
            <h3 class="section-title">📋 PO Variation Approval</h3>
        </div>
    </div>

    <!-- Variation Details Card -->
    <div class="card mb-4 border-start border-primary border-3">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0">📌 Variation Details</h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <!-- PO Information -->
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">PO Number</small>
                        <h6 class="fw-bold text-primary"><?= htmlspecialchars($variation['po_number']) ?></h6>
                    </div>
                    <div class="mb-3">
                        <small class="text-muted d-block">Requested By</small>
                        <p class="mb-0"><?= htmlspecialchars($variation['requested_by_name']) ?></p>
                    </div>
                    <div class="mb-3">
                        <small class="text-muted d-block">Requested At</small>
                        <p class="mb-0"><?= date('d M Y, H:i', strtotime($variation['requested_at'])) ?></p>
                    </div>
                </div>

                <!-- Financial Summary -->
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted d-block">Current PO Total</small>
                        <p class="mb-0 fs-6"><?= htmlspecialchars($vCurrency) ?> <span class="badge bg-info"><?= number_format($variation['po_total'], 2) ?></span></p>
                    </div>
                    <div class="mb-3">
                        <small class="text-muted d-block">Variation Amount</small>
                        <p class="mb-0 fs-6"><?= htmlspecialchars($vCurrency) ?> <span class="badge bg-warning text-dark"><?= number_format($variation['variation_amount'], 2) ?></span></p>
                    </div>
                    <div class="mb-3 p-2 bg-light rounded border-2 border-success">
                        <small class="text-muted d-block">New PO Total (if approved)</small>
                        <p class="mb-0 fs-6 fw-bold text-success"><?= htmlspecialchars($vCurrency) ?> <?= number_format($newPoTotal, 2) ?></p>
                    </div>
                </div>
            </div>

            <!-- Variation Reason -->
            <div class="mt-3 pt-3 border-top">
                <small class="text-muted d-block mb-2">Reason for Variation</small>
                <div class="p-2 bg-light rounded">
                    <?= nl2br(htmlspecialchars($variation['reason'])) ?>
                </div>
            </div>
        </div>
    </div>

    <!-- Decision Form -->
    <div class="card border-secondary mb-4">
        <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">✅ Your Decision</h5>
        </div>
        <div class="card-body">
            <form method="post" id="variationForm">

                <!-- Rejection Reason Field (Hidden by default) -->
                <div id="rejectionSection" class="mb-4" style="display: none;">
                    <label for="rejection_reason" class="form-label">
                        <span class="text-danger">*</span> Reason for Rejection
                    </label>
                    <textarea 
                        name="rejection_reason"
                        id="rejection_reason"
                        class="form-control"
                        placeholder="Explain why you are rejecting this variation..."
                        rows="4"
                    ></textarea>
                    <small class="text-muted d-block mt-1">This reason will be logged and visible to the requestor.</small>
                </div>

                <!-- Action Buttons -->
                <div class="d-grid gap-2 d-sm-flex justify-content-between">
                    <div class="d-flex gap-2 flex-wrap">
                        <button 
                            type="submit" 
                            name="action" 
                            value="approve" 
                            class="btn btn-success btn-lg"
                            onclick="return confirmAction('Approve this PO variation?')">
                            <i class="bi bi-check-circle"></i> Approve Variation
                        </button>

                        <button 
                            type="button" 
                            class="btn btn-danger btn-lg"
                            id="rejectBtn"
                            onclick="toggleRejectionSection()">
                            <i class="bi bi-x-circle"></i> Reject Variation
                        </button>
                    </div>

                    <a href="/po/view.php?po_id=<?= (int)$variation['po_id'] ?>"
                       class="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-arrow-left"></i> Cancel
                    </a>
                </div>

                <!-- Hidden reject button for form submission -->
                <button 
                    type="submit" 
                    name="action" 
                    value="reject" 
                    id="submitRejectBtn"
                    class="btn btn-danger"
                    style="display: none;">
                </button>
            </form>
        </div>
    </div>

    <!-- Info Box -->
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <i class="bi bi-info-circle"></i>
        <strong>Note:</strong> A supplementary commitment has been validated and is in place for this variation. Approving this will update the PO total.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</div>

<script>
function toggleRejectionSection() {
    const section = document.getElementById('rejectionSection');
    const rejectBtn = document.getElementById('rejectBtn');
    const isVisible = section.style.display !== 'none';
    
    if (isVisible) {
        section.style.display = 'none';
        rejectBtn.classList.remove('active');
    } else {
        section.style.display = 'block';
        rejectBtn.classList.add('active');
        document.getElementById('rejection_reason').focus();
    }
}

function confirmAction(message) {
    return confirm(message);
}

// Form validation before submission
document.getElementById('variationForm').addEventListener('submit', function(e) {
    const rejectButton = document.getElementById('submitRejectBtn');
    const rejectionSection = document.getElementById('rejectionSection');
    
    if (rejectionSection.style.display !== 'none' && !document.getElementById('rejection_reason').value.trim()) {
        e.preventDefault();
        alert('Please provide a reason for rejection.');
        document.getElementById('rejection_reason').focus();
        return false;
    }
});

document.getElementById('rejectBtn').addEventListener('click', function() {
    toggleRejectionSection();
    const section = document.getElementById('rejectionSection');
    if (section.style.display !== 'none') {
        this.innerHTML = '<i class="bi bi-check-circle"></i> Cancel Rejection';
    } else {
        this.innerHTML = '<i class="bi bi-x-circle"></i> Reject Variation';
    }
});
</script>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
