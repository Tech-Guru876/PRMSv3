-- ============================================================================
-- Migration: Inventory delete permissions
-- ============================================================================
-- Purpose:
--   1. Add explicit delete permissions for inventory items and locations.
--   2. Register delete endpoints in page_permissions so access can be reassigned.
-- Date: 2026-05-27
-- ============================================================================

INSERT INTO `permissions` (`name`, `description`) VALUES
('delete_inventory_items', 'Delete inventory item master records'),
('delete_inventory_locations', 'Delete storage location records')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `page_permissions` (`page_path`, `page_title`, `permission_name`, `module`, `is_active`) VALUES
('/inventory/items/delete.php', 'Delete Item', 'delete_inventory_items', 'Inventory', 1),
('/inventory/locations/delete.php', 'Delete Location', 'delete_inventory_locations', 'Inventory', 1)
ON DUPLICATE KEY UPDATE
    `page_title` = VALUES(`page_title`),
    `permission_name` = VALUES(`permission_name`),
    `module` = VALUES(`module`),
    `is_active` = VALUES(`is_active`);
