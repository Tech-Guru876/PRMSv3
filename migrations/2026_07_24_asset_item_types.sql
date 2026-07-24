-- ============================================================================
-- Migration 2026_07_24: Asset Item Type Groups and Specific Asset Item Types
-- ============================================================================
-- Purpose:
--   1. Create inv_asset_item_type_groups — top-level groupings:
--        OFFICE FURNITURE (OF), OFFICE MACHINE (OM),
--        EQUIPMENT (E), TOOLS/EQUIPMENT/MACHINES (ITEM)
--   2. Create inv_asset_item_types — specific named types within each group
--      (e.g. OF 1 - DESK (WOOD) NO DRAWER, OM 2 - PHOTO COPIER, etc.)
--   3. Add asset_item_type_id FK column to inv_items so each inventory item
--      can be tagged with a specific asset item type.
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ─── 1. Top-level type groups ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `inv_asset_item_type_groups` (
  `group_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `group_code`  varchar(20)  NOT NULL COMMENT 'Short code, e.g. OF, OM, E, ITEM',
  `group_name`  varchar(100) NOT NULL COMMENT 'Display name',
  `description` text         DEFAULT NULL,
  `sort_order`  int(11)      DEFAULT 0,
  `is_active`   tinyint(1)   NOT NULL DEFAULT 1,
  `created_at`  timestamp    NOT NULL DEFAULT current_timestamp(),
  `updated_at`  timestamp    NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uq_group_code` (`group_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── 2. Specific asset item types ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `inv_asset_item_types` (
  `item_type_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `group_id`       int(11)      NOT NULL,
  `type_code`      varchar(20)  NOT NULL COMMENT 'e.g. OF 1, OM 3, E 12, ITEM 4',
  `type_name`      varchar(200) NOT NULL COMMENT 'Full descriptive name',
  `description`    text         DEFAULT NULL,
  `sort_order`     int(11)      DEFAULT 0,
  `is_active`      tinyint(1)   NOT NULL DEFAULT 1,
  `created_at`     timestamp    NOT NULL DEFAULT current_timestamp(),
  `updated_at`     timestamp    NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`item_type_id`),
  UNIQUE KEY `uq_type_code` (`type_code`),
  KEY `idx_group_id` (`group_id`),
  CONSTRAINT `fk_ait_group` FOREIGN KEY (`group_id`) REFERENCES `inv_asset_item_type_groups` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── 3. FK column on inv_items ────────────────────────────────────────────

ALTER TABLE `inv_items`
  ADD COLUMN IF NOT EXISTS `asset_item_type_id` int(11) DEFAULT NULL
    COMMENT 'FK → inv_asset_item_types.item_type_id'
    AFTER `inventory_type_id`;

ALTER TABLE `inv_items`
  ADD CONSTRAINT IF NOT EXISTS `fk_items_asset_item_type`
    FOREIGN KEY (`asset_item_type_id`) REFERENCES `inv_asset_item_types` (`item_type_id`);

-- ─── 4. Seed groups ────────────────────────────────────────────────────────

INSERT INTO `inv_asset_item_type_groups` (`group_code`, `group_name`, `description`, `sort_order`) VALUES
('OF',   'Office Furniture',              'Desks, chairs, filing cabinets, cupboards, and other office furniture items.', 1),
('OM',   'Office Machine',               'Electronic and mechanical office machines: computers, copiers, air conditioners, UPS units, etc.', 2),
('E',    'Equipment',                    'Specialized laboratory, scientific, and technical equipment.', 3),
('ITEM', 'Tools, Equipment and Machines','Grounds-keeping tools, generators, containers, and general plant and equipment.', 4)
ON DUPLICATE KEY UPDATE
  `group_name` = VALUES(`group_name`),
  `description` = VALUES(`description`),
  `sort_order`  = VALUES(`sort_order`),
  `is_active`   = 1;

-- ─── 5. Seed OFFICE FURNITURE (OF) types ──────────────────────────────────

INSERT INTO `inv_asset_item_types` (`group_id`, `type_code`, `type_name`, `sort_order`) VALUES
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 1',  'DESK (WOOD) NO DRAWER', 1),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 2',  'DESK (METAL) THREE (3) DRAWER', 2),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 3',  'DESK (WOOD) (4 DRS)', 3),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 4',  'BENCH (WOOD)', 4),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 5',  'DESK (WOOD) (7 DRAWERS)', 5),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 6',  'DESK (WOOD) 1 DR AND SHELVES TYPIST', 6),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 7',  'DESK (WOOD) (3 DRS)', 7),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 8',  'BOOK RACK (WOOD) / 3 SHELVES', 8),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 9',  'CHAIRS WOOD (SWIVEL WITH ARMS)', 9),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 10', 'CHAIRS (WOOD) (WITH ARMS)', 10),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 11', 'CHAIRS W/OUT ARM REST', 11),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 12', 'CHAIRS TYPIST', 12),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 13', 'FILING CABINET (2 DOORS)', 13),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 14', 'STOOL (WOOD)', 14),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 15', 'STOOL (METAL AND WOOD)', 15),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 16', 'PAPER TRAY (WOOD)', 16),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 17', 'TABLE (WOOD)', 17),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 18', 'RUBBISH BIN (PLASTIC)', 18),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 19', 'FILING CABINET (FOUR DRS)', 19),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 20', 'DESK (WOOD) WITH TRAY AND FOUR DRAWERS', 20),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 21', 'TRAY PLASTIC (DOUBLE)', 21),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 22', 'STAND (METAL)', 22),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 23', 'CHAIRS (METAL AND FABRIC) WITH ARMS', 23),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 24', 'STAND (WOOD)', 24),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 25', 'CHAIRS (PLASTIC AND SWIVEL)', 25),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 26', 'DESK (WOOD) (SIX (6) DRS)', 26),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 27', 'BENCH (METAL AND WOOD)', 27),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 28', 'WOOD CUPBOARD', 28),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 29', 'CARD CABINET (METAL ONE (1) DRS)', 29),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 30', 'DESK (WOOD) WITH LIFT', 30),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 31', 'DESK (EIGHT (8) DRS)', 31),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 32', 'STAND (SHELVES) (EIGHT (8) SHELVES)', 32),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 33', 'CARD CABINET (WOOD) (ONE (1) DRS)', 33),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 34', 'BOOK CASE (WOOD & GLASS)', 34),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 35', 'CARD CABINET (2 DRS)', 35),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 36', 'TENDER BOX', 36),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 37', 'CONFERENCE TABLE', 37),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 38', 'CHAIR - MESH BACK WITH ARMS', 38),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 39', 'CABINET (METAL)', 39),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 40', 'DESK WITH RETURN AND DRAWERS (COMPRESSED BOARD)', 40),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 41', 'CHAIR (HIGH)', 41),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 42', 'TABLE (PLASTIC FOLDING)', 42),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 43', 'DESK COMPUTER', 43),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 44', 'CHAIRS (PLASTIC / CAN BE STACK)', 44),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 45', 'RETAINER BAR EASEL (WHITE BOARD STAND)', 45),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 46', 'QUARTET EASEL (WHITE BOARD)', 46),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 47', 'PROJECTION SCREEN (CEILING WALL MOUNT)', 47),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 48', 'DESK WITH PEDESTAL', 48),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 49', 'PEDESTAL (FOR DESK)', 49),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 50', 'ROUND TOP TABLE WITH METAL BASE', 50),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 51', 'CHAIRS (SIDE CHAIRS)', 51),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 52', 'RUBBISH BIN (METAL)', 52),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 53', 'DESK WITH RETURN COMPRESSED (BOARD) NO DRAWERS', 53),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 54', 'CUPBOARD - TWO (2) SHELF WITH DOORS', 54),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 55', 'BED BASE', 55),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 56', 'MATT (BED)', 56),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 57', 'IRON BOARD', 57),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 58', 'IRON (CLOTHING)', 58),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 59', 'SIDE CHAIRS (STACKABLE FABRIC)', 59),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OF'), 'OF 60', 'CUPBOARD (COMPRESSED BOARD)', 60)
ON DUPLICATE KEY UPDATE
  `type_name`  = VALUES(`type_name`),
  `sort_order` = VALUES(`sort_order`),
  `is_active`  = 1;

