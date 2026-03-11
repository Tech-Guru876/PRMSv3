<?php
/**
 * Inventory Alerts Cron Job
 * Run daily: 0 6 * * * php /path/to/cron/inventory_alerts.php
 *
 * Generates alerts for:
 * 1. Items below reorder level
 * 2. Expiring stock (within 30 / 7 days)
 * 3. Expired stock
 * 4. Pending approvals older than 48 hours
 * 5. Open incidents without investigation
 */
require_once __DIR__ . '/../config/db.php';

$alerts = [];

// 1. Reorder alerts — items where total stock <= reorder_level
$reorder = $pdo->query("
    SELECT i.item_code, i.item_name, i.reorder_level, COALESCE(SUM(s.quantity_on_hand), 0) AS total_stock
    FROM inv_items i
    LEFT JOIN inv_stock s ON i.item_id = s.item_id
    WHERE i.item_status = 'ACTIVE' AND i.reorder_level > 0
    GROUP BY i.item_id
    HAVING total_stock <= i.reorder_level
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($reorder as $r) {
    $alerts[] = "[REORDER] {$r['item_code']} {$r['item_name']} — Stock: {$r['total_stock']}, Reorder Level: {$r['reorder_level']}";
}

// 2. Expiring within 30 days
$expiring30 = $pdo->query("
    SELECT i.item_code, i.item_name, s.expiry_date, s.quantity_on_hand, l.location_code
    FROM inv_stock s
    JOIN inv_items i ON s.item_id = i.item_id
    LEFT JOIN inv_locations l ON s.location_id = l.location_id
    WHERE s.expiry_date IS NOT NULL
      AND s.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
      AND s.quantity_on_hand > 0
    ORDER BY s.expiry_date
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($expiring30 as $e) {
    $daysLeft = (int) ((strtotime($e['expiry_date']) - time()) / 86400);
    $urgency = $daysLeft <= 7 ? 'URGENT' : 'WARNING';
    $alerts[] = "[EXPIRY-$urgency] {$e['item_code']} {$e['item_name']} at {$e['location_code']} — Expires {$e['expiry_date']} ({$daysLeft}d), Qty: {$e['quantity_on_hand']}";
}

// 3. Already expired
$expired = $pdo->query("
    SELECT i.item_code, i.item_name, s.expiry_date, s.quantity_on_hand, l.location_code
    FROM inv_stock s
    JOIN inv_items i ON s.item_id = i.item_id
    LEFT JOIN inv_locations l ON s.location_id = l.location_id
    WHERE s.expiry_date IS NOT NULL AND s.expiry_date < CURDATE() AND s.quantity_on_hand > 0
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($expired as $e) {
    $alerts[] = "[EXPIRED] {$e['item_code']} {$e['item_name']} at {$e['location_code']} — Expired {$e['expiry_date']}, Qty: {$e['quantity_on_hand']}";
}

// 4. Pending approvals > 48 hours
$pendingIssues = $pdo->query("
    SELECT issue_number FROM inv_issues WHERE status = 'PENDING_APPROVAL' AND created_at < DATE_SUB(NOW(), INTERVAL 48 HOUR)
")->fetchAll(PDO::FETCH_ASSOC);
foreach ($pendingIssues as $p) {
    $alerts[] = "[PENDING] Issue {$p['issue_number']} — awaiting approval for over 48 hours";
}

$pendingReturns = $pdo->query("
    SELECT return_number FROM inv_returns WHERE status = 'PENDING_APPROVAL' AND created_at < DATE_SUB(NOW(), INTERVAL 48 HOUR)
")->fetchAll(PDO::FETCH_ASSOC);
foreach ($pendingReturns as $p) {
    $alerts[] = "[PENDING] Return {$p['return_number']} — awaiting approval for over 48 hours";
}

// 5. Open incidents without investigation assigned
$openIncidents = $pdo->query("
    SELECT incident_number, incident_type FROM inv_incidents
    WHERE status = 'REPORTED' AND investigator_id IS NULL AND reported_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)
")->fetchAll(PDO::FETCH_ASSOC);
foreach ($openIncidents as $inc) {
    $alerts[] = "[INCIDENT] {$inc['incident_number']} ({$inc['incident_type']}) — no investigator assigned after 24 hours";
}

// Output / send
if (empty($alerts)) {
    echo "No inventory alerts.\n";
    exit;
}

$subject = "Inventory Alerts — " . date('Y-m-d') . " (" . count($alerts) . " alerts)";
$body = "Inventory Management System — Daily Alert Report\n";
$body .= "Generated: " . date('Y-m-d H:i:s') . "\n";
$body .= str_repeat('=', 60) . "\n\n";
$body .= implode("\n", $alerts) . "\n";

echo $subject . "\n" . $body;

// Send email if mailer config exists
if (file_exists(__DIR__ . '/../config/mailer.php')) {
    require_once __DIR__ . '/../config/mailer.php';
    // Use configured admin email
    $adminEmail = defined('ADMIN_EMAIL') ? ADMIN_EMAIL : 'admin@governmentchemist.com';
    @mail($adminEmail, $subject, $body);
}
