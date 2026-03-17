-- Migration: Add Signed Request Support
-- Date: 2026-03-17
-- Description: Add columns and document type for branch head signed requests

-- Add signed_request columns to procurement_requests if they don't exist
ALTER TABLE `procurement_requests` 
ADD COLUMN IF NOT EXISTS `signed_request_document_path` VARCHAR(255) DEFAULT NULL COMMENT 'Path to uploaded signed request by branch head' AFTER `decline_reason`,
ADD COLUMN IF NOT EXISTS `signed_request_received_date` DATETIME DEFAULT NULL COMMENT 'Date when signed request was received' AFTER `signed_request_document_path`,
ADD COLUMN IF NOT EXISTS `signed_by_user_id` INT(11) DEFAULT NULL COMMENT 'User ID of person who signed the request' AFTER `signed_request_received_date`;

-- Update request_documents table to support SIGNED_REQUEST type (if not already supported)
-- The table already has a document_type column, just ensure it can accept SIGNED_REQUEST
-- No changes needed to the table structure - just document the new type
