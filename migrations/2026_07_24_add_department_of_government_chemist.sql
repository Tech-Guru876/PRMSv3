-- Migration: Add "Department of Government Chemist" as a branch/department option
-- Date: 2026-07-24

INSERT INTO `branches` (`branch_name`, `is_active`)
VALUES ('Department of Government Chemist', 1);
