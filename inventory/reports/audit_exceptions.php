<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo = $_GET['date_to'] ?? date('Y-m-d');

$rows = $pdo->prepare("
    SELECT al.audit_id, al.table_name, al.record_id, al.action, al.notes,
           al.created_at, u.full_name AS user_name
    FROM audit_logs al
    LEFT JOIN users u ON al.user_id = u.user_id
    WHERE al.table_name LIKE 'inv_%'
      AND al.created_at BETWEEN ? AND ?
    ORDER BY al.created_at DESC
    LIMIT 500
");
$rows->execute([$dateFrom, $dateTo . ' 23:59:59']);
$rows = $rows->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-shield-exclamation"></i> Audit Exceptions</h2>
    <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
</div>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to" class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-search"></i> Filter</button></div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr><th>Timestamp</th><th>Table</th><th>Record</th><th>Action</th><th>User</th><th>Notes</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="6" class="text-center text-muted py-4">No audit events found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i:s', strtotime($r['created_at'])) ?></td>
                        <td><code><?= htmlspecialchars($r['table_name']) ?></code></td>
                        <td>#<?= $r['record_id'] ?></td>
                        <td>
                            <?php $ac = match(true) {
                                str_contains($r['action'], 'REJECT') => 'danger',
                                str_contains($r['action'], 'APPROV') => 'success',
                                str_contains($r['action'], 'CREAT') => 'info',
                                default => 'secondary'
                            }; ?>
                            <span class="badge bg-<?= $ac ?>"><?= htmlspecialchars($r['action']) ?></span>
                        </td>
                        <td><?= htmlspecialchars($r['user_name'] ?? '-') ?></td>
                        <td><?= htmlspecialchars(mb_substr($r['notes'] ?? '', 0, 80)) ?></td>
                    </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
