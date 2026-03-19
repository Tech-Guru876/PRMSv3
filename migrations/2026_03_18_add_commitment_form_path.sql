-- Migration: Add commitment_form_path to procurement_requests
-- Purpose: Store the optional commitment form uploaded by Procurement Officers
--          Finance will use this reference when creating the commitment in GFMS
-- Date: 2026-03-18

ALTER TABLE procurement_requests
    ADD COLUMN IF NOT EXISTS commitment_form_path VARCHAR(500) NULL DEFAULT NULL
        COMMENT 'Optional scanned commitment form uploaded by Procurement Officer (Finance will create actual commitment in GFMS)'
    AFTER funds_available;
