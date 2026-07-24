-- ============================================================================
-- Migration 2026_07_23: Asset Register Field Requirement Settings
-- ============================================================================
-- Purpose:
--   1. Add secondary_custodian column to inv_asset_details.
--   2. Seed system_config rows allowing admins to enable/disable which
--      Asset Register Detail fields are mandatory.
-- ============================================================================

-- ─── 1. Add secondary custodian column ───────────────────────────────────────

ALTER TABLE `inv_asset_details`
  ADD COLUMN IF NOT EXISTS `secondary_custodian` varchar(150) DEFAULT NULL
    COMMENT 'Secondary custodian / backup responsible person';

-- ─── 2. System config keys for field requirement toggles ─────────────────────
-- Each key stores '1' (required) or '0' (optional). Default all to '1'
-- to preserve current behaviour.

INSERT INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`)
VALUES
  ('ar_require_inventory_number', '1', 'Require Inventory Number in Asset Register Details', NOW()),
  ('ar_require_condition',        '1', 'Require Asset Condition in Asset Register Details', NOW()),
  ('ar_require_status',           '1', 'Require Asset Status in Asset Register Details', NOW()),
  ('ar_require_acquired_date',    '1', 'Require Date of Acquisition in Asset Register Details', NOW()),
  ('ar_require_custodian',        '1', 'Require Custodian in Asset Register Details', NOW()),
  ('ar_require_location',         '1', 'Require Location (at least one field) in Asset Register Details', NOW()),
  ('ar_require_purchase_cost',    '1', 'Require Cost / Purchase Price in Asset Register Details', NOW())
ON DUPLICATE KEY UPDATE `config_value` = `config_value`;
