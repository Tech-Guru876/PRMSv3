<?php
$REQUIRE_PERMISSION = 'view_petty_cash_requests';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/helper.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/workflow.php";

/* Fetch petty cash requests */
$stmt = $pdo->prepare("
    SELECT 
        pr.request_id,
        pr.request_number,
        pr.description,
        pr.estimated_value,
        pr.status,
        pr.created_at,
        pr.created_by,
        pr.currency,
        b.branch_name,
        u.full_name,
        pcd.amount_authorized,
        pcd.disbursement_date,
        pcd.disbursement_deadline,
        pcd.status as disbursal_status
    FROM procurement_requests pr
    LEFT JOIN branches b ON pr.branch_id = b.branch_id
    LEFT JOIN users u ON pr.created_by = u.user_id
    LEFT JOIN petty_cash_disbursements pcd ON pr.request_id = pcd.request_id
    WHERE pr.request_type = 'PETTY_CASH'
    ORDER BY pr.created_at DESC
");
$stmt->execute();
$requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/header.php";
?>

<div class="container-fluid mt-4">
  <div class="card shadow-sm mb-4">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h3 class="section-title mb-1">💰 Petty Cash Requests</h3>
          <small class="text-muted">Manage petty cash requests and track 24-hour reconciliation deadlines</small>
        </div>
        <a href="/petty_cash/add.php" class="btn btn-success">
          <i class="bi bi-plus-circle"></i> New Petty Cash Request
        </a>
      </div>
    </div>
  </div>

  <?php if (empty($requests)): ?>
    <div class="alert alert-info">
      <i class="bi bi-info-circle"></i> No petty cash requests found.
      <a href="/petty_cash/add.php">Create one now</a>
    </div>
  <?php else: ?>
    <div class="card shadow-sm">
      <div class="table-responsive">
        <table class="table table-hover mb-0">
          <thead class="table-dark">
            <tr>
              <th>Request #</th>
              <th>Branch</th>
              <th>Requestor</th>
              <th>Amount</th>
              <th>Status</th>
              <th>Requested</th>
              <th>Deadline</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($requests as $req): ?>
              <tr>
                <td>
                  <strong><?= htmlspecialchars($req['request_number']) ?></strong>
                </td>
                <td><?= htmlspecialchars($req['branch_name'] ?? 'N/A') ?></td>
                <td><?= htmlspecialchars($req['full_name'] ?? 'N/A') ?></td>
                <td class="text-end">
                  <span class="badge bg-success">
                    <?= htmlspecialchars(normalizeCurrency($req['currency'] ?? 'JMD')) ?> <?= number_format($req['estimated_value'], 2) ?>
                  </span>
                </td>
                <td>
                  <?= getPettyCashStatusLabel($req['status']) ?>
                </td>
                <td>
                  <small class="text-muted"><?= date('M d, Y', strtotime($req['created_at'])) ?></small>
                </td>
                <td>
                  <?php if ($req['disbursement_deadline']): ?>
                    <?php
                    $now = new DateTime();
                    $deadline = new DateTime($req['disbursement_deadline']);
                    $isOverdue = $now > $deadline;
                    $isApproaching = $deadline->diff($now)->h <= 2;
                    ?>
                    <small class="<?= $isOverdue ? 'text-danger' : ($isApproaching ? 'text-warning' : 'text-muted') ?>">
                      <?php if ($isOverdue): ?>
                        <strong>OVERDUE</strong>
                      <?php else: ?>
                        <?= $deadline->format('M d, g:i A') ?>
                      <?php endif; ?>
                    </small>
                  <?php else: ?>
                    <small class="text-muted">N/A</small>
                  <?php endif; ?>
                </td>
                <td>
                  <a href="/petty_cash/view.php?request_id=<?= $req['request_id'] ?>" 
                     class="btn btn-sm btn-outline-primary">
                    <i class="bi bi-eye"></i> View
                  </a>
                </td>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
    </div>
  <?php endif; ?>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . "/includes/footer.php"; ?>
