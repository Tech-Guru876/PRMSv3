<?php
$REQUIRE_PERMISSION = 'manage_incidents';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$statusFilter = $_GET['status'] ?? '';
$typeFilter = $_GET['type'] ?? '';
$pagination = getPaginationParams();
extract($pagination);

$where = ["1=1"];
$params = [];
if ($statusFilter && in_array($statusFilter, ['REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED'])) {
    $where[] = "inc.status = ?";
    $params[] = $statusFilter;
}
if ($typeFilter && in_array($typeFilter, ['THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER'])) {
    $where[] = "inc.incident_type = ?";
    $params[] = $typeFilter;
}
$whereClause = implode(' AND ', $where);

$totalRows = $pdo->prepare("SELECT COUNT(*) FROM inv_incidents inc WHERE $whereClause");
$totalRows->execute($params);
$totalRows = (int) $totalRows->fetchColumn();

$stmt = $pdo->prepare("
    SELECT inc.*, u.full_name AS reported_by_name, l.location_code, l.site_name,
           ui.full_name AS investigator_name
    FROM inv_incidents inc
    LEFT JOIN users u ON inc.reported_by = u.user_id
    LEFT JOIN users ui ON inc.investigator_id = ui.user_id
    LEFT JOIN inv_locations l ON inc.location_id = l.location_id
    WHERE $whereClause
    ORDER BY inc.reported_at DESC
    LIMIT $perPage OFFSET $offset
");
$stmt->execute($params);
$incidents = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-exclamation-triangle"></i> Incident / Loss Register</h2>
    <a href="/inventory/incidents/add.php" class="btn btn-danger"><i class="bi bi-plus-lg"></i> Report Incident</a>
</div>

<div class="card border-0 shadow-sm mb-3">
    <div class="card-body py-2">
        <form method="GET" class="row g-2 align-items-end">
            <div class="col-auto">
                <select name="status" class="form-select form-select-sm">
                    <option value="">All Statuses</option>
                    <?php foreach (['REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED'] as $s): ?>
                    <option value="<?= $s ?>" <?= $statusFilter === $s ? 'selected' : '' ?>><?= str_replace('_', ' ', $s) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-auto">
                <select name="type" class="form-select form-select-sm">
                    <option value="">All Types</option>
                    <?php foreach (['THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER'] as $t): ?>
                    <option value="<?= $t ?>" <?= $typeFilter === $t ? 'selected' : '' ?>><?= $t ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-auto"><button type="submit" class="btn btn-sm btn-outline-primary">Filter</button></div>
        </form>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Incident #</th><th>Type</th><th>Location</th><th>Date</th><th class="text-end">Est. Loss</th><th>Status</th><th>Reported By</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if (empty($incidents)): ?>
                    <tr><td colspan="8" class="text-muted text-center py-4">No incidents found.</td></tr>
                    <?php else: foreach ($incidents as $inc):
                        $sc = match($inc['status']) { 'REPORTED' => 'danger', 'UNDER_INVESTIGATION' => 'warning', 'RESOLVED' => 'info', 'CLOSED' => 'success', default => 'secondary' };
                        $tc = match($inc['incident_type']) { 'THEFT' => 'danger', 'FIRE' => 'danger', 'FLOOD' => 'warning', 'VANDALISM' => 'danger', default => 'secondary' };
                    ?>
                    <tr>
                        <td><strong><?= htmlspecialchars($inc['incident_number']) ?></strong></td>
                        <td><span class="badge bg-<?= $tc ?>"><?= $inc['incident_type'] ?></span></td>
                        <td><?= htmlspecialchars(($inc['location_code'] ?? '') . ' ' . ($inc['site_name'] ?? '-')) ?></td>
                        <td><?= $inc['incident_date'] ?></td>
                        <td class="text-end">$<?= number_format($inc['total_estimated_loss'], 2) ?></td>
                        <td><span class="badge bg-<?= $sc ?>"><?= str_replace('_', ' ', $inc['status']) ?></span></td>
                        <td><?= htmlspecialchars($inc['reported_by_name']) ?></td>
                        <td><a href="/inventory/incidents/view.php?id=<?= $inc['incident_id'] ?>" class="btn btn-sm btn-outline-primary">View</a></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php renderPagination($totalRows, $perPage, $page, ['status' => $statusFilter, 'type' => $typeFilter]); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
