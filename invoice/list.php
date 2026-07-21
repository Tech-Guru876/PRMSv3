<?php
$REQUIRE_PERMISSION = 'view_invoices';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT']."/config/db.php";
require_once $_SERVER['DOCUMENT_ROOT']."/includes/pagination.php";

/* ================================
   Filters
================================ */
$where = [];
$params = [];

if (!empty($_GET['q'])) {
    $where[] = "(i.invoice_number LIKE :q OR po.po_number LIKE :q)";
    $params[':q'] = '%'.$_GET['q'].'%';
}

if (!empty($_GET['status'])) {
    $where[] = "i.status = :status";
    $params[':status'] = $_GET['status'];
}

if (!empty($_GET['from'])) {
    $where[] = "i.invoice_date >= :from";
    $params[':from'] = $_GET['from'];
}

if (!empty($_GET['to'])) {
    $where[] = "i.invoice_date <= :to";
    $params[':to'] = $_GET['to'];
}

$whereSQL = $where ? 'WHERE ' . implode(' AND ', $where) : '';

/* ================================
   Pagination params
================================ */
extract(getPaginationParams(20));

/* ================================
   Data query (paginated)
================================ */
$sql = "
    SELECT 
        i.invoice_id,
        i.invoice_number,
        i.invoice_date,
        i.invoice_amount,
        i.status,
        po.po_number
    FROM invoices i
    JOIN purchase_orders po ON i.po_id = po.po_id
    $whereSQL
    ORDER BY i.invoice_date DESC
    LIMIT :limit OFFSET :offset
";

$stmt = $pdo->prepare($sql);

foreach ($params as $k => $v) {
    $stmt->bindValue($k, $v);
}

$stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();

$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

/* ================================
   Count query
================================ */
$countSql = "
    SELECT COUNT(*)
    FROM invoices i
    JOIN purchase_orders po ON i.po_id = po.po_id
    $whereSQL
";

$countStmt = $pdo->prepare($countSql);

foreach ($params as $k => $v) {
    $countStmt->bindValue($k, $v);
}

$countStmt->execute();
$totalRows = (int)$countStmt->fetchColumn();

/* ================================
   Render page
================================ */
require_once $_SERVER['DOCUMENT_ROOT']."/includes/header.php";

/* ================================
   Calculate summary stats
================================ */
$statsSql = "SELECT 
    COUNT(*) as total_invoices,
    SUM(CASE WHEN status = 'Paid' THEN 1 ELSE 0 END) as paid_count,
    SUM(CASE WHEN status != 'Paid' THEN 1 ELSE 0 END) as unpaid_count,
    SUM(invoice_amount) as total_amount
FROM invoices i";

$statsStmt = $pdo->prepare($statsSql);
$statsStmt->execute();
$stats = $statsStmt->fetch(PDO::FETCH_ASSOC);

?>

<style>
    .gradient-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 12px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .gradient-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
    }
    .gradient-card-cyan {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        box-shadow: 0 4px 15px rgba(79, 172, 254, 0.4);
    }
    .gradient-card-cyan:hover {
        box-shadow: 0 6px 20px rgba(79, 172, 254, 0.6);
    }
    .gradient-card-green {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        box-shadow: 0 4px 15px rgba(67, 233, 123, 0.4);
    }
    .gradient-card-green:hover {
        box-shadow: 0 6px 20px rgba(67, 233, 123, 0.6);
    }
    .gradient-card-red {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        box-shadow: 0 4px 15px rgba(240, 147, 251, 0.4);
    }
    .gradient-card-red:hover {
        box-shadow: 0 6px 20px rgba(240, 147, 251, 0.6);
    }
    .stats-value {
        font-size: 1.75rem;
        font-weight: 700;
        margin: 0.5rem 0;
    }
    .stats-label {
        font-size: 0.9rem;
        opacity: 0.95;
        font-weight: 500;
    }
    .filter-card {
        background: white;
        border-radius: 10px;
        border: 1px solid #e0e0e0;
        padding: 1.5rem;
        margin-bottom: 2rem;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    }
    .form-control, .form-select {
        border-radius: 6px;
        border: 1px solid #d0d0d0;
        padding: 0.65rem 0.75rem;
        font-size: 0.95rem;
        transition: all 0.3s ease;
    }
    .form-control:focus, .form-select:focus {
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    .btn-filter {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        border-radius: 6px;
        padding: 0.65rem 1.5rem;
        font-weight: 500;
        transition: all 0.3s ease;
    }
    .btn-filter:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        color: white;
    }
