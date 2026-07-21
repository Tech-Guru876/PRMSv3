<?php
$REQUIRE_PERMISSION = 'manage_recalls';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$recallId = (int) ($_GET['id'] ?? 0);
if ($recallId <= 0) { pop("Invalid recall.", "/inventory/recall/list.php", 1800, 'warning'); exit; }

$recall = $pdo->prepare("
    SELECT r.*, i.item_code, i.item_name, u.full_name AS initiator_name
    FROM inv_recalls r
    JOIN inv_items i ON r.item_id = i.item_id
    LEFT JOIN users u ON r.initiated_by = u.user_id
    WHERE r.recall_id = ?
");
$recall->execute([$recallId]);
$recall = $recall->fetch(PDO::FETCH_ASSOC);
if (!$recall) { pop("Recall not found.", "/inventory/recall/list.php", 1800, 'warning'); exit; }

$affectedItems = $pdo->prepare("
    SELECT ri.*, l.location_code, l.site_name, u.full_name AS issued_to_name
    FROM inv_recall_items ri
    LEFT JOIN inv_locations l ON ri.location_id = l.location_id
    LEFT JOIN users u ON ri.issued_to_user_id = u.user_id
    WHERE ri.recall_id = ?
");
$affectedItems->execute([$recallId]);
$affectedItems = $affectedItems->fetchAll(PDO::FETCH_ASSOC);

// Get batch trace for this item/batch
$batchTrace = [];
if ($recall['batch_lot_number']) {
    $batchTrace = traceBatch($pdo, $recall['batch_lot_number']);
    // Filter to only this item
    $batchTrace = array_filter($batchTrace, fn($t) => $t['item_id'] == $recall['item_id']);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    try {
        $pdo->beginTransaction();

        if ($action === 'start_progress' && $recall['status'] === 'INITIATED') {
            $pdo->prepare("UPDATE inv_recalls SET status = 'IN_PROGRESS' WHERE recall_id = ?")->execute([$recallId]);
            logInventoryAudit($pdo, 'inv_recalls', $recallId, 'IN_PROGRESS', "Recall progress started");

        } elseif ($action === 'update_recovery') {
            $recoveredQty = $_POST['quantity_recovered'] ?? [];
            $itemStatuses = $_POST['item_status'] ?? [];
            $update = $pdo->prepare("UPDATE inv_recall_items SET quantity_recovered = ?, status = ?, notes = ? WHERE recall_item_id = ?");
            foreach ($recoveredQty as $lineId => $qty) {
                $update->execute([(float) $qty, $itemStatuses[$lineId] ?? 'PENDING', $_POST['item_notes'][$lineId] ?? null, (int) $lineId]);
            }
            // Update total recovered
            $totalRecovered = $pdo->prepare("SELECT COALESCE(SUM(quantity_recovered), 0) FROM inv_recall_items WHERE recall_id = ?");
            $totalRecovered->execute([$recallId]);
            $pdo->prepare("UPDATE inv_recalls SET total_quantity_recovered = ? WHERE recall_id = ?")
                ->execute([$totalRecovered->fetchColumn(), $recallId]);
            logInventoryAudit($pdo, 'inv_recalls', $recallId, 'RECOVERY_UPDATED', "Recovery quantities updated");

        } elseif ($action === 'complete' && $recall['status'] === 'IN_PROGRESS') {
            $pdo->prepare("UPDATE inv_recalls SET status = 'COMPLETED', completed_at = NOW() WHERE recall_id = ?")->execute([$recallId]);
            logInventoryAudit($pdo, 'inv_recalls', $recallId, 'COMPLETED', "Recall completed");
        }

        $pdo->commit();
        pop("Recall updated.", "/inventory/recall/view.php?id=$recallId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-counterclockwise"></i> <?= $recall['recall_type'] ?> <?= htmlspecialchars($recall['recall_number']) ?></h2>
    <a href="/inventory/recall/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="row g-3 mb-4">
    <div class="col-md-8">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4"><strong>Item:</strong> <code><?= htmlspecialchars($recall['item_code']) ?></code> <?= htmlspecialchars($recall['item_name']) ?></div>
                    <div class="col-md-4"><strong>Batch/Lot:</strong> <?= htmlspecialchars($recall['batch_lot_number'] ?: '-') ?></div>
                    <div class="col-md-4"><strong>Severity:</strong>
                        <?php $sv = match($recall['severity']) { 'CLASS_I' => 'danger', 'CLASS_II' => 'warning', 'CLASS_III' => 'info', default => 'secondary' }; ?>
                        <span class="badge bg-<?= $sv ?>"><?= str_replace('_', ' ', $recall['severity']) ?></span>
                    </div>
                    <div class="col-md-4"><strong>Status:</strong>
                        <?php $sc = match($recall['status']) { 'INITIATED' => 'warning', 'IN_PROGRESS' => 'info', 'COMPLETED' => 'success', default => 'secondary' }; ?>
                        <span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $recall['status']) ?></span>
                    </div>
                    <div class="col-md-4"><strong>Initiated By:</strong> <?= htmlspecialchars($recall['initiator_name']) ?></div>
                    <div class="col-md-4"><strong>Date:</strong> <?= date('Y-m-d H:i', strtotime($recall['initiated_at'])) ?></div>
                    <div class="col-md-6"><strong>Qty Affected:</strong> <?= number_format($recall['total_quantity_affected'], 2) ?></div>
                    <div class="col-md-6"><strong>Qty Recovered:</strong> <?= number_format($recall['total_quantity_recovered'], 2) ?></div>
                    <div class="col-12"><strong>Reason:</strong> <?= nl2br(htmlspecialchars($recall['reason'])) ?></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <?php if ($recall['status'] === 'INITIATED'): ?>
        <form method="POST" class="mb-3">
            <button type="submit" name="action" value="start_progress" class="btn btn-info w-100 btn-lg">
                <i class="bi bi-play-circle"></i> Start Recovery Process
            </button>
        </form>
        <?php endif; ?>
        <?php if ($recall['status'] === 'IN_PROGRESS'): ?>
        <form method="POST">
            <button type="submit" name="action" value="complete" class="btn btn-success w-100 btn-lg">
                <i class="bi bi-check-circle"></i> Complete Recall
            </button>
        </form>
        <?php endif; ?>
    </div>
</div>

<!-- Affected Locations / Recipients -->
<?php if (!empty($affectedItems)): ?>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-danger text-white"><i class="bi bi-geo-alt"></i> Affected Locations</div>
    <div class="card-body p-0">
        <form method="POST">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Location</th><th>Recipient</th><th class="text-end">Qty Affected</th><th class="text-end">Qty Recovered</th><th>Status</th><th>Notes</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($affectedItems as $ai): ?>
                    <tr>
                        <td><?= htmlspecialchars(($ai['location_code'] ?? '') . ' ' . ($ai['site_name'] ?? '-')) ?></td>
                        <td><?= htmlspecialchars($ai['issued_to_name'] ?? '-') ?></td>
                        <td class="text-end fw-bold"><?= number_format($ai['quantity_affected'], 2) ?></td>
                        <td class="text-end">
                            <?php if ($recall['status'] === 'IN_PROGRESS'): ?>
                            <input type="number" step="0.01" name="quantity_recovered[<?= $ai['recall_item_id'] ?>]" class="form-control form-control-sm text-end" style="width:100px;display:inline" value="<?= $ai['quantity_recovered'] ?>">
                            <?php else: ?>
                            <?= number_format($ai['quantity_recovered'], 2) ?>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php if ($recall['status'] === 'IN_PROGRESS'): ?>
                            <select name="item_status[<?= $ai['recall_item_id'] ?>]" class="form-select form-select-sm">
                                <option value="PENDING" <?= $ai['status'] === 'PENDING' ? 'selected' : '' ?>>Pending</option>
                                <option value="NOTIFIED" <?= $ai['status'] === 'NOTIFIED' ? 'selected' : '' ?>>Notified</option>
                                <option value="RECOVERED" <?= $ai['status'] === 'RECOVERED' ? 'selected' : '' ?>>Recovered</option>
                                <option value="UNRECOVERABLE" <?= $ai['status'] === 'UNRECOVERABLE' ? 'selected' : '' ?>>Unrecoverable</option>
                            </select>
                            <?php else: ?>
                            <span class="badge bg-<?= $ai['status'] === 'RECOVERED' ? 'success' : ($ai['status'] === 'UNRECOVERABLE' ? 'danger' : 'secondary') ?>"><?= $ai['status'] ?></span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php if ($recall['status'] === 'IN_PROGRESS'): ?>
                            <input type="text" name="item_notes[<?= $ai['recall_item_id'] ?>]" class="form-control form-control-sm" value="<?= htmlspecialchars($ai['notes'] ?? '') ?>">
                            <?php else: ?>
                            <?= htmlspecialchars($ai['notes'] ?? '-') ?>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php if ($recall['status'] === 'IN_PROGRESS'): ?>
        <div class="card-footer">
            <button type="submit" name="action" value="update_recovery" class="btn btn-primary"><i class="bi bi-save"></i> Update Recovery</button>
        </div>
        <?php endif; ?>
        </form>
    </div>
</div>
<?php endif; ?>

<!-- Batch Trace -->
<?php if (!empty($batchTrace)): ?>
<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white"><i class="bi bi-diagram-3"></i> Batch Traceability — <?= htmlspecialchars($recall['batch_lot_number']) ?></div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-sm align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Date</th><th>Type</th><th>Location</th><th class="text-end">Qty</th><th>Performed By</th><th>Notes</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($batchTrace as $t): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($t['created_at'])) ?></td>
                        <td><span class="badge bg-secondary"><?= $t['transaction_type'] ?></span></td>
                        <td><?= htmlspecialchars($t['location_code'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($t['quantity'], 2) ?></td>
                        <td><?= htmlspecialchars($t['performed_by_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($t['notes'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
