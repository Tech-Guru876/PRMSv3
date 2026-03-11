-- ============================================================
-- Migration 019: Inventory Management System
-- Full inventory module with classes, master data, locations,
-- transactions, document control, and segregation of duties
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. LOOKUP / CLASSIFICATION TABLES
-- ============================================================

-- Inventory categories (Consumables, Office supplies, etc.)
CREATE TABLE IF NOT EXISTS `inv_categories` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `category_code` varchar(20) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_category_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_category_code` (`category_code`),
  KEY `idx_parent` (`parent_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed inventory categories
INSERT INTO `inv_categories` (`category_code`, `category_name`, `description`, `sort_order`) VALUES
('CONSUMABLES', 'Consumables', 'General consumable items', 1),
('OFFICE_SUP', 'Office Supplies', 'Stationery, paper, toner, etc.', 2),
('CLEANING', 'Cleaning Supplies', 'Cleaning compounds, equipment', 3),
('LAB_SUP', 'Laboratory Supplies', 'Lab reagents, glassware, disposables', 4),
('CHEM_REAG', 'Chemicals and Reagents', 'Chemicals, reagents, standards', 5),
('PPE_SAFETY', 'PPE and Safety Items', 'Protective gear, safety equipment', 6),
('SPARE_PARTS', 'Spare Parts', 'Equipment and machinery spare parts', 7),
('MAINT_STOCK', 'Maintenance Stock', 'Maintenance and repair supplies', 8),
('UNIFORMS', 'Uniforms', 'Staff uniforms and workwear', 9),
('IT_CONSUM', 'IT Consumables', 'Cables, drives, peripherals', 10),
('PRINT_FORMS', 'Printed Forms and Controlled Stationery', 'Pre-printed forms, numbered stationery', 11),
('DIST_GOODS', 'Goods Held for Distribution', 'Items for distribution to clients/public', 12),
('RESALE', 'Goods Held for Resale', 'Items held for resale where applicable', 13),
('WIP_SERVICE', 'Work-in-Progress / Service-Related Stock', 'Service-related stock and WIP items', 14);

