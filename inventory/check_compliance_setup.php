<?php
/**
 * Include this file in every GoJ compliance inventory page (after db.php) to
 * ensure both the base inventory migration (019) and the GoJ compliance
 * migration (019c) have been applied. Redirects to the inventory dashboard
 * with an appropriate message when tables are missing.
 */
require_once $_SERVER['DOCUMENT_ROOT'] . '/services/InventoryService.php';

if (!inventoryTablesExist($pdo)) {
    header('Location: /inventory/dashboard.php');
    exit;
}

if (!inventoryComplianceTablesExist($pdo)) {
    header('Location: /inventory/dashboard.php?missing=compliance');
    exit;
}
