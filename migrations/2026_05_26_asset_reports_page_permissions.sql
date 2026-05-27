-- ============================================================================
-- Migration: Register Asset Report Pages in page_permissions
-- Purpose : Ensure page-level permission mapping includes new asset reports.
-- ============================================================================

INSERT INTO `page_permissions` (`page_path`, `page_name`, `required_permission`, `module`)
VALUES
('/inventory/reports/asset_register.php',         'Asset Register Report',         'view_inventory_reports', 'Inventory Reports'),
('/inventory/reports/asset_movement_register.php','Asset Movement Register Report','view_inventory_reports', 'Inventory Reports')
ON DUPLICATE KEY UPDATE
  `page_name` = VALUES(`page_name`),
  `required_permission` = VALUES(`required_permission`),
  `module` = VALUES(`module`);
