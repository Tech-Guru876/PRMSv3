-- ============================================================
-- Migration: Procurement Workflow Enhancements
-- Date: 2026-07-20
-- Features:
--   1. MEMO + SIGNED_REQUEST document types for request_documents
--   2. Request cancellation columns (any stage, mandatory reason)
--   3. RFQ auto-email enable/disable config
--   4. Post-completion document reminder tracking table
-- ============================================================

-- ============================================
-- 1. REQUEST DOCUMENTS: expand document_type enum
-- ============================================
ALTER TABLE `request_documents`
  MODIFY COLUMN `document_type` ENUM('SIGNED_PO','SIGNED_COMMITMENT','SIGNED_REQUEST','MEMO','OTHER') NOT NULL DEFAULT 'OTHER';

-- ============================================
-- 2. CANCELLATION SUPPORT
-- ============================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'procurement_requests' AND COLUMN_NAME = 'cancel_reason');
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE `procurement_requests` ADD COLUMN `cancel_reason` TEXT DEFAULT NULL COMMENT ''Reason provided when request was cancelled'' AFTER `decline_reason`, ADD COLUMN `cancelled_by` INT(11) DEFAULT NULL COMMENT ''User who cancelled the request'' AFTER `cancel_reason`, ADD COLUMN `cancelled_at` DATETIME DEFAULT NULL COMMENT ''When the request was cancelled'' AFTER `cancelled_by`',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================
-- 3. RFQ AUTO-EMAIL CONFIG
-- ============================================
INSERT INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`)
VALUES ('enable_rfq_auto_email', '1', 'Enable/disable automatic RFQ email distribution to vendors', NOW())
ON DUPLICATE KEY UPDATE `config_key` = `config_key`;

-- ============================================
-- 4. DOCUMENT REMINDER LOG (post-completion escalating reminders)
-- ============================================
CREATE TABLE IF NOT EXISTS `document_reminder_log` (
  `reminder_id` INT(11) NOT NULL AUTO_INCREMENT,
  `request_id` INT(11) NOT NULL,
  `document_type` ENUM('SIGNED_PO','SIGNED_COMMITMENT') NOT NULL,
  `escalation_level` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=responsible only, 2=+Branch Head, 3=+HOD (urgent)',
  `days_overdue` INT(11) NOT NULL DEFAULT 0,
  `sent_to` VARCHAR(500) DEFAULT NULL COMMENT 'Comma separated recipient emails',
  `sent_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reminder_id`),
  KEY `idx_doc_reminder_request` (`request_id`),
  KEY `idx_doc_reminder_sent` (`sent_at`),
  CONSTRAINT `fk_doc_reminder_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Done
-- ============================================
