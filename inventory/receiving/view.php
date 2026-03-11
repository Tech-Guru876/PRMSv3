<?php
$REQUIRE_PERMISSION = 'receive_goods';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';

$grnId = (int) ($_GET['id'] ?? 0);
if ($grnId <= 0) { pop("Invalid GRN.", "/inventory/receiving/list.php", 1800, 'warning'); exit; }

$grn = $pdo->prepare("
    SELECT g.*, u.full_name AS receiver_name, l.location_code, l.site_name
    FROM inv_goods_received_notes g
    JOIN users u ON g.received_by = u.user_id
    LEFT JOIN inv_locations l ON g.receiving_location_id = l.location_id
    WHERE g.grn_id = ?
");
$grn->execute([$grnId]);
$grn = $grn->fetch(PDO::FETCH_ASSOC);
if (!$grn) { pop("GRN not found.", "/inventory/receiving/list.php", 1800, 'warning'); exit; }

$lineItems = $pdo->prepare("
    SELECT gi.*, i.item_code, i.item_name, um.uom_code
    FROM inv_grn_items gi
    JOIN inv_items i ON gi.item_id = i.item_id
    LEFT JOIN inv_units_of_measure um ON i.uom_id = um.uom_id
    WHERE gi.grn_id = ?
");
$lineItems->execute([$grnId]);
$lineItems = $lineItems->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-box-seam"></i> GRN <?= htmlspecialchars($grn['grn_number']) ?></h2>
    <div>
        <?php if (in_array($grn['status'], ['DRAFT','INSPECTION'])): ?>
        <a href="/inventory/receiving/add.php?id=<?= $grnId ?>" class="btn btn-outline-primary"><i class="bi bi-pencil"></i> Edit</a>
        <?php endif; ?>
        <a href="/inventory/receiving/list.php" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
    </div>
</div>

<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <div class="row g-3">
            <div class="col-md-3"><strong>GRN #:</strong> <?= htmlspecialchars($grn['grn_number']) ?></div>
            <div class="col-md-3"><strong>PO #:</strong> <?= htmlspecialchars($grn['po_number'] ?: '-') ?></div>
            <div class="col-md-3"><strong>Supplier:</strong> <?= htmlspecialchars($grn['supplier_name']) ?></div>
            <div class="col-md-3"><strong>Status:</strong>
                <?php $sc = match($grn['status']) { 'COMPLETED' => 'success', 'INSPECTION' => 'warning', 'QUARANTINE' => 'danger', 'DRAFT' => 'secondary', default => 'light' }; ?>
                <span class="badge bg-<?= $sc ?>"><?= $grn['status'] ?></span>
            </div>
            <div class="col-md-3"><strong>Received Date:</strong> <?= $grn['received_date'] ?></div>
            <div class="col-md-3"><strong>Received By:</strong> <?= htmlspecialchars($grn['receiver_name']) ?></div>
            <div class="col-md-3"><strong>Location:</strong> <?= htmlspecialchars($grn['location_code'] . ' - ' . $grn['site_name']) ?></div>
            <div class="col-md-3"><strong>Delivery Note:</strong> <?= htmlspecialchars($grn['delivery_note_number'] ?: '-') ?></div>
            <?php if ($grn['invoice_number']): ?>
            <div class="col-md-3"><strong>Invoice #:</strong> <?= htmlspecialchars($grn['invoice_number']) ?></div>
            <?php endif; ?>
            <?php if ($grn['is_non_exchange_transaction']): ?>
            <div class="col-md-3"><span class="badge bg-info">Non-Exchange Transaction</span></div>
            <?php endif; ?>
            <?php if ($grn['donor_info']): ?>
            <div class="col-md-6"><strong>Donor:</strong> <?= htmlspecialchars($grn['donor_info']) ?></div>
            <?php endif; ?>
            <?php if ($grn['notes']): ?>
            <div class="col-12"><strong>Notes:</strong> <?= nl2br(htmlspecialchars($grn['notes'])) ?></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-dark text-white"><i class="bi bi-list-ol"></i> Received Items</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Item Code</th><th>Item Name</th><th>Lot</th><th>Batch</th><th>Serial</th>
                        <th>Expiry</th><th class="text-end">Qty Recv</th><th class="text-end">Accepted</th>
                        <th class="text-end">Rejected</th><th class="text-end">Unit Cost</th><th>Condition</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($lineItems as $li): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($li['item_code']) ?></code></td>
                        <td><?= htmlspecialchars($li['item_name']) ?></td>
                        <td><?= htmlspecialchars($li['lot_number'] ?: '-') ?></td>
                        <td><?= htmlspecialchars($li['batch_number'] ?: '-') ?></td>
                        <td><?= htmlspecialchars($li['serial_number'] ?: '-') ?></td>
                        <td><?= $li['expiry_date'] ?: '-' ?></td>
                        <td class="text-end fw-bold"><?= number_format($li['quantity_received'], 2) ?> <?= $li['uom_code'] ?></td>
                        <td class="text-end text-success"><?= number_format($li['quantity_accepted'], 2) ?></td>
                        <td class="text-end text-danger"><?= number_format($li['quantity_rejected'], 2) ?></td>
                        <td class="text-end">$<?= number_format($li['unit_cost'] ?? 0, 2) ?></td>
                        <td>
                            <?php $cc = match($li['condition_on_receipt']) { 'GOOD' => 'success', 'DAMAGED' => 'warning', 'REJECTED' => 'danger', default => 'secondary' }; ?>
                            <span class="badge bg-<?= $cc ?>"><?= $li['condition_on_receipt'] ?></span>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
