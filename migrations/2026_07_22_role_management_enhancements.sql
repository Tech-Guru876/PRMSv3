-- ============================================================================
-- Migration 2026_07_22: Role Management Enhancements & Asset Code Tag
-- ============================================================================
-- Purpose:
--   1. Add is_active and updated_at to roles table for soft-deactivation
--   2. Add module and operation columns to permissions for CRUD granularity
--   3. Create user_roles table for multi-role assignment
--   4. Seed role management permissions
--   5. Add edit_asset_code permission for Asset Code Tag editing
--   6. Add page_permissions entries for new admin pages
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ─── 1. Enhance roles table ────────────────────────────────────────────────────

ALTER TABLE `roles`
  ADD COLUMN IF NOT EXISTS `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Soft-deactivation flag',
  ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP;

-- ─── 2. Enhance permissions table with module/operation ────────────────────────

ALTER TABLE `permissions`
  ADD COLUMN IF NOT EXISTS `module` VARCHAR(50) DEFAULT NULL COMMENT 'Module this permission belongs to',
  ADD COLUMN IF NOT EXISTS `operation` VARCHAR(20) DEFAULT NULL COMMENT 'CRUD operation type: create, read, update, delete';

-- ─── 3. Create user_roles table (multi-role support) ───────────────────────────

CREATE TABLE IF NOT EXISTS `user_roles` (
  `id`          INT(11)     NOT NULL AUTO_INCREMENT,
  `user_id`     INT(11)     NOT NULL,
  `role_id`     INT(11)     NOT NULL,
  `assigned_at` TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `assigned_by` INT(11)     DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_user_roles_user` (`user_id`),
  KEY `idx_user_roles_role` (`role_id`),
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_roles_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Supports multiple roles per user';

-- ─── 4. Seed role management permissions ───────────────────────────────────────

INSERT IGNORE INTO `permissions` (`name`, `description`, `module`, `operation`) VALUES
('manage_roles',             'Create, edit, deactivate and delete roles',           'roles', NULL),
('create_role',              'Create new roles',                                     'roles', 'create'),
('edit_role',                'Edit existing roles',                                  'roles', 'update'),
('deactivate_role',          'Deactivate or reactivate roles',                       'roles', 'update'),
('delete_role',              'Delete roles',                                         'roles', 'delete'),
('assign_role_permissions',  'Assign permissions to roles',                          'roles', 'update'),
('assign_user_roles',        'Assign roles to users',                                'users', 'update');

-- ─── 5. Seed asset code edit permission ────────────────────────────────────────

INSERT IGNORE INTO `permissions` (`name`, `description`, `module`, `operation`) VALUES
('edit_asset_code', 'Edit Asset Code Tag on inventory items', 'inventory', 'update');

-- ─── 6. Assign role management permissions to Admin (5) and SuperAdmin (6) ─────

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 5, id FROM permissions WHERE name IN ('manage_roles','create_role','edit_role','deactivate_role','delete_role','assign_role_permissions','assign_user_roles','edit_asset_code');

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 6, id FROM permissions WHERE name IN ('manage_roles','create_role','edit_role','deactivate_role','delete_role','assign_role_permissions','assign_user_roles','edit_asset_code');

-- Assign edit_asset_code to Property Management Officer (13)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 13, id FROM permissions WHERE name = 'edit_asset_code';

-- ─── 7. Page permissions for new admin pages ───────────────────────────────────

INSERT IGNORE INTO `page_permissions` (`page_path`, `page_title`, `permission_name`, `module`, `is_active`) VALUES
('/admin/roles.php',        'Role Management',          'manage_roles', 'Administration', 1),
('/admin/roles_edit.php',   'Edit Role & Permissions',  'manage_roles', 'Administration', 1),
('/admin/roles_assign.php', 'Assign Roles to Users',    'manage_roles', 'Administration', 1);

-- ─── 8. Populate user_roles from existing users.role_id ────────────────────────
-- This ensures backward compatibility: existing primary roles are also in user_roles

INSERT IGNORE INTO `user_roles` (`user_id`, `role_id`, `assigned_at`)
SELECT `user_id`, `role_id`, COALESCE(`created_at`, NOW())
FROM `users`
WHERE `role_id` IS NOT NULL;

SET FOREIGN_KEY_CHECKS = 1;