-- ─── 6. Seed OFFICE MACHINE (OM) types ────────────────────────────────────

INSERT INTO `inv_asset_item_types` (`group_id`, `type_code`, `type_name`, `sort_order`) VALUES
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 1',  'SURGE PROTECTOR', 1),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 2',  'PHOTO COPIER', 2),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 3',  'AIR CONDITIONER SPLIT UNIT (12000 BTU)', 3),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 4',  'COMPUTER MONITOR (CRT)', 4),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 5',  'COMPUTER MONITOR (LCD)', 5),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 6',  'COMPUTER C.P.U.', 6),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 7',  'COMPUTER PRINTER', 7),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 8',  'COMPUTER KEYBOARD', 8),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 9',  'COMPUTER MOUSE', 9),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 10', 'UPS (350 VAC)', 10),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 11', 'UPS (550 VAC)', 11),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 12', 'POWER STRIP', 12),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 13', 'ADDING MACHINE', 13),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 14', 'COMPUTER SPEAKER', 14),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 15', 'PENCIL SHARPER', 15),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 16', 'FAX MACHINE', 16),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 17', 'MICROWAVE', 17),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 18', 'DESK LAMP', 18),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 19', 'UPS (1000 VAC)', 19),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 20', 'AIR CONDITIONER (24000 BTU SPLIT UNIT)', 20),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 21', 'CLOCK', 21),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 22', 'WINDOW UNIT (AIR CONDITIONER)', 22),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 23', 'UPS (1500 VAC)', 23),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 24', 'STANDING FAN', 24),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 25', 'TYPE WRITER', 25),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 26', 'UPS (500 VAC)', 26),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 28', 'VACCUM CLEANER', 28),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 29', 'COMPUTER ZIP DRIVE', 29),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 30', 'COMPUTER MICROPHONE', 30),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 31', 'UP-RIGHT FREEZER', 31),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 32', 'REFRIGERATOR', 32),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 33', 'UPS (800 VAC)', 33),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 34', 'LAPTOP', 34),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 35', 'AIR CONDITIONER (18000 BTU SPLIT UNIT)', 35),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 36', 'UPS (3000 VAC)', 36),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 37', 'WALL FAN', 37),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 38', 'UPS (600 VAC)', 38),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 39', 'UPS (850 VAC)', 39),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 40', 'AIR CONDITIONER (36000 BTU)', 40),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 41', 'LAMINATOR / LAMINATING MACHINE', 41),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 42', 'PAPER SHREDDER', 42),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 43', 'PROJECTOR', 43),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 44', 'A/C UNIT (CASSETTE)', 44),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 45', 'TELEVISION / LCD MONITOR (27 INCH)', 45),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 46', 'CCTV VIDEO RECORDER', 46),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 47', 'U.P.S (750VAC)', 47),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 48', 'WATER DISPENSER', 48),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 49', 'FREEZER (CHEST)', 49),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 50', 'UPS (BU 650)', 50),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 51', 'UPS (BE 425)', 51),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 52', 'SCANNER', 52),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 53', 'PROJECTOR SCREEN', 53),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 54', 'U.P.S (1100 VAC)', 54),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 55', 'U.P.S (6000 VAC)', 55),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 56', 'COMPUTER MOUSE (WIRELESS)', 56),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 57', 'COMPUTER KEYBOARD (WIRELESS)', 57),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 58', 'WIRED HEADSET', 58),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 59', 'VOICE RECORDER (DIGITAL VOICE RECORDER) PHONE WITH PLAY BACK', 59),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='OM'), 'OM 60', 'TABLET', 60)
ON DUPLICATE KEY UPDATE
  `type_name`  = VALUES(`type_name`),
  `sort_order` = VALUES(`sort_order`),
  `is_active`  = 1;

