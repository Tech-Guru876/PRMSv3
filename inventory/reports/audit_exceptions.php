<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once __DIR__ . '/../check_setup.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/pagination.php';

$dateFrom = $_GET['date_from'] ?? date('Y-m-01');
$dateTo = $_GET['date_to'] ?? date('Y-m-d');

extract(getPaginationParams(25));

$rows = [];
$reportError = null;
try {
    $countStmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM audit_log al
        WHERE al.table_name LIKE 'inv_%'
          AND al.change_date BETWEEN ? AND ?
    ");
    $countStmt->execute([$dateFrom, $dateTo . ' 23:59:59']);
    $totalRows = (int) $countStmt->fetchColumn();

    $rowsStmt = $pdo->prepare("
        SELECT al.audit_id, al.table_name, al.record_id, al.action, al.notes,
               al.change_date AS event_time, al.changed_by AS user_name
        FROM audit_log al
        WHERE al.table_name LIKE 'inv_%'
          AND al.change_date BETWEEN ? AND ?
        ORDER BY al.change_date DESC
        LIMIT $perPage OFFSET $offset
    ");
    $rowsStmt->execute([$dateFrom, $dateTo . ' 23:59:59']);
    $rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $totalRows = 0;
    $reportError = 'Audit data is temporarily unavailable.';
    error_log('audit_exceptions report error: ' . $e->getMessage());
}

$pdfUrl = '/inventory/reports/export_pdf.php?report=audit_exceptions&' . http_build_query($_GET);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-shield-exclamation"></i> Audit Exceptions</h2>
    <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($pdfUrl) ?>" class="btn btn-outline-danger" target="_blank"><i class="bi bi-file-pdf"></i> Export PDF</a>
        <a href="/inventory/reports/" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Reports</a>
    </div>
</div>

<?php if ($reportError): ?>
<div class="alert alert-warning"><?= htmlspecialchars($reportError) ?></div>
<?php endif; ?>

<form class="row g-2 mb-4">
    <div class="col-md-2"><input type="date" name="date_from" class="form-control" value="<?= htmlspecialchars($dateFrom) ?>"></div>
    <div class="col-md-2"><input type="date" name="date_to" class="form-control" value="<?= htmlspecialchars($dateTo) ?>"></div>
    <div class="col-md-2"><button class="btn btn-dark w-100"><i class="bi bi-search"></i> Filter</button></div>
</form>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr><th>Timestamp</th><th>Table</th><th>Record</th><th>Action</th><th>User</th><th>Notes</th></tr>
                </thead>
                <tbody>
                    <?php if (empty($rows)): ?>
                    <tr><td colspan="6" class="text-center text-muted py-4">No audit events found</td></tr>
                    <?php else: foreach ($rows as $r): ?>
                    <tr>
                        <td><?= date('Y-m-d H:i:s', strtotime($r['event_time'])) ?></td>
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

<?php renderShowingInfo($page, $perPage, $totalRows); ?>
<?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
