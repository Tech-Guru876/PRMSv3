-- ============================================================================
-- Migration 2026_07_23: Primary Asset Type Restructure (MoF Alignment)
-- ============================================================================
-- Purpose:
--   1. Simplify classification into two top-level Primary Asset Types:
--        A. Property, Plant, and Equipment (Non-Financial Assets)
--           (item_domain = ASSET / BOTH, classified via asset_types)
--        B. Consumable and Expendable Assets
--           (item_domain = INVENTORY / BOTH, classified via inventory_types)
--   2. Retire ALL legacy asset_types / inventory_types values and seed only
--      the approved classifications for each Primary Asset Type.
--   3. Clear legacy classification references from inv_items so users can
--      only select from the approved classifications.
--   4. Add required asset register fields (location, acquisition, financial
--      status, custodianship) to inv_asset_details.
--   5. Add indexes used by the Asset Register report global search.
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ─── 1. Retire ALL legacy classification values ─────────────────────────────

UPDATE `asset_types`     SET `is_active` = 0;
UPDATE `inventory_types` SET `is_active` = 0;

-- ─── 2. Approved classifications for
--        "Property, Plant, and Equipment (Non-Financial Assets)" ─────────────

INSERT INTO `asset_types` (`type_code`, `type_name`, `description`, `sort_order`, `is_active`) VALUES
('LAND',                'Land',                              'Acquisition value of land and rights to land owned by the organization.', 1, 1),
('BUILDINGS',           'Buildings',                         'Permanent structures and improvements, including administrative offices, warehouses, and related facilities.', 2, 1),
('INFRASTRUCTURE',      'Infrastructure',                    'Long-term capital assets such as roads, bridges, utility grids, and similar public works.', 3, 1),
('MACHINERY_EQUIPMENT', 'Machinery and Equipment',           'Heavy-duty technical equipment, operational machinery, and specialized units.', 4, 1),
('FURNITURE_FIXTURES',  'Furniture and Fixtures',            'Office desks, chairs, filing cabinets, and interior fittings.', 5, 1),
('COMPUTER_ELECTRONIC', 'Computer and Electronic Equipment', 'Servers, laptops, printers, network devices, and related technology assets.', 6, 1),
('MOTOR_VEHICLES',      'Motor Vehicles',                    'State-owned cars, trucks, and specialized transport fleets.', 7, 1)
ON DUPLICATE KEY UPDATE
  `type_name`   = VALUES(`type_name`),
  `description` = VALUES(`description`),
  `sort_order`  = VALUES(`sort_order`),
  `is_active`   = 1;

-- ─── 3. Approved classifications for
--        "Consumable and Expendable Assets" ──────────────────────────────────
--   Items used during normal operations, tracked by quantity rather than
--   individual asset records, supporting stock-level monitoring, minimum
--   re-order thresholds, and consumption tracking.

INSERT INTO `inventory_types` (`type_code`, `type_name`, `description`, `sort_order`, `is_active`) VALUES
('STATIONERY',           'Stationery',                      'Everyday operational stationery stock and supplies.', 1, 1),
('CLEANING_SUPPLIES',    'Cleaning Supplies',               'Everyday cleaning stock and janitorial supplies.', 2, 1),
('PRINTER_TONERS',       'Printer Toners',                  'Printer toner and ink cartridge stock.', 3, 1),
('LABORATORY_SUPPLIES',  'Laboratory Supplies',             'Everyday laboratory operational stock and supplies.', 4, 1),
('GARDENING_SUPPLIES',   'Gardening Supplies',              'Gardening and grounds-keeping stock and supplies.', 5, 1),
('MAINT_REPAIR_SUPPLIES','Maintenance and Repair Supplies', 'Maintenance and repair operational stock and supplies.', 6, 1),
('EMERGENCY_SUPPLIES',   'Emergency Supplies',              'Emergency preparedness and response stock and supplies.', 7, 1)
ON DUPLICATE KEY UPDATE
  `type_name`   = VALUES(`type_name`),
  `description` = VALUES(`description`),
  `sort_order`  = VALUES(`sort_order`),
  `is_active`   = 1;

-- ─── 4. Clear legacy (now inactive) classification references ────────────────

UPDATE `inv_items` i
  JOIN `asset_types` at ON i.asset_type_id = at.asset_type_id
