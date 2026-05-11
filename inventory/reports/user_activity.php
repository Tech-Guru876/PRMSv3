<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom  = $_GET['date_from'] ?? date('Y-m-01');
$dateTo    = $_GET['date_to']   ?? date('Y-m-d');
$userF     = (int) ($_GET['user_id'] ?? 0);
$typeF     = $_GET['transaction_type'] ?? '';

$where  = "t.created_at BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($userF > 0)    { $where .= " AND t.performed_by = ?";      $params[] = $userF; }
if ($typeF !== '') { $where .= " AND t.transaction_type = ?";  $params[] = $typeF; }

$rows = $pdo->prepare("
    SELECT t.transaction_id, t.transaction_type, t.quantity, t.unit_cost,
           (t.quantity * t.unit_cost) AS line_value,
           t.reference_number, t.created_at,
           i.item_code, i.item_name,
           l.location_code,
           u.full_name AS user_name, u.user_id
    FROM inv_transactions t
    JOIN inv_items i ON t.item_id = i.item_id
    LEFT JOIN inv_locations l ON t.location_id = l.location_id
    LEFT JOIN users u ON t.performed_by = u.user_id
    WHERE $where
    ORDER BY t.created_at DESC
    LIMIT 2000
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

// Summary by user
$userSummary = [];
foreach ($rows as $r) {
    $uid  = $r['user_id'] ?? 0;
    $name = $r['user_name'] ?? 'Unknown';
    if (!isset($userSummary[$uid])) {
        $userSummary[$uid] = ['name' => $name, 'count' => 0, 'value' => 0];
    }
    $userSummary[$uid]['count']++;
    $userSummary[$uid]['value'] += $r['line_value'];
}
uasort($userSummary, fn($a, $b) => $b['value'] <=> $a['value']);

$users = $pdo->query("SELECT user_id, full_name FROM users ORDER BY full_name")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-person-lines-fill"></i> User Activity Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-3">
        <select name="user_id" class="form-select">
            <option value="">All Users</option>
            <?php foreach ($users as $u): ?>
            <option value="<?= $u['user_id'] ?>" <?= $userF == $u['user_id'] ? 'selected' : '' ?>><?= htmlspecialchars($u['full_name']) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2">
        <select name="transaction_type" class="form-select">
            <option value="">All Types</option>
            <?php foreach (['RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN','ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST','RETURN','QUARANTINE_IN','QUARANTINE_OUT','WRITE_DOWN','RETURN_TO_SUPPLIER'] as $tt): ?>
            <option value="<?= $tt ?>" <?= $typeF === $tt ? 'selected' : '' ?>><?= str_replace('_', ' ', $tt) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<!-- Summary by User -->
<?php if (empty($userF) && !empty($userSummary)): ?>
<h5 class="mb-2">Activity Summary by User</h5>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-sm align-middle mb-0">
                <thead class="table-light"><tr><th>User</th><th class="text-end">Transactions</th><th class="text-end">Value</th></tr></thead>
                <tbody>
                    <?php foreach ($userSummary as $uid => $us): ?>
                    <tr>
                        <td><?= htmlspecialchars($us['name']) ?></td>
                        <td class="text-end"><?= number_format($us['count']) ?></td>
                        <td class="text-end">$<?= number_format($us['value'], 2) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- Transaction Detail -->
<h5 class="mb-2">Transaction Detail <small class="text-muted">(max 2,000 rows)</small></h5>
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr><th>Timestamp</th><th>User</th><th>Type</th><th>Item</th><th>Location</th><th>Ref</th><th class="text-end">Qty</th><th class="text-end">Value</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($r['created_at'])) ?></td>
                        <td><?= htmlspecialchars($r['user_name'] ?? '-') ?></td>
                        <td>
                            <?php $tc = match(true) {
                                in_array($r['transaction_type'], ['RECEIVE','TRANSFER_IN','ADJUSTMENT_GAIN','RETURN']) => 'success',
                                in_array($r['transaction_type'], ['ISSUE','TRANSFER_OUT','ADJUSTMENT_LOSS','DISPOSAL']) => 'danger',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $tc ?>"><?= str_replace('_', ' ', $r['transaction_type']) ?></span>
                        </td>
                        <td><code><?= htmlspecialchars($r['item_code']) ?></code> <?= htmlspecialchars($r['item_name']) ?></td>
                        <td><?= htmlspecialchars($r['location_code'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['reference_number'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($r['quantity'], 2) ?></td>
                        <td class="text-end">$<?= number_format($r['line_value'], 2) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
