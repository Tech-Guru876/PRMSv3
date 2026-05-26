-- ============================================================================
-- Migration: Asset Room Registry, Condition/Depreciation Cadence, Movement Log
-- ============================================================================
-- Purpose:
--   1) Add PMO asset status values and review cadence fields on inv_serial_numbers
--   2) Track purchase/current values for periodic depreciation updates
--   3) Create inv_asset_movements to keep room/location movement history
-- ============================================================================

ALTER TABLE `inv_serial_numbers`
  ADD COLUMN IF NOT EXISTS `asset_status` enum(
    'NEW','LIKE_NEW','USED','POOR','DAMAGED','GOOD','REPAIRED','SERVICED',
    'TO_BE_DISPOSED','BOARD_OF_SURVEY_ITEM','DONATED','SOLD'
  ) NOT NULL DEFAULT 'NEW' AFTER `lifecycle_status`,
  ADD COLUMN IF NOT EXISTS `condition_last_updated_at` date DEFAULT NULL AFTER `current_condition`,
  ADD COLUMN IF NOT EXISTS `next_condition_review_due_date` date DEFAULT NULL AFTER `condition_last_updated_at`,
  ADD COLUMN IF NOT EXISTS `purchase_value` decimal(14,2) DEFAULT NULL AFTER `next_condition_review_due_date`,
  ADD COLUMN IF NOT EXISTS `current_book_value` decimal(14,2) DEFAULT NULL AFTER `purchase_value`,
  ADD COLUMN IF NOT EXISTS `depreciation_last_updated_at` date DEFAULT NULL AFTER `current_book_value`,
  ADD COLUMN IF NOT EXISTS `next_depreciation_review_due_date` date DEFAULT NULL AFTER `depreciation_last_updated_at`;

CREATE TABLE IF NOT EXISTS `inv_asset_movements` (
  `movement_id`          int(11) NOT NULL AUTO_INCREMENT,
  `serial_id`            int(11) NOT NULL,
  `from_location_id`     int(11) DEFAULT NULL,
  `to_location_id`       int(11) DEFAULT NULL,
  `moved_at`             datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `movement_reason`      varchar(255) DEFAULT NULL,
  `moved_by`             int(11) DEFAULT NULL,
  `notes`                text DEFAULT NULL,
  `created_at`           timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`movement_id`),
  KEY `idx_asset_move_serial` (`serial_id`),
  KEY `idx_asset_move_moved_at` (`moved_at`),
  KEY `idx_asset_move_to_loc` (`to_location_id`),
  CONSTRAINT `fk_asset_move_serial` FOREIGN KEY (`serial_id`) REFERENCES `inv_serial_numbers` (`serial_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asset_move_from_loc` FOREIGN KEY (`from_location_id`) REFERENCES `inv_locations` (`location_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_asset_move_to_loc` FOREIGN KEY (`to_location_id`) REFERENCES `inv_locations` (`location_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_asset_move_user` FOREIGN KEY (`moved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Movement history of serialized assets between room/location registers';
