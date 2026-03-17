-- Migration: Add HOD Approval and Committee Review Thresholds
-- Date: 2026-03-17
-- Description: Add new system configuration for amount-based approval requirements

-- Add HOD Approval Threshold (500,000 JMD)
INSERT INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`, `updated_at`)
VALUES ('hod_approval_threshold', '500000.00', 'Procurement requests above this amount require HOD approval (JMD)', NOW(), NOW())
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

-- Add Committee Review Threshold (3,000,000 JMD)
INSERT INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`, `updated_at`)
VALUES ('committee_review_threshold', '3000000.00', 'Procurement requests above this amount require committee review (JMD)', NOW(), NOW())
ON DUPLICATE KEY UPDATE `updated_at` = NOW();
