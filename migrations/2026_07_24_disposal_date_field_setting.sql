-- ============================================================================
-- Migration 2026_07_24: Add Disposal Date Field Requirement Setting
-- ============================================================================
-- Purpose:
--   Add system_config row allowing admins to enable/disable whether
--   Disposal Date is mandatory when an asset is marked as disposed.
-- ============================================================================

INSERT INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`)
VALUES
  ('ar_require_disposal_date', '1', 'Require Disposal Date when asset is disposed', NOW())
ON DUPLICATE KEY UPDATE `config_value` = `config_value`;