SET i.asset_type_id = NULL
WHERE at.is_active = 0;

UPDATE `inv_items` i
  JOIN `inventory_types` it ON i.inventory_type_id = it.inventory_type_id
SET i.inventory_type_id = NULL
WHERE it.is_active = 0;

-- Classifications may only belong to the item's Primary Asset Type
UPDATE `inv_items` SET `asset_type_id`     = NULL WHERE `item_domain` = 'INVENTORY' AND `asset_type_id`     IS NOT NULL;
UPDATE `inv_items` SET `inventory_type_id` = NULL WHERE `item_domain` = 'ASSET'     AND `inventory_type_id` IS NOT NULL;

-- ─── 5. Required asset register fields (inv_asset_details) ───────────────────
--   Unique ID (asset_code), Purchase Date (acquired_date), Current Condition
--   (asset_condition), Assigned Department (department_branch_id) and
--   Custodian already exist. Add the remaining required registry fields.

ALTER TABLE `inv_asset_details`
  ADD COLUMN IF NOT EXISTS `site`                      varchar(150)  DEFAULT NULL COMMENT 'Location: site/campus'                    AFTER `address`,
  ADD COLUMN IF NOT EXISTS `building`                  varchar(150)  DEFAULT NULL COMMENT 'Location: building'                       AFTER `site`,
  ADD COLUMN IF NOT EXISTS `floor_room`                varchar(150)  DEFAULT NULL COMMENT 'Location: floor / room'                   AFTER `building`,
  ADD COLUMN IF NOT EXISTS `purchase_cost`             decimal(15,2) DEFAULT NULL COMMENT 'Acquisition: purchase cost'               AFTER `floor_room`,
  ADD COLUMN IF NOT EXISTS `source_of_funds`           varchar(150)  DEFAULT NULL COMMENT 'Acquisition: source of funds'             AFTER `purchase_cost`,
  ADD COLUMN IF NOT EXISTS `depreciation_method`       varchar(100)  DEFAULT NULL COMMENT 'Financial status: depreciation method'    AFTER `source_of_funds`,
  ADD COLUMN IF NOT EXISTS `current_replacement_value` decimal(15,2) DEFAULT NULL COMMENT 'Financial status: current replacement value' AFTER `depreciation_method`,
  ADD COLUMN IF NOT EXISTS `accountable_officer`       varchar(150)  DEFAULT NULL COMMENT 'Custodianship: accountable officer'       AFTER `current_replacement_value`;

-- Backfill new registry fields from existing data where available
UPDATE `inv_asset_details` SET `depreciation_method`  = `depreciation_method_rate` WHERE `depreciation_method`  IS NULL AND `depreciation_method_rate` IS NOT NULL;
UPDATE `inv_asset_details` SET `purchase_cost`        = `bos_value`                WHERE `purchase_cost`        IS NULL AND `bos_value`                IS NOT NULL;
UPDATE `inv_asset_details` SET `source_of_funds`      = `budget_code`              WHERE `source_of_funds`      IS NULL AND `budget_code`              IS NOT NULL;
UPDATE `inv_asset_details` SET `accountable_officer`  = `custodian_name`           WHERE `accountable_officer`  IS NULL AND `custodian_name`           IS NOT NULL;

-- ─── 6. Indexes for Asset Register report global search ─────────────────────

ALTER TABLE `inv_items`
  ADD INDEX IF NOT EXISTS `idx_item_name`    (`item_name`),
  ADD INDEX IF NOT EXISTS `idx_manufacturer` (`manufacturer`),
  ADD INDEX IF NOT EXISTS `idx_model`        (`model`);

ALTER TABLE `inv_asset_details`
  ADD INDEX IF NOT EXISTS `idx_asset_acquired` (`acquired_date`),
  ADD INDEX IF NOT EXISTS `idx_asset_condition` (`asset_condition`);

SET FOREIGN_KEY_CHECKS = 1;

-- ─── 7. Verification ─────────────────────────────────────────────────────────

SELECT COUNT(*) AS active_ppe_classifications        FROM `asset_types`     WHERE `is_active` = 1;
SELECT COUNT(*) AS active_consumable_classifications FROM `inventory_types` WHERE `is_active` = 1;
SELECT item_domain, COUNT(*) AS cnt FROM `inv_items` GROUP BY item_domain;