-- ─── 7. Seed EQUIPMENT (E) types ──────────────────────────────────────────

INSERT INTO `inv_asset_item_types` (`group_id`, `type_code`, `type_name`, `sort_order`) VALUES
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 1',  'FURANCE', 1),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 2',  'ULTRAVIOLET CABINET', 2),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 3',  'SPECTROMETER', 3),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 4',  'GAS CHROMATROGRAPH', 4),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 5',  'CENTRIFUGE', 5),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 6',  'CLAMP STAND', 6),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 7',  'TROLLEY (WOOD)', 7),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 8',  'TROLLEY (SIDE)', 8),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 9',  'WATER BATH AND CIRCULATOR', 9),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 10', 'FLAMME PHOTOMETER', 10),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 11', 'CENTRIFUGE (FOR MILK)', 11),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 12', 'PRECISION CRYOSCOPE', 12),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 13', 'WRIST ACTION SHAKER', 13),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 14', 'TRIPLE BEAM BALANCE', 14),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 15', 'OVEN', 15),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 16', 'CAPILLARY MELTING POINT APPARATUS', 16),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 17', 'MILK CALCULATOR', 17),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 18', 'BALANCE', 18),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 19', 'FLAMMABLE CABINET', 19),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 20', 'HPLC', 20),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 21', 'SCIENTIFIC REFRIGERATOR', 21),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 22', 'DISTALATOR', 22),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 23', 'STIR PLATE (STIRRER)', 23),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 24', 'MIXER', 24),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 25', 'WATER BATH (ELECTRICALLY HEATED)', 25),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 26', 'BLENDER (LABORATORY)', 26),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 27', 'DEIONISER ULTRA FILTRATION', 27),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 28', 'BALANCE (COUNTER TOP)', 28),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 29', 'PH/ISE METER', 29),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 30', 'WATER BATH FOR MILK', 30),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 31', 'ULTRASONIC CLEANER', 31),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 32', 'ULTRAVIOLET SPECTROMETER', 32),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 33', 'DISSOLUTION APPARATUS', 33),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 34', 'DISINTEGRATION APPARATUS', 34),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 35', 'FLUOROMETER (DIGITAL)', 35),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 36', 'MANUAL BENCH TOP PRESS', 36),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 37', 'VACCUM OVEN', 37),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 38', 'VACCUM PUMP', 38),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 39', 'WATER BATH (VARIABLE)', 39),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 40', 'CLINICAL CHEMICAL ANALYSER', 40),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 41', 'HEATING MANTLE', 41),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 42', 'POLARIMETER', 42),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 43', 'ULTRA PURE DISTALATOR (GLASS STILL)', 43),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='E'), 'E 44', 'PRINTER (FOR BALANCE)', 44)
ON DUPLICATE KEY UPDATE
  `type_name`  = VALUES(`type_name`),
  `sort_order` = VALUES(`sort_order`),
  `is_active`  = 1;

-- ─── 8. Seed TOOLS, EQUIPMENT AND MACHINES (ITEM) types ───────────────────

INSERT INTO `inv_asset_item_types` (`group_id`, `type_code`, `type_name`, `sort_order`) VALUES
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 1', 'LAWN MOWER', 1),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 2', 'BRUSH CUTTER', 2),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 3', 'WHEEL BARROW', 3),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 4', 'GENERATOR', 4),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 5', 'STEP LADDER (12FT)', 5),
((SELECT group_id FROM inv_asset_item_type_groups WHERE group_code='ITEM'), 'ITEM 6', 'SHIPPING CONTAINER', 6)
ON DUPLICATE KEY UPDATE
  `type_name`  = VALUES(`type_name`),
  `sort_order` = VALUES(`sort_order`),
  `is_active`  = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- ─── Verification ────────────────────────────────────────────────────────────

SELECT group_code, group_name, COUNT(t.item_type_id) AS type_count
FROM inv_asset_item_type_groups g
LEFT JOIN inv_asset_item_types t ON g.group_id = t.group_id AND t.is_active = 1
WHERE g.is_active = 1
GROUP BY g.group_id, g.group_code, g.group_name
ORDER BY g.sort_order;
