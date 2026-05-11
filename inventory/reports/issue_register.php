<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo   = $_GET['date_to']   ?? date('Y-m-d');
$statusF  = $_GET['status']    ?? '';

$where  = "i.issue_date BETWEEN ? AND ?";
$params = [$dateFrom, $dateTo];
if ($statusF !== '') { $where .= " AND i.status = ?"; $params[] = $statusF; }

$rows = $pdo->prepare("
    SELECT i.issue_id, i.issue_number, i.issue_date, i.status,
           i.issued_to_project, i.issued_to_event, i.issued_to_vehicle,
           i.issued_to_building_room, i.dispatch_confirmed,
           ub.full_name AS issued_by_name,
           ut.full_name AS issued_to_name,
           b.name AS department_name,
           COUNT(ii.issue_item_id) AS line_count,
           SUM(ii.total_cost) AS total_cost
    FROM inv_issues i
    LEFT JOIN users ub ON i.issued_by = ub.user_id
    LEFT JOIN users ut ON i.issued_to_user_id = ut.user_id
    LEFT JOIN branches b ON i.issued_to_department = b.branch_id
    LEFT JOIN inv_issue_items ii ON i.issue_id = ii.issue_id
    WHERE $where
    GROUP BY i.issue_id
    ORDER BY i.issue_date DESC, i.issue_id DESC
");
$rows->execute($params);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

$grandTotal = array_sum(array_column($rows, 'total_cost'));

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-arrow-right"></i> Stock Issue Register</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to"   class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2">
        <select name="status" class="form-select">
            <option value="">All Statuses</option>
            <?php foreach (['DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED','COMPLETED'] as $s): ?>
            <option value="<?= $s ?>" <?= $statusF === $s ? 'selected' : '' ?>><?= $s ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-funnel"></i> Filter</button></div>
</form>

<div class="alert alert-info mb-3">
    <strong><?= count($rows) ?></strong> issues &nbsp;|&nbsp;
    <strong>Total Cost of Issues: $<?= number_format($grandTotal, 2) ?></strong>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 table-sm">
                <thead class="table-light">
                    <tr>
                        <th>Issue #</th>
                        <th>Date</th>
                        <th>Issued To (Person)</th>
                        <th>Department</th>
                        <th>Project / Event</th>
                        <th>Status</th>
                        <th>Dispatched</th>
                        <th>Lines</th>
                        <th class="text-end">Total Cost</th>
                        <th>Issued By</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="10" class="text-center text-muted py-4">No records found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><a href="/inventory/issuing/view.php?id=<?= $r['issue_id'] ?>"><?= htmlspecialchars($r['issue_number']) ?></a></td>
                        <td><?= htmlspecialchars($r['issue_date']) ?></td>
                        <td><?= htmlspecialchars($r['issued_to_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['department_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($r['issued_to_project'] ?? $r['issued_to_event'] ?? $r['issued_to_vehicle'] ?? $r['issued_to_building_room'] ?? '-') ?></td>
                        <td>
                            <?php $sc = match($r['status']) {
                                'ISSUED','COMPLETED' => 'success',
                                'CANCELLED'          => 'danger',
                                'PARTIAL'            => 'warning',
                                'APPROVED'           => 'info',
                                default              => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $sc ?>"><?= $r['status'] ?></span>
                        </td>
                        <td class="text-center">
                            <?= $r['dispatch_confirmed'] ? '<i class="bi bi-check-circle text-success"></i>' : '<i class="bi bi-clock text-muted"></i>' ?>
                        </td>
                        <td class="text-center"><?= $r['line_count'] ?></td>
                        <td class="text-end">$<?= number_format($r['total_cost'] ?? 0, 2) ?></td>
                        <td><?= htmlspecialchars($r['issued_by_name'] ?? '-') ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
                <?php if (!empty($rows)): ?>
                <tfoot class="table-dark">
                    <tr>
                        <td colspan="8" class="text-end fw-bold">Grand Total:</td>
                        <td class="text-end fw-bold">$<?= number_format($grandTotal, 2) ?></td>
                        <td></td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
