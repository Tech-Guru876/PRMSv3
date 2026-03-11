<?php
$currentPage = $_SERVER['REQUEST_URI'];
$userName = $_SESSION['full_name'] ?? 'User';
$roleName = $_SESSION['role_name'] ?? '';
$isActing = isActingRole();
$actingRoles = isset($pdo) ? getActingRoles($pdo, $_SESSION['user_id'] ?? 0) : [];

function active($url, $currentPage) {
    return strpos($currentPage, $url) !== false ? 'active bg-secondary rounded' : '';
}

function isCollapsibleActive($urls, $currentPage) {
    foreach ($urls as $url) {
        if (strpos($currentPage, $url) !== false) return true;
    }
    return false;
}
?>

<div class="pt-3 text-white">

    <!-- BRAND -->
    <div class="text-center mb-3 border-bottom pb-3">
        <a href="/dashboard/index.php" class="text-decoration-none text-white d-flex align-items-center justify-content-center gap-2">
            <img src="/logo/cropped-Logo.png" alt="Logo" style="height:32px; filter: brightness(0) invert(1);">
            <span class="fw-semibold fs-5">DGC PRMS</span>
        </a>
    </div>

    <!-- USER PROFILE SECTION -->
    <div class="text-center mb-4 border-bottom pb-3">
        <div class="fw-bold"><?= htmlspecialchars($userName) ?></div>
        <?php if ($isActing): ?>
            <span class="badge bg-warning text-dark fs-7">
                ⚡ Acting: <?= htmlspecialchars($roleName) ?>
            </span>
            <br>
            <small class="text-muted" style="font-size: 0.7rem;">
                Primary: <?= htmlspecialchars(getPrimaryRoleName()) ?>
            </small>
        <?php else: ?>
            <span class="badge bg-info text-white fs-7">
                <?= htmlspecialchars($roleName) ?>
            </span>
        <?php endif; ?>

        <?php if ($isActing || !empty($actingRoles)): ?>
        <!-- Role Switcher -->
        <div class="mt-2">
            <?php if ($isActing): ?>
                <form method="POST" action="/auth/switch_role.php" class="d-inline">
                    <input type="hidden" name="action" value="revert">
                    <button type="submit" class="btn btn-outline-light btn-sm w-100" style="font-size: 0.75rem;">
                        🔄 Revert to <?= htmlspecialchars(getPrimaryRoleName()) ?>
                    </button>
                </form>
            <?php endif; ?>
            <?php foreach ($actingRoles as $ar): ?>
                <?php if ($ar['acting_role_id'] != ($_SESSION['role_id'] ?? 0)): ?>
                <form method="POST" action="/auth/switch_role.php" class="d-inline mt-1">
                    <input type="hidden" name="action" value="switch">
                    <input type="hidden" name="acting_role_id" value="<?= $ar['acting_role_id'] ?>">
                    <button type="submit" class="btn btn-outline-warning btn-sm w-100" style="font-size: 0.75rem;" title="<?= htmlspecialchars($ar['reason'] ?? '') ?>">
                        ⚡ Act as <?= htmlspecialchars($ar['role_name']) ?>
                    </button>
                </form>
                <?php endif; ?>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </div>

    <ul class="nav flex-column">

        <!-- ===== REQUESTOR DASHBOARD ===== -->
        <?php if ($roleName === 'Requestor'): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">REQUESTOR</div>
            <?php if (has_permission('submit_own_request')): ?>
            <a class="nav-link text-white <?= active('/procurement/add', $currentPage) ?>" href="/procurement/add.php">
                ➕ New Procurement Request
            </a>
            <?php endif; ?>
            <?php if (has_permission('view_own_requests')): ?>
            <a class="nav-link text-white <?= active('/procurement/my_requests', $currentPage) ?>" href="/procurement/my_requests.php">
                📋 My Requests
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>


        <!-- ===== HOD DASHBOARD ===== -->
        <?php if ($roleName === 'HOD'): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">HOD</div>
            <a class="nav-link text-white <?= active('/dashboard/hod', $currentPage) ?>" href="/dashboard/hod.php">
                🏢 HOD Dashboard
            </a>
            <a class="nav-link text-white <?= active('/procurement', $currentPage) ?>" href="/procurement/list.php">
                📋 All Requests
            </a>
            <a class="nav-link text-white <?= active('/commitments', $currentPage) ?>" href="/commitments/list.php">
                📄 Commitments
            </a>
            <a class="nav-link text-white <?= active('/po', $currentPage) ?>" href="/po/list.php">
                🧾 Purchase Orders
            </a>
        </li>
        <?php endif; ?>

        <!-- ===== DIRECTOR PROCUREMENT DASHBOARD ===== -->
        <?php if ($roleName === 'Director Procurement'): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">DIRECTOR PROCUREMENT</div>
            <a class="nav-link text-white <?= active('/dashboard/director_procurement', $currentPage) ?>" href="/dashboard/director_procurement.php">
                🏢 Director Procurement Dashboard
            </a>
            <a class="nav-link text-white <?= active('/procurement', $currentPage) ?>" href="/procurement/list.php">
                📋 All Requests
            </a>
            <a class="nav-link text-white <?= active('/commitments', $currentPage) ?>" href="/commitments/list.php">
                📄 Commitments
            </a>
            <a class="nav-link text-white <?= active('/po', $currentPage) ?>" href="/po/list.php">
                🧾 Purchase Orders
            </a>
        </li>
        <?php endif; ?>

        <!-- ===== CORE SECTION ===== -->
        <li class="nav-item">
            <a class="nav-link text-white <?= active('/dashboard', $currentPage) ?>"
               href="/dashboard/index.php">
                🏠 Dashboard
            </a>
        </li>

        <!-- ===== PROCUREMENT WORKFLOW ===== -->
        <?php if (has_permission('view_requests')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">PROCUREMENT</div>
            <a class="nav-link text-white <?= active('/procurement', $currentPage) ?>"
               href="/procurement/list.php">
                📄 Procurement Requests
            </a>
        </li>

        <li class="nav-item">
            <a class="nav-link text-white <?= active('/rfq', $currentPage) ?>"
               href="/rfq/list.php">
                📝 RFQ / Evaluation
            </a>
        </li>
        <?php endif; ?>

        <!-- ===== REIMBURSEMENT & PETTY CASH ===== -->
        <?php if (has_permission('submit_own_request') || has_permission('view_requests') || has_permission('approve_reimbursement') || has_permission('approve_petty_cash')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">SPECIAL REQUESTS</div>
            
            <?php if (has_permission('submit_own_request')): ?>
            <a class="nav-link text-white <?= active('/reimbursement', $currentPage) ?>"
               href="/reimbursement/add.php">
                💵 Submit Reimbursement Request
            </a>

            <a class="nav-link text-white <?= active('/petty_cash', $currentPage) ?>"
               href="/petty_cash/add.php">
                🏧 Submit Petty Cash Request
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_requests') || has_permission('approve_reimbursement')): ?>
            <a class="nav-link text-white <?= active('/reimbursement/list', $currentPage) ?>"
               href="/reimbursement/list.php">
                💵 Reimbursement Requests
                <?php
                // Show count of requests pending Finance approval
                $reimbPending = $pdo->query("
                    SELECT COUNT(*)
                    FROM procurement_requests
                    WHERE request_type='REIMBURSEMENT'
                    AND status = 'SUBMITTED'
                ")->fetchColumn();
                if ($reimbPending > 0):
                ?>
                    <span class="badge bg-warning ms-2"><?= $reimbPending ?></span>
                <?php endif; ?>
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_requests') || has_permission('approve_petty_cash')): ?>
            <a class="nav-link text-white <?= active('/petty_cash/list', $currentPage) ?>"
               href="/petty_cash/list.php">
                🏧 Petty Cash Requests
                <?php
                // Show count of requests pending Finance approval
                $pettyCashPending = $pdo->query("
                    SELECT COUNT(*)
                    FROM procurement_requests
                    WHERE request_type='PETTY_CASH'
                    AND status = 'SUBMITTED'
                ")->fetchColumn();
                if ($pettyCashPending > 0):
                ?>
                    <span class="badge bg-danger ms-2"><?= $pettyCashPending ?></span>
                <?php endif; ?>
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>

        <?php if (has_permission('view_commitments')): ?>
        <li class="nav-item">
            <a class="nav-link text-white <?= active('/commitments', $currentPage) ?>"
               href="/commitments/list.php">
                📑 Commitments
                <?php
                $pending = $pdo->query("
                    SELECT COUNT(*)
                    FROM request_approvals
                    WHERE entity_type='COMMITMENT'
                    AND status='pending'
                ")->fetchColumn();
                if ($pending > 0):
                ?>
                    <span class="badge bg-danger ms-2"><?= $pending ?></span>
                <?php endif; ?>
            </a>
        </li>
        <?php endif; ?>

        <!-- ===== FINANCIAL SECTION ===== -->
        <?php if (has_permission('view_purchase_orders') || has_permission('view_invoices') || has_permission('view_po_adjustments')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">FINANCIAL</div>
            
            <?php if (has_permission('view_purchase_orders')): ?>
            <a class="nav-link text-white <?= active('/po', $currentPage) ?>"
               href="/po/list.php">
                🧾 Purchase Orders
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_invoices')): ?>
            <a class="nav-link text-white <?= active('/invoice', $currentPage) ?>"
               href="/invoice/list.php">
                📋 Invoices
            </a>

            <a class="nav-link text-white <?= active('/payment', $currentPage) ?>"
               href="/payment/list.php">
                💳 Payments
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_po_adjustments')): ?>
            <a class="nav-link text-white <?= active('/po/variation', $currentPage) ?>"
               href="/po/variation_queue.php">
                ⚙️ PO Variations
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>

        <!-- ===== REPORTS SECTION ===== -->
        <?php if (has_permission('view_financial_reports') || has_permission('view_management_dashboard')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">REPORTS</div>

            <?php if (has_permission('view_financial_reports')): ?>
            <!-- Procurement Reports -->
            <div class="text-muted small px-3 mb-2 mt-2" style="font-size: 0.8rem;">Procurement</div>
            <a class="nav-link text-white <?= active('/reports/procurement_by_status', $currentPage) ?>"
               href="/reports/procurement_by_status.php">
                📊 By Status
            </a>
            <a class="nav-link text-white <?= active('/reports/procurement_by_type', $currentPage) ?>"
               href="/reports/procurement_by_type.php">
                📋 By Type
            </a>
            <a class="nav-link text-white <?= active('/reports/procurement_by_branch', $currentPage) ?>"
               href="/reports/procurement_by_branch.php">
                🏢 By Branch
            </a>
            <a class="nav-link text-white <?= active('/reports/procurement_by_supplier', $currentPage) ?>"
               href="/reports/procurement_by_supplier.php">
                🤝 By Supplier
            </a>

            <!-- PO & Financial Reports -->
            <div class="text-muted small px-3 mb-2 mt-2" style="font-size: 0.8rem;">Purchase Orders</div>
            <a class="nav-link text-white <?= active('/reports/po_status', $currentPage) ?>"
               href="/reports/po_status_report.php">
                📦 PO Status
            </a>

            <!-- Period & Payment Reports -->
            <div class="text-muted small px-3 mb-2 mt-2" style="font-size: 0.8rem;">Financial</div>
            <a class="nav-link text-white <?= active('/reports/period_reports', $currentPage) ?>"
               href="/reports/period_reports.php">
                📅 Period Reports
            </a>
            <a class="nav-link text-white <?= active('/reports/amounts_paid', $currentPage) ?>"
               href="/reports/amounts_paid_report.php">
                💳 Amounts Paid
            </a>
            <a class="nav-link text-white <?= active('/reports/outstanding', $currentPage) ?>"
               href="/reports/outstanding_commitments_po.php">
                ⏳ Outstanding
            </a>

            <!-- Legacy Reports -->
            <div class="text-muted small px-3 mb-2 mt-2" style="font-size: 0.8rem;">Branch</div>
            <a class="nav-link text-white <?= active('/reports/branch_summary', $currentPage) ?>"
               href="/reports/branch_summary.php">
                📊 Summary
            </a>
            <a class="nav-link text-white <?= active('/reports/branch_outstanding', $currentPage) ?>"
               href="/reports/branch_outstanding.php">
                💰 Outstanding Balances
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_management_dashboard')): ?>
            <a class="nav-link text-white <?= active('/reports/export', $currentPage) ?>"
               href="/reports/export_pdf.php">
                📄 Export Reports
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>

        <!-- ===== INVENTORY MANAGEMENT ===== -->
        <?php if (has_permission('view_inventory')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">INVENTORY</div>
            <a class="nav-link text-white <?= active('/inventory/dashboard', $currentPage) ?>"
               href="/inventory/dashboard.php">
                📊 Inventory Dashboard
            </a>
            <a class="nav-link text-white <?= active('/inventory/items', $currentPage) ?>"
               href="/inventory/items/list.php">
                📦 Items
            </a>
            <a class="nav-link text-white <?= active('/inventory/locations', $currentPage) ?>"
               href="/inventory/locations/list.php">
                📍 Locations
            </a>
            <a class="nav-link text-white <?= active('/inventory/requisitions', $currentPage) ?>"
               href="/inventory/requisitions/list.php">
                📋 Requisitions
            </a>
            <?php if (has_permission('receive_goods')): ?>
            <a class="nav-link text-white <?= active('/inventory/receiving', $currentPage) ?>"
               href="/inventory/receiving/list.php">
                📥 Receiving (GRN)
            </a>
            <?php endif; ?>
            <?php if (has_permission('issue_stock')): ?>
            <a class="nav-link text-white <?= active('/inventory/issuing', $currentPage) ?>"
               href="/inventory/issuing/list.php">
                📤 Stock Issues
            </a>
            <?php endif; ?>
            <?php if (has_permission('transfer_stock')): ?>
            <a class="nav-link text-white <?= active('/inventory/transfers', $currentPage) ?>"
               href="/inventory/transfers/list.php">
                🔄 Transfers
            </a>
            <?php endif; ?>
            <?php if (has_permission('adjust_stock')): ?>
            <a class="nav-link text-white <?= active('/inventory/adjustments', $currentPage) ?>"
               href="/inventory/adjustments/list.php">
                ⚖️ Adjustments
            </a>
            <?php endif; ?>
            <?php if (has_permission('dispose_stock')): ?>
            <a class="nav-link text-white <?= active('/inventory/disposal', $currentPage) ?>"
               href="/inventory/disposal/list.php">
                🗑️ Disposal
            </a>
            <?php endif; ?>
            <?php if (has_permission('conduct_stock_count')): ?>
            <a class="nav-link text-white <?= active('/inventory/stocktake', $currentPage) ?>"
               href="/inventory/stocktake/list.php">
                📝 Stock Counts
            </a>
            <?php endif; ?>
            <?php if (has_permission('manage_quarantine')): ?>
            <a class="nav-link text-white <?= active('/inventory/quarantine', $currentPage) ?>"
               href="/inventory/quarantine/list.php">
                🛡️ Quarantine
            </a>
            <?php endif; ?>
            <?php if (has_permission('manage_recalls')): ?>
            <a class="nav-link text-white <?= active('/inventory/recall', $currentPage) ?>"
               href="/inventory/recall/list.php">
                🔔 Recalls
            </a>
            <?php endif; ?>
            <?php if (has_permission('manage_returns')): ?>
            <a class="nav-link text-white <?= active('/inventory/returns', $currentPage) ?>"
               href="/inventory/returns/list.php">
                ↩️ Returns to Supplier
            </a>
            <?php endif; ?>
            <?php if (has_permission('manage_incidents')): ?>
            <a class="nav-link text-white <?= active('/inventory/incidents', $currentPage) ?>"
               href="/inventory/incidents/list.php">
                ⚠️ Incidents / Losses
            </a>
            <?php endif; ?>
            <?php if (has_permission('manage_write_downs')): ?>
            <a class="nav-link text-white <?= active('/inventory/writedowns', $currentPage) ?>"
               href="/inventory/writedowns/list.php">
                📉 Write-Downs (NRV)
            </a>
            <?php endif; ?>
            <?php if (has_permission('view_inventory_reports')): ?>
            <a class="nav-link text-white <?= active('/inventory/reports', $currentPage) ?>"
               href="/inventory/reports/">
                📈 Inventory Reports
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>

        <!-- ===== ADMINISTRATION SECTION ===== -->
        <?php if (has_permission('manage_users') || has_permission('view_audit_logs')): ?>
        <li class="nav-item mt-3">
            <div class="text-muted small fw-bold px-3 mb-2">ADMIN</div>
            
            <?php if (has_permission('manage_users')): ?>
            <a class="nav-link text-white <?= active('/users', $currentPage) ?>"
               href="/users/list.php">
                👥 Users
            </a>
            <a class="nav-link text-white <?= active('/acting_roles', $currentPage) ?>"
               href="/users/acting_roles.php">
                ⚡ Acting Roles
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_vendors') || has_permission('manage_vendors')): ?>
            <a class="nav-link text-white <?= active('/vendors', $currentPage) ?>"
               href="/vendors/list.php">
                🏢 Vendors
            </a>
            <?php endif; ?>

            <?php if (has_permission('view_audit_logs')): ?>
            <a class="nav-link text-white <?= active('/audit', $currentPage) ?>"
               href="/audit/list.php">
                📜 Audit Logs
            </a>
            <?php endif; ?>
        </li>
        <?php endif; ?>

        <!-- ===== ACCOUNT SECTION ===== -->
        <li class="nav-item mt-4 border-top pt-3">
            <a class="nav-link text-white <?= active('/change_password', $currentPage) ?>"
               href="/auth/change_password.php">
                🔑 Change Password
            </a>

            <a class="nav-link text-danger"
               href="/auth/logout.php">
                🚪 Logout
            </a>
        </li>

    </ul>

</div>
