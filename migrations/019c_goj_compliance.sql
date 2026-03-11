-- ============================================================
-- Migration 019c: GoJ Compliance Enhancements
-- Jamaica Government Financial Instructions, IPSAS 12,
-- Audit Requirements, Segregation of Duties
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. PERIOD-END CUT-OFF CONTROLS
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_fiscal_periods` (
  `period_id` int(11) NOT NULL AUTO_INCREMENT,
  `period_name` varchar(50) NOT NULL COMMENT 'e.g. 2024-Q1, 2024-APR',
  `fiscal_year` varchar(10) NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` enum('OPEN','CLOSING','CLOSED','LOCKED') DEFAULT 'OPEN',
  `closed_by` int(11) DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`period_id`),
  UNIQUE KEY `uk_period_name` (`period_name`),
  KEY `idx_period_dates` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Snapshot of stock values at period-end for reporting
CREATE TABLE IF NOT EXISTS `inv_period_snapshots` (
  `snapshot_id` int(11) NOT NULL AUTO_INCREMENT,
  `period_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity_on_hand` decimal(14,4) DEFAULT 0,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `nrv` decimal(14,2) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`snapshot_id`),
  KEY `idx_snap_period` (`period_id`),
  KEY `idx_snap_item` (`item_id`),
  CONSTRAINT `fk_snap_period` FOREIGN KEY (`period_id`) REFERENCES `inv_fiscal_periods` (`period_id`),
  CONSTRAINT `fk_snap_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. RECALL / WITHDRAWAL TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_recalls` (
  `recall_id` int(11) NOT NULL AUTO_INCREMENT,
  `recall_number` varchar(30) NOT NULL,
  `recall_type` enum('RECALL','WITHDRAWAL') NOT NULL DEFAULT 'RECALL',
  `item_id` int(11) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text NOT NULL,
  `severity` enum('CLASS_I','CLASS_II','CLASS_III') DEFAULT 'CLASS_II' COMMENT 'I=critical, II=moderate, III=minor',
  `status` enum('INITIATED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'INITIATED',
  `initiated_by` int(11) NOT NULL,
  `initiated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  `total_quantity_affected` decimal(14,4) DEFAULT 0,
  `total_quantity_recovered` decimal(14,4) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`recall_id`),
  UNIQUE KEY `uk_recall_number` (`recall_number`),
  KEY `idx_recall_item` (`item_id`),
  KEY `idx_recall_batch` (`batch_lot_number`),
  CONSTRAINT `fk_recall_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_recall_user` FOREIGN KEY (`initiated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Items affected by recall (traced by batch/serial from transactions)
CREATE TABLE IF NOT EXISTS `inv_recall_items` (
  `recall_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `recall_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `issued_to_user_id` int(11) DEFAULT NULL,
  `quantity_affected` decimal(14,4) DEFAULT 0,
  `quantity_recovered` decimal(14,4) DEFAULT 0,
  `status` enum('PENDING','NOTIFIED','RECOVERED','UNRECOVERABLE') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`recall_item_id`),
  CONSTRAINT `fk_rcli_recall` FOREIGN KEY (`recall_id`) REFERENCES `inv_recalls` (`recall_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. RETURN-TO-SUPPLIER TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_returns` (
  `return_id` int(11) NOT NULL AUTO_INCREMENT,
  `return_number` varchar(30) NOT NULL,
  `grn_id` int(11) DEFAULT NULL COMMENT 'Link to original GRN',
  `supplier_vendor_id` int(11) DEFAULT NULL,
  `supplier_name` varchar(200) DEFAULT NULL,
  `reason` text NOT NULL,
  `return_type` enum('DEFECTIVE','WRONG_ITEM','EXCESS','WARRANTY','OTHER') NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','DISPATCHED','COMPLETED','CANCELLED') DEFAULT 'DRAFT',
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `dispatched_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `debit_note_number` varchar(50) DEFAULT NULL,
  `rma_number` varchar(50) DEFAULT NULL COMMENT 'Return Merchandise Authorization',
  `from_location_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`return_id`),
  UNIQUE KEY `uk_return_number` (`return_number`),
  CONSTRAINT `fk_ret_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inv_return_items` (
  `return_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `return_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  PRIMARY KEY (`return_item_id`),
  CONSTRAINT `fk_reti_return` FOREIGN KEY (`return_id`) REFERENCES `inv_returns` (`return_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reti_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. INCIDENT / LOSS REPORTING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_incidents` (
  `incident_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_number` varchar(30) NOT NULL,
  `incident_type` enum('THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER') NOT NULL,
  `incident_date` date NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `status` enum('REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED') DEFAULT 'REPORTED',
  `reported_by` int(11) NOT NULL,
  `reported_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `investigator_id` int(11) DEFAULT NULL,
  `investigation_notes` text DEFAULT NULL,
  `investigation_completed_at` datetime DEFAULT NULL,
  `police_reference` varchar(100) DEFAULT NULL,
  `insurance_reference` varchar(100) DEFAULT NULL,
  `insurance_claim_amount` decimal(14,2) DEFAULT NULL,
  `total_estimated_loss` decimal(14,2) DEFAULT 0.00,
  `adjustment_id` int(11) DEFAULT NULL COMMENT 'Link to stock adjustment created from this incident',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`incident_id`),
  UNIQUE KEY `uk_incident_number` (`incident_number`),
  CONSTRAINT `fk_inc_user` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inv_incident_items` (
  `incident_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_lost` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `condition_notes` text DEFAULT NULL,
  PRIMARY KEY (`incident_item_id`),
  CONSTRAINT `fk_inci_incident` FOREIGN KEY (`incident_id`) REFERENCES `inv_incidents` (`incident_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inci_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. QUARANTINE LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_quarantine_log` (
  `quarantine_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quarantine_location_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('QUARANTINED','UNDER_INSPECTION','RELEASED','DISPOSED') DEFAULT 'QUARANTINED',
  `quarantined_by` int(11) NOT NULL,
  `quarantined_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `released_by` int(11) DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `release_decision` enum('RETURN_TO_STOCK','DISPOSE','RETURN_TO_SUPPLIER') DEFAULT NULL,
  `decision_notes` text DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`quarantine_id`),
  KEY `idx_quar_item` (`item_id`),
  CONSTRAINT `fk_quar_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_quar_user` FOREIGN KEY (`quarantined_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. WRITE-DOWN / NRV TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_write_downs` (
  `write_down_id` int(11) NOT NULL AUTO_INCREMENT,
  `write_down_number` varchar(30) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `reason` enum('NRV_DECLINE','OBSOLESCENCE','DAMAGE','EXPIRY','OTHER') NOT NULL,
  `original_cost` decimal(14,2) NOT NULL,
  `nrv_value` decimal(14,2) NOT NULL,
  `write_down_amount` decimal(14,2) NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','REVERSED','CANCELLED') DEFAULT 'DRAFT',
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `reversal_id` int(11) DEFAULT NULL COMMENT 'Points to write-down that reverses this one',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`write_down_id`),
  UNIQUE KEY `uk_wd_number` (`write_down_number`),
  CONSTRAINT `fk_wd_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_wd_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. ADD NRV AND FAIR VALUE COLUMNS TO EXISTING TABLES
-- ============================================================
ALTER TABLE `inv_items`
  ADD COLUMN IF NOT EXISTS `nrv` decimal(14,2) DEFAULT NULL COMMENT 'Net Realisable Value (IPSAS 12)' AFTER `unit_cost`,
  ADD COLUMN IF NOT EXISTS `nrv_last_assessed` date DEFAULT NULL AFTER `nrv`,
  ADD COLUMN IF NOT EXISTS `nrv_assessed_by` int(11) DEFAULT NULL AFTER `nrv_last_assessed`;

ALTER TABLE `inv_stock`
  ADD COLUMN IF NOT EXISTS `nrv` decimal(14,2) DEFAULT NULL AFTER `unit_cost`;

-- ============================================================
-- 8. STOCK COUNT ENHANCEMENTS (blind count, freeze, variance thresholds)
-- ============================================================
ALTER TABLE `inv_stock_counts`
  ADD COLUMN IF NOT EXISTS `is_blind_count` tinyint(1) DEFAULT 1 COMMENT 'Hide system qty from counters' AFTER `count_type`,
  ADD COLUMN IF NOT EXISTS `is_frozen` tinyint(1) DEFAULT 0 COMMENT 'Block transactions during count' AFTER `is_blind_count`,
  ADD COLUMN IF NOT EXISTS `frozen_at` datetime DEFAULT NULL AFTER `is_frozen`,
  ADD COLUMN IF NOT EXISTS `unfrozen_at` datetime DEFAULT NULL AFTER `frozen_at`,
  ADD COLUMN IF NOT EXISTS `variance_threshold_pct` decimal(5,2) DEFAULT 5.00 COMMENT 'Escalation threshold %' AFTER `unfrozen_at`,
  ADD COLUMN IF NOT EXISTS `approved_by` int(11) DEFAULT NULL AFTER `completed_at`,
  ADD COLUMN IF NOT EXISTS `approved_at` datetime DEFAULT NULL AFTER `approved_by`;

-- Expand status enum to include APPROVED and ADJUSTMENT_CREATED
ALTER TABLE `inv_stock_counts`
  MODIFY COLUMN `status` enum('PLANNED','IN_PROGRESS','COMPLETED','APPROVED','ADJUSTMENT_CREATED','CANCELLED') DEFAULT 'PLANNED';

-- ============================================================
-- 9. ISSUES TABLE — ADD APPROVAL STEP
-- ============================================================
ALTER TABLE `inv_issues`
  ADD COLUMN IF NOT EXISTS `approved_by` int(11) DEFAULT NULL AFTER `status`,
  ADD COLUMN IF NOT EXISTS `approved_at` datetime DEFAULT NULL AFTER `approved_by`;

-- Ensure status supports PENDING_APPROVAL
ALTER TABLE `inv_issues`
  MODIFY COLUMN `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED','COMPLETED') DEFAULT 'DRAFT';

-- Expand transfer status for FS approval
ALTER TABLE `inv_transfers`
  MODIFY COLUMN `status` enum('DRAFT','PENDING_APPROVAL','PENDING_FS_APPROVAL','APPROVED','IN_TRANSIT','COMPLETED','CANCELLED','REJECTED') DEFAULT 'DRAFT';

-- ============================================================
-- 10. APPROVAL TRACKING TABLE (multi-level approvals)
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_approval_log` (
  `approval_log_id` int(11) NOT NULL AUTO_INCREMENT,
  `reference_type` varchar(50) NOT NULL COMMENT 'inv_requisitions, inv_transfers, etc.',
  `reference_id` int(11) NOT NULL,
  `approval_level` int(11) NOT NULL DEFAULT 1,
  `required_role_code` varchar(30) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','SKIPPED') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`approval_log_id`),
  KEY `idx_aplog_ref` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. EXPAND TRANSACTION TYPES
-- ============================================================
ALTER TABLE `inv_transactions`
  MODIFY COLUMN `transaction_type` enum(
    'RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN',
    'ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST',
    'RETURN','RECEIPT','ADJUSTMENT_IN','ADJUSTMENT_OUT',
    'QUARANTINE_IN','QUARANTINE_OUT','WRITE_DOWN','RETURN_TO_SUPPLIER'
  ) NOT NULL;

-- ============================================================
-- 12. ADD PERMISSIONS FOR NEW MODULES
-- ============================================================
INSERT INTO `permissions` (`name`, `description`) VALUES
  ('manage_quarantine', 'Move stock into/out of quarantine'),
  ('manage_recalls', 'Initiate and manage recall/withdrawal'),
  ('manage_returns', 'Create and manage return-to-supplier'),
  ('manage_incidents', 'Report and manage incident/loss reports'),
  ('manage_write_downs', 'Create and approve write-downs (NRV)'),
  ('manage_fiscal_periods', 'Open/close fiscal periods'),
  ('approve_issue', 'Approve stock issue vouchers'),
  ('approve_stock_count', 'Approve completed stock counts'),
  ('inspect_goods', 'Inspect goods on GRN'),
  ('approve_return', 'Approve return-to-supplier requests')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- Grant to Procurement Officer (role 2)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 2, id FROM `permissions` WHERE `name` IN ('manage_returns', 'manage_quarantine', 'inspect_goods');

-- Grant to Finance Officer (role 3)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 3, id FROM `permissions` WHERE `name` IN ('manage_write_downs', 'manage_fiscal_periods');

-- Grant to HOD (role 4)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 4, id FROM `permissions` WHERE `name` IN ('approve_issue', 'approve_stock_count', 'approve_return', 'manage_incidents');

-- ============================================================
-- 13. SEED DEFAULT APPROVAL MATRIX RULES
-- ============================================================
INSERT INTO `inv_approval_matrix` (`transaction_type`, `item_class`, `min_value`, `max_value`, `is_emergency`, `required_role_code`, `approval_level`) VALUES
  ('REQUISITION', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('REQUISITION', NULL, 50000.01, 500000, 0, 'INVENTORY_MANAGER', 1),
  ('REQUISITION', NULL, 500000.01, 999999999.99, 0, 'STORES_SUPERINTENDENT', 1),
  ('REQUISITION', NULL, 0, 999999999.99, 1, 'STOCK_CONTROLLER', 1),
  ('DISPOSAL', NULL, 0, 100000, 0, 'INVENTORY_MANAGER', 1),
  ('DISPOSAL', NULL, 100000.01, 999999999.99, 0, 'STORES_SUPERINTENDENT', 1),
  ('ADJUSTMENT', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('ADJUSTMENT', NULL, 50000.01, 999999999.99, 0, 'INVENTORY_MANAGER', 1),
  ('TRANSFER', NULL, 0, 999999999.99, 0, 'INVENTORY_MANAGER', 1),
  ('ISSUE', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('ISSUE', NULL, 50000.01, 999999999.99, 0, 'INVENTORY_MANAGER', 1)
ON DUPLICATE KEY UPDATE `required_role_code` = VALUES(`required_role_code`);

-- ============================================================
-- 14. DONATION ACCEPTANCE ENHANCEMENTS
-- ============================================================
ALTER TABLE `inv_goods_received`
  ADD COLUMN IF NOT EXISTS `is_donation` tinyint(1) DEFAULT 0 AFTER `is_non_exchange_transaction`,
  ADD COLUMN IF NOT EXISTS `acceptance_certificate_number` varchar(50) DEFAULT NULL AFTER `is_donation`,
  ADD COLUMN IF NOT EXISTS `fair_value_assessor` varchar(200) DEFAULT NULL AFTER `fair_value_basis`;

SET FOREIGN_KEY_CHECKS = 1;
