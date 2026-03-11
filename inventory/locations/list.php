<?php
$REQUIRE_PERMISSION = 'view_inventory';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

$locations = $pdo->query("
    SELECT l.*, u.full_name AS custodian_name,
           (SELECT COUNT(*) FROM inv_stock s WHERE s.location_id = l.location_id AND s.quantity_on_hand > 0) AS item_count,
           (SELECT COALESCE(SUM(s.quantity_on_hand), 0) FROM inv_stock s WHERE s.location_id = l.location_id) AS total_qty
    FROM inv_locations l
    LEFT JOIN users u ON l.custodian_user_id = u.user_id
    ORDER BY l.site_campus, l.building, l.floor, l.room_storage_area
")->fetchAll(PDO::FETCH_ASSOC);

require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-geo-alt"></i> Storage Locations</h2>
    <?php if (has_permission('manage_inventory_locations')): ?>
    <a href="/inventory/locations/add.php" class="btn btn-primary"><i class="bi bi-plus-circle"></i> Add Location</a>
    <?php endif; ?>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Code</th>
                        <th>Site / Campus</th>
                        <th>Building</th>
                        <th>Floor</th>
                        <th>Room / Area</th>
                        <th>Bin/Shelf/Rack</th>
                        <th>Type</th>
                        <th>Security</th>
                        <th>Custodian</th>
                        <th class="text-end">Items</th>
                        <th>Active</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($locations)): ?>
                    <tr><td colspan="12" class="text-center text-muted py-4">No locations defined.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($locations as $loc): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($loc['location_code']) ?></code></td>
                        <td><?= htmlspecialchars($loc['site_campus'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($loc['building'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($loc['floor'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($loc['room_storage_area'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($loc['bin_shelf_rack'] ?? '-') ?></td>
                        <td><span class="badge bg-<?= $loc['location_type'] === 'USABLE' ? 'success' : ($loc['location_type'] === 'QUARANTINE' ? 'warning' : 'secondary') ?>"><?= $loc['location_type'] ?></span></td>
                        <td><?= $loc['security_level'] ?></td>
                        <td><?= htmlspecialchars($loc['custodian_name'] ?? '-') ?></td>
                        <td class="text-end"><?= number_format($loc['item_count']) ?></td>
                        <td><?= $loc['is_active'] ? '<span class="badge bg-success">Yes</span>' : '<span class="badge bg-secondary">No</span>' ?></td>
                        <td class="text-center">
                            <?php if (has_permission('manage_inventory_locations')): ?>
                            <a href="/inventory/locations/edit.php?id=<?= $loc['location_id'] ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></a>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
