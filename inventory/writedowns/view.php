<?php
$REQUIRE_PERMISSION = 'manage_write_downs';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$wdId = (int) ($_GET['id'] ?? 0);
if ($wdId <= 0) { pop("Invalid write-down.", "/inventory/writedowns/list.php", 1800, 'warning'); exit; }

$wd = $pdo->prepare("
    SELECT w.*, i.item_code, i.item_name, u.full_name AS requested_by_name,
           ua.full_name AS approved_by_name, l.location_code, l.site_name
    FROM inv_write_downs w
    JOIN inv_items i ON w.item_id = i.item_id
    LEFT JOIN users u ON w.requested_by = u.user_id
    LEFT JOIN users ua ON w.approved_by = ua.user_id
    LEFT JOIN inv_locations l ON w.location_id = l.location_id
    WHERE w.write_down_id = ?
");
$wd->execute([$wdId]);
$wd = $wd->fetch(PDO::FETCH_ASSOC);
if (!$wd) { pop("Write-down not found.", "/inventory/writedowns/list.php", 1800, 'warning'); exit; }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    try {
        $pdo->beginTransaction();

        if ($action === 'submit' && $wd['status'] === 'DRAFT') {
            $pdo->prepare("UPDATE inv_write_downs SET status = 'PENDING_APPROVAL' WHERE write_down_id = ?")->execute([$wdId]);
            logInventoryAudit($pdo, 'inv_write_downs', $wdId, 'SUBMITTED', "Write-down submitted for approval");

        } elseif ($action === 'approve' && $wd['status'] === 'PENDING_APPROVAL') {
            if ((int) $wd['requested_by'] === (int) $_SESSION['user_id']) {
                throw new Exception("Segregation of duties: approver cannot be the requester.");
            }

            requireOpenPeriod($pdo);

            // Update item NRV
            $pdo->prepare("UPDATE inv_items SET nrv = ?, nrv_last_assessed = CURDATE(), nrv_assessed_by = ? WHERE item_id = ?")
                ->execute([$wd['nrv_value'], $_SESSION['user_id'], $wd['item_id']]);

            // Update stock NRV if location-specific
            if ($wd['location_id']) {
                $pdo->prepare("UPDATE inv_stock SET nrv = ? WHERE item_id = ? AND location_id = ?")
                    ->execute([$wd['nrv_value'], $wd['item_id'], $wd['location_id']]);
            }

            // Record write-down transaction
            if ($wd['location_id']) {
                InventoryService::recordTransaction($pdo, $wd['item_id'], $wd['location_id'], 'WRITE_DOWN', 0,
                    "Write-down {$wd['write_down_number']}: \${$wd['write_down_amount']}", $_SESSION['user_id'], $wd['write_down_number']);
            }

            $pdo->prepare("UPDATE inv_write_downs SET status = 'APPROVED', approved_by = ?, approved_at = NOW() WHERE write_down_id = ?")
                ->execute([$_SESSION['user_id'], $wdId]);
            logInventoryAudit($pdo, 'inv_write_downs', $wdId, 'APPROVED', "Write-down approved, NRV updated to \${$wd['nrv_value']}");

        } elseif ($action === 'reverse' && $wd['status'] === 'APPROVED') {
            requireOpenPeriod($pdo);

            // Create reversal write-down
            $reversalNumber = generateWriteDownNumber($pdo);
            $pdo->prepare("INSERT INTO inv_write_downs
                (write_down_number, item_id, location_id, reason, original_cost, nrv_value, write_down_amount,
                 status, requested_by, approved_by, approved_at, reversal_id, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,NOW(),?,?)")
                ->execute([$reversalNumber, $wd['item_id'], $wd['location_id'], $wd['reason'],
                    $wd['nrv_value'], $wd['original_cost'], -$wd['write_down_amount'],
                    'APPROVED', $_SESSION['user_id'], $_SESSION['user_id'], $wdId,
                    "Reversal of {$wd['write_down_number']}"]);
            $reversalId = (int) $pdo->lastInsertId();

            // Restore item cost
            $pdo->prepare("UPDATE inv_items SET nrv = NULL, nrv_last_assessed = NULL, nrv_assessed_by = NULL WHERE item_id = ?")
                ->execute([$wd['item_id']]);

            $pdo->prepare("UPDATE inv_write_downs SET status = 'REVERSED', reversal_id = ? WHERE write_down_id = ?")
                ->execute([$reversalId, $wdId]);
            logInventoryAudit($pdo, 'inv_write_downs', $wdId, 'REVERSED', "Reversed by $reversalNumber");

        } elseif ($action === 'cancel' && $wd['status'] === 'DRAFT') {
            $pdo->prepare("UPDATE inv_write_downs SET status = 'CANCELLED' WHERE write_down_id = ?")->execute([$wdId]);
            logInventoryAudit($pdo, 'inv_write_downs', $wdId, 'CANCELLED', "Write-down cancelled");

        } else {
            throw new Exception("Invalid action for current status.");
        }

        $pdo->commit();
        pop("Write-down updated.", "/inventory/writedowns/view.php?id=$wdId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-graph-down-arrow"></i> Write-Down <?= htmlspecialchars($wd['write_down_number']) ?></h2>
    <a href="/inventory/writedowns/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="row g-3 mb-4">
    <div class="col-md-8">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6"><strong>Item:</strong> <code><?= htmlspecialchars($wd['item_code']) ?></code> <?= htmlspecialchars($wd['item_name']) ?></div>
                    <div class="col-md-6"><strong>Location:</strong> <?= htmlspecialchars(($wd['location_code'] ?? 'All') . ' ' . ($wd['site_name'] ?? '')) ?></div>
                    <div class="col-md-4"><strong>Reason:</strong> <span class="badge bg-secondary"><?= str_replace('_', ' ', $wd['reason']) ?></span></div>
                    <div class="col-md-4"><strong>Status:</strong>
                        <?php $sc = match($wd['status']) { 'DRAFT' => 'secondary', 'PENDING_APPROVAL' => 'warning', 'APPROVED' => 'success', 'REVERSED' => 'info', 'CANCELLED' => 'danger', default => 'secondary' }; ?>
                        <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $wd['status']) ?></span>
                    </div>
                    <div class="col-md-4"><strong>Date:</strong> <?= date('Y-m-d', strtotime($wd['created_at'])) ?></div>

                    <div class="col-md-4">
                        <div class="card bg-light p-3 text-center">
                            <small class="text-muted">Original Cost</small>
                            <div class="fs-5 fw-bold">$<?= number_format($wd['original_cost'], 2) ?></div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-light p-3 text-center">
                            <small class="text-muted">Net Realisable Value</small>
                            <div class="fs-5 fw-bold text-info">$<?= number_format($wd['nrv_value'], 2) ?></div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-danger bg-opacity-10 p-3 text-center">
                            <small class="text-muted">Write-Down Amount</small>
                            <div class="fs-5 fw-bold text-danger">$<?= number_format($wd['write_down_amount'], 2) ?></div>
                        </div>
                    </div>

                    <div class="col-md-6"><strong>Requested By:</strong> <?= htmlspecialchars($wd['requested_by_name']) ?></div>
                    <div class="col-md-6"><strong>Approved By:</strong> <?= htmlspecialchars($wd['approved_by_name'] ?? '-') ?></div>
                    <?php if ($wd['reversal_id']): ?>
                    <div class="col-12"><strong>Reversal:</strong> <a href="/inventory/writedowns/view.php?id=<?= $wd['reversal_id'] ?>">View Reversal #<?= $wd['reversal_id'] ?></a></div>
                    <?php endif; ?>
                    <?php if ($wd['notes']): ?>
                    <div class="col-12"><strong>Notes:</strong> <?= nl2br(htmlspecialchars($wd['notes'])) ?></div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <?php if ($wd['status'] === 'DRAFT'): ?>
        <form method="POST" class="mb-2">
            <button type="submit" name="action" value="submit" class="btn btn-warning w-100 btn-lg"><i class="bi bi-send"></i> Submit for Approval</button>
        </form>
        <form method="POST">
            <button type="submit" name="action" value="cancel" class="btn btn-outline-danger w-100"><i class="bi bi-x-circle"></i> Cancel</button>
        </form>
        <?php endif; ?>

        <?php if ($wd['status'] === 'PENDING_APPROVAL'): ?>
        <form method="POST">
            <button type="submit" name="action" value="approve" class="btn btn-success w-100 btn-lg"
                    onclick="return confirm('Approve this write-down? Item NRV will be updated.')">
                <i class="bi bi-check-circle"></i> Approve Write-Down
            </button>
        </form>
        <?php endif; ?>

        <?php if ($wd['status'] === 'APPROVED'): ?>
        <form method="POST">
            <button type="submit" name="action" value="reverse" class="btn btn-info w-100 btn-lg"
                    onclick="return confirm('Reverse this write-down? NRV will be restored.')">
                <i class="bi bi-arrow-counterclockwise"></i> Reverse Write-Down
            </button>
        </form>
        <?php endif; ?>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
