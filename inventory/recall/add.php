<?php
$REQUIRE_PERMISSION = 'manage_recalls';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_compliance_setup.php';

$items = $pdo->query("SELECT item_id, item_code, item_name FROM inv_items WHERE item_status='ACTIVE' ORDER BY item_name")->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo->beginTransaction();

        $itemId = (int) ($_POST['item_id'] ?? 0);
        $recallType = $_POST['recall_type'] ?? 'RECALL';
        $severity = $_POST['severity'] ?? 'CLASS_II';
        $batchLot = trim($_POST['batch_lot_number'] ?? '') ?: null;
        $serial = trim($_POST['serial_number'] ?? '') ?: null;
        $reason = trim($_POST['reason'] ?? '');

        if ($itemId <= 0) throw new Exception("Item is required.");
        if (empty($reason)) throw new Exception("Reason for recall is required.");
        if (!in_array($recallType, ['RECALL', 'WITHDRAWAL'])) throw new Exception("Invalid recall type.");
        if (!in_array($severity, ['CLASS_I', 'CLASS_II', 'CLASS_III'])) throw new Exception("Invalid severity.");

        $recallNumber = generateRecallNumber($pdo);

        // Trace affected quantities by batch
        $totalAffected = 0;
        if ($batchLot) {
            $traceData = traceBatch($pdo, $batchLot);
            foreach ($traceData as $t) {
                if ($t['item_id'] == $itemId && in_array($t['transaction_type'], ['ISSUE', 'TRANSFER_OUT'])) {
                    $totalAffected += (float) $t['quantity'];
                }
            }
        }

        $pdo->prepare("INSERT INTO inv_recalls
            (recall_number, recall_type, item_id, batch_lot_number, serial_number, reason,
             severity, initiated_by, total_quantity_affected)
            VALUES (?,?,?,?,?,?,?,?,?)")
            ->execute([$recallNumber, $recallType, $itemId, $batchLot, $serial, $reason,
                $severity, $_SESSION['user_id'], $totalAffected]);
        $recallId = (int) $pdo->lastInsertId();

        // Auto-populate affected locations from stock records
        if ($batchLot) {
            $stockStmt = $pdo->prepare("
                SELECT location_id, SUM(quantity_on_hand) AS qty
                FROM inv_stock WHERE item_id = ? AND batch_lot_number = ? AND quantity_on_hand > 0
                GROUP BY location_id
            ");
            $stockStmt->execute([$itemId, $batchLot]);
            $insertAffected = $pdo->prepare("INSERT INTO inv_recall_items (recall_id, location_id, quantity_affected) VALUES (?,?,?)");
            while ($row = $stockStmt->fetch(PDO::FETCH_ASSOC)) {
                $insertAffected->execute([$recallId, $row['location_id'], $row['qty']]);
            }
        }

        logInventoryAudit($pdo, 'inv_recalls', $recallId, 'INITIATED', "Recall $recallNumber initiated: $reason");

        $pdo->commit();
        pop("Recall $recallNumber initiated.", "/inventory/recall/view.php?id=$recallId", 1800, 'success');
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $error = extractDbMessage($e);
    }
}

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-arrow-counterclockwise"></i> Initiate Recall / Withdrawal</h2>
    <a href="/inventory/recall/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<?php if (!empty($error)): ?>
<div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="card border-0 shadow-sm">
    <div class="card-body">
        <form method="POST">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Type *</label>
                    <select name="recall_type" class="form-select" required>
                        <option value="RECALL">Recall (Safety/Quality)</option>
                        <option value="WITHDRAWAL">Withdrawal (Voluntary)</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Severity *</label>
                    <select name="severity" class="form-select" required>
                        <option value="CLASS_I">Class I — Critical (dangerous)</option>
                        <option value="CLASS_II" selected>Class II — Moderate</option>
                        <option value="CLASS_III">Class III — Minor</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Item *</label>
                    <select name="item_id" class="form-select" required>
                        <option value="">Select item...</option>
                        <?php foreach ($items as $it): ?>
                        <option value="<?= $it['item_id'] ?>"><?= htmlspecialchars($it['item_code'] . ' — ' . $it['item_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Batch/Lot Number</label>
                    <input type="text" name="batch_lot_number" class="form-control" placeholder="Batch to trace...">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Serial Number</label>
                    <input type="text" name="serial_number" class="form-control">
                </div>
                <div class="col-12">
                    <label class="form-label">Reason *</label>
                    <textarea name="reason" class="form-control" rows="4" required placeholder="Describe the reason for this recall/withdrawal..."></textarea>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-danger btn-lg"><i class="bi bi-arrow-counterclockwise"></i> Initiate Recall</button>
                </div>
            </div>
        </form>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
