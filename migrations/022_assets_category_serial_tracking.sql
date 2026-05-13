-- ============================================================================
-- Migration 022: Assets Category + Serial Number Lifecycle Tracking
-- ============================================================================
-- Purpose:
--   1. Add "Assets" as a new inventory category.
--   2. Create inv_serial_numbers table to track individual serialized assets
--      through the full procurement-to-disposal lifecycle.
--
-- Lifecycle chain:
--   Purchase Req # -> PO # -> Invoice # -> Serial # -> GRN # ->
--   DGC Asset # (Issue Requisition #) -> BOS -> Destroyed/Sold/etc.
--
-- Date: 2026-05-13
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Add Assets category to inv_categories
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `inv_categories` (`category_code`, `category_name`, `description`, `sort_order`)
VALUES ('ASSETS', 'Assets', 'Fixed and movable assets tracked by serial number (equipment, furniture, IT hardware, vehicles, etc.)', 15);

-- ═══════════════════════════════════════════════════════════
-- STEP 2: Serial Number Lifecycle Tracking Table
-- ═══════════════════════════════════════════════════════════
--
-- Each row represents ONE physical serialized unit of an inv_item.
-- The columns mirror the document chain from procurement through disposal.
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `inv_serial_numbers` (
  `serial_id`               int(11)       NOT NULL AUTO_INCREMENT,

  -- Which inventory item this serial unit belongs to
  `item_id`                 int(11)       NOT NULL,

  -- The physical serial number stamped on the asset
  `serial_number`           varchar(100)  NOT NULL,

  -- ── Procurement stage ───────────────────────────────────
  `purchase_req_number`     varchar(50)   DEFAULT NULL COMMENT 'Purchase Requisition # (procurement_requests.request_number)',
  `po_number`               varchar(50)   DEFAULT NULL COMMENT 'Purchase Order # (purchase_orders.po_number)',
  `invoice_number`          varchar(100)  DEFAULT NULL COMMENT 'Supplier Invoice #',

  -- ── Receiving stage ─────────────────────────────────────
  `grn_number`              varchar(30)   DEFAULT NULL COMMENT 'Goods Received Note # (inv_goods_received.grn_number)',
  `grn_item_id`             int(11)       DEFAULT NULL COMMENT 'FK to inv_grn_items',

  -- ── Asset assignment stage ───────────────────────────────
  `dgc_asset_number`        varchar(50)   DEFAULT NULL COMMENT 'DGC Asset Register # assigned after receiving',
  `issue_requisition_number` varchar(30)  DEFAULT NULL COMMENT 'Issue Requisition # (inv_requisitions.requisition_number)',
  `issue_number`            varchar(30)   DEFAULT NULL COMMENT 'Issue Voucher # (inv_issues.issue_number)',
  `issued_to_user_id`       int(11)       DEFAULT NULL COMMENT 'User the asset is assigned/issued to',
  `issued_to_department`    int(11)       DEFAULT NULL COMMENT 'Branch/department asset is assigned to',
  `location_id`             int(11)       DEFAULT NULL COMMENT 'Physical location of the asset',

  -- ── End-of-life stage ────────────────────────────────────
  `bos_number`              varchar(50)   DEFAULT NULL COMMENT 'Board of Survey / Bill of Sale reference',
  `disposal_number`         varchar(30)   DEFAULT NULL COMMENT 'Disposal record # (inv_disposals.disposal_number)',
  `disposal_method`         enum('DESTRUCTION','AUCTION','TRANSFER','DONATION','RETURN_TO_SUPPLIER','SCRAP','SOLD','OTHER')
                            DEFAULT NULL,
  `disposal_date`           date          DEFAULT NULL,

  -- ── Current lifecycle status ─────────────────────────────
  `lifecycle_status` enum(
    'ORDERED',           -- PO raised, not yet received
    'RECEIVED',          -- GRN accepted, in stores
    'ASSIGNED',          -- Issued/allocated to a user or department
    'IN_SERVICE',        -- Actively in use
    'UNDER_REPAIR',      -- Sent for maintenance/repair
    'TRANSFERRED',       -- Moved to another location/department
    'DISPOSED',          -- Formally disposed/written off
    'LOST_STOLEN'        -- Lost or stolen
  ) NOT NULL DEFAULT 'ORDERED',

  -- ── Condition tracking ───────────────────────────────────
  `condition_on_receipt`    varchar(50)   DEFAULT NULL,
  `current_condition`       varchar(50)   DEFAULT NULL,

  -- ── Warranty / maintenance ───────────────────────────────
  `warranty_expiry_date`    date          DEFAULT NULL,
  `last_service_date`       date          DEFAULT NULL,
  `next_service_date`       date          DEFAULT NULL,
  `service_notes`           text          DEFAULT NULL,

  -- ── Meta ─────────────────────────────────────────────────
  `notes`                   text          DEFAULT NULL,
  `created_by`              int(11)       DEFAULT NULL,
  `updated_by`              int(11)       DEFAULT NULL,
  `created_at`              timestamp     DEFAULT CURRENT_TIMESTAMP,
  `updated_at`              timestamp     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`serial_id`),
  UNIQUE KEY `uk_item_serial` (`item_id`, `serial_number`),
  KEY `idx_serial_number`    (`serial_number`),
  KEY `idx_grn_number`       (`grn_number`),
  KEY `idx_po_number`        (`po_number`),
  KEY `idx_dgc_asset`        (`dgc_asset_number`),
  KEY `idx_lifecycle_status` (`lifecycle_status`),
  KEY `idx_issued_user`      (`issued_to_user_id`),
  KEY `idx_location`         (`location_id`),

  CONSTRAINT `fk_sn_item`    FOREIGN KEY (`item_id`)          REFERENCES `inv_items`        (`item_id`),
  CONSTRAINT `fk_sn_grni`    FOREIGN KEY (`grn_item_id`)      REFERENCES `inv_grn_items`    (`grn_item_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sn_user`    FOREIGN KEY (`issued_to_user_id`) REFERENCES `users`            (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sn_loc`     FOREIGN KEY (`location_id`)      REFERENCES `inv_locations`    (`location_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Individual serialized asset lifecycle tracking from procurement to disposal';

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Verification
-- ═══════════════════════════════════════════════════════════

SELECT category_id, category_code, category_name FROM `inv_categories` WHERE category_code = 'ASSETS';
SELECT COUNT(*) AS serial_number_table_exists FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inv_serial_numbers';
