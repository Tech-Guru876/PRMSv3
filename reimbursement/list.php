<?php
$REQUIRE_PERMISSION = 'view_reimbursement_requests';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/helper.php";
require_once $_SERVER['DOCUMENT_ROOT'] . "/config/workflow.php";

/* Fetch reimbursement requests */
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
        pa.authorization_amount,
        pa.authorization_date,
        COUNT(ri.reimb_invoice_id) as invoice_count
    FROM procurement_requests pr
    LEFT JOIN branches b ON pr.branch_id = b.branch_id
    LEFT JOIN users u ON pr.created_by = u.user_id
    LEFT JOIN pre_authorizations pa ON pr.request_id = pa.request_id
    LEFT JOIN reimbursement_invoices ri ON pr.request_id = ri.request_id
    WHERE pr.request_type = 'REIMBURSEMENT'
    GROUP BY pr.request_id
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
          <h3 class="section-title mb-1">💵 Reimbursement Requests</h3>
          <small class="text-muted">Manage reimbursement requests from staff</small>
        </div>
        <a href="/reimbursement/add.php" class="btn btn-success">
          <i class="bi bi-plus-circle"></i> New Reimbursement Request
        </a>
      </div>
    </div>
  </div>

  <?php if (empty($requests)): ?>
    <div class="alert alert-info">
      <i class="bi bi-info-circle"></i> No reimbursement requests found.
      <a href="/reimbursement/add.php">Create one now</a>
    </div>
  <?php else: ?>
    <div class="card shadow-sm">
      <div class="table-responsive">
        <table class="table table-hover mb-0">
          <thead class="table-dark">
            <tr>
              <th  >Request #</th>
              <th> Branch</th>
              <th> Requestor</th>
              <th> Description</th>
              <th> Amount</th>
              <th> Status</th>
              <th> Invoices</th>
              <th> Created</th>
              <th  >Actions</th>
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
                <td>
                  <span class="text-truncate" title="<?= htmlspecialchars($req['description']) ?>">
                    <?= htmlspecialchars(substr($req['description'], 0, 50)) ?>...
                  </span>
                </td>
                <td class="text-end">
                  <span class="badge bg-info">
                    <?= htmlspecialchars(normalizeCurrency($req['currency'] ?? 'JMD')) ?> <?= number_format($req['estimated_value'], 2) ?>
                  </span>
                </td>
                <td>
                  <?= getReimbursementStatusLabel($req['status']) ?>
                </td>
                <td>
                  <span class="badge bg-secondary"><?= $req['invoice_count'] ?></span>
                </td>
                <td>
                  <small class="text-muted"><?= date('M d, Y', strtotime($req['created_at'])) ?></small>
                </td>
                <td>
                  <a href="/reimbursement/view.php?request_id=<?= $req['request_id'] ?>" 
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
