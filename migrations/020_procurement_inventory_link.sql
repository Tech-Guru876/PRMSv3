-- ============================================================
-- Migration 020: Procurement–Inventory Link
-- Adds a foreign-key reference from inventory GRNs to POs
-- and a helper table for inventory requisitions that escalate
-- to procurement requests.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ── 1. Link inventory GRNs to procurement purchase orders ────
--    The inv_goods_received table already stores po_reference
--    (a free-text PO number).  This column adds a proper FK so
--    that GRNs created from PRMS POs are traceable both ways.

-- Step 1a: Add column
ALTER TABLE `inv_goods_received`
    ADD COLUMN IF NOT EXISTS `procurement_po_id` int(11) DEFAULT NULL
        COMMENT 'FK to purchase_orders.po_id when GRN originates from a PRMS PO';

-- Step 1b: Add index
ALTER TABLE `inv_goods_received`
    ADD KEY IF NOT EXISTS `idx_grn_po_id` (`procurement_po_id`);

-- Step 1c: Add foreign key constraint
ALTER TABLE `inv_goods_received`
    ADD CONSTRAINT `fk_grn_procurement_po`
        FOREIGN KEY (`procurement_po_id`)
        REFERENCES `purchase_orders` (`po_id`)
        ON DELETE SET NULL ON UPDATE CASCADE;

-- ── 2. Escalation table: inventory requisitions → procurement ─
--    When an inventory requisition cannot be fulfilled from
--    current stock, store officers can escalate it to create
--    a procurement request automatically.

CREATE TABLE IF NOT EXISTS `inv_procurement_escalations` (
    `escalation_id`     int(11)       NOT NULL AUTO_INCREMENT,
    `inv_requisition_id` int(11)      NOT NULL COMMENT 'FK to inv_requisitions',
    `procurement_request_id` int(11)  DEFAULT NULL COMMENT 'FK to procurement_requests',
    `escalated_by`      int(11)       NOT NULL COMMENT 'FK to users',
    `escalated_at`      timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `escalation_notes`  text          DEFAULT NULL,
    `status`            enum('OPEN','LINKED','CANCELLED') NOT NULL DEFAULT 'OPEN',
    `resolved_at`       timestamp     DEFAULT NULL,
    PRIMARY KEY (`escalation_id`),
    KEY `idx_esc_inv_req`  (`inv_requisition_id`),
    KEY `idx_esc_proc_req` (`procurement_request_id`),
    CONSTRAINT `fk_esc_inv_req`  FOREIGN KEY (`inv_requisition_id`)
        REFERENCES `inv_requisitions` (`requisition_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_esc_proc_req` FOREIGN KEY (`procurement_request_id`)
        REFERENCES `procurement_requests` (`request_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Links inventory requisitions that require procurement action';

SET FOREIGN_KEY_CHECKS = 1;
