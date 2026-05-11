<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$typeF    = $_GET['reference_type'] ?? '';

$where  = "al.created_at BETWEEN ? AND ? AND al.approved_at IS NOT NULL";
$params = [$dateFrom, $dateTo . ' 23:59:59'];
if ($typeF !== '') { $where .= " AND al.reference_type = ?"; $params[] = $typeF; }

$rows = $pdo->prepare("
    SELECT al.reference_type,
           al.reference_id,
           al.approval_level,
           al.required_role_code,
           al.status,
           al.created_at,
           al.approved_at,
           u.full_name AS approved_by_name,
           TIMESTAMPDIFF(MINUTE, al.created_at, al.approved_at) AS minutes_to_approve
    FROM inv_approval_log al
    LEFT JOIN users u ON al.approved_by = u.user_id
    WHERE $where
    ORDER BY al.created_at DESC
    LIMIT 2000
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

// Summary by type
$typeSummary = [];
foreach ($rows as $r) {
    $type = $r['reference_type'] ?? 'UNKNOWN';
    if (!isset($typeSummary[$type])) {
        $typeSummary[$type] = ['count' => 0, 'total_min' => 0, 'approved' => 0, 'rejected' => 0];
    }
    $typeSummary[$type]['count']++;
    $typeSummary[$type]['total_min'] += $r['minutes_to_approve'];
    if ($r['status'] === 'APPROVED') $typeSummary[$type]['approved']++;
    if ($r['status'] === 'REJECTED') $typeSummary[$type]['rejected']++;
}

$refTypes = array_unique(array_column($rows, 'reference_type'));
sort($refTypes);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';

function formatDuration(int $minutes): string {
    if ($minutes < 60) return $minutes . ' min';
    if ($minutes < 1440) return round($minutes / 60, 1) . ' hrs';
    return round($minutes / 1440, 1) . ' days';
}
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-stopwatch"></i> Approval Turnaround Report</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-3">
        <select name="reference_type" class="form-select">
            <option value="">All Transaction Types</option>
            <?php foreach ($refTypes as $rt): ?>
            <option value="<?= htmlspecialchars($rt) ?>" <?= $typeF === $rt ? 'selected' : '' ?>><?= htmlspecialchars($rt) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<!-- Summary -->
<?php if (!empty($typeSummary)): ?>
<h5 class="mb-2">Average Turnaround by Transaction Type</h5>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-sm align-middle mb-0">
                <thead class="table-light"><tr><th>Type</th><th class="text-end">Total</th><th class="text-end">Approved</th><th class="text-end">Rejected</th><th class="text-end">Avg Turnaround</th></tr></thead>
                <tbody>
                    <?php foreach ($typeSummary as $type => $ts): ?>
                    <tr>
                        <td><?= htmlspecialchars($type) ?></td>
                        <td class="text-end"><?= $ts['count'] ?></td>
                        <td class="text-end text-success"><?= $ts['approved'] ?></td>
                        <td class="text-end text-danger"><?= $ts['rejected'] ?></td>
                        <td class="text-end"><?= $ts['count'] > 0 ? formatDuration((int)round($ts['total_min'] / $ts['count'])) : '-' ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- Detail -->
<h5 class="mb-2">Approval Detail <small class="text-muted">(max 2,000 rows)</small></h5>
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Submitted</th>
                        <th>Type</th>
                        <th>Record #</th>
                        <th>Level</th>
                        <th>Role Required</th>
                        <th>Status</th>
                        <th>Approved</th>
                        <th>Approved By</th>
                        <th class="text-end">Turnaround</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="9" class="text-center text-muted py-4">No approval records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i', strtotime($r['created_at'])) ?></td>
                        <td><?= htmlspecialchars($r['reference_type'] ?? '-') ?></td>
                        <td>#<?= $r['reference_id'] ?></td>
                        <td class="text-center"><?= $r['approval_level'] ?></td>
                        <td><?= htmlspecialchars($r['required_role_code'] ?? '-') ?></td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'APPROVED' => 'success',
                                'REJECTED' => 'danger',
                                'PENDING'  => 'warning',
                                default    => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= $r['status'] ?></span>
                        </td>
                        <td><?= $r['approved_at'] ? date('Y-m-d H:i', strtotime($r['approved_at'])) : '-' ?></td>
                        <td><?= htmlspecialchars($r['approved_by_name'] ?? '-') ?></td>
                        <td class="text-end">
                            <?= $r['minutes_to_approve'] !== null
                                ? formatDuration((int)$r['minutes_to_approve'])
                                : '<span class="text-muted">-</span>' ?>
                        </td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
