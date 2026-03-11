<?php
$REQUIRE_PERMISSION = 'view_inventory_reports';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-bar-chart"></i> Inventory Reports</h2>
    <a href="/inventory/dashboard.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Dashboard</a>
</div>

<div class="row g-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-currency-dollar display-4 text-primary"></i>
                <h5 class="mt-3">Stock Valuation</h5>
                <p class="text-muted">Total inventory value by item, location, and category with IPSAS 12 compliant valuation.</p>
                <a href="/inventory/reports/stock_valuation.php" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-exclamation-triangle display-4 text-warning"></i>
                <h5 class="mt-3">Reorder Report</h5>
                <p class="text-muted">Items at or below reorder point, sorted by criticality and shortfall.</p>
                <a href="/inventory/reports/reorder_report.php" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-calendar-x display-4 text-danger"></i>
                <h5 class="mt-3">Expiry Report</h5>
                <p class="text-muted">Items expiring within configurable time windows.</p>
                <a href="/inventory/reports/expiry_report.php" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-clock-history display-4 text-info"></i>
                <h5 class="mt-3">Transaction History</h5>
                <p class="text-muted">Complete audit trail of all stock movements with filters.</p>
                <a href="/inventory/reports/transaction_history.php" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-clipboard-data display-4 text-success"></i>
                <h5 class="mt-3">Stock Count Variances</h5>
                <p class="text-muted">View completed stock counts and analyze variances.</p>
                <a href="/inventory/stocktake/list.php?status=COMPLETED" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body text-center">
                <i class="bi bi-shield-exclamation display-4 text-secondary"></i>
                <h5 class="mt-3">Audit Exceptions</h5>
                <p class="text-muted">Review inventory audit trail and exception events.</p>
                <a href="/inventory/reports/audit_exceptions.php" class="btn btn-dark">View Report</a>
            </div>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
