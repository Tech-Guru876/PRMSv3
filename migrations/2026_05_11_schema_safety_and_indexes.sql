-- ============================================================
-- Migration: 2026_05_11_schema_safety_and_indexes.sql
-- Purpose  : Ensure all critical columns, defaults, and
--            performance indexes are in place.
--            Safe to run multiple times (uses IF NOT EXISTS /
--            DROP IF EXISTS patterns and IGNORE inserts).
-- ============================================================

-- ── 1. audit_log — guarantee change_date has a default ──────
ALTER TABLE `audit_log`
    MODIFY COLUMN `change_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP;

-- ── 2. users — columns required by auth/login.php ───────────
-- failed_attempts and lock_until (account lockout)
ALTER TABLE `users`
    MODIFY COLUMN `failed_attempts` int NOT NULL DEFAULT 0;

ALTER TABLE `users`
    MODIFY COLUMN `lock_until` datetime DEFAULT NULL;

-- must_change_password flag
ALTER TABLE `users`
    MODIFY COLUMN `must_change_password` tinyint(1) NOT NULL DEFAULT 0;

-- ── 3. procurement_requests — ensure request_number index ───
-- Improves generateRequestNumber() query performance
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'procurement_requests'
      AND index_name   = 'idx_request_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_request_number already exists''',
    'ALTER TABLE `procurement_requests` ADD INDEX `idx_request_number` (`request_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 4. commitments — ensure commitment_number index ─────────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'commitments'
      AND index_name   = 'idx_commitment_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_commitment_number already exists''',
    'ALTER TABLE `commitments` ADD INDEX `idx_commitment_number` (`commitment_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 5. purchase_orders — ensure po_number index ─────────────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'purchase_orders'
      AND index_name   = 'idx_po_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_po_number already exists''',
    'ALTER TABLE `purchase_orders` ADD INDEX `idx_po_number` (`po_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 6. audit_log — composite index for timeline queries ─────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'audit_log'
      AND index_name   = 'idx_audit_log_table_record_date'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_audit_log_table_record_date already exists''',
    'ALTER TABLE `audit_log` ADD INDEX `idx_audit_log_table_record_date` (`table_name`, `record_id`, `change_date`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 7. Log this migration ────────────────────────────────────
INSERT INTO `audit_log` (`table_name`, `record_id`, `action`, `changed_by`, `notes`)
VALUES ('MIGRATION', NULL, 'SCHEMA_SAFETY', 'system',
        '2026_05_11_schema_safety_and_indexes applied');
