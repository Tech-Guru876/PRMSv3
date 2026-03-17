-- ============================================================================
-- Migration: Fix request_type Enum in procurement_requests Table
-- Database: u153072617_prms
-- Date: 2026-03-17
-- Purpose: Ensure request_type enum supports REGULAR, REIMBURSEMENT, PETTY_CASH
--          and remove incorrect EXPEDITED, EMERGENCY values
-- ============================================================================

-- Check current status
-- SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME='procurement_requests' AND COLUMN_NAME='request_type';

-- Modify the request_type enum to support all three types
-- MySQL requires recreating the constraint when changing enum values
ALTER TABLE `procurement_requests` 
MODIFY COLUMN `request_type` ENUM('REGULAR', 'REIMBURSEMENT', 'PETTY_CASH') 
NOT NULL DEFAULT 'REGULAR' 
COMMENT 'Type of request: REGULAR procurement, REIMBURSEMENT, or PETTY_CASH';

-- Verify update
-- SELECT DISTINCT request_type FROM procurement_requests;

-- ============================================================================
-- CONFIRMATION QUERY (Run after migration to verify)
-- ============================================================================
-- SELECT 
--   COUNT(*) as total_requests,
--   SUM(CASE WHEN request_type='REGULAR' THEN 1 ELSE 0 END) as regular,
--   SUM(CASE WHEN request_type='REIMBURSEMENT' THEN 1 ELSE 0 END) as reimbursement,
--   SUM(CASE WHEN request_type='PETTY_CASH' THEN 1 ELSE 0 END) as petty_cash
-- FROM procurement_requests;
