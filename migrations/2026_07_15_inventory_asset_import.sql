-- ============================================================================
-- Migration 2026_07_15: Inventory Asset Excel Import
-- ============================================================================
-- Purpose:
--   1. Create inv_asset_details — extended fixed-asset register fields for
--      inv_items rows imported from the asset register spreadsheet
--      (asset code, depreciation, revaluation, disposal, custodian, etc.).
--   2. Create inv_import_batches / inv_import_errors — audit trail and
--      downloadable error log for every import run.
--   3. Widen inv_items.item_code so full asset codes fit.
--   4. Seed the import_inventory_assets permission and page permissions.
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ─── 1. Extended asset register details (1:1 with inv_items) ────────────────

CREATE TABLE IF NOT EXISTS `inv_asset_details` (
  `asset_detail_id`          int(11)       NOT NULL AUTO_INCREMENT,
  `item_id`                  int(11)       NOT NULL,
  `asset_code`               varchar(50)   DEFAULT NULL,
  `reference_number`         varchar(100)  DEFAULT NULL,
  `make`                     varchar(150)  DEFAULT NULL,
  `serial_number`            varchar(100)  DEFAULT NULL,
  `acquired_date`            date          DEFAULT NULL,
  `department_branch_id`     int(11)       DEFAULT NULL,
  `custodian_user_id`        int(11)       DEFAULT NULL,
  `custodian_name`           varchar(150)  DEFAULT NULL,
  `asset_status`             varchar(100)  DEFAULT NULL,
  `asset_condition`          varchar(100)  DEFAULT NULL,
  `bos_value`                decimal(15,2) DEFAULT NULL,
  `increase_value`           decimal(15,2) DEFAULT NULL,
  `balance_value`            decimal(15,2) DEFAULT NULL,
  `decrease_value`           decimal(15,2) DEFAULT NULL,
  `delivery_date`            date          DEFAULT NULL,
  `placed_in_service_date`   date          DEFAULT NULL,
  `warranty_expiration`      date          DEFAULT NULL,
  `title_deed_number`        varchar(100)  DEFAULT NULL,
  `address`                  varchar(255)  DEFAULT NULL,
  `revalued_cost`            decimal(15,2) DEFAULT NULL,
  `revalued_date`            date          DEFAULT NULL,
  `accumulated_depreciation` decimal(15,2) DEFAULT NULL,
  `depreciation_charge`      decimal(15,2) DEFAULT NULL,
  `carrying_value`           decimal(15,2) DEFAULT NULL,
  `depreciation_method_rate` varchar(150)  DEFAULT NULL,
  `impairment`               decimal(15,2) DEFAULT NULL,
  `budget_code`              varchar(50)   DEFAULT NULL,
  `acquisition_method`       varchar(30)   DEFAULT NULL COMMENT 'Purchased or Donated',
  `insured_value`            decimal(15,2) DEFAULT NULL,
  `forced_sale_value`        decimal(15,2) DEFAULT NULL,
  `disposal_date`            date          DEFAULT NULL,
  `disposal_amount`          decimal(15,2) DEFAULT NULL,
  `disposal_authorization`   varchar(150)  DEFAULT NULL,
  `is_disposed`              tinyint(1)    NOT NULL DEFAULT 0,
  `attachments_note`         text          DEFAULT NULL,
  `comments`                 text          DEFAULT NULL,
  `created_at`               timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`               timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`asset_detail_id`),
  UNIQUE KEY `uk_asset_detail_item` (`item_id`),
  UNIQUE KEY `uk_asset_detail_code` (`asset_code`),
  KEY `idx_asset_serial` (`serial_number`),
  KEY `idx_asset_reference` (`reference_number`),
  KEY `idx_asset_department` (`department_branch_id`),
  KEY `idx_asset_custodian` (`custodian_user_id`),
  CONSTRAINT `fk_asset_detail_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asset_detail_branch` FOREIGN KEY (`department_branch_id`) REFERENCES `branches` (`branch_id`),
  CONSTRAINT `fk_asset_detail_custodian` FOREIGN KEY (`custodian_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Extended fixed-asset register details for imported assets';

-- ─── 2. Import audit trail ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `inv_import_batches` (
  `batch_id`            int(11)      NOT NULL AUTO_INCREMENT,
  `source_file_name`    varchar(255) NOT NULL,
  `file_hash`           char(64)     DEFAULT NULL COMMENT 'SHA-256 of uploaded file',
  `imported_by`         int(11)      DEFAULT NULL,
  `update_existing`     tinyint(1)   NOT NULL DEFAULT 0,
  `auto_create_lookups` tinyint(1)   NOT NULL DEFAULT 0,
  `total_rows`          int(11)      NOT NULL DEFAULT 0,
  `created_count`       int(11)      NOT NULL DEFAULT 0,
  `updated_count`       int(11)      NOT NULL DEFAULT 0,
  `skipped_count`       int(11)      NOT NULL DEFAULT 0,
  `error_count`         int(11)      NOT NULL DEFAULT 0,
  `status`              varchar(20)  NOT NULL DEFAULT 'RUNNING' COMMENT 'RUNNING / COMPLETED / FAILED',
  `started_at`          timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at`        timestamp    NULL DEFAULT NULL,
  PRIMARY KEY (`batch_id`),
  KEY `idx_import_user` (`imported_by`),
  CONSTRAINT `fk_import_batch_user` FOREIGN KEY (`imported_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='History of inventory asset spreadsheet imports';

CREATE TABLE IF NOT EXISTS `inv_import_errors` (
  `error_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `batch_id`   int(11)      NOT NULL,
  `row_number` int(11)      NOT NULL,
  `asset_code` varchar(50)  DEFAULT NULL,
  `field`      varchar(100) DEFAULT NULL,
  `message`    varchar(500) NOT NULL,
  `created_at` timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`error_id`),
  KEY `idx_import_error_batch` (`batch_id`),
  CONSTRAINT `fk_import_error_batch` FOREIGN KEY (`batch_id`) REFERENCES `inv_import_batches` (`batch_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Row-level validation errors per import batch';

-- ─── 3. Widen item_code so full asset codes fit ─────────────────────────────

ALTER TABLE `inv_items` MODIFY `item_code` varchar(50) NOT NULL COMMENT 'Unique SKU / internal stock code / asset code';

-- ─── 4. Permissions ──────────────────────────────────────────────────────────

INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
('import_inventory_assets', 'Import inventory assets from Excel/CSV files');

-- Admin (5), SuperAdmin (6), Property Management Officer (13)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `roles` r
JOIN `permissions` p ON p.name = 'import_inventory_assets'
WHERE r.id IN (5, 6, 13);

INSERT IGNORE INTO `page_permissions` (`page_path`, `page_title`, `permission_name`, `module`) VALUES
('/inventory/items/import.php',            'Import Assets',            'import_inventory_assets', 'Inventory'),
('/inventory/items/import_errors_csv.php', 'Import Error Log Export',  'import_inventory_assets', 'Inventory'),
('/inventory/items/import_template.php',   'Import Template Download', 'import_inventory_assets', 'Inventory');

SET FOREIGN_KEY_CHECKS = 1;
