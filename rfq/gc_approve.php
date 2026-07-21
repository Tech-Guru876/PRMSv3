<?php
/**
 * GC Approval for Over-Threshold RFQ (SOP Step 10)
 * 
 * After committee evaluation is complete and the RFQ is at COMMITTEE_RECOMMENDED,
 * the Deputy Government Chemist reviews and approves/rejects before award.
 * 
 * Flow: COMMITTEE_RECOMMENDED → GC_APPROVED → AWARDED
 */
$REQUIRE_PERMISSION = 'approve_request';

require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/workflow.php';

$rfq_id = (int)($_GET['id'] ?? 0);
if (!$rfq_id) {
    pop('Invalid RFQ ID', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ and request data */
$stmt = $pdo->prepare("
    SELECT r.rfq_id, r.rfq_number, r.request_id, r.status as rfq_status,
           pr.request_number, pr.status as request_status, pr.estimated_value,
           pr.description, pr.branch_id, b.branch_name
    FROM rfqs r
    JOIN procurement_requests pr ON r.request_id = pr.request_id
    LEFT JOIN branches b ON pr.branch_id = b.branch_id
    WHERE r.rfq_id = ?
");
$stmt->execute([$rfq_id]);
$data = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$data) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Verify this is an over-threshold RFQ at COMMITTEE_RECOMMENDED */
$estimatedValue = (float)($data['estimated_value'] ?? 0);
$isUnderThreshold = $estimatedValue <= getDirectProcurementThreshold($pdo);

if ($isUnderThreshold) {
    pop('GC approval is only required for over-threshold RFQs.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

if ($data['request_status'] !== 'COMMITTEE_RECOMMENDED') {
    pop('RFQ must be at Committee Recommended stage for GC approval. Current: '.$data['request_status'], '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Map status field for enforceTransition compatibility */
$data['status'] = $data['request_status'];

/* Verify user is Deputy Government Chemist */
$stmt = $pdo->prepare("
    SELECT r.name FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.user_id = ?
");
$stmt->execute([$_SESSION['user_id']]);
$userRole = $stmt->fetchColumn();

if ($userRole !== 'Deputy Government Chemist') {
    pop('Only the Deputy Government Chemist can provide GC approval.', '/rfq/view.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch committee evaluation summary for the approval page */
$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_committee WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$committeeCount = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(DISTINCT user_id) FROM rfq_votes WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$votesSubmitted = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) FROM rfq_evaluation_reports WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$reportCount = (int)$stmt->fetchColumn();

/* Get vote breakdown */
$stmt = $pdo->prepare("
    SELECT v.vendor_name, COUNT(vt.vote_id) as total_votes
    FROM rfq_votes vt
    JOIN rfq_vendors v ON vt.rfq_vendor_id = v.rfq_vendor_id
    WHERE vt.rfq_id = ?
    GROUP BY v.rfq_vendor_id ORDER BY total_votes DESC
");
$stmt->execute([$rfq_id]);
$voteSummary = $stmt->fetchAll(PDO::FETCH_ASSOC);

/* ===============================
   Handle POST (Approve / Reject)
================================ */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'approve') {
        $pdo->beginTransaction();
        try {
            enforceTransition($data, 'GC_APPROVED');

            /* Update procurement request status */
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'GC_APPROVED',
                    approved_by = ?,
                    approved_at = NOW()
                WHERE request_id = ?
            ")->execute([$_SESSION['user_id'], $data['request_id']]);

            /* Mark any pending GC approval as approved */
            $pdo->prepare("
                UPDATE request_approvals
                SET status = 'approved',
                    approved_by = ?,
                    approved_at = NOW()
                WHERE request_id = ?
                  AND role = 'Deputy Government Chemist'
                  AND status = 'pending'
            ")->execute([$_SESSION['user_id'], $data['request_id']]);

            /* Audit */
            logAudit($pdo, 'procurement_requests', $data['request_id'], 'STATUS_CHANGE',
                'GC Approved for over-threshold RFQ (SOP Step 10) — Status changed from COMMITTEE_RECOMMENDED to GC_APPROVED');
            logRequestTimeline($pdo, $data['request_id'], 'GC_APPROVED',
                'GC approval for over-threshold RFQ by ' . ($_SESSION['full_name'] ?? 'Unknown'));

            /* Notify procurement officer that award is now available */
            require_once $_SERVER['DOCUMENT_ROOT'].'/config/notifications.php';
            notifyRequestFinalized($data['request_id'], 'GC_APPROVED');

            $pdo->commit();
            pop('GC Approval granted. RFQ can now be awarded.', '/rfq/view.php?id='.$rfq_id, 1500, 'success');
        } catch (Exception $e) {
            $pdo->rollBack();
            pop('Error: '.extractDbMessage($e), '/rfq/gc_approve.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        }
        exit;
    }

    elseif ($action === 'reject') {
        $reason = trim($_POST['rejection_reason'] ?? '');
        if (empty($reason)) {
            pop('Rejection reason is required.', '/rfq/gc_approve.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'warning');
            exit;
        }

        $pdo->beginTransaction();
        try {
            /* Revert to EVALUATION_STAGE so committee can re-evaluate */
            $pdo->prepare("
                UPDATE procurement_requests
                SET status = 'EVALUATION_STAGE',
                    decline_reason = ?
                WHERE request_id = ?
            ")->execute([$reason, $data['request_id']]);

            /* Mark GC approval as rejected */
            $pdo->prepare("
                UPDATE request_approvals
                SET status = 'rejected',
                    approved_by = ?,
                    approved_at = NOW()
                WHERE request_id = ?
                  AND role = 'Deputy Government Chemist'
                  AND status = 'pending'
            ")->execute([$_SESSION['user_id'], $data['request_id']]);

            logAudit($pdo, 'procurement_requests', $data['request_id'], 'STATUS_CHANGE',
                'GC Rejected over-threshold RFQ — Reverted to EVALUATION_STAGE. Reason: ' . $reason);
            logRequestTimeline($pdo, $data['request_id'], 'GC_REJECTED',
                'GC rejected by ' . ($_SESSION['full_name'] ?? 'Unknown') . ': ' . $reason);

            /* Notify requestor of GC rejection */
            require_once $_SERVER['DOCUMENT_ROOT'].'/config/notifications.php';
            notifyRequestDeclined($data['request_id'], 0, $reason);

            $pdo->commit();
            pop('Request rejected. Reverted to evaluation stage. Reason: ' . htmlspecialchars($reason),
                '/rfq/view.php?id='.$rfq_id, 2000, 'warning');
        } catch (Exception $e) {
            $pdo->rollBack();
            pop('Error: '.extractDbMessage($e), '/rfq/gc_approve.php?id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        }
        exit;
    }
}

/* ===============================
   Render Approval Form
================================ */
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';
?>

<div class="container mt-4" style="max-width:800px;">
    <a href="/rfq/view.php?id=<?= $rfq_id ?>" class="text-decoration-none text-muted small">
        <i class="bi bi-arrow-left me-1"></i>Back to RFQ
    </a>

    <div class="card border-0 shadow-sm rounded-4 mt-3">
        <div class="card-header bg-white border-0 rounded-top-4 py-3" style="border-bottom:3px solid #0b5e2b !important;">
            <h4 class="mb-0 fw-bold" style="color:#1a1a2e;">
                <i class="bi bi-shield-check me-2" style="color:#0b5e2b;"></i>GC Approval — SOP Step 10
            </h4>
            <p class="text-muted small mb-0 mt-1">Over-threshold procurement requires Deputy Government Chemist approval before award.</p>
        </div>
        <div class="card-body">

            <!-- Request Summary -->
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <div class="small text-muted text-uppercase fw-semibold" style="font-size:.65rem;">RFQ Number</div>
                    <div class="fw-bold"><?= htmlspecialchars($data['rfq_number']) ?></div>
                </div>
                <div class="col-md-6">
                    <div class="small text-muted text-uppercase fw-semibold" style="font-size:.65rem;">Request Number</div>
                    <div class="fw-bold"><?= htmlspecialchars($data['request_number']) ?></div>
                </div>
                <div class="col-md-6">
                    <div class="small text-muted text-uppercase fw-semibold" style="font-size:.65rem;">Branch</div>
                    <div><?= htmlspecialchars($data['branch_name'] ?? 'N/A') ?></div>
                </div>
                <div class="col-md-6">
                    <div class="small text-muted text-uppercase fw-semibold" style="font-size:.65rem;">Estimated Value</div>
                    <div class="fw-bold" style="color:#c9a227;">$<?= number_format($estimatedValue, 2) ?></div>
                </div>
            </div>

            <!-- Committee Evaluation Summary -->
            <div class="card border-0 rounded-3 mb-4" style="background:#f8f9fa;">
                <div class="card-body py-3">
                    <h6 class="fw-semibold mb-3"><i class="bi bi-clipboard2-check me-1"></i> Committee Evaluation Summary</h6>
                    <div class="row g-2">
                        <div class="col-4 text-center">
                            <div class="fs-4 fw-bold" style="color:#0b5e2b;"><?= $committeeCount ?></div>
                            <div class="small text-muted">Members</div>
                        </div>
                        <div class="col-4 text-center">
                            <div class="fs-4 fw-bold" style="color:#0d6efd;"><?= $votesSubmitted ?></div>
                            <div class="small text-muted">Votes Cast</div>
                        </div>
                        <div class="col-4 text-center">
                            <div class="fs-4 fw-bold" style="color:#c9a227;"><?= $reportCount ?></div>
                            <div class="small text-muted">Reports</div>
                        </div>
                    </div>

                    <?php if (!empty($voteSummary)): ?>
                    <hr class="my-3">
                    <h6 class="fw-semibold mb-2 small">Vote Breakdown</h6>
                    <?php foreach ($voteSummary as $idx => $v): ?>
                    <div class="d-flex justify-content-between align-items-center small mb-1">
                        <div class="d-flex align-items-center gap-1">
                            <?php if ($idx === 0): ?><i class="bi bi-trophy-fill" style="color:#c9a227;font-size:.7rem;"></i><?php endif; ?>
                            <span class="<?= $idx === 0 ? 'fw-bold' : '' ?>"><?= htmlspecialchars($v['vendor_name']) ?></span>
                        </div>
                        <span class="badge rounded-pill <?= $idx === 0 ? '' : 'bg-secondary' ?>" 
                              <?= $idx === 0 ? 'style="background:#0b5e2b;"' : '' ?>>
                            <?= $v['total_votes'] ?> vote<?= $v['total_votes'] != 1 ? 's' : '' ?>
                        </span>
                    </div>
                    <?php endforeach; ?>
                    <?php endif; ?>

                    <div class="mt-3">
                        <a href="/rfq/generate_evaluation_summary.php?id=<?= $rfq_id ?>" target="_blank"
                           class="btn btn-sm btn-outline-dark rounded-pill">
                            <i class="bi bi-download me-1"></i>Download Evaluation Summary PDF
                        </a>
                    </div>
                </div>
            </div>

            <!-- Approval Form -->
            <form method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">
                        Rejection Reason <span class="text-muted fw-normal">(required if rejecting)</span>
                    </label>
                    <textarea name="rejection_reason" class="form-control rounded-3" rows="3"
                              placeholder="Enter reason for rejection..."></textarea>
                </div>
                <div class="d-flex gap-2">
                    <button name="action" value="approve" class="btn text-white rounded-pill px-4"
                            style="background:#0b5e2b;"
                            onclick="return confirm('Approve this over-threshold RFQ for award? This satisfies SOP Step 10.')">
                        <i class="bi bi-check-circle me-1"></i>Approve for Award
                    </button>
                    <button name="action" value="reject" class="btn btn-outline-danger rounded-pill px-4"
                            onclick="return confirm('Reject this RFQ? It will be reverted to evaluation stage.')">
                        <i class="bi bi-x-circle me-1"></i>Reject
                    </button>
                    <a href="/rfq/view.php?id=<?= $rfq_id ?>" class="btn btn-outline-secondary rounded-pill px-4">
                        <i class="bi bi-arrow-left me-1"></i>Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
