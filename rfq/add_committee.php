<?php
$REQUIRE_PERMISSION = 'manage_rfq_committee';

require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';

$rfq_id = (int)($_GET['rfq_id'] ?? 0);

if (!$rfq_id) {
    pop('Invalid RFQ', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Fetch RFQ */
$stmt = $pdo->prepare("SELECT rfq_number FROM rfqs WHERE rfq_id = ?");
$stmt->execute([$rfq_id]);
$rfq = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$rfq) {
    pop('RFQ not found', '/rfq/list.php', POP_DEFAULT_DELAY_MS, 'error');
    exit;
}

/* Handle Form */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $user_id = (int)($_POST['user_id'] ?? 0);

    if (!$user_id) {
        pop('Select a user', '/rfq/add_committee.php?rfq_id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    /* Prevent duplicate */
    $stmt = $pdo->prepare("
        SELECT COUNT(*) FROM rfq_evaluation_committee
        WHERE rfq_id = ? AND user_id = ?
    ");
    $stmt->execute([$rfq_id, $user_id]);

    if ($stmt->fetchColumn() > 0) {
        pop('User already assigned', '/rfq/add_committee.php?rfq_id='.$rfq_id, POP_DEFAULT_DELAY_MS, 'warning');
        exit;
    }

    try {
    $pdo->prepare("
        INSERT INTO rfq_evaluation_committee (rfq_id, user_id)
        VALUES (?, ?)
    ")->execute([$rfq_id, $user_id]);
    } catch (Throwable $e) {
        require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
        pop(extractDbMessage($e), '/rfq/add_committee.php?rfq_id=' . $rfq_id, POP_DEFAULT_DELAY_MS, 'error');
        exit;
    }

    header("Location: view.php?id=".$rfq_id);
    exit;
}

/* Fetch eligible users (Evaluation Committee Members role) */
$stmt = $pdo->prepare("
    SELECT u.user_id, u.full_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE r.name = 'Evaluation Committee Member'
    ORDER BY u.full_name
");
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';
?>

<div class="container-fluid mt-2">

  <!-- Page Header -->
  <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
    <a href="view.php?id=<?= $rfq_id ?>" class="btn btn-outline-secondary btn-sm">
      <i class="bi bi-arrow-left"></i>
    </a>
    <div>
      <h2 class="fw-bold mb-0">👥 Add Committee Member</h2>
      <p class="text-muted mb-0">RFQ <?= htmlspecialchars($rfq['rfq_number']) ?></p>
    </div>
  </div>

  <div class="row justify-content-center">
    <div class="col-lg-6 col-md-8">

      <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">

          <div class="text-center mb-4">
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width:64px;height:64px;background:#e3f2fd;">
              <span class="fs-2">🧑‍⚖️</span>
            </div>
            <h5 class="fw-semibold mb-1">Assign Evaluation Member</h5>
            <small class="text-muted">Select a committee member to assign to this RFQ evaluation</small>
          </div>

          <form method="POST">

            <div class="mb-4">
              <label class="form-label fw-semibold">
                <i class="bi bi-person-badge me-1 text-muted"></i> Select Member
              </label>
              <select name="user_id" class="form-select form-select-lg" required>
                <option value="">— Choose a member —</option>
                <?php foreach ($users as $u): ?>
                  <option value="<?= $u['user_id'] ?>">
                    <?= htmlspecialchars($u['full_name']) ?>
                  </option>
                <?php endforeach; ?>
              </select>
              <?php if (empty($users)): ?>
                <div class="form-text text-warning mt-2">
                  <i class="bi bi-exclamation-triangle me-1"></i> No eligible evaluation committee members found.
                </div>
              <?php else: ?>
                <div class="form-text"><?= count($users) ?> eligible members available</div>
              <?php endif; ?>
            </div>

            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-primary flex-grow-1">
                <i class="bi bi-person-plus me-1"></i> Add Member
              </button>
              <a href="view.php?id=<?= $rfq_id ?>" class="btn btn-outline-secondary">
                Cancel
              </a>
            </div>

          </form>

        </div>
      </div>

    </div>
  </div>

</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