-- Item criticality classes
CREATE TABLE IF NOT EXISTS `inv_criticality_classes` (
  `criticality_id` int(11) NOT NULL AUTO_INCREMENT,
  `criticality_code` varchar(30) NOT NULL,
  `criticality_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  PRIMARY KEY (`criticality_id`),
  UNIQUE KEY `uk_crit_code` (`criticality_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `inv_criticality_classes` (`criticality_code`, `criticality_name`, `description`, `sort_order`) VALUES
('CRITICAL', 'Critical / Mission Essential', 'Items essential for core operations', 1),
('ESSENTIAL', 'Essential', 'Important items needed for normal operations', 2),
('ROUTINE', 'Routine', 'Standard items with no special urgency', 3),
('OBSOLETE', 'Obsolete / Pending Disposal', 'Items no longer needed or to be disposed', 4),
('QUARANTINE', 'Quarantined / Under Investigation', 'Items under review or investigation', 5);

-- Risk and control classes (an item can have multiple)
CREATE TABLE IF NOT EXISTS `inv_risk_classes` (
  `risk_class_id` int(11) NOT NULL AUTO_INCREMENT,
  `risk_code` varchar(30) NOT NULL,
  `risk_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  PRIMARY KEY (`risk_class_id`),
  UNIQUE KEY `uk_risk_code` (`risk_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `inv_risk_classes` (`risk_code`, `risk_name`, `description`, `sort_order`) VALUES
('HIGH_VALUE', 'High-Value Items', 'Items above defined value threshold', 1),
('CONTROLLED', 'Controlled Items', 'Items with restricted access', 2),
('HAZARDOUS', 'Hazardous Items', 'Items requiring special handling', 3),
('EXPIRY_SENS', 'Expiry-Sensitive Items', 'Items with shelf life constraints', 4),
('SERIALIZED', 'Serialized Items', 'Items tracked by serial number', 5),
('REGULATED', 'Regulated Items', 'Items under regulatory control', 6),
('DONATED', 'Donated Items', 'Items received as donations/grants', 7),
('EMERG_RESERVE', 'Emergency Reserve / Contingency Stock', 'Items reserved for emergencies', 8);

-- Accounting classes
CREATE TABLE IF NOT EXISTS `inv_accounting_classes` (
  `acct_class_id` int(11) NOT NULL AUTO_INCREMENT,
  `acct_class_code` varchar(30) NOT NULL,
  `acct_class_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  PRIMARY KEY (`acct_class_id`),
  UNIQUE KEY `uk_acct_code` (`acct_class_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `inv_accounting_classes` (`acct_class_code`, `acct_class_name`, `description`, `sort_order`) VALUES
('EXCHANGE', 'Exchange-Purchased Inventory', 'Purchased through normal procurement', 1),
('NON_EXCHANGE', 'Non-Exchange Inventory', 'Received via donations or grants', 2),
('NOMINAL_DIST', 'Inventory for Nominal/No-Charge Distribution', 'Distributed free or at nominal cost', 3),
('WRITE_DOWN', 'Write-Down Candidates', 'Items flagged for potential write-down', 4),
('DAMAGED_LOST', 'Damaged/Lost/Shrinkage Stock', 'Items damaged, lost, or shrunk', 5),
('DISPOSAL', 'Disposal Stock', 'Items designated for disposal', 6);

-- Units of measure
CREATE TABLE IF NOT EXISTS `inv_units_of_measure` (
  `uom_id` int(11) NOT NULL AUTO_INCREMENT,
  `uom_code` varchar(10) NOT NULL,
  `uom_name` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`uom_id`),
  UNIQUE KEY `uk_uom_code` (`uom_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `inv_units_of_measure` (`uom_code`, `uom_name`) VALUES
('EA', 'Each'), ('PK', 'Pack'), ('BX', 'Box'), ('CS', 'Case'),
('RL', 'Roll'), ('BT', 'Bottle'), ('KG', 'Kilogram'), ('LT', 'Litre'),
('M', 'Metre'), ('PR', 'Pair'), ('ST', 'Set'), ('DZ', 'Dozen'),
('RM', 'Ream'), ('GL', 'Gallon'), ('TB', 'Tube'), ('DR', 'Drum'),
('CT', 'Carton'), ('TN', 'Tin'), ('SH', 'Sheet'), ('BAG', 'Bag');

-- ============================================================
-- 2. MASTER DATA: INVENTORY ITEMS
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_code` varchar(30) NOT NULL COMMENT 'Unique SKU / internal stock code',
  `item_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `subcategory_id` int(11) DEFAULT NULL,
  `uom_id` int(11) NOT NULL,
  `pack_size` decimal(10,2) DEFAULT 1.00 COMMENT 'Pack size / conversion factor',
  `barcode` varchar(50) DEFAULT NULL COMMENT 'Barcode / QR / GS1 identifier',
  `manufacturer` varchar(150) DEFAULT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `model` varchar(100) DEFAULT NULL,
  `part_number` varchar(100) DEFAULT NULL COMMENT 'Part number / catalogue number',

  -- Tracking flags
  `serial_number_flag` tinyint(1) DEFAULT 0,
  `batch_lot_flag` tinyint(1) DEFAULT 0,
  `expiry_date_flag` tinyint(1) DEFAULT 0,
  `hazard_class_flag` tinyint(1) DEFAULT 0,

  -- Storage
  `storage_conditions` varchar(255) DEFAULT NULL,
  `shelf_life_days` int(11) DEFAULT NULL,
  `inspection_required` tinyint(1) DEFAULT 0,
  `receiving_tolerance_pct` decimal(5,2) DEFAULT 0.00,

  -- Procurement linkage
  `preferred_supplier_ids` text DEFAULT NULL COMMENT 'JSON array of vendor IDs',
  `contract_reference` varchar(100) DEFAULT NULL,
  `procurement_method` varchar(100) DEFAULT NULL,

  -- Replenishment
  `reorder_level` decimal(12,2) DEFAULT 0,
  `reorder_quantity` decimal(12,2) DEFAULT 0,
  `min_level` decimal(12,2) DEFAULT 0,
  `max_level` decimal(12,2) DEFAULT 0,
  `safety_stock` decimal(12,2) DEFAULT 0,
  `lead_time_days` int(11) DEFAULT 0,
  `economic_order_qty` decimal(12,2) DEFAULT NULL,

  -- Costing
  `standard_cost` decimal(14,2) DEFAULT 0.00,
  `last_cost` decimal(14,2) DEFAULT 0.00,
  `average_cost` decimal(14,2) DEFAULT 0.00,
  `valuation_method` enum('AVERAGE','FIFO','STANDARD','SPECIFIC') DEFAULT 'AVERAGE',

  -- Financial coding
  `funding_source` varchar(100) DEFAULT NULL,
  `program_project_code` varchar(50) DEFAULT NULL,
  `gl_account_code` varchar(50) DEFAULT NULL,

  -- Classification
  `criticality_id` int(11) DEFAULT NULL,
  `acct_class_id` int(11) DEFAULT NULL,
  `item_status` enum('ACTIVE','BLOCKED','OBSOLETE','QUARANTINED','DISPOSAL') DEFAULT 'ACTIVE',
  `issue_policy` enum('UNRESTRICTED','APPROVAL_REQUIRED','CONTROLLED') DEFAULT 'UNRESTRICTED',
  `asset_inventory_boundary` tinyint(1) DEFAULT 0 COMMENT 'Flag if item straddles asset/inventory line',

  -- Meta
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uk_item_code` (`item_code`),
  KEY `idx_category` (`category_id`),
  KEY `idx_criticality` (`criticality_id`),
  KEY `idx_status` (`item_status`),
  CONSTRAINT `fk_item_category` FOREIGN KEY (`category_id`) REFERENCES `inv_categories` (`category_id`),
  CONSTRAINT `fk_item_subcategory` FOREIGN KEY (`subcategory_id`) REFERENCES `inv_categories` (`category_id`),
  CONSTRAINT `fk_item_uom` FOREIGN KEY (`uom_id`) REFERENCES `inv_units_of_measure` (`uom_id`),
  CONSTRAINT `fk_item_criticality` FOREIGN KEY (`criticality_id`) REFERENCES `inv_criticality_classes` (`criticality_id`),
  CONSTRAINT `fk_item_acct_class` FOREIGN KEY (`acct_class_id`) REFERENCES `inv_accounting_classes` (`acct_class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Item risk class mapping (many-to-many)
CREATE TABLE IF NOT EXISTS `inv_item_risk_classes` (
  `item_id` int(11) NOT NULL,
  `risk_class_id` int(11) NOT NULL,
  PRIMARY KEY (`item_id`, `risk_class_id`),
  CONSTRAINT `fk_irc_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_irc_risk` FOREIGN KEY (`risk_class_id`) REFERENCES `inv_risk_classes` (`risk_class_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Item preferred suppliers mapping
CREATE TABLE IF NOT EXISTS `inv_item_suppliers` (
  `item_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `last_supply_date` date DEFAULT NULL,
  `last_price` decimal(14,2) DEFAULT NULL,
  PRIMARY KEY (`item_id`, `vendor_id`),
  CONSTRAINT `fk_is_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_is_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`vendor_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. MASTER DATA: LOCATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_locations` (
  `location_id` int(11) NOT NULL AUTO_INCREMENT,
  `location_code` varchar(30) NOT NULL,
  `site_campus` varchar(100) DEFAULT NULL,
  `building` varchar(100) DEFAULT NULL,
  `floor` varchar(20) DEFAULT NULL,
  `room_storage_area` varchar(100) DEFAULT NULL,
  `bin_shelf_rack` varchar(50) DEFAULT NULL,
  `security_level` enum('STANDARD','RESTRICTED','HIGH_SECURITY') DEFAULT 'STANDARD',
  `temp_humidity_req` varchar(100) DEFAULT NULL,
  `custodian_user_id` int(11) DEFAULT NULL,
  `capacity` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `location_type` enum('USABLE','QUARANTINE','EXPIRED','DAMAGED','DISPOSAL','RECEIVING','STAGING') DEFAULT 'USABLE',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `uk_location_code` (`location_code`),
  KEY `idx_custodian` (`custodian_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. STOCK BALANCES (per item per location per batch)
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_stock` (
  `stock_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_on_hand` decimal(14,4) DEFAULT 0,
  `quantity_reserved` decimal(14,4) DEFAULT 0 COMMENT 'Reserved for approved requisitions',
  `quantity_available` decimal(14,4) GENERATED ALWAYS AS (`quantity_on_hand` - `quantity_reserved`) STORED,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `stock_status` enum('USABLE','QUARANTINE','EXPIRED','DAMAGED','DISPOSAL') DEFAULT 'USABLE',
  `received_date` date DEFAULT NULL,
  `last_count_date` date DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stock_id`),
  KEY `idx_item_loc` (`item_id`, `location_id`),
  KEY `idx_expiry` (`expiry_date`),
  KEY `idx_status` (`stock_status`),
  CONSTRAINT `fk_stock_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_stock_location` FOREIGN KEY (`location_id`) REFERENCES `inv_locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. INVENTORY ROLES  
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_roles` (
  `inv_role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_code` varchar(30) NOT NULL,
  `role_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`inv_role_id`),
  UNIQUE KEY `uk_inv_role` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `inv_roles` (`role_code`, `role_name`, `description`) VALUES
('ACCT_OFFICER', 'Accounting Officer / Head of Department', 'Overall accountability for inventory'),
('ASSET_MGR', 'Asset Manager / Inventory Controller', 'Day-to-day inventory management'),
('STOREKEEPER', 'Storekeeper / Stores Clerk', 'Physical custody of stores'),
('REQ_OFFICER', 'Requisitioning Officer', 'Authorized to submit stock requisitions'),
('RCV_OFFICER', 'Receiving Officer', 'Authorized to receive goods'),
('APR_OFFICER', 'Approving Officer', 'Authorized to approve inventory transactions'),
('PROC_OFFICER', 'Procurement Officer', 'Links procurement to inventory'),
('FIN_OFFICER', 'Finance Officer', 'Financial oversight of inventory'),
('DISP_AUTH', 'Disposal / Survey / Write-off Authority', 'Authorized for disposal and write-off'),
('INT_AUDITOR', 'Internal Auditor', 'Audit and review of inventory'),
('SYS_ADMIN', 'System Administrator', 'System configuration for inventory'),
('DEPT_CUSTODIAN', 'Departmental Custodian / Location Custodian', 'Responsible for inventory at a location');

-- User-to-inventory-role mapping
CREATE TABLE IF NOT EXISTS `inv_user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `inv_role_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL COMMENT 'Optional: scope role to a location',
  `is_active` tinyint(1) DEFAULT 1,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_inv_role_loc` (`user_id`, `inv_role_id`, `location_id`),
  CONSTRAINT `fk_iur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_iur_role` FOREIGN KEY (`inv_role_id`) REFERENCES `inv_roles` (`inv_role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. APPROVAL MATRIX FOR INVENTORY
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_approval_matrix` (
  `matrix_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_type` enum('REQUISITION','RECEIVING','ISSUE','TRANSFER','ADJUSTMENT','DISPOSAL','WRITE_OFF') NOT NULL,
  `item_class` varchar(30) DEFAULT NULL COMMENT 'Category or risk class code filter',
  `min_value` decimal(14,2) DEFAULT 0,
  `max_value` decimal(14,2) DEFAULT 999999999.99,
  `department_id` int(11) DEFAULT NULL,
  `is_emergency` tinyint(1) DEFAULT 0,
  `required_role_code` varchar(30) NOT NULL COMMENT 'inv_roles.role_code required to approve',
  `approval_level` int(11) DEFAULT 1 COMMENT 'Sequence in multi-level approval',
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Delegation controls
CREATE TABLE IF NOT EXISTS `inv_delegations` (
  `delegation_id` int(11) NOT NULL AUTO_INCREMENT,
  `delegator_user_id` int(11) NOT NULL,
  `delegate_user_id` int(11) NOT NULL,
  `inv_role_id` int(11) NOT NULL,
  `effective_from` datetime NOT NULL,
  `effective_to` datetime NOT NULL,
  `reason` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`delegation_id`),
  KEY `idx_delegate` (`delegate_user_id`),
  KEY `idx_expiry` (`effective_to`),
  CONSTRAINT `fk_del_delegator` FOREIGN KEY (`delegator_user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_del_delegate` FOREIGN KEY (`delegate_user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_del_role` FOREIGN KEY (`inv_role_id`) REFERENCES `inv_roles` (`inv_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. DOCUMENT CONTROL
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_documents` (
  `document_id` int(11) NOT NULL AUTO_INCREMENT,
  `document_number` varchar(30) NOT NULL,
  `document_type` enum(
    'REQUISITION','PURCHASE_REQUEST','PURCHASE_ORDER','GOODS_RECEIVED_NOTE',
    'INSPECTION_REPORT','BIN_CARD','STOCK_ISSUE_VOUCHER','TRANSFER_NOTE',
    'ADJUSTMENT_NOTE','STOCK_COUNT_SHEET','VARIANCE_REPORT','QUARANTINE_NOTE',
    'DISPOSAL_FORM','RETURN_TO_SUPPLIER','DONATION_ACCEPTANCE','INCIDENT_REPORT'
  ) NOT NULL,
  `reference_table` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 1,
  `status` enum('DRAFT','PENDING','APPROVED','REJECTED','CANCELLED','CLOSED') DEFAULT 'DRAFT',
  `created_by` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `digital_signature` text DEFAULT NULL COMMENT 'Approval evidence',
  `notes` text DEFAULT NULL,
  `is_locked` tinyint(1) DEFAULT 0 COMMENT 'Locked after approval - no edits',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`document_id`),
  UNIQUE KEY `uk_doc_number` (`document_number`),
  KEY `idx_doc_type` (`document_type`),
  KEY `idx_doc_ref` (`reference_table`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Document attachments
CREATE TABLE IF NOT EXISTS `inv_document_attachments` (
  `attachment_id` int(11) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `uploaded_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attachment_id`),
  CONSTRAINT `fk_att_doc` FOREIGN KEY (`document_id`) REFERENCES `inv_documents` (`document_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. STOCK REQUISITIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_requisitions` (
  `requisition_id` int(11) NOT NULL AUTO_INCREMENT,
  `requisition_number` varchar(30) NOT NULL,
  `requester_user_id` int(11) NOT NULL,
  `department_id` int(11) DEFAULT NULL COMMENT 'branch_id reference',
  `cost_centre` varchar(50) DEFAULT NULL,
  `intended_use` text DEFAULT NULL,
  `destination_location_id` int(11) DEFAULT NULL,
  `urgency` enum('NORMAL','URGENT','EMERGENCY') DEFAULT 'NORMAL',
  `justification` text DEFAULT NULL,
  `emergency_reason_code` varchar(30) DEFAULT NULL,
  `status` enum('DRAFT','SUBMITTED','APPROVED','PARTIALLY_ISSUED','ISSUED','REJECTED','CANCELLED') DEFAULT 'DRAFT',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `is_duplicate_flagged` tinyint(1) DEFAULT 0,
  `procurement_trigger` tinyint(1) DEFAULT 0 COMMENT 'If true, triggers procurement for out-of-stock items',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`requisition_id`),
  UNIQUE KEY `uk_req_number` (`requisition_number`),
  KEY `idx_requester` (`requester_user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_req_user` FOREIGN KEY (`requester_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Requisition line items
CREATE TABLE IF NOT EXISTS `inv_requisition_items` (
  `req_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `requisition_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_requested` decimal(14,4) NOT NULL,
  `quantity_approved` decimal(14,4) DEFAULT NULL,
  `quantity_issued` decimal(14,4) DEFAULT 0,
  `substitute_item_id` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `stock_available_at_request` decimal(14,4) DEFAULT NULL COMMENT 'Snapshot of available stock',
  PRIMARY KEY (`req_item_id`),
  KEY `idx_req_id` (`requisition_id`),
  CONSTRAINT `fk_ri_req` FOREIGN KEY (`requisition_id`) REFERENCES `inv_requisitions` (`requisition_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ri_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. GOODS RECEIVING
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_goods_received` (
  `grn_id` int(11) NOT NULL AUTO_INCREMENT,
  `grn_number` varchar(30) NOT NULL,
  `po_reference` varchar(50) DEFAULT NULL COMMENT 'Link to purchase_orders.po_number',
  `contract_reference` varchar(100) DEFAULT NULL,
  `donation_reference` varchar(100) DEFAULT NULL,
  `supplier_vendor_id` int(11) DEFAULT NULL,
  `donor_source` varchar(200) DEFAULT NULL COMMENT 'For non-exchange transactions',
  `received_by` int(11) NOT NULL,
  `received_date` date NOT NULL,
  `status` enum('DRAFT','RECEIVED','INSPECTED','ACCEPTED','PARTIAL','REJECTED','QUARANTINE') DEFAULT 'DRAFT',
  `inspected_by` int(11) DEFAULT NULL,
  `inspection_date` date DEFAULT NULL,
  `inspection_result` enum('PASS','FAIL','CONDITIONAL','PENDING') DEFAULT 'PENDING',
  `inspection_notes` text DEFAULT NULL,
  `fair_value_basis` varchar(200) DEFAULT NULL COMMENT 'IPSAS 12: valuation for donated inventory',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`grn_id`),
  UNIQUE KEY `uk_grn_number` (`grn_number`),
  KEY `idx_grn_po` (`po_reference`),
  CONSTRAINT `fk_grn_receiver` FOREIGN KEY (`received_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- GRN line items
CREATE TABLE IF NOT EXISTS `inv_grn_items` (
  `grn_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `grn_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_ordered` decimal(14,4) DEFAULT 0,
  `quantity_received` decimal(14,4) NOT NULL,
  `quantity_accepted` decimal(14,4) DEFAULT 0,
  `quantity_rejected` decimal(14,4) DEFAULT 0,
  `quantity_short` decimal(14,4) DEFAULT 0,
  `quantity_over` decimal(14,4) DEFAULT 0,
  `quantity_damaged` decimal(14,4) DEFAULT 0,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `manufacturer_date` date DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `destination_location_id` int(11) DEFAULT NULL,
  `inspection_status` enum('PENDING','PASS','FAIL','CONDITIONAL') DEFAULT 'PENDING',
  `quality_notes` text DEFAULT NULL,
  PRIMARY KEY (`grn_item_id`),
  CONSTRAINT `fk_grni_grn` FOREIGN KEY (`grn_id`) REFERENCES `inv_goods_received` (`grn_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_grni_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. STOCK ISSUES
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_issues` (
  `issue_id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_number` varchar(30) NOT NULL,
  `requisition_id` int(11) DEFAULT NULL,
  `issued_to_user_id` int(11) DEFAULT NULL,
  `issued_to_department` int(11) DEFAULT NULL COMMENT 'branch_id',
  `issued_to_project` varchar(100) DEFAULT NULL,
  `issued_to_event` varchar(100) DEFAULT NULL,
  `issued_to_vehicle` varchar(50) DEFAULT NULL,
  `issued_to_building_room` varchar(100) DEFAULT NULL,
  `issue_date` date NOT NULL,
  `issued_by` int(11) NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED') DEFAULT 'DRAFT',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `acknowledgement_signature` text DEFAULT NULL COMMENT 'Digital signature or evidence',
  `acknowledged_at` datetime DEFAULT NULL,
  `delivery_note_number` varchar(50) DEFAULT NULL,
  `dispatch_confirmed` tinyint(1) DEFAULT 0,
  `expense_recognition_event` varchar(50) DEFAULT NULL COMMENT 'IPSAS 12: event triggering expense',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`issue_id`),
  UNIQUE KEY `uk_issue_number` (`issue_number`),
  CONSTRAINT `fk_iss_req` FOREIGN KEY (`requisition_id`) REFERENCES `inv_requisitions` (`requisition_id`),
  CONSTRAINT `fk_iss_by` FOREIGN KEY (`issued_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Issue line items
CREATE TABLE IF NOT EXISTS `inv_issue_items` (
  `issue_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL COMMENT 'Specific stock record (batch/location)',
  `quantity_issued` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_cost` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `is_substitute` tinyint(1) DEFAULT 0,
  `original_item_id` int(11) DEFAULT NULL COMMENT 'If substitute, the originally requested item',
  PRIMARY KEY (`issue_item_id`),
  CONSTRAINT `fk_ii_issue` FOREIGN KEY (`issue_id`) REFERENCES `inv_issues` (`issue_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ii_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. STOCK TRANSFERS
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_transfers` (
  `transfer_id` int(11) NOT NULL AUTO_INCREMENT,
  `transfer_number` varchar(30) NOT NULL,
  `transfer_type` enum('INTERNAL','INTER_BRANCH','INTER_MDA') NOT NULL DEFAULT 'INTERNAL',
  `source_location_id` int(11) NOT NULL,
  `destination_location_id` int(11) NOT NULL,
  `transfer_date` date NOT NULL,
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `financial_secretary_approval` tinyint(1) DEFAULT 0 COMMENT 'Required for inter-MDA transfers',
  `fs_approved_by` varchar(100) DEFAULT NULL,
  `fs_approved_at` datetime DEFAULT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','IN_TRANSIT','RECEIVED','REJECTED','CANCELLED') DEFAULT 'DRAFT',
  `received_by` int(11) DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`transfer_id`),
  UNIQUE KEY `uk_transfer_number` (`transfer_number`),
  CONSTRAINT `fk_xfer_src` FOREIGN KEY (`source_location_id`) REFERENCES `inv_locations` (`location_id`),
  CONSTRAINT `fk_xfer_dst` FOREIGN KEY (`destination_location_id`) REFERENCES `inv_locations` (`location_id`),
  CONSTRAINT `fk_xfer_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transfer line items
CREATE TABLE IF NOT EXISTS `inv_transfer_items` (
  `transfer_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `transfer_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `valuation_at_transfer` decimal(14,2) DEFAULT NULL,
  PRIMARY KEY (`transfer_item_id`),
  CONSTRAINT `fk_ti_xfer` FOREIGN KEY (`transfer_id`) REFERENCES `inv_transfers` (`transfer_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ti_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. STOCK ADJUSTMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_adjustments` (
  `adjustment_id` int(11) NOT NULL AUTO_INCREMENT,
  `adjustment_number` varchar(30) NOT NULL,
  `adjustment_type` enum('GAIN','LOSS') NOT NULL,
  `reason_code` enum('DAMAGE','EXPIRY','COUNT_VARIANCE','BREAKAGE','THEFT','ADMIN_CORRECTION','OTHER') NOT NULL,
  `reason_detail` text DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `requested_by` int(11) NOT NULL,
  `supervisor_approved_by` int(11) DEFAULT NULL,
  `supervisor_approved_at` datetime DEFAULT NULL,
  `review_required` tinyint(1) DEFAULT 0 COMMENT 'For high-value/controlled items',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `investigation_notes` text DEFAULT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','UNDER_INVESTIGATION','REJECTED','COMPLETED') DEFAULT 'DRAFT',
  `total_value_impact` decimal(14,2) DEFAULT 0.00,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`adjustment_id`),
  UNIQUE KEY `uk_adj_number` (`adjustment_number`),
  CONSTRAINT `fk_adj_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Adjustment line items
CREATE TABLE IF NOT EXISTS `inv_adjustment_items` (
  `adj_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `adjustment_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_cost` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`adj_item_id`),
  CONSTRAINT `fk_ai_adj` FOREIGN KEY (`adjustment_id`) REFERENCES `inv_adjustments` (`adjustment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ai_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. DISPOSAL AND WRITE-OFF
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_disposals` (
  `disposal_id` int(11) NOT NULL AUTO_INCREMENT,
  `disposal_number` varchar(30) NOT NULL,
  `disposal_method` enum('DESTRUCTION','AUCTION','TRANSFER','DONATION','RETURN_TO_SUPPLIER','SCRAP','OTHER') NOT NULL,
  `reason` text NOT NULL,
  `survey_assessment` text DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `requested_by` int(11) NOT NULL,
  `recommended_by` int(11) DEFAULT NULL,
  `recommended_at` datetime DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `committee_review_required` tinyint(1) DEFAULT 0,
  `committee_reviewed_by` varchar(200) DEFAULT NULL,
  `committee_reviewed_at` datetime DEFAULT NULL,
  `committee_decision` text DEFAULT NULL,
  `status` enum('DRAFT','RECOMMENDED','PENDING_APPROVAL','APPROVED','COMMITTEE_REVIEW','COMPLETED','REJECTED','CANCELLED') DEFAULT 'DRAFT',
  `proceeds_amount` decimal(14,2) DEFAULT 0.00,
  `proceeds_reference` varchar(100) DEFAULT NULL,
  `total_write_off_value` decimal(14,2) DEFAULT 0.00,
  `evidence_notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`disposal_id`),
  UNIQUE KEY `uk_disp_number` (`disposal_number`),
  CONSTRAINT `fk_disp_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Disposal line items
CREATE TABLE IF NOT EXISTS `inv_disposal_items` (
  `disp_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `disposal_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `serial_number` varchar(100) DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `condition_description` text DEFAULT NULL,
  PRIMARY KEY (`disp_item_id`),
  CONSTRAINT `fk_di_disp` FOREIGN KEY (`disposal_id`) REFERENCES `inv_disposals` (`disposal_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_di_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. STOCK COUNT / PHYSICAL INVENTORY
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_stock_counts` (
  `count_id` int(11) NOT NULL AUTO_INCREMENT,
  `count_number` varchar(30) NOT NULL,
  `count_date` date NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `count_type` enum('FULL','CYCLE','SPOT') DEFAULT 'FULL',
  `conducted_by` int(11) NOT NULL,
  `supervised_by` int(11) DEFAULT NULL,
  `status` enum('PLANNED','IN_PROGRESS','COMPLETED','VARIANCE_REVIEW','CLOSED') DEFAULT 'PLANNED',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`count_id`),
  UNIQUE KEY `uk_count_number` (`count_number`),
  CONSTRAINT `fk_sc_by` FOREIGN KEY (`conducted_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stock count items
CREATE TABLE IF NOT EXISTS `inv_stock_count_items` (
  `count_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `count_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `system_quantity` decimal(14,4) NOT NULL,
  `counted_quantity` decimal(14,4) NOT NULL,
  `variance` decimal(14,4) GENERATED ALWAYS AS (`counted_quantity` - `system_quantity`) STORED,
  `variance_reason` text DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`count_item_id`),
  CONSTRAINT `fk_sci_count` FOREIGN KEY (`count_id`) REFERENCES `inv_stock_counts` (`count_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sci_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 15. TRANSACTION LEDGER (immutable stock movement history)
-- ============================================================

CREATE TABLE IF NOT EXISTS `inv_transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_type` enum('RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN','ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST','RETURN') NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_cost` decimal(14,2) DEFAULT 0.00,
  `balance_after` decimal(14,4) DEFAULT NULL COMMENT 'Running balance at location',
  `reference_type` varchar(30) DEFAULT NULL COMMENT 'GRN, ISSUE, TRANSFER, etc.',
  `reference_id` int(11) DEFAULT NULL,
  `reference_number` varchar(30) DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_txn_item` (`item_id`),
  KEY `idx_txn_type` (`transaction_type`),
  KEY `idx_txn_ref` (`reference_type`, `reference_id`),
  KEY `idx_txn_date` (`created_at`),
  CONSTRAINT `fk_txn_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. INVENTORY PERMISSIONS (seed)
-- ============================================================

INSERT INTO `permissions` (`name`, `description`) VALUES
('view_inventory', 'View inventory items and stock levels'),
('manage_inventory_items', 'Create and edit inventory item master data'),
('manage_inventory_locations', 'Manage storage locations'),
('submit_stock_requisition', 'Submit stock requisitions'),
('approve_stock_requisition', 'Approve stock requisitions'),
('receive_goods', 'Record goods received notes'),
('inspect_goods', 'Perform goods inspection'),
('issue_stock', 'Issue stock from stores'),
('approve_stock_issue', 'Approve stock issues for controlled items'),
('create_transfer', 'Create stock transfers'),
('approve_transfer', 'Approve stock transfers'),
('create_adjustment', 'Create stock adjustments'),
('approve_adjustment', 'Approve stock adjustments'),
('create_disposal', 'Create disposal/write-off requests'),
('approve_disposal', 'Approve disposals and write-offs'),
('conduct_stock_count', 'Conduct physical stock counts'),
('manage_inv_roles', 'Manage inventory user roles'),
('view_inv_reports', 'View inventory reports'),
('manage_inv_delegations', 'Manage inventory delegations'),
('inventory_admin', 'Full inventory administration access')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- Grant inventory permissions to key roles
-- SuperAdmin (role 6) and Admin (role 5) get all via code
-- Finance Officer (role 3)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 3, id FROM `permissions` WHERE `name` IN ('view_inventory', 'view_inv_reports');

-- Procurement Officer (role 2)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 2, id FROM `permissions` WHERE `name` IN ('view_inventory', 'receive_goods', 'view_inv_reports');

-- HOD (role 4)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 4, id FROM `permissions` WHERE `name` IN ('view_inventory', 'approve_stock_requisition', 'approve_stock_issue', 'approve_transfer', 'approve_adjustment', 'view_inv_reports');

-- Requestor (role 12)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 12, id FROM `permissions` WHERE `name` IN ('view_inventory', 'submit_stock_requisition');

SET FOREIGN_KEY_CHECKS = 1;