</style>

<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-lg-12">
            <h2 style="font-weight: 700; color: #1a1a1a; margin-bottom: 0.5rem;">🧾 Invoice Register</h2>
            <p style="color: #666; font-size: 0.95rem; margin-bottom: 1.5rem;">View and manage all invoices across your procurement system</p>
        </div>
    </div>

    <!-- KPI Cards Row -->
    <div class="row mb-3">
        <div class="col-md-3">
            <div class="gradient-card gradient-card">
                <div class="stats-label">Total Invoices</div>
                <div class="stats-value"><?= number_format((int)$stats['total_invoices']) ?></div>
                <div class="stats-label" style="opacity: 0.8; font-size: 0.85rem;">All invoices in system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="gradient-card gradient-card-green">
                <div class="stats-label">Paid</div>
                <div class="stats-value"><?= number_format((int)$stats['paid_count']) ?></div>
                <div class="stats-label" style="opacity: 0.8; font-size: 0.85rem;">Completed payments</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="gradient-card gradient-card-red">
                <div class="stats-label">Unpaid</div>
                <div class="stats-value"><?= number_format((int)$stats['unpaid_count']) ?></div>
                <div class="stats-label" style="opacity: 0.8; font-size: 0.85rem;">Pending payment</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="gradient-card gradient-card-cyan">
                <div class="stats-label">Total Amount</div>
                <div class="stats-value">JMD <?= number_format((float)$stats['total_amount'] ?? 0, 0) ?></div>
                <div class="stats-label" style="opacity: 0.8; font-size: 0.85rem;">All invoices sum</div>
            </div>
        </div>
    </div>

    <!-- Filter Card -->
    <div class="filter-card">
        <form method="get" class="row g-3">
            <div class="col-md-4">
                <label class="form-label" style="font-weight: 500; color: #1a1a1a; margin-bottom: 0.5rem;"><i class="bi bi-search"></i> Search</label>
                <input type="text"
                       name="q"
                       value="<?= htmlspecialchars($_GET['q'] ?? '') ?>"
                       class="form-control"
                       placeholder="Invoice #, PO #...">
            </div>
            <div class="col-md-2">
                <label class="form-label" style="font-weight: 500; color: #1a1a1a; margin-bottom: 0.5rem;"><i class="bi bi-info-circle"></i> Status</label>
                <select name="status" class="form-select">
                    <option value="">All Status</option>
                    <?php foreach (['Unpaid','Partially Paid','Paid'] as $s): ?>
                        <option value="<?= $s ?>"
                            <?= ($_GET['status'] ?? '') === $s ? 'selected' : '' ?>>
                            <?= $s ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label" style="font-weight: 500; color: #1a1a1a; margin-bottom: 0.5rem;"><i class="bi bi-calendar"></i> From</label>
                <input type="date" name="from" value="<?= htmlspecialchars($_GET['from'] ?? '') ?>" class="form-control">
            </div>
            <div class="col-md-2">
                <label class="form-label" style="font-weight: 500; color: #1a1a1a; margin-bottom: 0.5rem;"><i class="bi bi-calendar"></i> To</label>
                <input type="date" name="to" value="<?= htmlspecialchars($_GET['to'] ?? '') ?>" class="form-control">
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-filter w-100">
                    <i class="bi bi-funnel"></i> Filter
                </button>
            </div>
        </form>
    </div>

    <?php renderShowingInfo($page, $perPage, $totalRows); ?>

    <!-- Invoices Table -->
    <div style="background: white; border-radius: 10px; border: 1px solid #e0e0e0; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05); overflow: hidden;">
        <div style="background: #f8f9fa; padding: 1rem; border-bottom: 1px solid #e0e0e0;">
            <h5 style="margin: 0; font-weight: 600; color: #1a1a1a;">📋 Invoice List</h5>
        </div>
        <div class="table-responsive">
            <table class="table mb-0" style="border-collapse: collapse;">
                <thead>
                    <tr style="background-color: #f8f9fa; border-bottom: 2px solid #e0e0e0;">
                        <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none;"><i class="bi bi-receipt"></i> Invoice #</th>
                        <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none;"><i class="bi bi-file-earmark"></i> PO #</th>
                        <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none;"><i class="bi bi-calendar-event"></i> Date</th>
                        <th style="padding: 1rem; text-align: right; font-weight: 600; color: #333; border: none;"><i class="bi bi-currency-dollar"></i> Amount</th>
                        <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none;"><i class="bi bi-info-circle"></i> Status</th>
                        <th style="padding: 1rem; text-align: center; font-weight: 600; color: #333; border: none;"><i class="bi bi-lightning"></i> Action</th>
                    </tr>
                </thead>
                <tbody>
                <?php if (empty($rows)): ?>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 3rem 1rem; border: none;">
                            <i class="bi bi-inbox" style="font-size: 2rem; color: #ccc;"></i>
                            <p style="color: #999; margin-top: 1rem; margin-bottom: 0;">No invoices found. All clear! ✨</p>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($rows as $i): ?>
                        <tr style="border-bottom: 1px solid #f0f0f0; transition: background-color 0.2s ease;">
                            <td style="padding: 1rem; border: none;"><span style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 0.4rem 0.8rem; border-radius: 6px; font-weight: 500; font-size: 0.9rem;"><?= htmlspecialchars($i['invoice_number']) ?></span></td>
                            <td style="padding: 1rem; border: none; color: #666;"><?= htmlspecialchars($i['po_number']) ?></td>
                            <td style="padding: 1rem; border: none; color: #666;"><?= date('d M Y', strtotime($i['invoice_date'])) ?></td>
                            <td style="padding: 1rem; border: none; text-align: right; font-weight: 600; color: #1a1a1a;">JMD <?= number_format((float)$i['invoice_amount'], 2) ?></td>
                            <td style="padding: 1rem; border: none;">
                                <?php
                                    $statusColor = match ($i['status']) {
                                        'Paid' => 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
                                        'Partially Paid' => 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
                                        default => 'linear-gradient(135deg, #a8a8a8 0%, #707070 100%)'
                                    };
                                ?>
                                <span style="background: <?= $statusColor ?>; color: white; padding: 0.35rem 0.75rem; border-radius: 5px; font-size: 0.85rem; font-weight: 500;">
                                    <?= htmlspecialchars($i['status']) ?>
                                </span>
                            </td>
                            <td style="padding: 1rem; border: none; text-align: center;">
                                <a href="/invoice/view.php?id=<?= (int)$i['invoice_id'] ?>"
                                   style="display: inline-block; padding: 0.4rem 0.8rem; background: white; color: #667eea; border: 1px solid #667eea; border-radius: 5px; text-decoration: none; font-size: 0.9rem; font-weight: 500; transition: all 0.2s ease;" 
                                   onmouseover="this.style.background='#667eea'; this.style.color='white';"
                                   onmouseout="this.style.background='white'; this.style.color='#667eea';"
                                   title="View Invoice">
                                    <i class="bi bi-eye"></i> View
                                </a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php if ($totalRows > 0): ?>
<div class="mt-3">
    <?php renderShowingInfo($page, $perPage, $totalRows); ?>
    <?php renderPagination($totalRows, $perPage, $page, $_GET); ?>
</div>
<?php endif; ?>

<?php require_once $_SERVER['DOCUMENT_ROOT']."/includes/footer.php"; ?>
