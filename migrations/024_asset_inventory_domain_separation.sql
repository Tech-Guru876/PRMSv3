-- ============================================================================
-- Migration 024: Asset / Inventory Domain Separation
-- ============================================================================
-- Purpose:
--   1. Create asset_types  — named types of fixed/movable assets
--      (IT Equipment, Furniture, Vehicles, Machinery, Tools, …)
--   2. Create inventory_types — named types of consumable/stock items
--      (Consumables, Office Supplies, Cleaning, PPE, Spare Parts, …)
--   3. Add item_domain, asset_type_id, inventory_type_id to inv_items so
--      every item is explicitly labelled INVENTORY, ASSET, or BOTH instead
--      of relying on category_code = 'ASSETS'.
--   4. Backfill: items in the ASSETS inv_category → item_domain = ASSET;
--      all others default to INVENTORY.
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ─── 1. Asset Types ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `asset_types` (
  `asset_type_id` int(11)      NOT NULL AUTO_INCREMENT,
  `type_code`     varchar(30)  NOT NULL,
  `type_name`     varchar(100) NOT NULL,
  `description`   text         DEFAULT NULL,
  `is_active`     tinyint(1)   NOT NULL DEFAULT 1,
  `sort_order`    int(11)      NOT NULL DEFAULT 0,
  `created_at`    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`asset_type_id`),
  UNIQUE KEY `uk_asset_type_code` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Named types of fixed and movable assets';

INSERT IGNORE INTO `asset_types` (`type_code`, `type_name`, `description`, `sort_order`) VALUES
('IT_EQUIPMENT',      'IT Equipment',          'Computers, servers, network hardware, peripherals',      1),
('FURNITURE',         'Furniture',             'Desks, chairs, shelving, filing cabinets',               2),
('VEHICLES',          'Vehicles',              'Motor vehicles, motorcycles, boats',                     3),
('MACHINERY',         'Machinery',             'Heavy machinery, industrial equipment',                  4),
('TOOLS',             'Tools & Instruments',   'Hand tools, power tools, measuring instruments',         5),
('BUILDING_FIXTURES', 'Building Fixtures',     'Installed fixtures, HVAC, electrical fittings',          6),
('MEDICAL_EQUIPMENT', 'Medical Equipment',     'Clinical and laboratory equipment',                      7),
('AV_COMMUNICATIONS', 'AV / Communications',  'Audio-visual, radio, telecommunications equipment',      8),
('OTHER',             'Other Assets',          'Assets not classified elsewhere',                        9);

-- ─── 2. Inventory Types ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `inventory_types` (
  `inventory_type_id` int(11)      NOT NULL AUTO_INCREMENT,
  `type_code`         varchar(30)  NOT NULL,
  `type_name`         varchar(100) NOT NULL,
  `description`       text         DEFAULT NULL,
  `is_active`         tinyint(1)   NOT NULL DEFAULT 1,
  `sort_order`        int(11)      NOT NULL DEFAULT 0,
  `created_at`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_type_id`),
  UNIQUE KEY `uk_inv_type_code` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Named types of consumable/stock inventory items';

INSERT IGNORE INTO `inventory_types` (`type_code`, `type_name`, `description`, `sort_order`) VALUES
('CONSUMABLES',    'Consumables',           'General consumable items used in operations',             1),
('OFFICE_SUPPLIES','Office Supplies',       'Stationery, paper, toner, pens, files',                  2),
('CLEANING',       'Cleaning Supplies',     'Detergents, mops, bins, cleaning chemicals',             3),
('LAB_SUPPLIES',   'Laboratory Supplies',   'Lab reagents, glassware, disposable consumables',        4),
('CHEMICALS',      'Chemicals & Reagents',  'Chemicals, reagents, standards, solvents',               5),
('PPE',            'PPE & Safety',          'Personal protective equipment, safety gear',             6),
('SPARE_PARTS',    'Spare Parts',           'Replacement parts for equipment and machinery',          7),
('UNIFORMS',       'Uniforms & Workwear',   'Staff uniforms, work clothes, protective clothing',      8),
('DIST_GOODS',     'Distribution Goods',    'Items held for distribution to clients or the public',   9),
('PRINTED_FORMS',  'Printed Forms',         'Controlled stationery, pre-printed numbered forms',     10),
('OTHER',          'Other Stock',           'Stock items not classified elsewhere',                  11);

-- ─── 3. Add domain columns to inv_items ──────────────────────────────────────

ALTER TABLE `inv_items`
  ADD COLUMN IF NOT EXISTS `item_domain`
    enum('INVENTORY','ASSET','BOTH') NOT NULL DEFAULT 'INVENTORY'
    COMMENT 'Operational domain: INVENTORY=consumable stock, ASSET=tracked fixed/movable asset, BOTH=straddles both'
    AFTER `asset_inventory_boundary`,

  ADD COLUMN IF NOT EXISTS `asset_type_id`
    int(11) DEFAULT NULL
    COMMENT 'FK to asset_types; set when item_domain = ASSET or BOTH'
    AFTER `item_domain`,

  ADD COLUMN IF NOT EXISTS `inventory_type_id`
    int(11) DEFAULT NULL
    COMMENT 'FK to inventory_types; set when item_domain = INVENTORY or BOTH'
    AFTER `asset_type_id`;

ALTER TABLE `inv_items`
  ADD KEY `idx_item_domain`  (`item_domain`),
  ADD KEY `idx_asset_type`   (`asset_type_id`),
  ADD KEY `idx_inv_type`     (`inventory_type_id`);

ALTER TABLE `inv_items`
  ADD CONSTRAINT `fk_item_asset_type`
    FOREIGN KEY (`asset_type_id`)
    REFERENCES `asset_types` (`asset_type_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_item_inv_type`
    FOREIGN KEY (`inventory_type_id`)
    REFERENCES `inventory_types` (`inventory_type_id`) ON DELETE SET NULL;

-- ─── 4. Backfill item_domain from existing ASSETS inv_category ───────────────

UPDATE `inv_items` i
  JOIN `inv_categories` c ON i.category_id = c.category_id
SET i.item_domain = 'ASSET'
WHERE c.category_code = 'ASSETS'
  AND i.item_domain = 'INVENTORY';

SET FOREIGN_KEY_CHECKS = 1;

-- ─── 5. Verification ─────────────────────────────────────────────────────────

SELECT COUNT(*) AS asset_types_seeded  FROM `asset_types`;
SELECT COUNT(*) AS inventory_types_seeded FROM `inventory_types`;
SELECT item_domain, COUNT(*) AS cnt FROM `inv_items` GROUP BY item_domain;
