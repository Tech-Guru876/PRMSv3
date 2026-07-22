-- =============================================================================
-- PRMS v3 — Combined Schema Script
-- Generated from: prmsv2.sql (base schema) + all migrations in LC_ALL=C order
--
-- Idempotent — safe to run against an existing MariaDB database:
--   • CREATE TABLE IF NOT EXISTS     — skips tables that already exist
--   • ADD COLUMN IF NOT EXISTS       — skips columns that already exist
--   • ADD KEY / INDEX IF NOT EXISTS  — skips indexes that already exist
--   • ADD CONSTRAINT IF NOT EXISTS   — skips constraints that already exist
--   • INSERT IGNORE                  — skips duplicate rows silently
--   • DROP TRIGGER IF EXISTS         — recreates triggers safely
--
-- Target: MariaDB 10.5+ (developed on 11.8.6-MariaDB)
--
-- Usage:
--   mysql -u <user> -p <database> < deploy/combined_schema.sql
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';

-- ═══════════════════════════════════════════════════════════════════════
-- BASE SCHEMA  (prmsv2.sql)
-- ═══════════════════════════════════════════════════════════════════════

--
-- Table structure for table `acting_roles`
--

CREATE TABLE IF NOT EXISTS `acting_roles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `acting_role_id` int(11) NOT NULL COMMENT 'The role this user can act in',
  `assigned_by` int(11) NOT NULL COMMENT 'Admin who created the assignment',
  `reason` varchar(255) DEFAULT NULL COMMENT 'e.g. "Leave cover for J. Smith"',
  `starts_at` datetime NOT NULL DEFAULT current_timestamp(),
  `ends_at` datetime DEFAULT NULL COMMENT 'NULL = indefinite until manually revoked',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `acting_roles`
--

INSERT IGNORE INTO `acting_roles` (`id`, `user_id`, `acting_role_id`, `assigned_by`, `reason`, `starts_at`, `ends_at`, `is_active`, `created_at`) VALUES
(10, 27, 4, 27, NULL, '2026-03-17 11:51:00', NULL, 0, '2026-03-17 11:51:15'),
(11, 30, 3, 27, NULL, '2026-03-18 09:47:00', NULL, 0, '2026-03-18 09:48:06'),
(12, 27, 3, 27, NULL, '2026-03-18 09:48:00', NULL, 0, '2026-03-18 09:48:48'),
(13, 27, 11, 27, NULL, '2026-03-18 12:55:00', NULL, 0, '2026-03-18 12:56:09'),
(14, 42, 2, 27, 'acting procurement officer', '2026-04-07 09:52:00', '2026-08-28 09:53:00', 1, '2026-04-07 09:51:58'),
(16, 40, 5, 27, NULL, '2026-05-13 10:11:00', NULL, 0, '2026-05-13 10:13:56');

-- --------------------------------------------------------

--
-- Table structure for table `acting_role_log`
--

CREATE TABLE IF NOT EXISTS `acting_role_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `switched_from_role_id` int(11) NOT NULL,
  `switched_to_role_id` int(11) NOT NULL,
  `is_acting` tinyint(1) NOT NULL COMMENT '1=switched to acting, 0=reverted to primary',
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `acting_role_log`
--

INSERT IGNORE INTO `acting_role_log` (`id`, `user_id`, `switched_from_role_id`, `switched_to_role_id`, `is_acting`, `ip_address`, `created_at`) VALUES
(42, 27, 6, 4, 1, '67.230.76.197', '2026-03-17 11:51:19'),
(43, 27, 6, 4, 1, '67.230.76.197', '2026-03-17 12:12:58'),
(44, 27, 4, 6, 0, '67.230.76.197', '2026-03-17 12:14:06'),
(45, 27, 6, 4, 1, '67.230.76.197', '2026-03-18 09:48:18'),
(46, 27, 4, 6, 0, '67.230.76.197', '2026-03-18 09:48:26'),
(47, 27, 6, 3, 1, '67.230.76.197', '2026-03-18 09:49:01'),
(48, 27, 3, 6, 0, '67.230.76.197', '2026-03-18 09:57:27'),
(49, 27, 6, 3, 1, '67.230.76.197', '2026-03-18 11:07:48'),
(50, 27, 3, 6, 0, '67.230.76.197', '2026-03-18 11:20:33'),
(51, 27, 6, 3, 1, '67.230.76.197', '2026-03-18 11:52:29'),
(52, 27, 6, 11, 1, '67.230.76.197', '2026-03-18 12:56:14'),
(53, 27, 6, 4, 1, '67.230.76.197', '2026-03-18 12:57:03'),
(54, 27, 4, 11, 1, '67.230.76.197', '2026-03-18 13:00:13'),
(55, 27, 11, 6, 0, '67.230.76.197', '2026-03-18 13:00:43'),
(56, 27, 6, 11, 1, '67.230.76.197', '2026-03-19 09:00:43'),
(57, 27, 11, 3, 1, '67.230.76.197', '2026-03-19 09:03:22'),
(58, 27, 3, 11, 1, '67.230.76.197', '2026-03-19 09:08:39'),
(59, 27, 11, 6, 0, '67.230.76.197', '2026-03-19 09:10:05'),
(60, 27, 6, 3, 1, '67.230.76.197', '2026-03-19 09:11:04'),
(61, 27, 3, 6, 0, '67.230.76.197', '2026-03-19 09:11:12'),
(62, 27, 6, 11, 1, '67.230.76.197', '2026-03-19 09:11:59'),
(63, 27, 11, 6, 0, '67.230.76.197', '2026-03-19 09:12:07'),
(64, 27, 6, 11, 1, '67.230.76.197', '2026-03-19 09:13:34'),
(65, 27, 11, 3, 1, '67.230.76.197', '2026-03-19 09:14:43'),
(66, 27, 3, 11, 1, '67.230.76.197', '2026-03-19 09:14:51'),
(67, 27, 11, 3, 1, '67.230.76.197', '2026-03-19 09:15:44'),
(68, 27, 6, 3, 1, '72.252.32.165', '2026-03-22 08:29:01'),
(69, 42, 12, 2, 1, '67.230.76.197', '2026-04-07 09:52:11'),
(70, 27, 6, 4, 1, '67.213.150.200', '2026-05-01 17:16:34'),
(71, 27, 6, 3, 1, '67.213.149.6', '2026-05-04 17:48:22'),
(72, 27, 3, 6, 0, '67.213.149.6', '2026-05-04 17:48:48'),
(73, 40, 12, 5, 1, '67.230.76.197', '2026-05-13 10:14:22');

-- --------------------------------------------------------

--
-- Table structure for table `approval_rules`
--

CREATE TABLE IF NOT EXISTS `approval_rules` (
  `id` int(11) NOT NULL,
  `min_amount` decimal(15,2) DEFAULT NULL,
  `max_amount` decimal(15,2) DEFAULT NULL,
  `procurement_type` enum('goods','services','works') DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `stage_order` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approval_steps`
--

CREATE TABLE IF NOT EXISTS `approval_steps` (
  `step_id` int(11) NOT NULL,
  `workflow_id` int(11) NOT NULL,
  `step_order` int(11) NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_steps`
--

INSERT IGNORE INTO `approval_steps` (`step_id`, `workflow_id`, `step_order`, `role_id`, `is_mandatory`) VALUES
(3, 3, 1, 3, 1),
(4, 9, 2, 9, 1),
(11, 3, 1, 3, 1),
(12, 7, 2, NULL, 1),
(13, 8, 3, 8, 1),
(14, 9, 4, 9, 1);

-- --------------------------------------------------------

--
-- Table structure for table `approval_transactions`
--

CREATE TABLE IF NOT EXISTS `approval_transactions` (
  `transaction_id` int(11) NOT NULL,
  `entity_type` enum('PROCUREMENT_REQUEST','RFQ','COMMITMENT','PO','INVOICE') DEFAULT NULL,
  `entity_id` int(11) NOT NULL,
  `step_id` int(11) NOT NULL,
  `approved_by` int(11) NOT NULL,
  `decision` enum('APPROVED','REJECTED') DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `decision_date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approval_workflows`
--

CREATE TABLE IF NOT EXISTS `approval_workflows` (
  `workflow_id` int(11) NOT NULL,
  `entity_type` enum('PROCUREMENT_REQUEST','RFQ','COMMITMENT','PO','INVOICE') NOT NULL,
  `min_amount` decimal(15,2) DEFAULT 0.00,
  `max_amount` decimal(15,2) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_workflows`
--

INSERT IGNORE INTO `approval_workflows` (`workflow_id`, `entity_type`, `min_amount`, `max_amount`, `description`, `is_active`) VALUES
(1, 'PROCUREMENT_REQUEST', 0.00, 3000000.00, 'Single Source Workflow', 1),
(2, 'PROCUREMENT_REQUEST', 3000000.01, 20000000.00, 'Restricted Bidding Workflow', 1),
(3, 'PROCUREMENT_REQUEST', 20000000.01, NULL, 'National Competitive Workflow', 1);

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE IF NOT EXISTS `audit_log` (
  `audit_id` int(11) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `action` varchar(20) DEFAULT NULL,
  `changed_by` varchar(100) DEFAULT NULL COMMENT 'Full name of user who made the change',
  `change_date` timestamp NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_log`
--

INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(55, 'procurement_requests', 18, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-30 22:22:20', 'Submitted → Declined'),
(56, 'procurement_requests', 16, 'STATUS_CHANGE', NULL, '2026-01-30 22:27:24', 'Submitted → Declined'),
(57, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-30 23:27:51', 'Back-dating of Commitment was attempted'),
(58, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-30 23:37:14', 'Back-dating of Commitment was attempted'),
(59, 'procurement_requests', 19, 'STATUS_CHANGE', NULL, '2026-01-30 23:40:17', 'Draft → Submitted'),
(60, 'users', 13, 'CREATE', 'Technical & User Support Officer', '2026-01-30 23:42:49', 'User created by admin'),
(61, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-01-30 23:43:10', 'Password updated'),
(62, 'procurement_requests', 20, 'STATUS_CHANGE', NULL, '2026-01-30 23:43:42', 'Draft → Submitted'),
(63, 'procurement_requests', 20, 'STATUS_CHANGE', NULL, '2026-01-30 23:44:35', 'Submitted → Declined'),
(64, 'procurement_requests', 22, 'STATUS_CHANGE', NULL, '2026-01-31 00:02:15', 'Draft → Submitted'),
(65, 'procurement_requests', 21, 'STATUS_CHANGE', NULL, '2026-01-31 00:02:22', 'Draft → Submitted'),
(66, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 00:03:30', 'Back-dating of procurement request was attempted'),
(67, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 00:05:41', 'Back-dating of Commitment was attempted'),
(68, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 00:06:09', 'Back-dating of Commitment was attempted'),
(69, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 00:11:39', 'Back-dating of procurement request was attempted'),
(70, 'procurement_requests', 23, 'STATUS_CHANGE', NULL, '2026-01-31 00:18:57', 'Draft → Submitted'),
(71, 'procurement_requests', 23, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 00:19:38', 'Submitted → Approved'),
(72, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 00:20:31', 'Back-dating of procurement request was attempted'),
(73, 'procurement_requests', 24, 'STATUS_CHANGE', NULL, '2026-01-31 01:23:34', 'Draft → Submitted'),
(74, 'procurement_requests', 19, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 01:45:33', 'Submitted → Approved'),
(75, 'procurement_requests', 21, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 01:45:43', 'Submitted → Approved'),
(76, 'procurement_requests', 22, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 01:45:49', 'Submitted → Approved'),
(77, 'procurement_requests', 24, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 01:45:57', 'Submitted → Approved'),
(78, 'procurement_requests', 25, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 01:46:27', 'Draft → Submitted'),
(79, 'procurement_requests', 26, 'STATUS_CHANGE', NULL, '2026-01-31 15:59:30', 'Draft → Submitted'),
(80, 'procurement_requests', 26, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 16:00:00', 'Submitted → Approved'),
(81, 'procurement_requests', 25, 'STATUS_CHANGE', NULL, '2026-01-31 16:55:15', 'Submitted → Approved'),
(82, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-01-31 16:55:31', 'Back-dating of Commitment was attempted'),
(83, 'procurement_requests', 27, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 20:17:35', 'Draft → Submitted'),
(84, 'procurement_requests', 28, 'STATUS_CHANGE', NULL, '2026-01-31 21:24:16', 'Draft → Submitted'),
(85, 'procurement_requests', 28, 'STATUS_CHANGE', NULL, '2026-01-31 21:24:41', 'Submitted → Approved'),
(86, 'commitments', 14, 'CREATE', NULL, '2026-01-31 21:24:53', 'Commitment created'),
(87, 'purchase_orders', 14, 'CREATE', NULL, '2026-01-31 21:25:04', 'Purchase Order created'),
(88, 'invoices', 19, 'CREATE', NULL, '2026-01-31 21:25:26', 'Invoice created'),
(89, 'payments', 23, 'CREATE', NULL, '2026-01-31 21:56:58', 'Payment recorded'),
(90, 'payments', 24, 'CREATE', NULL, '2026-01-31 21:57:51', 'Payment recorded'),
(91, 'payments', 25, 'CREATE', NULL, '2026-01-31 21:58:19', 'Payment recorded'),
(92, 'payments', 26, 'CREATE', NULL, '2026-01-31 21:58:45', 'Payment recorded'),
(93, 'procurement_requests', 29, 'STATUS_CHANGE', NULL, '2026-01-31 22:08:59', 'Draft → Submitted'),
(94, 'procurement_requests', 29, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-01-31 22:10:59', 'Submitted → Approved'),
(95, 'commitments', 15, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:11:52', 'Commitment created'),
(96, 'purchase_orders', 15, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:12:18', 'Purchase Order created'),
(97, 'invoices', 20, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:13:12', 'Invoice created'),
(98, 'invoices', 21, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:13:33', 'Invoice created'),
(99, 'payments', 27, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:14:37', 'Payment recorded'),
(100, 'payments', 28, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:14:57', 'Payment recorded'),
(101, 'payments', 29, 'CREATE', 'Technical & User Support Officer', '2026-01-31 22:15:30', 'Payment recorded'),
(102, 'procurement_requests', 30, 'STATUS_CHANGE', NULL, '2026-01-31 22:54:29', 'Draft → Submitted'),
(103, 'users', 14, 'CREATE', 'Technical & User Support Officer', '2026-02-01 02:03:11', 'User created by admin'),
(104, 'users', 2, 'ADMIN_PASSWORD_RESET', NULL, '2026-02-01 19:47:15', 'Admin reset user password'),
(105, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-01 19:47:39', 'Password updated'),
(106, 'procurement_requests', 31, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-01 20:41:21', 'Draft → Submitted'),
(107, 'procurement_requests', 31, 'STATUS_CHANGE', NULL, '2026-02-01 22:40:08', 'Submitted → Approved'),
(108, 'commitments', 16, 'CREATE', NULL, '2026-02-01 22:40:23', 'Commitment created'),
(109, 'purchase_orders', 16, 'CREATE', NULL, '2026-02-01 22:45:36', 'Purchase Order created'),
(110, 'users', 12, 'ROLE_CHANGE', NULL, '2026-02-02 01:00:38', 'Role updated to Procurement'),
(111, 'users', 11, 'ROLE_CHANGE', NULL, '2026-02-02 01:01:49', 'Role updated to Procurement'),
(112, 'users', 12, 'STATUS_TOGGLE', NULL, '2026-02-02 01:14:57', 'User disabled'),
(113, 'users', 12, 'STATUS_TOGGLE', NULL, '2026-02-02 01:15:46', 'User re-enabled'),
(114, 'users', 4, 'ROLE_CHANGE', NULL, '2026-02-02 01:17:27', 'Role updated to Procurement'),
(115, 'users', 15, 'CREATE', NULL, '2026-02-02 03:05:18', 'User created by admin'),
(116, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-02 03:06:12', 'Password updated'),
(117, 'invoices', 22, 'CREATE', NULL, '2026-02-02 12:51:40', 'Invoice created'),
(118, 'procurement_requests', 32, 'STATUS_CHANGE', NULL, '2026-02-02 14:14:14', 'Draft → Submitted'),
(119, 'procurement_requests', NULL, 'CREATE', NULL, '2026-02-02 14:19:10', NULL),
(120, 'procurement_requests', 33, 'STATUS_CHANGE', NULL, '2026-02-02 14:20:49', 'Draft → Submitted'),
(121, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', NULL, '2026-02-02 14:27:41', 'Back-dating of procurement request was attempted'),
(122, 'procurement_requests', 34, 'CREATE', 'Technical & User Support Officer', '2026-02-02 14:53:17', 'Procurement request created'),
(123, 'procurement_requests', 35, 'CREATE', 'Technical & User Support Officer', '2026-02-02 14:56:26', 'Procurement request created'),
(124, 'procurement_requests', 36, 'CREATE', 'Technical & User Support Officer', '2026-02-02 14:59:20', 'Procurement request created'),
(125, 'procurement_requests', 34, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:00:47', 'Draft → Submitted'),
(126, 'procurement_requests', 36, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:01:10', 'Draft → Submitted'),
(127, 'procurement_requests', 35, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:01:28', 'Draft → Submitted'),
(128, 'procurement_requests', 37, 'CREATE', 'Technical & User Support Officer', '2026-02-02 15:12:27', 'Procurement request created'),
(129, 'procurement_requests', 38, 'CREATE', 'Technical & User Support Officer', '2026-02-02 15:14:11', 'Procurement request created'),
(130, 'procurement_requests', 39, 'CREATE', 'Technical & User Support Officer', '2026-02-02 15:20:58', 'Procurement request created'),
(131, 'procurement_requests', 39, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:23:49', 'Draft → Submitted'),
(132, 'procurement_requests', 38, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:24:17', 'Draft → Submitted'),
(133, 'procurement_requests', 37, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 15:24:32', 'Draft → Submitted'),
(134, 'procurement_requests', 40, 'CREATE', NULL, '2026-02-02 15:32:45', 'Procurement request created'),
(135, 'procurement_requests', 37, 'STATUS_CHANGE', NULL, '2026-02-02 15:40:39', 'Submitted → Approved'),
(136, 'procurement_requests', 36, 'STATUS_CHANGE', NULL, '2026-02-02 15:53:50', 'Submitted → Approved'),
(137, 'procurement_requests', 35, 'STATUS_CHANGE', NULL, '2026-02-02 15:56:29', 'Submitted → Approved'),
(138, 'procurement_requests', 40, 'STATUS_CHANGE', NULL, '2026-02-02 16:23:19', 'Draft → Submitted'),
(139, 'procurement_requests', 41, 'CREATE', 'Technical & User Support Officer', '2026-02-02 16:24:10', 'Procurement request created'),
(140, 'procurement_requests', 41, 'STATUS_CHANGE', NULL, '2026-02-02 16:24:45', 'Draft → Submitted'),
(141, 'procurement_requests', 41, 'STATUS_CHANGE', NULL, '2026-02-02 16:24:49', 'Submitted → Approved'),
(142, 'commitments', 19, 'CREATE', NULL, '2026-02-02 16:30:26', 'Commitment created'),
(143, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:30:49', 'PO attempted before approval'),
(144, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:30:56', 'PO attempted before approval'),
(145, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:31:04', 'PO attempted before approval'),
(146, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:31:25', 'PO attempted before approval'),
(147, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:32:07', 'PO attempted before approval'),
(148, 'POLICY', NULL, 'BLOCKED_PO', NULL, '2026-02-02 16:32:23', 'PO attempted before approval'),
(149, 'purchase_orders', 17, 'CREATE', NULL, '2026-02-02 16:38:13', 'Purchase Order created'),
(150, 'purchase_orders', 18, 'CREATE', NULL, '2026-02-02 16:47:26', 'Purchase Order created'),
(151, 'purchase_orders', 19, 'CREATE', NULL, '2026-02-02 16:49:26', 'Purchase Order created'),
(152, 'procurement_requests', 34, 'STATUS_CHANGE', NULL, '2026-02-02 16:50:13', 'Submitted → Approved'),
(153, 'commitments', 20, 'CREATE', NULL, '2026-02-02 16:50:40', 'Commitment created'),
(154, 'purchase_orders', 20, 'CREATE', NULL, '2026-02-02 16:51:16', 'Purchase Order created'),
(155, 'invoices', 25, 'CREATE', NULL, '2026-02-02 17:03:20', 'Invoice created'),
(156, 'invoices', 26, 'CREATE', NULL, '2026-02-02 17:04:09', 'Invoice created'),
(157, 'users', 4, 'ROLE_CHANGE', NULL, '2026-02-02 17:30:59', 'Role updated to Admin'),
(158, 'users', 4, 'ROLE_CHANGE', NULL, '2026-02-02 17:32:50', 'Role updated to SuperAdmin'),
(159, 'users', 4, 'ROLE_CHANGE', NULL, '2026-02-02 17:36:43', 'Role updated to Admin'),
(160, 'users', 13, 'ROLE_CHANGE', NULL, '2026-02-02 17:36:59', 'Role updated to Finance'),
(161, 'commitments', 21, 'CREATE', NULL, '2026-02-02 17:39:13', 'Commitment created'),
(162, 'purchase_orders', 21, 'CREATE', NULL, '2026-02-02 17:39:22', 'Purchase Order created'),
(163, 'purchase_orders', 22, 'CREATE', NULL, '2026-02-02 17:41:07', 'Purchase Order created'),
(164, 'procurement_requests', 33, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 18:45:42', 'Submitted → Approved'),
(165, 'procurement_requests', 40, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 18:45:54', 'Submitted → Approved'),
(166, 'purchase_orders', 23, 'CREATE', 'Technical & User Support Officer', '2026-02-02 18:46:28', 'Purchase Order created'),
(167, 'purchase_orders', 24, 'CREATE', 'Technical & User Support Officer', '2026-02-02 18:46:54', 'Purchase Order created'),
(168, 'procurement_requests', 32, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-02 18:48:08', 'Submitted → Approved'),
(169, 'users', 15, 'ADMIN_PASSWORD_RESET', NULL, '2026-02-03 00:38:50', 'Admin reset user password'),
(170, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-03 00:39:14', 'Password updated'),
(171, 'procurement_requests', 42, 'CREATE', NULL, '2026-02-03 00:48:55', 'Procurement request created'),
(172, 'procurement_requests', 42, 'STATUS_CHANGE', NULL, '2026-02-03 00:49:03', 'Draft → Submitted'),
(173, 'procurement_requests', 42, 'STATUS_CHANGE', NULL, '2026-02-03 00:49:34', 'Submitted → Approved'),
(174, 'users', 15, 'ROLE_CHANGE', NULL, '2026-02-03 00:50:05', 'Role updated to Procurement'),
(175, 'commitments', 22, 'CREATE', NULL, '2026-02-03 00:50:33', 'Commitment created'),
(176, 'purchase_orders', 25, 'CREATE', NULL, '2026-02-03 00:50:42', 'Purchase Order created'),
(177, 'invoices', 27, 'CREATE', NULL, '2026-02-03 00:51:02', 'Invoice created'),
(178, 'users', 15, 'ROLE_CHANGE', NULL, '2026-02-03 00:52:00', 'Role updated to Finance'),
(179, 'purchase_orders', 26, 'CREATE', NULL, '2026-02-03 01:15:52', 'Purchase Order created'),
(180, 'invoices', 28, 'CREATE', NULL, '2026-02-03 01:31:04', 'Invoice created'),
(181, 'payments', 30, 'CREATE', NULL, '2026-02-03 01:33:36', 'Payment recorded'),
(182, 'payments', 31, 'CREATE', NULL, '2026-02-03 01:34:53', 'Payment recorded'),
(183, 'payments', 32, 'CREATE', NULL, '2026-02-03 01:35:13', 'Payment recorded'),
(184, 'payments', 33, 'CREATE', NULL, '2026-02-03 01:35:33', 'Payment recorded'),
(185, 'POLICY', NULL, 'OVERPAY_ATTEMPT', NULL, '2026-02-03 01:35:49', 'Payment exceeds invoice balance'),
(186, 'procurement_requests', 43, 'CREATE', NULL, '2026-02-03 01:42:42', 'Procurement request created'),
(187, 'procurement_requests', 43, 'STATUS_CHANGE', NULL, '2026-02-03 01:42:48', 'Draft → Submitted'),
(188, 'procurement_requests', 43, 'STATUS_CHANGE', NULL, '2026-02-03 01:46:01', 'Submitted → Approved'),
(189, 'procurement_requests', 44, 'CREATE', NULL, '2026-02-03 01:46:30', 'Procurement request created'),
(190, 'procurement_requests', 44, 'STATUS_CHANGE', NULL, '2026-02-03 01:46:37', 'Draft → Submitted'),
(191, 'procurement_requests', 44, 'STATUS_CHANGE', NULL, '2026-02-03 01:47:10', 'Submitted → Approved'),
(192, 'commitments', 23, 'CREATE', NULL, '2026-02-03 01:47:49', 'Commitment created'),
(193, 'purchase_orders', 27, 'CREATE', NULL, '2026-02-03 01:47:58', 'Purchase Order created'),
(194, 'payments', 34, 'CREATE', NULL, '2026-02-03 01:48:43', 'Payment recorded'),
(195, 'invoices', 29, 'CREATE', NULL, '2026-02-03 01:50:23', 'Invoice created'),
(196, 'invoices', 30, 'CREATE', NULL, '2026-02-03 01:51:05', 'Invoice created'),
(197, 'invoices', 31, 'CREATE', NULL, '2026-02-03 01:51:35', 'Invoice created'),
(198, 'payments', 35, 'CREATE', NULL, '2026-02-03 01:52:12', 'Payment recorded'),
(199, 'procurement_requests', 45, 'CREATE', NULL, '2026-02-03 02:24:26', 'Procurement request created'),
(200, 'procurement_requests', 45, 'STATUS_CHANGE', NULL, '2026-02-03 11:31:51', 'Draft → Submitted'),
(201, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-03 13:28:20', 'Role updated to Viewer'),
(202, 'procurement_requests', 46, 'CREATE', NULL, '2026-02-03 13:29:47', 'Procurement request created'),
(203, 'procurement_requests', 47, 'CREATE', 'Technical & User Support Officer', '2026-02-03 13:36:22', 'Procurement request created'),
(204, 'procurement_requests', 48, 'CREATE', 'Technical & User Support Officer', '2026-02-03 13:39:24', 'Procurement request created'),
(205, 'procurement_requests', 48, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 13:39:33', 'Draft → Submitted'),
(206, 'procurement_requests', 47, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 13:39:57', 'Draft → Submitted'),
(207, 'procurement_requests', 46, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 13:40:08', 'Draft → Submitted'),
(208, 'procurement_requests', 46, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 13:42:01', 'Submitted → Approved'),
(209, 'procurement_requests', 49, 'CREATE', NULL, '2026-02-03 13:43:51', 'Procurement request created'),
(210, 'procurement_requests', 49, 'STATUS_CHANGE', NULL, '2026-02-03 13:43:59', 'Draft → Submitted'),
(211, 'commitments', 24, 'CREATE', 'Technical & User Support Officer', '2026-02-03 13:49:40', 'Commitment created'),
(212, 'purchase_orders', 28, 'CREATE', 'Technical & User Support Officer', '2026-02-03 13:49:49', 'Purchase Order created'),
(213, 'invoices', 32, 'CREATE', 'Technical & User Support Officer', '2026-02-03 14:13:39', 'Invoice created'),
(214, 'procurement_requests', 50, 'CREATE', NULL, '2026-02-03 14:18:06', 'Procurement request created'),
(215, 'procurement_requests', 50, 'STATUS_CHANGE', NULL, '2026-02-03 14:18:19', 'Draft → Submitted'),
(216, 'procurement_requests', 50, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 14:18:49', 'Submitted → Approved'),
(217, 'procurement_requests', 49, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-03 14:25:46', 'Submitted → Approved'),
(218, 'payments', 36, 'CREATE', 'Technical & User Support Officer', '2026-02-03 20:26:40', 'Payment recorded'),
(219, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-03 22:13:23', 'Role updated to Admin'),
(220, 'procurement_requests', 45, 'STATUS_CHANGE', NULL, '2026-02-03 22:13:53', 'Submitted → Approved'),
(221, 'procurement_requests', 47, 'STATUS_CHANGE', NULL, '2026-02-03 22:14:16', 'Submitted → Approved'),
(222, 'procurement_requests', 48, 'STATUS_CHANGE', NULL, '2026-02-03 22:14:28', 'Submitted → Approved'),
(223, 'commitments', 25, 'CREATE', NULL, '2026-02-03 22:14:51', 'Commitment created'),
(224, 'purchase_orders', 29, 'CREATE', NULL, '2026-02-03 22:15:01', 'Purchase Order created'),
(225, 'invoices', 33, 'CREATE', NULL, '2026-02-04 00:50:45', 'Invoice created'),
(226, 'commitments', 26, 'CREATE', NULL, '2026-02-04 01:23:06', 'Commitment created'),
(227, 'users', 2, 'ROLE_CHANGE', NULL, '2026-02-04 01:23:17', 'Role updated to SuperAdmin'),
(228, 'purchase_orders', 30, 'CREATE', NULL, '2026-02-04 01:23:37', 'Purchase Order created'),
(229, 'po_variations', 1, 'CREATE', NULL, '2026-02-04 02:37:49', 'PO variation requested'),
(230, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 02:45:41', 'Role updated to Finance'),
(231, 'users', 2, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 02:45:54', 'Role updated to Admin'),
(232, 'po_variations', 1, 'APPROVE', NULL, '2026-02-04 02:58:30', 'PO variation approved'),
(233, 'invoices', 34, 'CREATE', NULL, '2026-02-04 03:06:37', 'Invoice created'),
(234, 'payments', 37, 'CREATE', NULL, '2026-02-04 03:07:14', 'Payment recorded'),
(235, 'commitments', 27, 'CREATE', NULL, '2026-02-04 03:07:46', 'Commitment created'),
(236, 'purchase_orders', 31, 'CREATE', NULL, '2026-02-04 03:07:57', 'Purchase Order created'),
(237, 'po_variations', 2, 'CREATE', NULL, '2026-02-04 03:08:35', 'PO variation requested'),
(238, 'po_variations', 2, 'APPROVE', NULL, '2026-02-04 03:09:18', 'PO variation approved'),
(239, 'invoices', 35, 'CREATE', NULL, '2026-02-04 03:10:15', 'Invoice created'),
(240, 'procurement_requests', 51, 'CREATE', NULL, '2026-02-04 03:13:48', 'Procurement request created'),
(241, 'procurement_requests', 51, 'STATUS_CHANGE', NULL, '2026-02-04 03:14:15', 'Draft → Submitted'),
(242, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-04 13:50:23', 'Password updated'),
(243, 'procurement_requests', 51, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-04 13:51:18', 'Submitted → Approved'),
(244, 'commitments', 28, 'CREATE', 'Technical & User Support Officer', '2026-02-04 14:27:29', 'Commitment created'),
(245, 'purchase_orders', 32, 'CREATE', 'Technical & User Support Officer', '2026-02-04 14:27:39', 'Purchase Order created'),
(246, 'commitments', 29, 'CREATE', 'Technical & User Support Officer', '2026-02-04 14:40:02', 'Commitment created'),
(247, 'purchase_orders', 33, 'CREATE', 'Technical & User Support Officer', '2026-02-04 14:40:13', 'Purchase Order created'),
(248, 'po_variations', 3, 'CREATE', 'Technical & User Support Officer', '2026-02-04 14:46:22', 'PO variation requested'),
(249, 'po_variations', 3, 'APPROVE', 'Latoya Gayle', '2026-02-04 14:47:33', 'PO variation approved'),
(250, 'commitments', 30, 'CREATE', 'Latoya Gayle', '2026-02-04 14:58:41', 'Commitment created'),
(251, 'purchase_orders', 34, 'CREATE', 'Latoya Gayle', '2026-02-04 14:59:02', 'Purchase Order created'),
(252, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 15:47:57', 'Role updated to Viewer'),
(253, 'users', 15, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-04 15:48:18', 'Admin reset user password'),
(254, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-04 15:48:38', 'Password updated'),
(255, 'procurement_requests', 52, 'CREATE', NULL, '2026-02-04 15:49:05', 'Procurement request created'),
(256, 'procurement_requests', 52, 'STATUS_CHANGE', NULL, '2026-02-04 15:49:13', 'Draft → Submitted'),
(257, 'procurement_requests', 52, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-04 15:49:25', 'Submitted → Approved'),
(258, 'commitments', 31, 'CREATE', 'Technical & User Support Officer', '2026-02-04 15:49:40', 'Commitment created'),
(259, 'users', 6, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-04 15:50:45', 'Admin reset user password'),
(260, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-04 15:51:00', 'Password updated'),
(261, 'users', 2, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 15:56:57', 'Role updated to HOD'),
(262, 'users', 2, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 15:57:43', 'Role updated to HOD'),
(263, 'users', 2, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-04 15:59:14', 'Role updated to HOD'),
(264, 'users', 2, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-04 15:59:34', 'Admin reset user password'),
(265, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-04 15:59:56', 'Password updated'),
(266, 'procurement_requests', 53, 'CREATE', NULL, '2026-02-04 16:41:18', 'Procurement request created'),
(267, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-04 18:33:37', 'Password updated'),
(268, 'purchase_orders', 35, 'CREATE', 'Technical & User Support Officer', '2026-02-04 20:26:48', 'Purchase Order created'),
(269, 'procurement_requests', 53, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-04 20:30:30', 'Draft → Submitted'),
(270, 'procurement_requests', 53, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-04 20:30:33', 'Submitted → Approved'),
(271, 'commitments', 32, 'CREATE', 'Technical & User Support Officer', '2026-02-04 20:30:59', 'Commitment created'),
(272, 'purchase_orders', 36, 'CREATE', 'Technical & User Support Officer', '2026-02-04 21:45:11', 'Purchase Order created'),
(273, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 00:43:54', 'Account locked after failed attempts'),
(274, 'users', 2, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-05 00:44:29', 'Admin reset user password'),
(275, 'procurement_requests', 54, 'CREATE', NULL, '2026-02-05 00:54:55', 'Procurement request created'),
(276, 'procurement_requests', 54, 'STATUS_CHANGE', NULL, '2026-02-05 00:55:11', 'Draft → Submitted'),
(277, 'procurement_requests', 54, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-05 00:55:44', 'Submitted → Approved'),
(278, 'users', 16, 'CREATE', 'Technical & User Support Officer', '2026-02-05 00:56:20', 'User created by admin'),
(279, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-05 00:56:27', 'Role updated to HOD'),
(280, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-05 00:56:56', 'Password updated'),
(281, 'users', 9, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-05 00:58:23', 'Admin reset user password'),
(282, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-05 00:58:43', 'Password updated'),
(283, 'commitments', 33, 'CREATE', 'Gabrielle Green', '2026-02-05 00:59:04', 'Commitment created'),
(284, 'purchase_orders', 37, 'CREATE', 'Latoya Gayle', '2026-02-05 01:15:00', 'Purchase Order created'),
(285, 'invoices', 36, 'CREATE', 'Latoya Gayle', '2026-02-05 01:38:54', 'Invoice created'),
(286, 'payments', 38, 'CREATE', 'Latoya Gayle', '2026-02-05 01:39:34', 'Payment recorded'),
(287, 'procurement_requests', 55, 'CREATE', 'Latoya Gayle', '2026-02-05 01:45:53', 'Procurement request created'),
(288, 'procurement_requests', 55, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-05 01:46:01', 'Draft → Submitted'),
(289, 'procurement_requests', 55, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-05 01:56:04', 'Submitted → Approved'),
(290, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 01:56:56', 'Account locked after failed attempts'),
(291, 'commitments', 34, 'CREATE', 'Gabrielle Green', '2026-02-05 01:57:59', 'Commitment created'),
(292, 'procurement_requests', 56, 'CREATE', NULL, '2026-02-05 02:02:59', 'Procurement request created'),
(293, 'procurement_requests', 56, 'STATUS_CHANGE', NULL, '2026-02-05 02:03:09', 'Draft → Submitted'),
(294, 'procurement_requests', 56, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-05 02:03:56', 'Submitted → Approved'),
(295, 'commitments', NULL, 'CREATE', 'Gabrielle Green', '2026-02-05 02:51:53', 'Commitment created'),
(296, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 02:54:54', 'Account locked after failed attempts'),
(297, 'commitments', 34, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-05 02:57:55', 'Commitment approved by HOD'),
(298, 'commitments', 35, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-05 02:58:29', 'Commitment approved by HOD'),
(299, 'commitments', 34, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-05 03:01:29', 'Commitment approved by Finance'),
(300, 'purchase_orders', 38, 'CREATE', 'Gabrielle Green', '2026-02-05 13:04:51', 'Purchase Order created'),
(301, 'purchase_orders', 38, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-05 13:06:13', 'Purchase Order approved by HOD'),
(302, 'commitments', 35, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-05 15:44:54', 'Commitment approved by Finance'),
(303, 'invoices', 37, 'CREATE', 'Latoya Gayle', '2026-02-05 15:56:37', 'Invoice created'),
(304, 'purchase_orders', 39, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-05 16:30:24', 'Purchase Order approved by HOD'),
(305, 'invoices', 38, 'CREATE', 'Gabrielle Green', '2026-02-05 16:44:11', 'Invoice created'),
(306, 'payments', 39, 'CREATE', 'Latoya Gayle', '2026-02-05 16:45:18', 'Payment recorded'),
(307, 'payments', 40, 'CREATE', 'Latoya Gayle', '2026-02-05 16:45:39', 'Payment recorded'),
(308, 'procurement_requests', 57, 'CREATE', 'Latoya Gayle', '2026-02-05 16:58:09', 'Procurement request created'),
(309, 'procurement_requests', 57, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-05 16:58:17', 'Draft → Submitted'),
(310, 'procurement_requests', 57, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-05 17:44:30', 'Submitted → Approved'),
(311, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 18:32:12', 'Account locked after failed attempts'),
(312, 'users', 17, 'CREATE', 'Technical & User Support Officer', '2026-02-05 18:40:53', 'User created by admin'),
(313, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-05 18:42:44', 'Password updated'),
(314, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', 'Shermaine McKenzie', '2026-02-05 18:50:02', 'Back-dating of procurement request was attempted'),
(315, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 20:53:43', 'Account locked after failed attempts'),
(316, 'commitments', NULL, 'CREATE', 'Demario Ewan', '2026-02-05 20:56:05', 'Commitment created'),
(317, 'commitments', 36, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-05 20:56:18', 'Commitment approved by HOD'),
(318, 'users', 2, 'LOCKOUT', NULL, '2026-02-05 23:43:45', 'Account locked after failed attempts'),
(319, 'commitments', 36, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-05 23:44:21', 'Commitment approved by Finance'),
(320, 'procurement_requests', 58, 'CREATE', NULL, '2026-02-05 23:52:42', 'Procurement request created'),
(321, 'procurement_requests', 58, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-05 23:53:00', 'Draft → Submitted'),
(322, 'procurement_requests', 58, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-05 23:53:07', 'Submitted → Approved'),
(323, 'commitments', NULL, 'CREATE', 'Gabrielle Green', '2026-02-05 23:53:36', 'Commitment created'),
(324, 'commitments', 37, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-05 23:55:09', 'Commitment approved by HOD'),
(325, 'commitments', 37, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-05 23:55:33', 'Commitment approved by Finance'),
(326, 'procurement_requests', 59, 'CREATE', NULL, '2026-02-06 00:06:27', 'Procurement request created'),
(327, 'procurement_requests', 59, 'STATUS_CHANGE', NULL, '2026-02-06 00:06:58', 'Draft → Submitted'),
(328, 'procurement_requests', 59, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-06 00:07:52', 'Submitted → Approved'),
(329, 'commitments', NULL, 'CREATE', 'Gabrielle Green', '2026-02-06 00:08:24', 'Commitment created'),
(330, 'commitments', 38, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 00:21:00', 'Commitment approved by HOD'),
(331, 'commitments', 38, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 00:21:13', 'Commitment approved by Finance'),
(332, 'purchase_orders', 42, 'CREATE', 'Latoya Gayle', '2026-02-06 00:21:31', 'Purchase Order created'),
(333, 'purchase_orders', 43, 'CREATE', 'Latoya Gayle', '2026-02-06 00:22:18', 'Purchase Order created'),
(334, 'purchase_orders', 40, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 00:22:46', 'Purchase Order approved by HOD'),
(335, 'purchase_orders', 42, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 00:23:02', 'Purchase Order approved by HOD'),
(336, 'purchase_orders', 43, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 00:23:37', 'Purchase Order approved by HOD'),
(337, 'purchase_orders', 42, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 00:24:15', 'Purchase Order approved by Finance'),
(338, 'purchase_orders', 40, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 00:24:37', 'Purchase Order approved by Finance'),
(339, 'invoices', 39, 'CREATE', 'Gabrielle Green', '2026-02-06 00:26:03', 'Invoice created'),
(340, 'invoices', 40, 'CREATE', 'Gabrielle Green', '2026-02-06 00:26:24', 'Invoice created'),
(341, 'purchase_orders', 43, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 00:27:30', 'Purchase Order approved by Finance'),
(342, 'po_variations', 4, 'CREATE', 'Gabrielle Green', '2026-02-06 00:42:42', 'PO variation requested'),
(343, 'po_variations', 4, 'APPROVE', 'Latoya Gayle', '2026-02-06 00:51:56', 'PO variation approved'),
(344, 'invoices', 41, 'CREATE', 'Latoya Gayle', '2026-02-06 01:03:23', 'Invoice added by user ID 6'),
(345, 'invoices', 41, 'CREATE', 'Latoya Gayle', '2026-02-06 01:03:23', 'Invoice created'),
(346, 'payments', 41, 'CREATE', 'Latoya Gayle', '2026-02-06 01:03:57', 'Payment recorded'),
(347, 'payments', 42, 'CREATE', 'Latoya Gayle', '2026-02-06 01:06:13', 'Payment recorded'),
(348, 'payments', 43, 'CREATE', 'Latoya Gayle', '2026-02-06 01:06:36', 'Payment recorded'),
(349, 'procurement_requests', 60, 'CREATE', NULL, '2026-02-06 01:36:27', 'Procurement request created'),
(350, 'procurement_requests', 60, 'STATUS_CHANGE', NULL, '2026-02-06 01:37:01', 'Draft → Submitted'),
(351, 'procurement_requests', 60, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-06 01:40:52', 'Submitted → Approved'),
(352, 'commitments', 39, 'CREATE', 'Gabrielle Green', '2026-02-06 01:41:26', 'Commitment created'),
(353, 'commitments', 39, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 01:43:26', 'Commitment approved by HOD'),
(354, 'commitments', 39, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 01:45:58', 'Commitment approved by Finance'),
(355, 'purchase_orders', 44, 'CREATE', 'Gabrielle Green', '2026-02-06 01:46:41', 'Purchase Order created'),
(356, 'purchase_orders', 44, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 01:48:40', 'Purchase Order approved by HOD'),
(357, 'purchase_orders', 44, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 01:48:55', 'Purchase Order approved by Finance'),
(358, 'po_variations', 5, 'CREATE', 'Gabrielle Green', '2026-02-06 01:51:33', 'PO variation requested'),
(359, 'procurement_requests', 61, 'CREATE', NULL, '2026-02-06 02:59:43', 'Procurement request created'),
(360, 'procurement_requests', 61, 'STATUS_CHANGE', NULL, '2026-02-06 02:59:51', 'Draft → Submitted'),
(361, 'procurement_requests', 61, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-06 03:00:07', 'Submitted → Approved'),
(362, 'commitments', 40, 'CREATE', 'Gabrielle Green', '2026-02-06 03:00:38', 'Commitment created'),
(363, 'commitments', 40, 'APPROVE', 'Demario Ewan', '2026-02-06 03:00:56', 'Commitment approved (ORIGINAL)'),
(364, 'commitments', 40, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 03:00:56', 'Commitment approved by HOD'),
(365, 'commitments', 40, 'APPROVE', 'Latoya Gayle', '2026-02-06 03:01:10', 'Commitment approved (ORIGINAL)'),
(366, 'commitments', 40, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 03:01:10', 'Commitment approved by Finance'),
(367, 'purchase_orders', 45, 'CREATE', 'Gabrielle Green', '2026-02-06 03:01:30', 'Purchase Order created'),
(368, 'purchase_orders', 45, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 03:01:45', 'Purchase Order approved by HOD'),
(369, 'purchase_orders', 45, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 03:02:01', 'Purchase Order approved by Finance'),
(370, 'po_variations', 6, 'CREATE', 'Gabrielle Green', '2026-02-06 03:02:50', 'PO variation requested'),
(371, 'procurement_requests', 62, 'CREATE', NULL, '2026-02-06 03:19:10', 'Procurement request created'),
(372, 'procurement_requests', 62, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-06 03:19:28', 'Draft → Submitted'),
(373, 'procurement_requests', 62, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-06 03:19:33', 'Submitted → Approved'),
(374, 'commitments', 41, 'CREATE', 'Gabrielle Green', '2026-02-06 03:19:56', 'Commitment created'),
(375, 'commitments', 41, 'APPROVE', 'Demario Ewan', '2026-02-06 03:20:32', 'Commitment approved (ORIGINAL)'),
(376, 'commitments', 41, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 03:20:32', 'Commitment approved by HOD'),
(377, 'commitments', 41, 'APPROVE', 'Latoya Gayle', '2026-02-06 03:21:24', 'Commitment approved (ORIGINAL)'),
(378, 'commitments', 41, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 03:21:24', 'Commitment approved by Finance'),
(379, 'purchase_orders', 46, 'CREATE', 'Gabrielle Green', '2026-02-06 03:21:55', 'Purchase Order created'),
(380, 'purchase_orders', 46, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 03:22:18', 'Purchase Order approved by HOD'),
(381, 'purchase_orders', 46, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 03:22:38', 'Purchase Order approved by Finance'),
(382, 'po_variations', 7, 'CREATE', 'Gabrielle Green', '2026-02-06 03:24:16', 'PO variation requested'),
(383, 'commitments', 59, 'CREATE', 'Latoya Gayle', '2026-02-06 03:55:10', 'Supplementary commitment created'),
(384, 'po_variations', 7, 'LINK', 'Latoya Gayle', '2026-02-06 03:55:10', 'Variation linked to supplementary commitment'),
(385, 'commitments', 59, 'APPROVE', 'Demario Ewan', '2026-02-06 03:57:35', 'Commitment approved (SUPPLEMENTARY)'),
(386, 'commitments', 59, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 03:57:35', 'Commitment approved by HOD'),
(387, 'commitments', 59, 'APPROVE', 'Latoya Gayle', '2026-02-06 03:57:58', 'Commitment approved (SUPPLEMENTARY)'),
(388, 'commitments', 59, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 03:57:58', 'Commitment approved by Finance'),
(389, 'purchase_orders', 47, 'CREATE', 'Gabrielle Green', '2026-02-06 04:22:54', 'Purchase Order created'),
(390, 'po_variations', 7, 'APPROVE', 'Latoya Gayle', '2026-02-06 04:23:38', 'PO variation approved after supplementary commitment approval'),
(391, 'commitments', 60, 'CREATE', 'Latoya Gayle', '2026-02-06 04:24:11', 'Supplementary commitment created for PO variation 6'),
(392, 'po_variations', 6, 'LINK', 'Latoya Gayle', '2026-02-06 04:24:11', 'Variation linked to supplementary commitment'),
(393, 'commitments', 60, 'APPROVE', 'Demario Ewan', '2026-02-06 04:28:14', 'Commitment approved (SUPPLEMENTARY)'),
(394, 'commitments', 60, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 04:28:14', 'Commitment approved by HOD'),
(395, 'purchase_orders', 47, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 04:28:51', 'Purchase Order approved by HOD'),
(396, 'purchase_orders', 47, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 11:34:05', 'Purchase Order approved by Finance'),
(397, 'commitments', 60, 'APPROVE', 'Latoya Gayle', '2026-02-06 11:34:41', 'Commitment approved (SUPPLEMENTARY)'),
(398, 'commitments', 60, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 11:34:41', 'Commitment approved by Finance'),
(399, 'po_variations', 6, 'APPROVE', 'Latoya Gayle', '2026-02-06 11:35:28', 'PO variation approved after supplementary commitment approval'),
(400, 'commitments', 61, 'CREATE', 'Latoya Gayle', '2026-02-06 11:35:57', 'Supplementary commitment created for PO variation 5'),
(401, 'po_variations', 5, 'LINK', 'Latoya Gayle', '2026-02-06 11:35:57', 'Variation linked to supplementary commitment'),
(402, 'commitments', 61, 'APPROVE', 'Demario Ewan', '2026-02-06 11:37:37', 'Commitment approved (SUPPLEMENTARY)'),
(403, 'commitments', 61, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 11:37:37', 'Commitment approved by HOD'),
(404, 'commitments', 61, 'APPROVE', 'Latoya Gayle', '2026-02-06 11:39:41', 'Commitment approved (SUPPLEMENTARY)'),
(405, 'commitments', 61, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 11:39:41', 'Commitment approved by Finance'),
(406, 'purchase_orders', 48, 'CREATE', 'Gabrielle Green', '2026-02-06 11:40:25', 'Purchase Order created'),
(407, 'purchase_orders', 49, 'CREATE', 'Gabrielle Green', '2026-02-06 11:41:31', 'Purchase Order created'),
(408, 'purchase_orders', 48, 'PO_APPROVED_HOD', 'Technical & User Support Officer', '2026-02-06 11:42:19', 'Purchase Order approved by HOD'),
(409, 'purchase_orders', 49, 'PO_APPROVED_HOD', 'Technical & User Support Officer', '2026-02-06 11:42:29', 'Purchase Order approved by HOD'),
(410, 'purchase_orders', 48, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 11:43:35', 'Purchase Order approved by Finance'),
(411, 'purchase_orders', 49, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 11:44:07', 'Purchase Order approved by Finance'),
(412, 'invoices', 42, 'CREATE', 'Latoya Gayle', '2026-02-06 14:59:02', 'Invoice added by user ID 6'),
(413, 'invoices', 42, 'CREATE', 'Latoya Gayle', '2026-02-06 14:59:02', 'Invoice created'),
(414, 'invoices', 43, 'CREATE', 'Latoya Gayle', '2026-02-06 15:12:10', 'Invoice added by user ID 6'),
(415, 'invoices', 43, 'CREATE', 'Latoya Gayle', '2026-02-06 15:12:10', 'Invoice created'),
(416, 'invoices', 44, 'CREATE', 'Latoya Gayle', '2026-02-06 15:12:45', 'Invoice added by user ID 6'),
(417, 'invoices', 44, 'CREATE', 'Latoya Gayle', '2026-02-06 15:12:45', 'Invoice created'),
(418, 'invoices', 45, 'CREATE', 'Latoya Gayle', '2026-02-06 15:13:23', 'Invoice added by user ID 6'),
(419, 'invoices', 45, 'CREATE', 'Latoya Gayle', '2026-02-06 15:13:23', 'Invoice created'),
(420, 'invoices', 46, 'CREATE', 'Latoya Gayle', '2026-02-06 15:14:27', 'Invoice added by user ID 6'),
(421, 'invoices', 46, 'CREATE', 'Latoya Gayle', '2026-02-06 15:14:27', 'Invoice created'),
(422, 'invoices', 47, 'CREATE', 'Latoya Gayle', '2026-02-06 15:15:31', 'Invoice added by user ID 6'),
(423, 'invoices', 47, 'CREATE', 'Latoya Gayle', '2026-02-06 15:15:31', 'Invoice created'),
(424, 'procurement_requests', 63, 'CREATE', NULL, '2026-02-06 16:39:38', 'Procurement request created'),
(425, 'procurement_requests', 63, 'STATUS_CHANGE', NULL, '2026-02-06 16:39:59', 'Draft → Submitted'),
(426, 'procurement_requests', 63, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-06 16:40:44', 'Submitted → Approved'),
(427, 'procurement_requests', 64, 'CREATE', NULL, '2026-02-06 16:47:08', 'Procurement request created'),
(428, 'procurement_requests', 64, 'STATUS_CHANGE', NULL, '2026-02-06 16:47:15', 'Draft → Submitted'),
(429, 'procurement_requests', 64, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-06 16:47:38', 'Submitted → Approved'),
(430, 'commitments', 62, 'CREATE', 'Gabrielle Green', '2026-02-06 16:48:41', 'Commitment created'),
(431, 'commitments', 62, 'APPROVE', 'Demario Ewan', '2026-02-06 16:49:03', 'Commitment approved (ORIGINAL)'),
(432, 'commitments', 62, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 16:49:03', 'Commitment approved by HOD'),
(433, 'commitments', 62, 'APPROVE', 'Latoya Gayle', '2026-02-06 16:53:21', 'Commitment approved (ORIGINAL)'),
(434, 'commitments', 62, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 16:53:21', 'Commitment approved by Finance'),
(435, 'procurement_requests', 64, 'SUPPLEMENTARY_COMMIT', 'Latoya Gayle', '2026-02-06 16:53:21', 'Supplementary commitment CM001 approved by Finance'),
(436, 'procurement_requests', 65, 'CREATE', NULL, '2026-02-06 17:00:37', 'Procurement request created'),
(437, 'procurement_requests', 65, 'STATUS_CHANGE', NULL, '2026-02-06 17:10:53', 'Draft → Submitted'),
(438, 'procurement_requests', 65, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-06 17:11:47', 'Submitted → Approved'),
(439, 'commitments', 63, 'CREATE', 'Gabrielle Green', '2026-02-06 17:15:09', 'Commitment created'),
(440, 'commitments', 63, 'APPROVE', 'Demario Ewan', '2026-02-06 17:15:45', 'Commitment approved (ORIGINAL)'),
(441, 'commitments', 63, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 17:15:45', 'Commitment approved by HOD'),
(442, 'procurement_requests', 65, 'ORIGINAL_COMMITMENT_', 'Demario Ewan', '2026-02-06 17:15:45', 'Original commitment CM002 approved by HOD'),
(443, 'commitments', 63, 'APPROVE', 'Latoya Gayle', '2026-02-06 17:16:28', 'Commitment approved (ORIGINAL)'),
(444, 'commitments', 63, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 17:16:28', 'Commitment approved by Finance'),
(445, 'procurement_requests', 65, 'ORIGINAL_COMMITMENT_', 'Latoya Gayle', '2026-02-06 17:16:28', 'Original commitment CM002 approved by Finance'),
(446, 'users', 18, 'CREATE', 'Technical & User Support Officer', '2026-02-06 17:50:27', 'User created by admin'),
(447, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-06 17:50:40', 'Role updated to Admin'),
(448, 'procurement_requests', 66, 'CREATE', 'Latoya Gayle', '2026-02-06 18:50:06', 'Procurement request created'),
(449, 'procurement_requests', 67, 'CREATE', 'Gabrielle Green', '2026-02-06 18:50:35', 'Procurement request created'),
(450, 'procurement_requests', 66, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-06 18:51:29', 'Draft → Submitted'),
(451, 'procurement_requests', 66, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-06 18:52:27', 'Submitted → Approved'),
(452, 'commitments', 64, 'CREATE', 'Gabrielle Green', '2026-02-06 18:53:21', 'Commitment created'),
(453, 'commitments', 64, 'APPROVE', 'Demario Ewan', '2026-02-06 18:55:13', 'Commitment approved (ORIGINAL)'),
(454, 'commitments', 64, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-06 18:55:13', 'Commitment approved by HOD'),
(455, 'procurement_requests', 66, 'ORIGINAL_COMMITMENT_', 'Demario Ewan', '2026-02-06 18:55:13', 'Original commitment CM003 approved by HOD'),
(456, 'commitments', 64, 'APPROVE', 'Latoya Gayle', '2026-02-06 18:57:08', 'Commitment approved (ORIGINAL)'),
(457, 'commitments', 64, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-06 18:57:08', 'Commitment approved by Finance'),
(458, 'procurement_requests', 66, 'ORIGINAL_COMMITMENT_', 'Latoya Gayle', '2026-02-06 18:57:08', 'Original commitment CM003 approved by Finance'),
(459, 'purchase_orders', 50, 'CREATE', 'Gabrielle Green', '2026-02-06 18:57:56', 'Purchase Order created'),
(460, 'purchase_orders', 50, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-06 19:02:47', 'Purchase Order approved by HOD'),
(461, 'purchase_orders', 50, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-06 19:03:05', 'Purchase Order approved by Finance'),
(462, 'po_variations', 8, 'CREATE', 'Gabrielle Green', '2026-02-06 19:06:33', 'PO variation requested'),
(465, 'procurement_requests', 67, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-06 19:39:04', 'Draft → Submitted'),
(466, 'purchase_orders', 51, 'CREATE', 'Latoya Gayle', '2026-02-06 19:39:37', 'Purchase Order created'),
(469, 'procurement_requests', 67, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-07 00:58:04', 'Submitted → Approved'),
(470, 'commitments', 67, 'CREATE', 'Gabrielle Green', '2026-02-07 00:59:10', 'Commitment created'),
(471, 'commitments', 67, 'APPROVE', 'Demario Ewan', '2026-02-07 00:59:28', 'Commitment approved (ORIGINAL)'),
(472, 'commitments', 67, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-07 00:59:28', 'Commitment approved by HOD'),
(473, 'procurement_requests', 67, 'ORIGINAL_COMMITMENT_', 'Demario Ewan', '2026-02-07 00:59:28', 'Original commitment CM004 approved by HOD'),
(474, 'commitments', 67, 'APPROVE', 'Latoya Gayle', '2026-02-07 00:59:44', 'Commitment approved (ORIGINAL)'),
(475, 'commitments', 67, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-07 00:59:44', 'Commitment approved by Finance'),
(476, 'procurement_requests', 67, 'ORIGINAL_COMMITMENT_', 'Latoya Gayle', '2026-02-07 00:59:44', 'Original commitment CM004 approved by Finance'),
(477, 'purchase_orders', 52, 'CREATE', 'Gabrielle Green', '2026-02-07 01:00:17', 'Purchase Order created'),
(478, 'purchase_orders', 52, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-07 01:00:44', 'Purchase Order approved by HOD'),
(479, 'purchase_orders', 52, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-07 01:01:02', 'Purchase Order approved by Finance'),
(480, 'invoices', 48, 'CREATE', 'Gabrielle Green', '2026-02-07 01:01:30', 'Invoice added by user ID 9'),
(481, 'invoices', 48, 'CREATE', 'Gabrielle Green', '2026-02-07 01:01:30', 'Invoice created'),
(482, 'invoices', 49, 'CREATE', 'Gabrielle Green', '2026-02-07 01:01:54', 'Invoice added by user ID 9'),
(483, 'invoices', 49, 'CREATE', 'Gabrielle Green', '2026-02-07 01:01:54', 'Invoice created'),
(484, 'payments', 44, 'CREATE', 'Latoya Gayle', '2026-02-07 01:02:59', 'Payment recorded'),
(487, 'commitments', 69, 'CREATE', 'Latoya Gayle', '2026-02-07 01:10:21', 'Supplementary commitment created for PO variation 8'),
(488, 'po_variations', 8, 'LINK', 'Latoya Gayle', '2026-02-07 01:10:21', 'Variation linked to supplementary commitment'),
(489, 'procurement_requests', 66, 'SUPPLEMENTARY_COMMIT', 'Latoya Gayle', '2026-02-07 01:10:21', 'Supplementary commitment CM005 created for JMD 1,000.00'),
(490, 'commitments', 69, 'APPROVE', 'Demario Ewan', '2026-02-07 01:11:57', 'Commitment approved (SUPPLEMENTARY)'),
(491, 'commitments', 69, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-07 01:11:57', 'Commitment approved by HOD'),
(492, 'procurement_requests', 66, 'SUPPLEMENTARY_COMMIT', 'Demario Ewan', '2026-02-07 01:11:57', 'Supplementary commitment CM005 approved by HOD'),
(493, 'commitments', 69, 'APPROVE', 'Latoya Gayle', '2026-02-07 01:16:59', 'Commitment approved (SUPPLEMENTARY)'),
(494, 'commitments', 69, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-07 01:16:59', 'Commitment approved by Finance'),
(495, 'procurement_requests', 66, 'SUPPLEMENTARY_COMMIT', 'Latoya Gayle', '2026-02-07 01:16:59', 'Supplementary commitment CM005 approved by Finance'),
(496, 'purchase_orders', 53, 'CREATE', 'Gabrielle Green', '2026-02-07 01:18:06', 'Purchase Order created'),
(497, 'purchase_orders', 54, 'CREATE', 'Gabrielle Green', '2026-02-07 01:18:23', 'Purchase Order created'),
(498, 'purchase_orders', 54, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-07 01:20:16', 'Purchase Order approved by HOD'),
(499, 'purchase_orders', 51, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-07 01:20:25', 'Purchase Order approved by HOD'),
(500, 'purchase_orders', 53, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-07 01:20:35', 'Purchase Order approved by HOD'),
(501, 'invoices', 52, 'CREATE', 'Latoya Gayle', '2026-02-07 01:24:10', 'Invoice added by user ID 6'),
(502, 'invoices', 52, 'CREATE', 'Latoya Gayle', '2026-02-07 01:24:10', 'Invoice created'),
(503, 'purchase_orders', 54, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-07 01:24:29', 'Purchase Order approved by Finance'),
(504, 'invoices', 53, 'CREATE', 'Latoya Gayle', '2026-02-07 01:24:48', 'Invoice added by user ID 6'),
(505, 'invoices', 53, 'CREATE', 'Latoya Gayle', '2026-02-07 01:24:48', 'Invoice created'),
(506, 'purchase_orders', 51, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-07 01:28:36', 'Purchase Order approved by Finance'),
(507, 'invoices', 54, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:05', 'Invoice added by user ID 6'),
(508, 'invoices', 54, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:05', 'Invoice created'),
(509, 'invoices', 55, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:27', 'Invoice added by user ID 6'),
(510, 'invoices', 55, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:27', 'Invoice created'),
(511, 'invoices', 56, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:49', 'Invoice added by user ID 6'),
(512, 'invoices', 56, 'CREATE', 'Latoya Gayle', '2026-02-07 01:29:49', 'Invoice created'),
(513, 'purchase_orders', 53, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-07 01:30:29', 'Purchase Order approved by Finance'),
(514, 'invoices', 57, 'CREATE', 'Latoya Gayle', '2026-02-07 01:31:22', 'Invoice added by user ID 6'),
(515, 'invoices', 57, 'CREATE', 'Latoya Gayle', '2026-02-07 01:31:22', 'Invoice created'),
(516, 'po_variations', 8, 'APPROVE', 'Latoya Gayle', '2026-02-07 01:32:25', 'PO variation approved after supplementary commitment approval'),
(517, 'payments', 45, 'CREATE', 'Latoya Gayle', '2026-02-07 01:44:58', 'Payment recorded'),
(518, 'payments', 46, 'CREATE', 'Latoya Gayle', '2026-02-07 01:45:18', 'Payment recorded'),
(519, 'payments', 47, 'CREATE', 'Latoya Gayle', '2026-02-07 01:51:12', 'Payment recorded'),
(520, 'payments', 48, 'CREATE', 'Latoya Gayle', '2026-02-07 01:52:40', 'Payment recorded'),
(521, 'payments', 49, 'CREATE', 'Latoya Gayle', '2026-02-07 02:04:45', 'Payment recorded'),
(522, 'payments', 50, 'CREATE', 'Latoya Gayle', '2026-02-07 02:05:11', 'Payment recorded');
INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(523, 'payments', 51, 'CREATE', 'Latoya Gayle', '2026-02-07 02:05:32', 'Payment recorded'),
(524, 'payments', 52, 'CREATE', 'Latoya Gayle', '2026-02-07 02:05:59', 'Payment recorded'),
(525, 'POLICY', NULL, 'OVERPAY_ATTEMPT', 'Latoya Gayle', '2026-02-07 02:07:08', 'Payment exceeds invoice balance'),
(526, 'payments', 53, 'CREATE', 'Latoya Gayle', '2026-02-07 02:07:23', 'Payment recorded'),
(527, 'procurement_requests', 68, 'CREATE', NULL, '2026-02-07 02:30:42', 'Procurement request created'),
(528, 'procurement_requests', 69, 'CREATE', 'Gabrielle Green', '2026-02-08 18:05:25', 'Procurement request created'),
(529, 'procurement_requests', 69, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-08 18:11:40', 'Draft → Submitted'),
(530, 'procurement_requests', 70, 'CREATE', 'Gabrielle Green', '2026-02-08 18:16:33', 'Procurement request created'),
(531, 'procurement_requests', 69, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-08 21:25:17', 'Submitted → Approved'),
(532, 'procurement_requests', 70, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-08 21:25:36', 'Draft → Submitted'),
(533, 'commitments', 70, 'CREATE', 'Gabrielle Green', '2026-02-08 21:26:11', 'Commitment created'),
(534, 'commitments', 70, 'APPROVE', 'Demario Ewan', '2026-02-08 21:26:24', 'Commitment approved (ORIGINAL)'),
(535, 'commitments', 70, 'COMMITMENT_APPROVED_', 'Demario Ewan', '2026-02-08 21:26:24', 'Commitment approved by HOD'),
(536, 'procurement_requests', 69, 'ORIGINAL_COMMITMENT_', 'Demario Ewan', '2026-02-08 21:26:24', 'Original commitment CM006 approved by HOD'),
(537, 'commitments', 70, 'APPROVE', 'Latoya Gayle', '2026-02-08 21:26:35', 'Commitment approved (ORIGINAL)'),
(538, 'commitments', 70, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-08 21:26:35', 'Commitment approved by Finance'),
(539, 'procurement_requests', 69, 'ORIGINAL_COMMITMENT_', 'Latoya Gayle', '2026-02-08 21:26:35', 'Original commitment CM006 approved by Finance'),
(540, 'purchase_orders', 55, 'CREATE', 'Gabrielle Green', '2026-02-08 21:27:12', 'Purchase Order created'),
(541, 'purchase_orders', 55, 'PO_APPROVED_HOD', 'Demario Ewan', '2026-02-08 21:27:56', 'Purchase Order approved by HOD'),
(542, 'purchase_orders', 55, 'PO_APPROVED_FINANCE', 'Latoya Gayle', '2026-02-08 21:28:17', 'Purchase Order approved by Finance'),
(543, 'invoices', 58, 'CREATE', 'Latoya Gayle', '2026-02-08 21:28:41', 'Invoice added by user ID 6'),
(544, 'invoices', 58, 'CREATE', 'Latoya Gayle', '2026-02-08 21:28:41', 'Invoice created'),
(545, 'payments', 54, 'CREATE', 'Latoya Gayle', '2026-02-08 21:29:01', 'Payment recorded'),
(546, 'payments', 55, 'CREATE', 'Latoya Gayle', '2026-02-08 21:29:14', 'Payment recorded'),
(547, 'procurement_requests', 70, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-08 21:30:35', 'Submitted → Approved'),
(548, 'users', 2, 'LOCKOUT', NULL, '2026-02-13 01:10:44', 'Account locked after failed attempts'),
(549, 'users', 2, 'LOCKOUT', NULL, '2026-02-13 01:29:02', 'Account locked after failed attempts'),
(550, 'users', 6, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 02:10:29', 'Role updated to Finance Officer'),
(551, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 5 override set (granted=0)'),
(552, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 7 override set (granted=1)'),
(553, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 25 override set (granted=0)'),
(554, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 28 override set (granted=0)'),
(555, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 27 override set (granted=0)'),
(556, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 3 override set (granted=0)'),
(557, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 4 override set (granted=0)'),
(558, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 18 override set (granted=0)'),
(559, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 20 override set (granted=0)'),
(560, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 6 override set (granted=0)'),
(561, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 22 override set (granted=0)'),
(562, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 1 override set (granted=0)'),
(563, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 29 override set (granted=0)'),
(564, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 10 override set (granted=0)'),
(565, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 32 override set (granted=0)'),
(566, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 33 override set (granted=0)'),
(567, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 8 override set (granted=0)'),
(568, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 9 override set (granted=0)'),
(569, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 23 override set (granted=0)'),
(570, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 2 override set (granted=0)'),
(571, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 17 override set (granted=0)'),
(572, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 26 override set (granted=0)'),
(573, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 11 override set (granted=0)'),
(574, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 13 override set (granted=0)'),
(575, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 19 override set (granted=0)'),
(576, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 14 override set (granted=0)'),
(577, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 15 override set (granted=0)'),
(578, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 21 override set (granted=0)'),
(579, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 31 override set (granted=0)'),
(580, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 16 override set (granted=0)'),
(581, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 24 override set (granted=0)'),
(582, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:22:50', 'Permission ID 12 override set (granted=0)'),
(583, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 5 override set (granted=0)'),
(584, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 7 override set (granted=0)'),
(585, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 25 override set (granted=0)'),
(586, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 28 override set (granted=0)'),
(587, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 27 override set (granted=0)'),
(588, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 3 override set (granted=0)'),
(589, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 4 override set (granted=0)'),
(590, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 18 override set (granted=0)'),
(591, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 20 override set (granted=0)'),
(592, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 6 override set (granted=0)'),
(593, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 22 override set (granted=0)'),
(594, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 1 override set (granted=0)'),
(595, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 29 override set (granted=0)'),
(596, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 10 override set (granted=0)'),
(597, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 32 override set (granted=0)'),
(598, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 33 override set (granted=0)'),
(599, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 8 override set (granted=0)'),
(600, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 9 override set (granted=0)'),
(601, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 23 override set (granted=0)'),
(602, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 2 override set (granted=0)'),
(603, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 17 override set (granted=0)'),
(604, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 26 override set (granted=0)'),
(605, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 11 override set (granted=0)'),
(606, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 13 override set (granted=0)'),
(607, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 19 override set (granted=0)'),
(608, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 14 override set (granted=0)'),
(609, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 15 override set (granted=0)'),
(610, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 21 override set (granted=0)'),
(611, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 31 override set (granted=0)'),
(612, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 16 override set (granted=0)'),
(613, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 24 override set (granted=0)'),
(614, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:24', 'Permission ID 12 override set (granted=0)'),
(615, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 5 override set (granted=1)'),
(616, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 7 override set (granted=1)'),
(617, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 25 override set (granted=1)'),
(618, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 28 override set (granted=1)'),
(619, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 27 override set (granted=1)'),
(620, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 3 override set (granted=0)'),
(621, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 4 override set (granted=0)'),
(622, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 18 override set (granted=0)'),
(623, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 20 override set (granted=0)'),
(624, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 6 override set (granted=0)'),
(625, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 22 override set (granted=0)'),
(626, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 1 override set (granted=0)'),
(627, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 29 override set (granted=0)'),
(628, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 10 override set (granted=0)'),
(629, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 32 override set (granted=0)'),
(630, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 33 override set (granted=0)'),
(631, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 8 override set (granted=0)'),
(632, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 9 override set (granted=0)'),
(633, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 23 override set (granted=0)'),
(634, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 2 override set (granted=0)'),
(635, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 17 override set (granted=0)'),
(636, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 26 override set (granted=0)'),
(637, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 11 override set (granted=0)'),
(638, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 13 override set (granted=0)'),
(639, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 19 override set (granted=0)'),
(640, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 14 override set (granted=0)'),
(641, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 15 override set (granted=0)'),
(642, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 21 override set (granted=0)'),
(643, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 31 override set (granted=0)'),
(644, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 16 override set (granted=0)'),
(645, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 24 override set (granted=0)'),
(646, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:23:40', 'Permission ID 12 override set (granted=0)'),
(647, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 5 override set (granted=1)'),
(648, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 7 override set (granted=1)'),
(649, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 25 override set (granted=1)'),
(650, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 28 override set (granted=1)'),
(651, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 27 override set (granted=1)'),
(652, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 3 override set (granted=0)'),
(653, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 4 override set (granted=0)'),
(654, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 18 override set (granted=0)'),
(655, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 20 override set (granted=0)'),
(656, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 6 override set (granted=0)'),
(657, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 22 override set (granted=0)'),
(658, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 1 override set (granted=0)'),
(659, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 29 override set (granted=0)'),
(660, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 10 override set (granted=0)'),
(661, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 32 override set (granted=0)'),
(662, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 33 override set (granted=0)'),
(663, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 8 override set (granted=0)'),
(664, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 9 override set (granted=0)'),
(665, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 23 override set (granted=0)'),
(666, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 2 override set (granted=0)'),
(667, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 17 override set (granted=0)'),
(668, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 26 override set (granted=0)'),
(669, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 11 override set (granted=0)'),
(670, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 13 override set (granted=0)'),
(671, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 19 override set (granted=0)'),
(672, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 14 override set (granted=0)'),
(673, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 15 override set (granted=0)'),
(674, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 21 override set (granted=0)'),
(675, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 31 override set (granted=0)'),
(676, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 16 override set (granted=0)'),
(677, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 24 override set (granted=0)'),
(678, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:24:18', 'Permission ID 12 override set (granted=0)'),
(679, 'users', 18, 'STATUS_TOGGLE', 'Technical & User Support Officer', '2026-02-14 02:24:44', 'User disabled'),
(680, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 5 override set (granted=0)'),
(681, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 7 override set (granted=0)'),
(682, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 25 override set (granted=0)'),
(683, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 28 override set (granted=0)'),
(684, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 27 override set (granted=0)'),
(685, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 3 override set (granted=0)'),
(686, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 4 override set (granted=0)'),
(687, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 18 override set (granted=0)'),
(688, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 20 override set (granted=0)'),
(689, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 6 override set (granted=0)'),
(690, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 22 override set (granted=0)'),
(691, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 1 override set (granted=0)'),
(692, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 29 override set (granted=0)'),
(693, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 10 override set (granted=0)'),
(694, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 32 override set (granted=0)'),
(695, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 33 override set (granted=0)'),
(696, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 8 override set (granted=0)'),
(697, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 9 override set (granted=0)'),
(698, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 23 override set (granted=0)'),
(699, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 2 override set (granted=0)'),
(700, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 17 override set (granted=0)'),
(701, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 26 override set (granted=0)'),
(702, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 11 override set (granted=0)'),
(703, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 13 override set (granted=0)'),
(704, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 19 override set (granted=0)'),
(705, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 14 override set (granted=0)'),
(706, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 15 override set (granted=0)'),
(707, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 21 override set (granted=0)'),
(708, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 31 override set (granted=0)'),
(709, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 16 override set (granted=0)'),
(710, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 24 override set (granted=0)'),
(711, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 02:25:35', 'Permission ID 12 override set (granted=1)'),
(712, 'users', 2, 'LOCKOUT', NULL, '2026-02-14 02:26:33', 'Account locked after failed attempts'),
(713, 'procurement_requests', 71, 'CREATE', 'Technical & User Support Officer', '2026-02-14 03:31:45', 'Procurement request created'),
(714, 'procurement_requests', 71, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-14 03:31:52', 'Draft → Submitted'),
(715, 'users', 15, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-14 03:37:22', 'Admin reset user password'),
(716, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-14 03:38:14', 'Password updated'),
(717, 'user_permissions', 15, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 03:39:50', 'Permission 12 updated (granted=1)'),
(718, 'user_permissions', 15, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 03:54:53', 'Permission 12 updated (granted=1)'),
(719, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 03:55:21', 'Role updated to Finance Officer'),
(720, 'user_permissions', 15, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 04:00:17', 'Permission 33 updated (granted=1)'),
(721, 'user_permissions', 15, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 04:00:17', 'Permission 12 updated (granted=1)'),
(722, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 05:58:15', 'Role updated to Procurement Officer'),
(723, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 06:00:45', 'Role updated to Procurement Officer'),
(724, 'rfqs', NULL, 'CREATE', NULL, '2026-02-14 07:03:25', 'RFQ Created: RFQ-2026-001 for Request ID 69'),
(725, 'rfqs', 2, 'CREATE', 'Technical & User Support Officer', '2026-02-14 07:11:58', 'RFQ created for request ID 66'),
(726, 'rfq_vendors', 1, 'CREATE', 'Technical & User Support Officer', '2026-02-14 07:24:22', 'Vendor \'Printers & More\' added to RFQ RFQ-20260214-66'),
(727, 'vendors', 1, 'CREATE', 'Technical & User Support Officer', '2026-02-14 15:52:41', 'Vendor \'Printers & Office Supplies Limited\' created'),
(728, 'rfq_vendors', 2, 'CREATE', 'Technical & User Support Officer', '2026-02-14 15:53:31', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-2026-001'),
(729, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 16:02:50', 'Quote uploaded for RFQ ID 1'),
(730, 'vendors', 2, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:09:11', 'Vendor \'D&S IT Services Limited\' created'),
(731, 'rfqs', 3, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:09:46', 'RFQ created for request ID 64'),
(732, 'rfq_vendors', 3, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:09:52', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-20260214-64'),
(733, 'rfq_vendors', 4, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:09:56', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260214-64'),
(734, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 16:10:18', 'Quote uploaded for RFQ ID 3'),
(735, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 16:10:30', 'Quote uploaded for RFQ ID 3'),
(736, 'vendors', 3, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:11:32', 'Vendor \'Intcomex\' created'),
(737, 'rfq_vendors', 5, 'CREATE', 'Technical & User Support Officer', '2026-02-14 16:11:59', 'Vendor \'Intcomex\' added to RFQ RFQ-20260214-64'),
(738, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 16:12:10', 'Quote uploaded for RFQ ID 3'),
(739, 'rfqs', NULL, 'AWARD', NULL, '2026-02-14 16:12:16', 'RFQ ID 3 awarded to Quote ID 3'),
(740, 'rfqs', 4, 'CREATE', 'Technical & User Support Officer', '2026-02-14 18:08:12', 'RFQ created for request ID 65'),
(741, 'rfq_vendors', 6, 'CREATE', 'Technical & User Support Officer', '2026-02-14 18:08:17', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-20260214-65'),
(742, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 18:08:35', 'Quote uploaded for RFQ ID 4'),
(743, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 19:35:10', 'Role updated to Deputy Government Chemist'),
(744, 'user_permissions', 16, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 19:49:04', 'Permission 24 updated (granted=1)'),
(745, 'user_permissions', 16, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 19:49:04', 'Permission 12 updated (granted=1)'),
(746, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 20:36:03', 'Role updated to Evaluation Committee Member'),
(747, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 20:51:32', 'Role updated to HOD'),
(748, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 20:52:22', 'Role updated to Deputy Government Chemist'),
(749, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 20:53:30', 'Role updated to Procurement Committee'),
(750, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 21:11:43', 'Role updated to Deputy Government Chemist'),
(751, 'rfq_vendors', 7, 'CREATE', 'Technical & User Support Officer', '2026-02-14 21:26:50', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-2026-001'),
(752, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 21:27:08', 'Quote uploaded for RFQ ID 1'),
(753, 'rfq_vendors', 8, 'CREATE', 'Technical & User Support Officer', '2026-02-14 21:27:17', 'Vendor \'Intcomex\' added to RFQ RFQ-2026-001'),
(754, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 21:27:31', 'Quote uploaded for RFQ ID 1'),
(755, 'user_permissions', 16, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 21:33:10', 'Permission 1 updated (granted=1)'),
(756, 'user_permissions', 16, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 21:33:10', 'Permission 24 updated (granted=1)'),
(757, 'user_permissions', 16, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 21:33:10', 'Permission 12 updated (granted=1)'),
(758, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 21:52:57', 'Role updated to Procurement Officer'),
(759, 'users', 2, 'LOCKOUT', NULL, '2026-02-14 22:57:23', 'Account locked after failed attempts'),
(760, 'users', 2, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-14 23:00:17', 'Admin reset user password'),
(761, 'rfq_vendors', 9, 'CREATE', 'Technical & User Support Officer', '2026-02-14 23:02:23', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-20260214-66'),
(762, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 23:02:34', 'Quote uploaded for RFQ ID 2'),
(763, 'rfq_vendors', 10, 'CREATE', 'Technical & User Support Officer', '2026-02-14 23:04:58', 'Vendor \'Intcomex\' added to RFQ RFQ-20260214-66'),
(764, 'rfq_vendors', 11, 'CREATE', 'Technical & User Support Officer', '2026-02-14 23:05:02', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260214-66'),
(765, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 23:05:24', 'Quote uploaded for RFQ ID 2'),
(766, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 23:05:38', 'Quote uploaded for RFQ ID 2'),
(767, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:06:55', 'Role updated to Deputy Government Chemist'),
(768, 'rfq_vendors', 12, 'CREATE', 'Technical & User Support Officer', '2026-02-14 23:22:15', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260214-65'),
(769, 'rfq_vendors', 13, 'CREATE', 'Technical & User Support Officer', '2026-02-14 23:22:19', 'Vendor \'Intcomex\' added to RFQ RFQ-20260214-65'),
(770, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 23:22:35', 'Quote uploaded for RFQ ID 4'),
(771, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-14 23:22:52', 'Quote uploaded for RFQ ID 4'),
(772, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:25:58', 'Role updated to Evaluation Committee Member'),
(773, 'users', 9, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:26:06', 'Role updated to Evaluation Committee Member'),
(774, 'users', 6, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:26:14', 'Role updated to Finance Officer'),
(775, 'users', 9, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:39:27', 'Role updated to Procurement Officer'),
(776, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 5 updated (granted=1)'),
(777, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 7 updated (granted=1)'),
(778, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 25 updated (granted=1)'),
(779, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 28 updated (granted=1)'),
(780, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 27 updated (granted=1)'),
(781, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 3 updated (granted=0)'),
(782, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 4 updated (granted=1)'),
(783, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 18 updated (granted=0)'),
(784, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 20 updated (granted=0)'),
(785, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 6 updated (granted=1)'),
(786, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 22 updated (granted=1)'),
(787, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 1 updated (granted=1)'),
(788, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 29 updated (granted=1)'),
(789, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 10 updated (granted=0)'),
(790, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 32 updated (granted=0)'),
(791, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 33 updated (granted=0)'),
(792, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 8 updated (granted=0)'),
(793, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 9 updated (granted=0)'),
(794, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 23 updated (granted=1)'),
(795, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 2 updated (granted=1)'),
(796, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 17 updated (granted=0)'),
(797, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 26 updated (granted=1)'),
(798, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 11 updated (granted=1)'),
(799, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 13 updated (granted=0)'),
(800, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 19 updated (granted=0)'),
(801, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 14 updated (granted=0)'),
(802, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 15 updated (granted=0)'),
(803, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 21 updated (granted=0)'),
(804, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 31 updated (granted=0)'),
(805, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 16 updated (granted=1)'),
(806, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 24 updated (granted=1)'),
(807, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-14 23:42:29', 'Permission 12 updated (granted=1)'),
(808, 'users', 17, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:47:07', 'Role updated to Evaluation Committee Member'),
(809, 'users', 7, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:47:14', 'Role updated to Deputy Government Chemist'),
(810, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-14 23:47:26', 'Role updated to Evaluation Committee Member'),
(811, 'users', 18, 'STATUS_TOGGLE', 'Technical & User Support Officer', '2026-02-14 23:47:32', 'User re-enabled'),
(812, 'users', 18, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-15 00:13:20', 'Admin reset user password'),
(813, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-15 00:13:45', 'Password updated'),
(814, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-15 00:15:28', 'Permission 12 updated (granted=1)'),
(815, 'users', 2, 'DELETE', 'Technical & User Support Officer', '2026-02-15 15:10:51', 'User \'System Administrator\' (demario.ewan@moh.gov.jm) deleted.'),
(816, 'users', 9, 'STATUS_TOGGLE', 'Technical & User Support Officer', '2026-02-15 15:24:23', 'User disabled'),
(817, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 17:27:07', 'Role updated to Finance Officer'),
(818, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 17:40:01', 'Role updated to Procurement Officer'),
(819, 'users', 9, 'STATUS_TOGGLE', 'Technical & User Support Officer', '2026-02-15 20:43:25', 'User re-enabled'),
(820, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 20:48:35', 'Role updated to Evaluation Committee Member'),
(821, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 20:49:02', 'Role updated to Finance Officer'),
(822, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 20:50:01', 'Role updated to Deputy Government Chemist'),
(823, 'rfq_votes', 4, 'CREATE', 'Nellesha Samuels', '2026-02-15 20:50:42', 'Vote cast for vendor (rfq_vendor_id=6)'),
(824, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 20:51:23', 'Role updated to HOD'),
(825, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', 'Technical & User Support Officer', '2026-02-15 21:48:39', 'Back-dating of procurement request was attempted'),
(826, 'procurement_requests', 72, 'CREATE', 'Technical & User Support Officer', '2026-02-15 21:48:51', 'Procurement request created'),
(827, 'procurement_requests', 72, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-15 21:48:59', 'Draft → Submitted'),
(828, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 21:49:25', 'Role updated to Deputy Government Chemist'),
(829, 'users', 15, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-15 21:51:41', 'Role updated to HOD'),
(830, 'procurement_requests', 72, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:22:59', 'HOD Approved — Status changed to HOD_APPROVED'),
(831, 'procurement_requests', 72, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:22:59', 'HOD approval by Nellesha Samuels'),
(832, 'procurement_requests', 71, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:23:19', 'HOD Approved — Status changed to HOD_APPROVED'),
(833, 'procurement_requests', 71, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:23:19', 'HOD approval by Nellesha Samuels'),
(834, 'procurement_requests', 73, 'CREATE', 'Technical & User Support Officer', '2026-02-15 22:30:04', 'Procurement request created'),
(835, 'procurement_requests', 73, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-15 22:30:13', 'Draft → Submitted'),
(836, 'procurement_requests', 73, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:30:38', 'HOD Approved — Status changed to HOD_APPROVED'),
(837, 'procurement_requests', 73, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:30:38', 'HOD approval by Nellesha Samuels'),
(838, 'procurement_requests', 73, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:43:37', 'HOD Approved — Status changed to HOD_APPROVED'),
(839, 'procurement_requests', 73, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:43:37', 'HOD approval by Nellesha Samuels'),
(840, 'procurement_requests', 72, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:43:51', 'HOD Approved — Status changed to HOD_APPROVED'),
(841, 'procurement_requests', 72, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:43:51', 'HOD approval by Nellesha Samuels'),
(842, 'procurement_requests', 71, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-15 22:44:22', 'HOD Approved — Status changed to HOD_APPROVED'),
(843, 'procurement_requests', 71, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-15 22:44:22', 'HOD approval by Nellesha Samuels'),
(844, 'users', 15, 'DELETE', 'Technical & User Support Officer', '2026-02-16 00:10:23', 'User \'Accounts\' (a@gmail.com) deleted.'),
(845, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-16 00:11:09', 'Role updated to SuperAdmin'),
(846, 'users', 19, 'CREATE', 'Technical & User Support Officer', '2026-02-16 00:12:05', 'User \'Viewer\' (v@gmail.com) created by admin.'),
(847, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-16 00:15:32', 'Password updated'),
(848, 'procurement_requests', 74, 'CREATE', 'Gabrielle Green', '2026-02-16 00:16:34', 'Procurement request created'),
(849, 'procurement_requests', 74, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-16 00:16:42', 'Draft → Submitted'),
(850, 'procurement_requests', 74, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-16 00:16:54', 'HOD Approved — Status changed to HOD_APPROVED'),
(851, 'procurement_requests', 74, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-16 00:16:54', 'HOD approval by Nellesha Samuels'),
(852, 'procurement_requests', 74, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-16 00:43:32', 'Finance Approved — Status changed to FINANCE_APPROVED'),
(853, 'procurement_requests', 74, 'FINANCE_APPROVED', 'Latoya Gayle', '2026-02-16 00:43:32', 'Finance approval by Latoya Gayle'),
(854, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 5 updated (granted=1)'),
(855, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 7 updated (granted=1)'),
(856, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 25 updated (granted=1)'),
(857, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 28 updated (granted=1)'),
(858, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 27 updated (granted=1)'),
(859, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 3 updated (granted=0)'),
(860, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 4 updated (granted=1)'),
(861, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 18 updated (granted=0)'),
(862, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 20 updated (granted=0)'),
(863, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 6 updated (granted=1)'),
(864, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 22 updated (granted=1)'),
(865, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 1 updated (granted=1)'),
(866, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 29 updated (granted=1)'),
(867, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 10 updated (granted=0)'),
(868, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 32 updated (granted=0)'),
(869, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 33 updated (granted=0)'),
(870, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 8 updated (granted=0)'),
(871, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 9 updated (granted=0)'),
(872, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 23 updated (granted=1)'),
(873, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 2 updated (granted=1)');
INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(874, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 17 updated (granted=0)'),
(875, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 26 updated (granted=1)'),
(876, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 11 updated (granted=1)'),
(877, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 13 updated (granted=1)'),
(878, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 19 updated (granted=0)'),
(879, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 14 updated (granted=0)'),
(880, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 15 updated (granted=0)'),
(881, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 21 updated (granted=0)'),
(882, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 31 updated (granted=0)'),
(883, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 16 updated (granted=1)'),
(884, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 24 updated (granted=1)'),
(885, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 01:12:33', 'Permission 12 updated (granted=1)'),
(886, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 5 updated (granted=1)'),
(887, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 7 updated (granted=1)'),
(888, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 25 updated (granted=1)'),
(889, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 28 updated (granted=1)'),
(890, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 27 updated (granted=1)'),
(891, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 3 updated (granted=1)'),
(892, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 4 updated (granted=1)'),
(893, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 18 updated (granted=0)'),
(894, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 20 updated (granted=0)'),
(895, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 6 updated (granted=1)'),
(896, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 22 updated (granted=1)'),
(897, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 1 updated (granted=1)'),
(898, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 29 updated (granted=1)'),
(899, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 10 updated (granted=0)'),
(900, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 32 updated (granted=0)'),
(901, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 33 updated (granted=0)'),
(902, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 8 updated (granted=0)'),
(903, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 9 updated (granted=0)'),
(904, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 23 updated (granted=1)'),
(905, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 2 updated (granted=1)'),
(906, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 17 updated (granted=0)'),
(907, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 26 updated (granted=1)'),
(908, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 11 updated (granted=1)'),
(909, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 13 updated (granted=1)'),
(910, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 19 updated (granted=0)'),
(911, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 14 updated (granted=0)'),
(912, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 15 updated (granted=0)'),
(913, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 21 updated (granted=0)'),
(914, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 31 updated (granted=0)'),
(915, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 16 updated (granted=1)'),
(916, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 24 updated (granted=1)'),
(917, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:21:14', 'Permission 12 updated (granted=1)'),
(918, 'permissions', 45, 'CREATE', 'Technical & User Support Officer', '2026-02-16 02:23:23', 'Permission \'edit_requests\' created'),
(919, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 5 updated (granted=1)'),
(920, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 7 updated (granted=1)'),
(921, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 25 updated (granted=1)'),
(922, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 28 updated (granted=1)'),
(923, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 27 updated (granted=1)'),
(924, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 3 updated (granted=1)'),
(925, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 4 updated (granted=1)'),
(926, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 18 updated (granted=0)'),
(927, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 20 updated (granted=0)'),
(928, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 6 updated (granted=1)'),
(929, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 22 updated (granted=1)'),
(930, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 1 updated (granted=1)'),
(931, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 29 updated (granted=1)'),
(932, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 45 updated (granted=1)'),
(933, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 10 updated (granted=0)'),
(934, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 32 updated (granted=0)'),
(935, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 33 updated (granted=0)'),
(936, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 8 updated (granted=0)'),
(937, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 9 updated (granted=0)'),
(938, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 23 updated (granted=1)'),
(939, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 2 updated (granted=1)'),
(940, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 17 updated (granted=0)'),
(941, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 26 updated (granted=1)'),
(942, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 11 updated (granted=1)'),
(943, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 13 updated (granted=1)'),
(944, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 19 updated (granted=0)'),
(945, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 14 updated (granted=0)'),
(946, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 15 updated (granted=0)'),
(947, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 21 updated (granted=0)'),
(948, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 31 updated (granted=0)'),
(949, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 16 updated (granted=1)'),
(950, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 24 updated (granted=1)'),
(951, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:24:00', 'Permission 12 updated (granted=1)'),
(952, 'rfqs', 5, 'CREATE', 'Gabrielle Green', '2026-02-16 02:24:15', 'RFQ created for request ID 74'),
(953, 'rfq_evaluation_committee', 5, 'DELETE', 'Gabrielle Green', '2026-02-16 02:28:07', 'Committee member (user_id=17) removed from RFQ'),
(954, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 5 updated (granted=1)'),
(955, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 7 updated (granted=1)'),
(956, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 25 updated (granted=1)'),
(957, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 28 updated (granted=1)'),
(958, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 27 updated (granted=1)'),
(959, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 3 updated (granted=1)'),
(960, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 4 updated (granted=1)'),
(961, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 18 updated (granted=0)'),
(962, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 20 updated (granted=0)'),
(963, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 6 updated (granted=1)'),
(964, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 22 updated (granted=1)'),
(965, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 1 updated (granted=1)'),
(966, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 29 updated (granted=1)'),
(967, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 45 updated (granted=1)'),
(968, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 10 updated (granted=0)'),
(969, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 32 updated (granted=0)'),
(970, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 33 updated (granted=1)'),
(971, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 8 updated (granted=0)'),
(972, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 9 updated (granted=0)'),
(973, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 23 updated (granted=1)'),
(974, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 2 updated (granted=1)'),
(975, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 17 updated (granted=0)'),
(976, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 26 updated (granted=1)'),
(977, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 11 updated (granted=1)'),
(978, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 13 updated (granted=1)'),
(979, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 19 updated (granted=0)'),
(980, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 14 updated (granted=0)'),
(981, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 15 updated (granted=0)'),
(982, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 21 updated (granted=0)'),
(983, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 31 updated (granted=0)'),
(984, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 16 updated (granted=1)'),
(985, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 24 updated (granted=1)'),
(986, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:29:33', 'Permission 12 updated (granted=1)'),
(987, 'users', 19, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-16 02:30:20', 'Role updated to Evaluation Committee Member'),
(988, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-16 02:30:53', 'Role updated to Evaluation Committee Member'),
(989, 'rfq_vendors', 14, 'CREATE', 'Gabrielle Green', '2026-02-16 02:33:14', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-20260215-74'),
(990, 'rfq_vendors', 15, 'CREATE', 'Gabrielle Green', '2026-02-16 02:34:53', 'Vendor \'Intcomex\' added to RFQ RFQ-20260215-74'),
(991, 'rfq_vendors', 16, 'CREATE', 'Gabrielle Green', '2026-02-16 02:34:59', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260215-74'),
(992, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 02:35:22', 'Quote uploaded for RFQ ID 5'),
(993, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 02:35:35', 'Quote uploaded for RFQ ID 5'),
(994, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 02:35:50', 'Quote uploaded for RFQ ID 5'),
(995, 'users', 17, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-16 02:36:20', 'Admin reset user password'),
(996, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-16 02:38:06', 'Password updated'),
(997, 'permissions', 46, 'CREATE', 'Technical & User Support Officer', '2026-02-16 02:39:39', 'Permission \'view_evaluation\' created'),
(998, 'user_permissions', 17, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:40:35', 'Permission 46 updated (granted=1)'),
(999, 'user_permissions', 17, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:41:25', 'Permission 46 updated (granted=1)'),
(1000, 'user_permissions', 17, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:41:25', 'Permission 12 updated (granted=1)'),
(1001, 'rfq_votes', 5, 'CREATE', 'Shermaine McKenzie', '2026-02-16 02:41:51', 'Vote cast for vendor (rfq_vendor_id=15)'),
(1002, 'rfq_votes', 5, 'CREATE', 'Demario Ewan', '2026-02-16 02:42:54', 'Vote cast for vendor (rfq_vendor_id=14)'),
(1003, 'user_permissions', 19, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:45:39', 'Permission 12 updated (granted=1)'),
(1004, 'rfq_votes', 5, 'CREATE', 'Viewer', '2026-02-16 02:45:58', 'Vote cast for vendor (rfq_vendor_id=14)'),
(1005, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 02:48:53', 'Quote uploaded for RFQ ID 5'),
(1006, 'users', 21, 'CREATE', 'Technical & User Support Officer', '2026-02-16 02:54:50', 'User \'Deputy Government Chemist\' (d@gmail.com) created by admin.'),
(1007, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-16 02:55:20', 'Password updated'),
(1008, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 02:55:59', 'Permission 12 updated (granted=1)'),
(1009, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 03:06:45', 'Permission 1 updated (granted=1)'),
(1010, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 03:06:45', 'Permission 12 updated (granted=1)'),
(1011, 'procurement_requests', 75, 'CREATE', 'Gabrielle Green', '2026-02-16 03:34:53', 'Procurement request created'),
(1012, 'procurement_requests', 75, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-16 03:35:01', 'Draft → Submitted'),
(1013, 'procurement_requests', 75, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-16 03:35:33', 'HOD Approved — Status changed to HOD_APPROVED'),
(1014, 'procurement_requests', 75, 'HOD_APPROVED', 'Nellesha Samuels', '2026-02-16 03:35:33', 'HOD approval by Nellesha Samuels'),
(1015, 'procurement_requests', 75, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-16 03:36:34', 'Finance Approved — Status changed to FINANCE_APPROVED'),
(1016, 'procurement_requests', 75, 'FINANCE_APPROVED', 'Latoya Gayle', '2026-02-16 03:36:34', 'Finance approval by Latoya Gayle'),
(1017, 'rfqs', 6, 'CREATE', 'Gabrielle Green', '2026-02-16 03:36:57', 'RFQ created for request ID 75'),
(1018, 'rfq_vendors', 17, 'CREATE', 'Gabrielle Green', '2026-02-16 03:41:26', 'Vendor \'D&S IT Services Limited\' added to RFQ RFQ-20260215-75'),
(1019, 'rfq_vendors', 18, 'CREATE', 'Gabrielle Green', '2026-02-16 03:41:32', 'Vendor \'Intcomex\' added to RFQ RFQ-20260215-75'),
(1020, 'rfq_vendors', 19, 'CREATE', 'Gabrielle Green', '2026-02-16 03:41:38', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260215-75'),
(1021, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 03:42:43', 'Quote uploaded for RFQ ID 6'),
(1022, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 03:43:01', 'Quote uploaded for RFQ ID 6'),
(1023, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 03:43:28', 'Quote uploaded for RFQ ID 6'),
(1024, 'rfq_votes', 6, 'CREATE', 'Demario Ewan', '2026-02-16 03:43:54', 'Vote cast for vendor (rfq_vendor_id=19)'),
(1025, 'rfq_votes', 6, 'CREATE', 'Shermaine McKenzie', '2026-02-16 03:45:01', 'Vote cast for vendor (rfq_vendor_id=19)'),
(1026, 'rfq_votes', 6, 'CREATE', 'Viewer', '2026-02-16 03:46:27', 'Vote cast for vendor (rfq_vendor_id=19)'),
(1027, 'rfqs', 6, 'AWARD', 'Deputy Government Chemist', '2026-02-16 03:57:08', 'RFQ awarded to Vendor ID 2 (Quote ID 17)'),
(1028, 'rfqs', 5, 'AWARD', 'Deputy Government Chemist', '2026-02-16 03:58:08', 'RFQ awarded to Vendor ID 3 (Quote ID 14)'),
(1029, 'rfqs', 5, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-16 04:20:25', 'Award ACCEPTED by vendor'),
(1030, 'commitments', 71, 'CREATE', 'Gabrielle Green', '2026-02-16 04:21:16', 'Commitment created'),
(1031, 'procurement_requests', 74, 'COMMITMENT_APPROVED_', 'Nellesha Samuels', '2026-02-16 15:00:57', 'Commitment CM001 approved by HOD'),
(1032, 'commitments', 71, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-16 15:00:57', 'Approved by HOD'),
(1033, 'procurement_requests', 74, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-16 15:02:00', 'Commitment CM001 approved by Finance Officer'),
(1034, 'commitments', 71, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-16 15:02:00', 'Approved by Finance Officer'),
(1035, 'procurement_requests', 74, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-16 15:02:00', 'Commitment CM001 fully approved'),
(1036, 'commitments', 71, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-16 15:02:00', 'All approval stages complete'),
(1037, 'purchase_orders', 56, 'CREATE', 'Gabrielle Green', '2026-02-16 15:02:55', 'Purchase Order created'),
(1038, 'procurement_requests', 74, 'PO_APPROVED_STAGE', 'Nellesha Samuels', '2026-02-16 16:09:33', 'PO PO-2026-0001 approved by HOD'),
(1039, 'purchase_orders', 56, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-16 16:09:33', 'Approved by HOD'),
(1040, 'procurement_requests', 74, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-16 16:12:00', 'PO PO-2026-0001 approved by Finance Officer'),
(1041, 'purchase_orders', 56, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-16 16:12:00', 'Approved by Finance Officer'),
(1042, 'procurement_requests', 74, 'PO_FULLY_APPROVED', 'Latoya Gayle', '2026-02-16 16:12:00', 'PO PO-2026-0001 fully approved'),
(1043, 'purchase_orders', 56, 'PO_APPROVED', 'Latoya Gayle', '2026-02-16 16:12:00', 'All approval stages complete'),
(1044, 'invoices', 59, 'CREATE', 'Latoya Gayle', '2026-02-16 16:21:50', 'Invoice added by user ID 6'),
(1045, 'invoices', 60, 'CREATE', 'Latoya Gayle', '2026-02-16 16:22:19', 'Invoice added by user ID 6'),
(1046, 'payments', 56, 'CREATE', 'Latoya Gayle', '2026-02-16 16:25:36', 'Payment recorded'),
(1047, 'payments', 57, 'CREATE', 'Latoya Gayle', '2026-02-16 16:26:34', 'Payment recorded'),
(1048, 'payments', 58, 'CREATE', 'Latoya Gayle', '2026-02-16 16:26:53', 'Payment recorded'),
(1049, 'vendors', 2, 'UPDATE', 'Technical & User Support Officer', '2026-02-16 16:31:11', 'Updated: Name: D&S IT Services Limited → Accu Power Limited; Email: ssmith@dsitservicesja.com → accu@accupower.com'),
(1050, 'vendors', 3, 'UPDATE', 'Technical & User Support Officer', '2026-02-16 16:31:49', 'Updated: Name: Intcomex → Intcomex Limited'),
(1051, 'rfqs', 6, 'STATUS_CHANGE', 'Gabrielle Green', '2026-02-16 16:33:25', 'Award DECLINED by vendor'),
(1052, 'users', 7, 'DELETE', 'Technical & User Support Officer', '2026-02-16 17:08:56', 'User \'Yanique A. Fraser\' (yanique.fraser@moh.gov.jm) deleted.'),
(1053, 'users', 22, 'CREATE', 'Technical & User Support Officer', '2026-02-16 17:09:27', 'User \'Yanique A. Fraser\' (yanique.fraser@moh.gov.jm) created by admin.'),
(1054, 'procurement_requests', 76, 'CREATE', 'Technical & User Support Officer', '2026-02-16 18:07:56', 'Procurement request created'),
(1055, 'procurement_requests', 76, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-16 18:08:37', 'Draft → Submitted'),
(1056, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-16 18:11:21', 'Password updated'),
(1057, 'procurement_requests', 76, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-02-16 18:14:50', 'HOD Approved — Status changed to HOD_APPROVED'),
(1058, 'procurement_requests', 76, 'HOD_APPROVED', 'Yanique A. Fraser', '2026-02-16 18:14:50', 'HOD approval by Yanique A. Fraser'),
(1059, 'procurement_requests', 76, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-16 18:17:19', 'Finance Approved — Status changed to FINANCE_APPROVED'),
(1060, 'procurement_requests', 76, 'FINANCE_APPROVED', 'Latoya Gayle', '2026-02-16 18:17:19', 'Finance approval by Latoya Gayle'),
(1061, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-16 18:18:03', 'Role updated to Procurement Officer'),
(1062, 'users', 9, 'ADMIN_PASSWORD_RESET', 'Technical & User Support Officer', '2026-02-16 18:21:49', 'Admin reset user password'),
(1063, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-16 18:22:16', 'Password updated'),
(1064, 'rfqs', 7, 'CREATE', 'Gabrielle Green', '2026-02-16 18:23:13', 'RFQ created for request ID 76'),
(1065, 'rfq_vendors', 20, 'CREATE', 'Gabrielle Green', '2026-02-16 18:23:27', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260216-76'),
(1066, 'rfq_vendors', 21, 'CREATE', 'Gabrielle Green', '2026-02-16 18:23:31', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260216-76'),
(1067, 'rfq_vendors', 22, 'CREATE', 'Gabrielle Green', '2026-02-16 18:23:35', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260216-76'),
(1068, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 18:25:43', 'Quote uploaded for RFQ ID 7'),
(1069, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 18:26:00', 'Quote uploaded for RFQ ID 7'),
(1070, 'rfq_votes', 7, 'CREATE', 'Shermaine McKenzie', '2026-02-16 18:29:19', 'Vote cast for vendor (rfq_vendor_id=20)'),
(1071, 'rfq_votes', 7, 'CREATE', 'Demario Ewan', '2026-02-16 18:37:45', 'Vote cast for vendor (rfq_vendor_id=20)'),
(1072, 'rfq_votes', 7, 'CREATE', 'Viewer', '2026-02-16 18:50:24', 'Vote cast for vendor (rfq_vendor_id=20)'),
(1073, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 28 updated (granted=1)'),
(1074, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 4 updated (granted=1)'),
(1075, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 45 updated (granted=1)'),
(1076, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 10 updated (granted=1)'),
(1077, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 8 updated (granted=1)'),
(1078, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 9 updated (granted=1)'),
(1079, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 23 updated (granted=1)'),
(1080, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 2 updated (granted=1)'),
(1081, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 17 updated (granted=1)'),
(1082, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 48 updated (granted=1)'),
(1083, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 46 updated (granted=1)'),
(1084, 'user_permissions', 22, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 18:54:24', 'Permission 31 updated (granted=1)'),
(1085, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-16 18:56:06', 'Quote uploaded for RFQ ID 7'),
(1086, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 19:00:29', 'Permission 1 updated (granted=1)'),
(1087, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 19:00:29', 'Permission 45 updated (granted=1)'),
(1088, 'user_permissions', 21, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-16 19:00:29', 'Permission 12 updated (granted=1)'),
(1089, 'procurement_requests', 77, 'CREATE', 'Technical & User Support Officer', '2026-02-17 02:59:11', 'Procurement request created'),
(1090, 'procurement_requests', 77, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-17 02:59:22', 'Draft → Submitted'),
(1091, 'users', 21, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-17 03:01:51', 'Role updated to HOD'),
(1092, 'procurement_requests', 77, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-17 03:02:10', 'HOD Approved — Status changed to HOD_APPROVED'),
(1093, 'procurement_requests', 77, 'HOD_APPROVED', 'Deputy Government Chemist', '2026-02-17 03:02:10', 'HOD approval by Deputy Government Chemist'),
(1094, 'procurement_requests', 77, 'STATUS_CHANGE', 'Latoya Gayle', '2026-02-17 03:33:40', 'Finance Verified Funds — Status changed to FUNDS_VERIFIED'),
(1095, 'procurement_requests', 77, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-02-17 03:33:40', 'Finance verification by Latoya Gayle'),
(1096, 'users', 23, 'CREATE', 'Technical & User Support Officer', '2026-02-17 03:45:26', 'User \'Requestor 1\' (r@gmail.com) created by admin.'),
(1097, 'users', NULL, 'PASSWORD_CHANGE', NULL, '2026-02-17 03:45:43', 'Password updated'),
(1098, 'permissions', 54, 'CREATE', 'Technical & User Support Officer', '2026-02-17 03:47:46', 'Permission \'view_own_requests\' created'),
(1099, 'user_permissions', 23, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 03:48:47', 'Permission 54 updated (granted=1)'),
(1100, 'user_permissions', 23, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 03:49:47', 'Permission 1 updated (granted=1)'),
(1101, 'user_permissions', 23, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 03:49:47', 'Permission 54 updated (granted=1)'),
(1102, 'permissions', 55, 'CREATE', 'Technical & User Support Officer', '2026-02-17 21:30:43', 'Permission \'manage_system_settings\' created'),
(1103, 'user_permissions', 4, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 21:31:13', 'Permission 55 updated (granted=1)'),
(1104, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-17 21:42:25', 'Role updated to Director HRM&A'),
(1105, 'procurement_requests', 78, 'CREATE', 'Technical & User Support Officer', '2026-02-17 21:42:57', 'Procurement request created'),
(1106, 'procurement_requests', 78, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-17 21:43:11', 'Draft → Submitted'),
(1107, 'procurement_requests', 78, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-17 21:43:11', 'Approval chain created: Director HRM&A'),
(1108, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-17 21:45:21', 'Notification settings updated: enable_notifications=ON'),
(1109, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-17 21:46:09', 'Notification settings updated: enable_notifications=ON'),
(1110, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-17 21:46:13', 'Notification settings updated: enable_notifications=ON'),
(1111, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-17 23:24:21', 'Role updated to Deputy Government Chemist'),
(1112, 'procurement_requests', 79, 'CREATE', 'Technical & User Support Officer', '2026-02-17 23:25:10', 'Procurement request created'),
(1113, 'procurement_requests', 79, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-17 23:25:27', 'Draft → Submitted'),
(1114, 'procurement_requests', 79, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-17 23:25:27', 'Approval chain created: Deputy Government Chemist'),
(1115, 'procurement_requests', 80, 'CREATE', 'Technical & User Support Officer', '2026-02-17 23:29:11', 'Procurement request created'),
(1116, 'procurement_requests', 81, 'CREATE', 'Technical & User Support Officer', '2026-02-17 23:31:12', 'Procurement request created'),
(1117, 'procurement_requests', 81, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-17 23:33:54', 'Draft → Submitted'),
(1118, 'procurement_requests', 81, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-17 23:33:54', 'Approval chain created: Deputy Government Chemist'),
(1119, 'users', 18, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-17 23:41:14', 'Role updated to Director HRM&A'),
(1120, 'permissions', 56, 'CREATE', 'Technical & User Support Officer', '2026-02-17 23:42:44', 'Permission \'approve_as_director_hrma\' created'),
(1121, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 23:43:25', 'Permission 56 updated (granted=1)'),
(1122, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 23:43:25', 'Permission 12 updated (granted=1)'),
(1123, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 23:45:47', 'Permission 56 updated (granted=1)'),
(1124, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 23:45:47', 'Permission 3 updated (granted=1)'),
(1125, 'user_permissions', 18, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-17 23:45:47', 'Permission 12 updated (granted=1)'),
(1126, 'request_approvals', 5, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-17 23:46:07', 'Approved by Director HRM&A'),
(1127, 'procurement_requests', 79, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-17 23:47:42', 'HOD Approved — Status changed to HOD_APPROVED by HOD (as fallback for Deputy Government Chemist)'),
(1128, 'procurement_requests', 79, 'HOD_APPROVED', 'Deputy Government Chemist', '2026-02-17 23:47:42', 'HOD approval by Deputy Government Chemist - HOD (as fallback for Deputy Government Chemist)'),
(1129, 'procurement_requests', 81, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-17 23:47:56', 'HOD Approved — Status changed to HOD_APPROVED by HOD (as fallback for Deputy Government Chemist)'),
(1130, 'procurement_requests', 81, 'HOD_APPROVED', 'Deputy Government Chemist', '2026-02-17 23:47:56', 'HOD approval by Deputy Government Chemist - HOD (as fallback for Deputy Government Chemist)'),
(1131, 'procurement_requests', 82, 'CREATE', 'Technical & User Support Officer', '2026-02-17 23:50:16', 'Procurement request created'),
(1132, 'procurement_requests', 82, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-17 23:50:31', 'Draft → Submitted'),
(1133, 'procurement_requests', 82, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-17 23:50:31', 'Approval chain created: Deputy Government Chemist'),
(1134, 'procurement_requests', 83, 'CREATE', 'Technical & User Support Officer', '2026-02-18 00:11:24', 'Procurement request created'),
(1135, 'procurement_requests', 83, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 00:11:36', 'Draft → Submitted'),
(1136, 'procurement_requests', 83, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 00:11:36', 'Approval chain created: Deputy Government Chemist'),
(1137, 'users', 22, 'STATUS_TOGGLE', 'Technical & User Support Officer', '2026-02-18 00:17:02', 'User disabled'),
(1138, 'procurement_requests', 84, 'CREATE', 'Technical & User Support Officer', '2026-02-18 00:19:58', 'Procurement request created'),
(1139, 'procurement_requests', 84, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 00:20:49', 'Draft → Submitted'),
(1140, 'procurement_requests', 84, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 00:20:49', 'Approval chain created: Deputy Government Chemist'),
(1141, 'procurement_requests', 85, 'CREATE', 'Technical & User Support Officer', '2026-02-18 00:30:38', 'Procurement request created'),
(1142, 'procurement_requests', 85, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 00:31:55', 'Draft → Submitted'),
(1143, 'procurement_requests', 85, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 00:31:55', 'Approval chain created: Deputy Government Chemist'),
(1144, 'request_approvals', 8, 'APPROVE_STAGE', 'Demario Ewan', '2026-02-18 03:02:19', 'Approved by Deputy Government Chemist'),
(1145, 'request_approvals', 9, 'APPROVE_STAGE', 'Demario Ewan', '2026-02-18 03:02:28', 'Approved by Deputy Government Chemist'),
(1146, 'request_approvals', 10, 'APPROVE_STAGE', 'Demario Ewan', '2026-02-18 03:02:37', 'Approved by Deputy Government Chemist'),
(1147, 'request_approvals', 11, 'APPROVE_STAGE', 'Demario Ewan', '2026-02-18 03:02:41', 'Approved by Deputy Government Chemist'),
(1148, 'procurement_requests', 80, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 03:08:35', 'Draft → Submitted'),
(1149, 'procurement_requests', 80, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 03:08:35', 'Approval chain created: Deputy Government Chemist'),
(1150, 'procurement_requests', 85, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-18 03:15:16', 'Submitted → Declined'),
(1151, 'procurement_requests', 85, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 03:23:12', 'Declined → Draft (Resubmitted by Technical & User Support Officer)'),
(1152, 'procurement_requests', 85, 'RESUBMITTED', 'Technical & User Support Officer', '2026-02-18 03:23:12', 'Request resubmitted after decline by Technical & User Support Officer'),
(1153, 'procurement_requests', 85, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 03:35:56', 'Draft → Submitted'),
(1154, 'procurement_requests', 85, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 03:35:56', 'Approval chain created: Deputy Government Chemist'),
(1155, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-18 03:36:17', 'Notification settings updated: enable_notifications=OFF'),
(1156, 'request_approvals', 12, 'APPROVE_STAGE', 'Demario Ewan', '2026-02-18 03:38:27', 'Approved by Deputy Government Chemist'),
(1157, 'procurement_requests', 84, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-18 03:47:26', 'GC Approved — Status changed to GC_APPROVED'),
(1158, 'procurement_requests', 84, 'GC_APPROVED', 'Demario Ewan', '2026-02-18 03:47:26', 'GC final approval by Demario Ewan'),
(1159, 'procurement_requests', 85, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-18 03:49:23', 'GC Approved — Status changed to GC_APPROVED'),
(1160, 'procurement_requests', 85, 'GC_APPROVED', 'Demario Ewan', '2026-02-18 03:49:23', 'GC final approval by Demario Ewan'),
(1161, 'procurement_requests', 86, 'CREATE', 'Technical & User Support Officer', '2026-02-18 05:23:23', 'Procurement request created'),
(1162, 'procurement_requests', 86, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 05:23:31', 'Draft → Submitted'),
(1163, 'procurement_requests', 86, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 05:23:31', 'Approval chain created: HOD'),
(1164, 'procurement_requests', 86, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-18 05:35:52', 'Approved — Status changed to AWARDED by HOD'),
(1165, 'procurement_requests', 86, 'AWARDED', 'Deputy Government Chemist', '2026-02-18 05:35:52', 'Approval by Deputy Government Chemist - HOD'),
(1166, 'procurement_requests', 85, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-18 14:07:01', 'GC Approved — Status changed to AWARDED'),
(1167, 'procurement_requests', 85, 'AWARDED', 'Demario Ewan', '2026-02-18 14:07:01', 'GC approval by Demario Ewan'),
(1168, 'commitments', 72, 'CREATE', 'Gabrielle Green', '2026-02-18 14:13:54', 'Commitment created with HOD → Finance approval chain'),
(1169, 'procurement_requests', 86, 'COMMITMENT_CREATED', 'Gabrielle Green', '2026-02-18 14:13:54', 'Commitment CM002 created — awaiting HOD approval'),
(1170, 'procurement_requests', 86, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-18 14:23:44', 'Commitment CM002 approved by HOD'),
(1171, 'commitments', 72, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-18 14:23:44', 'Approved by HOD'),
(1172, 'procurement_requests', 86, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-18 14:24:29', 'Commitment CM002 approved by Finance Officer'),
(1173, 'commitments', 72, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-18 14:24:29', 'Approved by Finance Officer'),
(1174, 'procurement_requests', 86, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-18 14:24:29', 'Commitment CM002 fully approved'),
(1175, 'commitments', 72, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-18 14:24:29', 'All approval stages complete'),
(1176, 'user_permissions', 6, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-18 15:06:42', 'Permission 108 updated (granted=1)'),
(1177, 'user_permissions', 6, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-18 15:06:42', 'Permission 109 updated (granted=1)'),
(1178, 'procurement_requests', 87, 'CREATE', 'Requestor 1', '2026-02-18 15:10:53', 'Procurement request created'),
(1179, 'procurement_requests', 87, 'STATUS_CHANGE', 'Requestor 1', '2026-02-18 15:11:03', 'Draft → Submitted'),
(1180, 'procurement_requests', 87, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-18 15:11:03', 'Approval chain created: HOD'),
(1181, 'procurement_requests', 87, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-18 15:11:34', 'Approved — Status changed to AWARDED by HOD'),
(1182, 'procurement_requests', 87, 'AWARDED', 'Deputy Government Chemist', '2026-02-18 15:11:34', 'Approval by Deputy Government Chemist - HOD'),
(1183, 'commitments', 73, 'CREATE', 'Gabrielle Green', '2026-02-18 15:13:59', 'Commitment created with approval chain: HOD → Finance Officer'),
(1184, 'procurement_requests', 87, 'COMMITMENT_CREATED', 'Gabrielle Green', '2026-02-18 15:13:59', 'Commitment CM003 created — awaiting HOD approval'),
(1185, 'procurement_requests', 87, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-18 15:16:33', 'Commitment CM003 approved by HOD'),
(1186, 'commitments', 73, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-18 15:16:33', 'Approved by HOD'),
(1187, 'purchase_orders', 57, 'CREATE', 'Gabrielle Green', '2026-02-18 15:49:05', 'Purchase Order created'),
(1188, 'procurement_requests', 87, 'PO_CREATED', 'Gabrielle Green', '2026-02-18 15:49:05', 'PO PO-2026-0002 created, pending HOD + Finance approval'),
(1189, 'procurement_requests', 88, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:01:35', 'Reimbursement request created'),
(1190, 'pre_authorizations', 1189, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:01:35', 'Pre-authorization created for reimbursement'),
(1191, 'procurement_requests', 89, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:05:52', 'Reimbursement request created'),
(1192, 'pre_authorizations', 1191, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:05:52', 'Pre-authorization created for reimbursement'),
(1193, 'procurement_requests', 90, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:06:58', 'Petty cash request created'),
(1194, 'procurement_requests', 91, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:09:05', 'Reimbursement request created'),
(1195, 'pre_authorizations', 1194, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:09:05', 'Pre-authorization created for reimbursement'),
(1196, 'procurement_requests', 92, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:10:19', 'Petty cash request created'),
(1197, 'procurement_requests', 93, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:12:11', 'Petty cash request created'),
(1198, 'procurement_requests', 94, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:12:53', 'Petty cash request created'),
(1199, 'procurement_requests', 95, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:23:41', 'Petty cash request created'),
(1200, 'procurement_requests', 96, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:26:44', 'Petty cash request created'),
(1201, 'procurement_requests', 97, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:28:58', 'Petty cash request created'),
(1202, 'procurement_requests', 97, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 16:29:08', 'Petty Cash Request: Draft → Submitted'),
(1203, 'procurement_requests', 97, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 16:29:08', 'Petty cash approval chain created: HOD → Procurement Officer → Finance Officer'),
(1204, 'procurement_requests', 98, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:34:29', 'Petty cash request created'),
(1205, 'procurement_requests', 98, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 16:34:33', 'Petty Cash Request: Draft → Submitted'),
(1206, 'procurement_requests', 98, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 16:34:33', 'Petty cash approval chain created: HOD → Procurement Officer → Finance Officer'),
(1207, 'procurement_requests', 99, 'CREATE', 'Technical & User Support Officer', '2026-02-18 16:42:35', 'Petty cash request created'),
(1208, 'procurement_requests', 99, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 16:42:39', 'Petty Cash Request: Draft → Submitted'),
(1209, 'procurement_requests', 99, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 16:42:39', 'Petty cash approval chain created: HOD → Procurement Officer → Finance Officer'),
(1210, 'procurement_requests', 100, 'CREATE', 'Technical & User Support Officer', '2026-02-18 17:41:16', 'Procurement request created'),
(1211, 'procurement_requests', 100, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-18 17:41:25', 'Draft → Submitted'),
(1212, 'procurement_requests', 100, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-18 17:41:25', 'Approval chain created: HOD'),
(1213, 'request_approvals', 31, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-18 17:46:14', 'Approved by HOD'),
(1214, 'procurement_requests', 100, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-18 17:46:14', 'Approved → AWARDED by HOD'),
(1215, 'procurement_requests', 100, 'AWARDED', 'Deputy Government Chemist', '2026-02-18 17:46:14', 'Approval by HOD'),
(1216, 'commitments', 74, 'CREATE', 'Technical & User Support Officer', '2026-02-18 17:55:31', 'Commitment created with approval chain: HOD → Finance Officer'),
(1217, 'procurement_requests', 100, 'COMMITMENT_CREATED', 'Technical & User Support Officer', '2026-02-18 17:55:31', 'Commitment CM001 created — awaiting HOD approval'),
(1218, 'procurement_requests', 100, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-18 18:18:51', 'Commitment CM001 approved by HOD'),
(1219, 'commitments', 74, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-18 18:18:51', 'Approved by HOD'),
(1220, 'procurement_requests', 100, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-18 18:19:16', 'Commitment CM001 approved by Finance Officer'),
(1221, 'commitments', 74, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-18 18:19:16', 'Approved by Finance Officer'),
(1222, 'procurement_requests', 100, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-18 18:19:16', 'Commitment CM001 fully approved'),
(1223, 'commitments', 74, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-18 18:19:16', 'All approval stages complete'),
(1224, 'purchase_orders', 58, 'CREATE', 'Technical & User Support Officer', '2026-02-18 22:23:28', 'Purchase Order created'),
(1225, 'procurement_requests', 100, 'PO_CREATED', 'Technical & User Support Officer', '2026-02-18 22:23:28', 'PO PO-2026-0001 created, pending HOD + Finance approval'),
(1226, 'procurement_requests', 100, 'PO_APPROVED_STAGE', 'Deputy Government Chemist', '2026-02-18 22:25:53', 'PO PO-2026-0001 approved by HOD'),
(1227, 'purchase_orders', 58, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-18 22:25:53', 'Approved by HOD'),
(1228, 'procurement_requests', 100, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-18 22:26:27', 'PO PO-2026-0001 approved by Finance Officer'),
(1229, 'purchase_orders', 58, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-18 22:26:27', 'Approved by Finance Officer'),
(1230, 'procurement_requests', 100, 'PO_FULLY_APPROVED', 'Latoya Gayle', '2026-02-18 22:26:27', 'PO PO-2026-0001 fully approved'),
(1231, 'purchase_orders', 58, 'PO_APPROVED', 'Latoya Gayle', '2026-02-18 22:26:27', 'All approval stages complete'),
(1232, 'invoices', 61, 'CREATE', 'Latoya Gayle', '2026-02-18 22:26:51', 'Invoice added by user ID 6'),
(1233, 'payments', 59, 'CREATE', 'Latoya Gayle', '2026-02-18 22:27:30', 'Payment recorded');
INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(1234, 'procurement_requests', 101, 'CREATE', 'Requestor 1', '2026-02-19 00:47:12', 'Procurement request created'),
(1235, 'procurement_requests', 101, 'STATUS_CHANGE', 'Requestor 1', '2026-02-19 00:47:18', 'Draft → Submitted'),
(1236, 'procurement_requests', 101, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-19 00:47:18', 'Approval chain created: HOD'),
(1237, 'procurement_requests', 101, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-19 00:48:01', 'Approved — Status changed to AWARDED by HOD'),
(1238, 'procurement_requests', 101, 'AWARDED', 'Deputy Government Chemist', '2026-02-19 00:48:01', 'Approval by Deputy Government Chemist - HOD'),
(1239, 'procurement_requests', 102, 'CREATE', 'Requestor 1', '2026-02-19 01:36:29', 'Procurement request created'),
(1240, 'procurement_requests', 102, 'STATUS_CHANGE', 'Requestor 1', '2026-02-19 01:36:34', 'Draft → Submitted'),
(1241, 'procurement_requests', 102, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-19 01:36:34', 'Approval chain created: HOD'),
(1242, 'procurement_requests', 103, 'CREATE', 'Requestor 1', '2026-02-19 01:37:04', 'Procurement request created'),
(1243, 'procurement_requests', 103, 'STATUS_CHANGE', 'Requestor 1', '2026-02-19 01:37:08', 'Draft → Submitted'),
(1244, 'procurement_requests', 103, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-19 01:37:08', 'Approval chain created: HOD'),
(1245, 'procurement_requests', 102, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-19 01:39:15', 'Approved — Status changed to AWARDED by HOD'),
(1246, 'procurement_requests', 102, 'AWARDED', 'Deputy Government Chemist', '2026-02-19 01:39:15', 'Approval by Deputy Government Chemist - HOD'),
(1247, 'commitments', 75, 'CREATE', 'Gabrielle Green', '2026-02-19 01:41:31', 'Commitment created with approval chain: HOD → Finance Officer'),
(1248, 'procurement_requests', 102, 'COMMITMENT_CREATED', 'Gabrielle Green', '2026-02-19 01:41:31', 'Commitment CM002 created — awaiting HOD approval'),
(1249, 'commitments', 76, 'CREATE', 'Technical & User Support Officer', '2026-02-19 14:52:07', 'Commitment created with approval chain: HOD → Finance Officer'),
(1250, 'procurement_requests', 101, 'COMMITMENT_CREATED', 'Technical & User Support Officer', '2026-02-19 14:52:07', 'Commitment CM003 created — awaiting HOD approval'),
(1251, 'DATABASE', 0, 'SCHEMA_CHANGE', NULL, '2026-02-19 14:54:15', 'Added document_path fields to commitments and purchase_orders tables for GFMS integration'),
(1252, 'procurement_requests', 104, 'CREATE', 'Technical & User Support Officer', '2026-02-19 15:08:08', 'Procurement request created'),
(1253, 'procurement_requests', 104, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-19 15:08:15', 'Draft → Submitted'),
(1254, 'procurement_requests', 104, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-19 15:08:15', 'Approval chain created: Deputy Government Chemist'),
(1255, 'procurement_requests', 104, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-19 15:08:49', 'GC Approved — Status changed to AWARDED'),
(1256, 'procurement_requests', 104, 'AWARDED', 'Demario Ewan', '2026-02-19 15:08:49', 'GC approval by Demario Ewan'),
(1257, 'procurement_requests', 103, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-19 16:51:25', 'Approved — Status changed to PROCUREMENT_STAGE by HOD'),
(1258, 'procurement_requests', 103, 'PROCUREMENT_STAGE', 'Deputy Government Chemist', '2026-02-19 16:51:25', 'Approval by Deputy Government Chemist - HOD'),
(1259, 'procurement_requests', 101, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-19 17:42:09', 'Commitment CM003 approved by HOD'),
(1260, 'commitments', 76, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-19 17:42:09', 'Approved by HOD'),
(1261, 'procurement_requests', 105, 'CREATE', 'Requestor 1', '2026-02-19 17:54:36', 'Procurement request created'),
(1262, 'procurement_requests', 105, 'STATUS_CHANGE', 'Requestor 1', '2026-02-19 17:54:42', 'Draft → Submitted'),
(1263, 'procurement_requests', 105, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-19 17:54:42', 'Approval chain created: HOD'),
(1264, 'procurement_requests', 105, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-19 20:03:29', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1265, 'procurement_requests', 105, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-19 20:03:29', 'Approval by Deputy Government Chemist - HOD'),
(1266, 'rfqs', 8, 'CREATE', 'Deputy Government Chemist', '2026-02-19 20:03:40', 'RFQ created for request ID 105'),
(1267, 'procurement_requests', 102, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-19 23:06:24', 'Commitment CM002 approved by HOD'),
(1268, 'commitments', 75, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-19 23:06:24', 'Approved by HOD'),
(1269, 'rfq_vendors', 23, 'CREATE', 'Technical & User Support Officer', '2026-02-19 23:25:05', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260219-105'),
(1270, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:02:26', 'Quote uploaded for RFQ ID 8'),
(1271, 'rfq_vendors', 24, 'CREATE', 'Gabrielle Green', '2026-02-20 00:03:20', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260219-105'),
(1272, 'rfq_vendors', 25, 'CREATE', 'Gabrielle Green', '2026-02-20 00:03:25', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260219-105'),
(1273, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:03:43', 'Quote uploaded for RFQ ID 8'),
(1274, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:03:58', 'Quote uploaded for RFQ ID 8'),
(1275, 'rfqs', 9, 'CREATE', 'Requestor 1', '2026-02-20 00:22:20', 'RFQ created for request ID 103'),
(1276, 'user_permissions', 23, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-02-20 00:30:25', 'Permission 12 updated (granted=0)'),
(1277, 'rfq_vendors', 26, 'CREATE', 'Deputy Government Chemist', '2026-02-20 00:40:54', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260219-103'),
(1278, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:41:14', 'Quote uploaded for RFQ ID 9'),
(1279, 'users', 16, 'FORCE_ALL_PERMISSION', 'Technical & User Support Officer', '2026-02-20 00:49:57', 'All permissions force-enabled by Technical & User Support Officer'),
(1280, 'rfq_vendors', 27, 'CREATE', 'Demario Ewan', '2026-02-20 00:57:36', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260219-103'),
(1281, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:57:51', 'Quote uploaded for RFQ ID 9'),
(1282, 'rfq_vendors', 28, 'CREATE', 'Demario Ewan', '2026-02-20 00:58:13', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260219-103'),
(1283, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 00:58:25', 'Quote uploaded for RFQ ID 9'),
(1284, 'users', 4, 'FORCE_ALL_PERMISSION', 'Demario Ewan', '2026-02-20 00:59:08', 'All permissions force-enabled by Demario Ewan'),
(1285, 'users', 16, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-02-20 01:00:25', 'Role updated to Admin'),
(1286, 'procurement_requests', 106, 'CREATE', 'Requestor 1', '2026-02-20 01:22:03', 'Procurement request created'),
(1287, 'procurement_requests', 106, 'STATUS_CHANGE', 'Requestor 1', '2026-02-20 01:22:09', 'Draft → Submitted'),
(1288, 'procurement_requests', 106, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-20 01:22:09', 'Approval chain created: HOD'),
(1289, 'rfqs', 10, 'CREATE', 'Requestor 1', '2026-02-20 01:22:19', 'RFQ created for request ID 106'),
(1290, 'rfq_vendors', 29, 'CREATE', 'Requestor 1', '2026-02-20 01:22:29', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260219-106'),
(1291, 'procurement_requests', 106, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-20 01:23:51', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1292, 'procurement_requests', 106, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-20 01:23:51', 'Approval by Deputy Government Chemist - HOD'),
(1293, 'rfq_vendors', 30, 'CREATE', 'Gabrielle Green', '2026-02-20 01:25:03', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260219-106'),
(1294, 'rfq_vendors', 31, 'CREATE', 'Gabrielle Green', '2026-02-20 01:25:14', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260219-106'),
(1295, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 01:25:31', 'Quote uploaded for RFQ ID 10'),
(1296, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 01:26:06', 'Quote uploaded for RFQ ID 10'),
(1297, 'procurement_requests', 107, 'CREATE', 'Requestor 1', '2026-02-20 01:44:52', 'Procurement request created'),
(1298, 'procurement_requests', 107, 'STATUS_CHANGE', 'Requestor 1', '2026-02-20 01:44:57', 'Draft → Submitted'),
(1299, 'procurement_requests', 107, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-20 01:44:57', 'Approval chain created: HOD'),
(1300, 'procurement_requests', 107, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-20 01:45:19', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1301, 'procurement_requests', 107, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-20 01:45:19', 'Approval by Deputy Government Chemist - HOD'),
(1302, 'rfqs', 11, 'CREATE', 'Deputy Government Chemist', '2026-02-20 01:45:33', 'RFQ created for request ID 107'),
(1303, 'rfq_vendors', 32, 'CREATE', 'Deputy Government Chemist', '2026-02-20 01:46:20', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260219-107'),
(1304, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 01:46:31', 'Quote uploaded for RFQ ID 11'),
(1305, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-20 01:46:50', 'Quote 31 reviewed: MEETS_REQUIREMENTS by Deputy Government Chemist'),
(1306, 'rfq_vendors', 33, 'CREATE', 'Deputy Government Chemist', '2026-02-20 01:47:05', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260219-107'),
(1307, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 01:47:20', 'Quote uploaded for RFQ ID 11'),
(1308, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-20 01:47:28', 'Quote 31 reviewed: DOES_NOT_MEET by Deputy Government Chemist'),
(1309, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-20 01:48:30', 'Quote 32 selected by Finance Officer Latoya Gayle - Vendor: Intcomex Limited, Amount: $98.00'),
(1310, 'rfq_vendors', 34, 'CREATE', 'Gabrielle Green', '2026-02-20 02:10:33', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260219-107'),
(1311, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-20 02:10:49', 'Quote uploaded for RFQ ID 11'),
(1312, 'commitments', 77, 'CREATE', 'Technical & User Support Officer', '2026-02-20 02:38:32', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1313, 'procurement_requests', 107, 'COMMITMENT_APPROVED', 'Technical & User Support Officer', '2026-02-20 02:38:32', 'Finance Officer approved commitment CM004. Funds available. Ready for PO creation.'),
(1314, 'commitments', 77, 'SEED_APPROVAL_CHAIN', 'Deputy Government Chemist', '2026-02-20 02:48:44', 'Approval chain auto-created for legacy commitment: HOD → Finance Officer'),
(1315, 'procurement_requests', 107, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-20 02:48:47', 'Commitment CM004 approved by HOD'),
(1316, 'commitments', 77, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-20 02:48:47', 'Approved by HOD'),
(1317, 'procurement_requests', 101, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-20 02:52:56', 'Commitment CM003 approved by Finance Officer'),
(1318, 'commitments', 76, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-20 02:52:56', 'Approved by Finance Officer'),
(1319, 'procurement_requests', 101, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-20 02:52:56', 'Commitment CM003 fully approved'),
(1320, 'commitments', 76, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-20 02:52:56', 'All approval stages complete'),
(1321, 'purchase_orders', 59, 'CREATE', 'Gabrielle Green', '2026-02-20 02:54:13', 'Purchase Order created'),
(1322, 'procurement_requests', 101, 'PO_CREATED', 'Gabrielle Green', '2026-02-20 02:54:13', 'PO PO-2026-0002 created, pending HOD + Finance approval'),
(1323, 'procurement_requests', 101, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-20 02:54:46', 'PO PO-2026-0002 approved by Finance Officer'),
(1324, 'purchase_orders', 59, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-20 02:54:46', 'Approved by Finance Officer'),
(1325, 'procurement_requests', 101, 'PO_APPROVED_STAGE', 'Deputy Government Chemist', '2026-02-20 02:55:29', 'PO PO-2026-0002 approved by HOD'),
(1326, 'purchase_orders', 59, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-20 02:55:29', 'Approved by HOD'),
(1327, 'procurement_requests', 101, 'PO_FULLY_APPROVED', 'Deputy Government Chemist', '2026-02-20 02:55:29', 'PO PO-2026-0002 fully approved'),
(1328, 'purchase_orders', 59, 'PO_APPROVED', 'Deputy Government Chemist', '2026-02-20 02:55:29', 'All approval stages complete'),
(1329, 'invoices', 62, 'CREATE', 'Latoya Gayle', '2026-02-20 02:56:19', 'Invoice added by user ID 6'),
(1330, 'procurement_requests', 107, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-20 02:56:49', 'Commitment CM004 approved by Finance Officer'),
(1331, 'commitments', 77, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-20 02:56:49', 'Approved by Finance Officer'),
(1332, 'procurement_requests', 107, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-20 02:56:49', 'Commitment CM004 fully approved'),
(1333, 'commitments', 77, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-20 02:56:49', 'All approval stages complete'),
(1334, 'payments', 60, 'CREATE', 'Latoya Gayle', '2026-02-20 02:57:20', 'Payment recorded'),
(1335, 'procurement_requests', 102, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-20 03:10:29', 'Commitment CM002 approved by Finance Officer'),
(1336, 'commitments', 75, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-20 03:10:29', 'Approved by Finance Officer'),
(1337, 'procurement_requests', 102, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-20 03:10:29', 'Commitment CM002 fully approved'),
(1338, 'commitments', 75, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-20 03:10:29', 'All approval stages complete'),
(1339, 'procurement_requests', 108, 'CREATE', 'Requestor 1', '2026-02-21 02:41:48', 'Procurement request created'),
(1340, 'procurement_requests', 108, 'STATUS_CHANGE', 'Requestor 1', '2026-02-21 02:42:02', 'Draft → Submitted'),
(1341, 'procurement_requests', 108, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-21 02:42:02', 'Approval chain created: HOD'),
(1342, 'procurement_requests', 108, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-21 02:42:34', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1343, 'procurement_requests', 108, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-21 02:42:34', 'Approval by Deputy Government Chemist - HOD'),
(1344, 'rfqs', 12, 'CREATE', 'Gabrielle Green', '2026-02-21 02:43:55', 'RFQ created for request ID 108'),
(1345, 'rfq_vendors', 35, 'CREATE', 'Gabrielle Green', '2026-02-21 02:44:04', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260220-108'),
(1346, 'rfq_vendors', 36, 'CREATE', 'Gabrielle Green', '2026-02-21 02:44:15', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260220-108'),
(1347, 'rfq_vendors', 37, 'CREATE', 'Gabrielle Green', '2026-02-21 02:44:22', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260220-108'),
(1348, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-21 02:44:49', 'Quote uploaded for RFQ ID 12'),
(1349, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-21 02:45:15', 'Quote uploaded for RFQ ID 12'),
(1350, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-21 02:45:44', 'Quote uploaded for RFQ ID 12'),
(1351, 'rfq_votes', 12, 'CREATE', 'Viewer', '2026-02-21 02:47:52', 'Vote cast for vendor (rfq_vendor_id=36)'),
(1352, 'users', 4, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-21 02:49:05', 'Role updated to Evaluation Committee Member'),
(1353, 'rfq_votes', 12, 'CREATE', 'Shermaine McKenzie', '2026-02-21 02:50:49', 'Vote cast for vendor (rfq_vendor_id=36)'),
(1354, 'rfq_votes', 12, 'CREATE', 'Technical & User Support Officer', '2026-02-21 02:51:52', 'Vote cast for vendor (rfq_vendor_id=35)'),
(1355, 'procurement_requests', 109, 'CREATE', 'Requestor 1', '2026-02-22 15:16:06', 'Procurement request created'),
(1356, 'procurement_requests', 109, 'STATUS_CHANGE', 'Requestor 1', '2026-02-22 15:16:26', 'Draft → Submitted'),
(1357, 'procurement_requests', 109, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-22 15:16:26', 'Approval chain created: HOD'),
(1358, 'procurement_requests', 109, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 15:16:54', 'Approved — Funds certified & Status changed to PROCUREMENT_STAGE by HOD'),
(1359, 'procurement_requests', 109, 'PROCUREMENT_STAGE', 'Deputy Government Chemist', '2026-02-22 15:16:54', 'Approval by Deputy Government Chemist - HOD'),
(1360, 'rfqs', 13, 'CREATE', 'Gabrielle Green', '2026-02-22 15:18:18', 'RFQ created for request ID 109'),
(1361, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 5 updated (granted=1)'),
(1362, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 7 updated (granted=1)'),
(1363, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 25 updated (granted=1)'),
(1364, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 28 updated (granted=1)'),
(1365, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 27 updated (granted=1)'),
(1366, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 3 updated (granted=1)'),
(1367, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 4 updated (granted=1)'),
(1368, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 18 updated (granted=0)'),
(1369, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 20 updated (granted=0)'),
(1370, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 6 updated (granted=1)'),
(1371, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 22 updated (granted=1)'),
(1372, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 1 updated (granted=1)'),
(1373, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 175 updated (granted=1)'),
(1374, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 29 updated (granted=1)'),
(1375, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 45 updated (granted=1)'),
(1376, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 10 updated (granted=0)'),
(1377, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 32 updated (granted=0)'),
(1378, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 33 updated (granted=1)'),
(1379, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 8 updated (granted=0)'),
(1380, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 9 updated (granted=0)'),
(1381, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 23 updated (granted=1)'),
(1382, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 2 updated (granted=1)'),
(1383, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 17 updated (granted=0)'),
(1384, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 26 updated (granted=1)'),
(1385, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 11 updated (granted=1)'),
(1386, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 13 updated (granted=1)'),
(1387, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 19 updated (granted=0)'),
(1388, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 14 updated (granted=0)'),
(1389, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 15 updated (granted=0)'),
(1390, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 21 updated (granted=0)'),
(1391, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 31 updated (granted=0)'),
(1392, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 16 updated (granted=1)'),
(1393, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 24 updated (granted=1)'),
(1394, 'user_permissions', 9, 'PERMISSION_OVERRIDE', 'Demario Ewan', '2026-02-22 15:20:54', 'Permission 12 updated (granted=1)'),
(1395, 'rfq_vendors', 38, 'CREATE', 'Gabrielle Green', '2026-02-22 15:25:46', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260222-109'),
(1396, 'rfq_vendors', 39, 'CREATE', 'Gabrielle Green', '2026-02-22 15:25:50', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-109'),
(1397, 'rfq_vendors', 40, 'CREATE', 'Gabrielle Green', '2026-02-22 15:25:56', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260222-109'),
(1398, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 15:26:11', 'Quote uploaded for RFQ ID 13'),
(1399, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 15:26:26', 'Quote uploaded for RFQ ID 13'),
(1400, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 15:26:39', 'Quote uploaded for RFQ ID 13'),
(1401, 'rfq_votes', 13, 'CREATE', 'Viewer', '2026-02-22 15:28:58', 'Vote cast for vendor (rfq_vendor_id=39)'),
(1402, 'rfq_votes', 13, 'CREATE', 'Technical & User Support Officer', '2026-02-22 15:29:39', 'Vote cast for vendor (rfq_vendor_id=39)'),
(1403, 'rfq_votes', 13, 'CREATE', 'Shermaine McKenzie', '2026-02-22 15:30:37', 'Vote cast for vendor (rfq_vendor_id=38)'),
(1404, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 15:52:00', 'Role updated to Director HRM&A'),
(1405, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 15:52:53', 'Role updated to Deputy Government Chemist'),
(1406, 'procurement_requests', 110, 'CREATE', 'Requestor 1', '2026-02-22 16:29:57', 'Procurement request created'),
(1407, 'procurement_requests', 110, 'STATUS_CHANGE', 'Requestor 1', '2026-02-22 16:30:02', 'Draft → Submitted'),
(1408, 'procurement_requests', 110, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-22 16:30:02', 'Approval chain created: HOD'),
(1409, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 16:30:54', 'Role updated to HOD'),
(1410, 'procurement_requests', 110, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 16:31:14', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1411, 'procurement_requests', 110, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-22 16:31:14', 'Approval by Deputy Government Chemist - HOD'),
(1412, 'rfqs', 14, 'CREATE', 'Gabrielle Green', '2026-02-22 16:31:49', 'RFQ created for request ID 110'),
(1413, 'rfq_vendors', 41, 'CREATE', 'Gabrielle Green', '2026-02-22 16:32:12', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260222-110'),
(1414, 'rfq_vendors', 42, 'CREATE', 'Gabrielle Green', '2026-02-22 16:32:20', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-110'),
(1415, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 16:33:19', 'Quote uploaded for RFQ ID 14'),
(1416, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 16:33:39', 'Quote uploaded for RFQ ID 14'),
(1417, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-22 16:35:01', 'Quote 41 reviewed: DOES_NOT_MEET by Requestor 1'),
(1418, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-22 16:35:14', 'Quote 40 reviewed: MEETS_REQUIREMENTS by Requestor 1'),
(1419, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-22 16:37:10', 'Quote 40 selected by Finance Officer Latoya Gayle - Vendor: Accu Power Limited, Amount: $8000.00'),
(1420, 'commitments', 78, 'CREATE', 'Latoya Gayle', '2026-02-22 16:37:38', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1421, 'procurement_requests', 110, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-22 16:37:38', 'Finance Officer approved commitment CM001. Funds available. Ready for PO creation.'),
(1422, 'commitments', 78, 'SEED_APPROVAL_CHAIN', 'Deputy Government Chemist', '2026-02-22 16:38:21', 'Approval chain auto-created for legacy commitment: HOD → Finance Officer'),
(1423, 'procurement_requests', 110, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-22 16:38:23', 'Commitment CM001 approved by HOD'),
(1424, 'commitments', 78, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-22 16:38:23', 'Approved by HOD'),
(1425, 'procurement_requests', 110, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-22 16:39:23', 'Commitment CM001 approved by Finance Officer'),
(1426, 'commitments', 78, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-22 16:39:23', 'Approved by Finance Officer'),
(1427, 'procurement_requests', 110, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-22 16:39:23', 'Commitment CM001 fully approved'),
(1428, 'commitments', 78, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-22 16:39:23', 'All approval stages complete'),
(1429, 'purchase_orders', 60, 'CREATE', 'Gabrielle Green', '2026-02-22 16:40:27', 'Purchase Order created'),
(1430, 'procurement_requests', 110, 'PO_CREATED', 'Gabrielle Green', '2026-02-22 16:40:27', 'PO PO-2026-0001 created, pending HOD + Finance approval'),
(1431, 'procurement_requests', 110, 'PO_APPROVED_STAGE', 'Deputy Government Chemist', '2026-02-22 16:41:03', 'PO PO-2026-0001 approved by HOD'),
(1432, 'purchase_orders', 60, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-22 16:41:03', 'Approved by HOD'),
(1433, 'procurement_requests', 110, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-22 16:41:46', 'PO PO-2026-0001 approved by Finance Officer'),
(1434, 'purchase_orders', 60, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-22 16:41:46', 'Approved by Finance Officer'),
(1435, 'procurement_requests', 110, 'PO_FULLY_APPROVED', 'Latoya Gayle', '2026-02-22 16:41:46', 'PO PO-2026-0001 fully approved'),
(1436, 'purchase_orders', 60, 'PO_APPROVED', 'Latoya Gayle', '2026-02-22 16:41:46', 'All approval stages complete'),
(1437, 'invoices', 63, 'CREATE', 'Latoya Gayle', '2026-02-22 16:42:05', 'Invoice added by user ID 6'),
(1438, 'payments', 61, 'CREATE', 'Latoya Gayle', '2026-02-22 16:42:35', 'Payment recorded'),
(1439, 'payments', 62, 'CREATE', 'Latoya Gayle', '2026-02-22 16:42:50', 'Payment recorded'),
(1440, 'procurement_requests', 111, 'CREATE', 'Requestor 1', '2026-02-22 16:50:24', 'Procurement request created'),
(1441, 'procurement_requests', 111, 'STATUS_CHANGE', 'Requestor 1', '2026-02-22 16:50:30', 'Draft → Submitted'),
(1442, 'procurement_requests', 111, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-22 16:50:30', 'Approval chain created: HOD'),
(1443, 'procurement_requests', 111, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 17:17:32', 'Approved — Funds certified & Status changed to PROCUREMENT_STAGE by HOD'),
(1444, 'procurement_requests', 111, 'PROCUREMENT_STAGE', 'Deputy Government Chemist', '2026-02-22 17:17:32', 'Approval by Deputy Government Chemist - HOD'),
(1445, 'rfqs', 15, 'CREATE', 'Gabrielle Green', '2026-02-22 17:18:09', 'RFQ created for request ID 111'),
(1446, 'rfq_vendors', 43, 'CREATE', 'Gabrielle Green', '2026-02-22 17:18:16', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260222-111'),
(1447, 'rfq_vendors', 44, 'CREATE', 'Gabrielle Green', '2026-02-22 17:18:22', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260222-111'),
(1448, 'rfq_vendors', 45, 'CREATE', 'Gabrielle Green', '2026-02-22 17:18:27', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-111'),
(1449, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:18:44', 'Quote uploaded for RFQ ID 15'),
(1450, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:18:57', 'Quote uploaded for RFQ ID 15'),
(1451, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:19:15', 'Quote uploaded for RFQ ID 15'),
(1452, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:21:15', 'Quote uploaded for RFQ ID 15'),
(1453, 'rfq_votes', 15, 'CREATE', 'Shermaine McKenzie', '2026-02-22 17:22:19', 'Vote cast for vendor (rfq_vendor_id=44)'),
(1454, 'rfq_votes', 15, 'CREATE', 'Viewer', '2026-02-22 17:22:55', 'Vote cast for vendor (rfq_vendor_id=44)'),
(1455, 'rfq_votes', 15, 'CREATE', 'Technical & User Support Officer', '2026-02-22 17:24:07', 'Vote cast for vendor (rfq_vendor_id=44)'),
(1456, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 17:27:30', 'Role updated to Deputy Government Chemist'),
(1457, 'procurement_requests', 112, 'CREATE', 'Demario Ewan', '2026-02-22 17:55:07', 'Procurement request created'),
(1458, 'procurement_requests', 112, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-22 17:55:14', 'Draft → Submitted'),
(1459, 'procurement_requests', 112, 'APPROVAL_CHAIN_CREAT', 'Demario Ewan', '2026-02-22 17:55:14', 'Approval chain created: HOD'),
(1460, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 17:56:59', 'Role updated to HOD'),
(1461, 'procurement_requests', 112, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 17:57:34', 'Approved — Funds certified & Status changed to PROCUREMENT_STAGE by HOD'),
(1462, 'procurement_requests', 112, 'PROCUREMENT_STAGE', 'Deputy Government Chemist', '2026-02-22 17:57:34', 'Approval by Deputy Government Chemist - HOD'),
(1463, 'rfqs', 16, 'CREATE', 'Gabrielle Green', '2026-02-22 17:58:18', 'RFQ created for request ID 112'),
(1464, 'rfq_vendors', 46, 'CREATE', 'Gabrielle Green', '2026-02-22 17:58:24', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260222-112'),
(1465, 'rfq_vendors', 47, 'CREATE', 'Gabrielle Green', '2026-02-22 17:58:29', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-112'),
(1466, 'rfq_vendors', 48, 'CREATE', 'Gabrielle Green', '2026-02-22 17:58:38', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260222-112'),
(1467, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:58:58', 'Quote uploaded for RFQ ID 16'),
(1468, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:59:15', 'Quote uploaded for RFQ ID 16'),
(1469, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 17:59:51', 'Quote uploaded for RFQ ID 16'),
(1470, 'rfq_votes', 16, 'CREATE', 'Viewer', '2026-02-22 18:03:50', 'Vote cast for vendor (rfq_vendor_id=48)'),
(1471, 'rfq_votes', 16, 'CREATE', 'Shermaine McKenzie', '2026-02-22 18:04:21', 'Vote cast for vendor (rfq_vendor_id=47)'),
(1472, 'rfq_votes', 16, 'CREATE', 'Technical & User Support Officer', '2026-02-22 18:06:10', 'Vote cast for vendor (rfq_vendor_id=46)'),
(1473, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 18:07:31', 'Role updated to Deputy Government Chemist'),
(1474, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 18:19:03', 'Role updated to HOD'),
(1475, 'procurement_requests', 113, 'CREATE', 'Requestor 1', '2026-02-22 18:39:25', 'Procurement request created'),
(1476, 'procurement_requests', 113, 'STATUS_CHANGE', 'Requestor 1', '2026-02-22 18:39:31', 'Draft → Submitted'),
(1477, 'procurement_requests', 113, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-22 18:39:31', 'Approval chain created: HOD'),
(1478, 'procurement_requests', 113, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 18:41:32', 'Approved — Funds certified & Status changed to PROCUREMENT_STAGE by HOD'),
(1479, 'procurement_requests', 113, 'PROCUREMENT_STAGE', 'Deputy Government Chemist', '2026-02-22 18:41:32', 'Approval by Deputy Government Chemist - HOD'),
(1480, 'rfqs', 17, 'CREATE', 'Gabrielle Green', '2026-02-22 18:42:59', 'RFQ created for request ID 113'),
(1481, 'rfq_vendors', 49, 'CREATE', 'Gabrielle Green', '2026-02-22 18:43:31', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260222-113'),
(1482, 'rfq_vendors', 50, 'CREATE', 'Gabrielle Green', '2026-02-22 18:43:35', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-113'),
(1483, 'rfq_vendors', 51, 'CREATE', 'Gabrielle Green', '2026-02-22 18:43:40', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260222-113'),
(1484, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 18:53:50', 'Quote uploaded for RFQ ID 17'),
(1485, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 18:54:04', 'Quote uploaded for RFQ ID 17'),
(1486, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 18:54:25', 'Quote uploaded for RFQ ID 17'),
(1487, 'rfq_votes', 17, 'CREATE', 'Viewer', '2026-02-22 18:55:39', 'Vote cast for vendor (rfq_vendor_id=51)'),
(1488, 'rfq_votes', 17, 'CREATE', 'Shermaine McKenzie', '2026-02-22 18:56:06', 'Vote cast for vendor (rfq_vendor_id=51)'),
(1489, 'rfq_votes', 17, 'CREATE', 'Technical & User Support Officer', '2026-02-22 18:58:41', 'Vote cast for vendor (rfq_vendor_id=51)'),
(1490, 'rfqs', 15, 'ADVANCE_EVALUATION', 'Gabrielle Green', '2026-02-22 19:27:29', 'Advanced over-threshold RFQ from EVALUATION_STAGE to COMMITTEE_RECOMMENDED — pending GC approval (SOP Step 10)'),
(1491, 'rfqs', 17, 'ADVANCE_EVALUATION', 'Gabrielle Green', '2026-02-22 19:27:56', 'Advanced over-threshold RFQ from EVALUATION_STAGE to COMMITTEE_RECOMMENDED — pending GC approval (SOP Step 10)'),
(1492, 'rfqs', 17, 'ADVANCE_EVALUATION', 'Gabrielle Green', '2026-02-22 19:29:15', 'Advanced over-threshold RFQ from COMMITTEE_RECOMMENDED to COMMITTEE_RECOMMENDED — pending GC approval (SOP Step 10)'),
(1493, 'procurement_requests', 113, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 19:32:45', 'GC Approved (funds certified) — Status changed to GC_APPROVED'),
(1494, 'procurement_requests', 113, 'GC_APPROVED', 'Deputy Government Chemist', '2026-02-22 19:32:45', 'GC approval by Deputy Government Chemist'),
(1495, 'rfqs', 17, 'AWARD', 'Deputy Government Chemist', '2026-02-22 19:33:27', 'RFQ awarded to Vendor ID 1 (Quote ID 51)'),
(1496, 'commitments', 80, 'CREATE', 'Latoya Gayle', '2026-02-22 19:42:30', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1497, 'procurement_requests', 113, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-22 19:42:30', 'Finance Officer approved commitment CM002. Funds available. Ready for PO creation.'),
(1498, 'commitments', 80, 'SEED_APPROVAL_CHAIN', 'Deputy Government Chemist', '2026-02-22 19:43:27', 'Approval chain auto-created for legacy commitment: HOD → Finance Officer'),
(1499, 'procurement_requests', 113, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-22 19:43:29', 'Commitment CM002 approved by HOD'),
(1500, 'commitments', 80, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-22 19:43:29', 'Approved by HOD'),
(1501, 'procurement_requests', 111, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-22 19:44:35', 'GC Approved (funds certified) — Status changed to GC_APPROVED'),
(1502, 'procurement_requests', 111, 'GC_APPROVED', 'Deputy Government Chemist', '2026-02-22 19:44:35', 'GC approval by Deputy Government Chemist'),
(1503, 'procurement_requests', 113, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-22 19:45:37', 'Commitment CM002 approved by Finance Officer'),
(1504, 'commitments', 80, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-22 19:45:37', 'Approved by Finance Officer'),
(1505, 'procurement_requests', 113, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-22 19:45:37', 'Commitment CM002 fully approved'),
(1506, 'commitments', 80, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-22 19:45:37', 'All approval stages complete'),
(1507, 'purchase_orders', 61, 'CREATE', 'Gabrielle Green', '2026-02-22 19:47:15', 'Purchase Order created'),
(1508, 'procurement_requests', 113, 'PO_CREATED', 'Gabrielle Green', '2026-02-22 19:47:15', 'PO PO-2026-0002 created, pending HOD + Finance approval'),
(1509, 'rfqs', 15, 'AWARD', 'Deputy Government Chemist', '2026-02-22 19:48:03', 'RFQ awarded to Vendor ID 1 (Quote ID 43)'),
(1510, 'procurement_requests', 113, 'PO_APPROVED_STAGE', 'Deputy Government Chemist', '2026-02-22 19:52:30', 'PO PO-2026-0002 approved by HOD'),
(1511, 'purchase_orders', 61, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-22 19:52:30', 'Approved by HOD'),
(1512, 'procurement_requests', 113, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-22 19:52:50', 'PO PO-2026-0002 approved by Finance Officer'),
(1513, 'purchase_orders', 61, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-22 19:52:50', 'Approved by Finance Officer'),
(1514, 'procurement_requests', 113, 'PO_FULLY_APPROVED', 'Latoya Gayle', '2026-02-22 19:52:50', 'PO PO-2026-0002 fully approved'),
(1515, 'purchase_orders', 61, 'PO_APPROVED', 'Latoya Gayle', '2026-02-22 19:52:50', 'All approval stages complete'),
(1516, 'invoices', 64, 'CREATE', 'Latoya Gayle', '2026-02-22 19:53:22', 'Invoice added by user ID 6'),
(1517, 'payments', 63, 'CREATE', 'Latoya Gayle', '2026-02-22 19:54:16', 'Payment recorded'),
(1518, 'procurement_requests', 111, 'COMMITMENT_DECLINED', 'Latoya Gayle', '2026-02-22 20:08:19', 'Finance declined - Reason: no funds avail'),
(1519, 'procurement_requests', 111, 'COMMITMENT_DECLINED', 'Latoya Gayle', '2026-02-22 20:08:19', 'Finance Officer: Funds not available or quote issues. Reason: no funds avail'),
(1520, 'procurement_requests', 114, 'CREATE', 'Demario Ewan', '2026-02-22 21:01:47', 'Procurement request created'),
(1521, 'procurement_requests', 114, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-22 21:01:57', 'Draft → Submitted'),
(1522, 'procurement_requests', 114, 'APPROVAL_CHAIN_CREAT', 'Demario Ewan', '2026-02-22 21:01:57', 'Approval chain created: Deputy Government Chemist'),
(1523, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-22 21:02:33', 'Role updated to Deputy Government Chemist'),
(1524, 'users', 24, 'CREATE', 'Demario Ewan', '2026-02-22 21:02:54', 'User \'HOD\' (h@gmail.com) created by admin.'),
(1525, 'users', 24, 'PASSWORD_CHANGE', 'HOD', '2026-02-22 21:03:31', 'Password updated'),
(1526, 'procurement_requests', 114, 'STATUS_CHANGE', 'HOD', '2026-02-22 21:21:13', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1527, 'procurement_requests', 114, 'RFQ_LETTER_AVAILABLE', 'HOD', '2026-02-22 21:21:13', 'GC approval by HOD'),
(1528, 'rfqs', 18, 'CREATE', 'Gabrielle Green', '2026-02-22 21:24:14', 'RFQ created for request ID 114'),
(1529, 'rfq_vendors', 52, 'CREATE', 'Gabrielle Green', '2026-02-22 21:24:23', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-114'),
(1530, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-22 21:24:42', 'Quote uploaded for RFQ ID 18'),
(1531, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-22 21:28:31', 'Quote 52 selected by Finance Officer Latoya Gayle - Vendor: Intcomex Limited, Amount: $7000.00'),
(1532, 'commitments', 81, 'CREATE', 'Latoya Gayle', '2026-02-22 21:29:16', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1533, 'procurement_requests', 114, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-22 21:29:16', 'Finance Officer approved commitment CM003. Funds available. Ready for PO creation.'),
(1534, 'procurement_requests', 115, 'CREATE', 'Requestor 1', '2026-02-23 00:04:00', 'Procurement request created'),
(1535, 'procurement_requests', 115, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 00:06:23', 'Draft → Submitted'),
(1536, 'procurement_requests', 115, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-23 00:06:23', 'Approval chain created: Director HRM&A'),
(1537, 'request_approvals', 68, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-23 00:08:30', 'Approved by Director HRM&A'),
(1538, 'procurement_requests', 115, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-23 00:19:30', 'Submitted → Declined by Nellesha Samuels'),
(1539, 'procurement_requests', 115, 'DECLINED', 'Nellesha Samuels', '2026-02-23 00:19:30', 'Request declined: test — by Nellesha Samuels'),
(1540, 'procurement_requests', 115, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 00:19:49', 'Declined → Draft (Resubmitted by Requestor 1)'),
(1541, 'procurement_requests', 115, 'RESUBMITTED', 'Requestor 1', '2026-02-23 00:19:49', 'Request resubmitted after decline by Requestor 1'),
(1542, 'procurement_requests', 115, 'EDIT', 'Requestor 1', '2026-02-23 00:22:42', 'Procurement Request #115 edited.\n\nOLD ITEMS:\n- 12c | Qty: 3 | 23\n- we | Qty: 3 | wee\n\nNEW ITEMS:\n- 12c | Qty: 3 | 23\n- we | Qty: 3 | wee\n'),
(1543, 'procurement_requests', 115, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 00:22:47', 'Draft → Submitted'),
(1544, 'procurement_requests', 115, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-23 00:22:47', 'Approval chain created: Director HRM&A'),
(1545, 'request_approvals', 69, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-23 00:23:24', 'Approved by Director HRM&A'),
(1546, 'procurement_requests', 115, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-23 00:23:24', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1547, 'procurement_requests', 115, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-02-23 00:23:24', 'Approval by Director HRM&A'),
(1548, 'rfqs', 19, 'CREATE', 'Gabrielle Green', '2026-02-23 00:24:08', 'RFQ created for request ID 115'),
(1549, 'rfq_vendors', 53, 'CREATE', 'Gabrielle Green', '2026-02-23 00:24:14', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260222-115'),
(1550, 'rfq_vendors', 54, 'CREATE', 'Gabrielle Green', '2026-02-23 00:24:19', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260222-115'),
(1551, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-23 00:24:47', 'Quote uploaded for RFQ ID 19'),
(1552, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-23 00:25:01', 'Quote uploaded for RFQ ID 19'),
(1553, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-23 00:31:48', 'Quote 54 selected by Finance Officer Latoya Gayle - Vendor: Intcomex Limited, Amount: $5350.00'),
(1554, 'commitments', 82, 'CREATE', 'Latoya Gayle', '2026-02-23 00:36:10', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1555, 'procurement_requests', 115, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-23 00:36:10', 'Finance Officer approved commitment CM004. Funds available. Ready for PO creation.'),
(1556, 'commitments', 81, 'SEED_APPROVAL_CHAIN', 'HOD', '2026-02-23 00:37:42', 'Approval chain auto-created for legacy commitment: Deputy Government Chemist → Finance Officer'),
(1557, 'commitments', 82, 'SEED_APPROVAL_CHAIN', 'HOD', '2026-02-23 00:38:00', 'Approval chain auto-created for legacy commitment: Director HRM&A → Finance Officer'),
(1558, 'procurement_requests', 115, 'COMMITMENT_APPROVED_', 'Requestor 1', '2026-02-23 00:46:16', 'Commitment CM004 approved by Director HRM&A'),
(1559, 'commitments', 82, 'APPROVE_STAGE', 'Requestor 1', '2026-02-23 00:46:16', 'Approved by Director HRM&A'),
(1560, 'procurement_requests', 115, 'COMMITMENT_APPROVED_', 'Requestor 1', '2026-02-23 00:46:44', 'Commitment CM004 approved by Finance Officer'),
(1561, 'commitments', 82, 'APPROVE_STAGE', 'Requestor 1', '2026-02-23 00:46:44', 'Approved by Finance Officer'),
(1562, 'procurement_requests', 115, 'COMMITMENT_FULLY_APP', 'Requestor 1', '2026-02-23 00:46:44', 'Commitment CM004 fully approved'),
(1563, 'commitments', 82, 'COMMITMENT_APPROVED', 'Requestor 1', '2026-02-23 00:46:44', 'All approval stages complete'),
(1564, 'purchase_orders', 62, 'CREATE', 'Gabrielle Green', '2026-02-23 00:48:24', 'Purchase Order created'),
(1565, 'procurement_requests', 115, 'PO_CREATED', 'Gabrielle Green', '2026-02-23 00:48:24', 'PO PO-2026-0003 created, pending HOD + Finance approval'),
(1566, 'procurement_requests', 115, 'PO_APPROVED_STAGE', 'HOD', '2026-02-23 00:49:02', 'PO PO-2026-0003 approved by HOD'),
(1567, 'purchase_orders', 62, 'APPROVE_STAGE', 'HOD', '2026-02-23 00:49:02', 'Approved by HOD'),
(1568, 'procurement_requests', 115, 'PO_APPROVED_STAGE', 'Latoya Gayle', '2026-02-23 00:49:29', 'PO PO-2026-0003 approved by Finance Officer'),
(1569, 'purchase_orders', 62, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-23 00:49:29', 'Approved by Finance Officer'),
(1570, 'procurement_requests', 115, 'PO_FULLY_APPROVED', 'Latoya Gayle', '2026-02-23 00:49:29', 'PO PO-2026-0003 fully approved'),
(1571, 'purchase_orders', 62, 'PO_APPROVED', 'Latoya Gayle', '2026-02-23 00:49:29', 'All approval stages complete'),
(1572, 'invoices', 65, 'CREATE', 'Latoya Gayle', '2026-02-23 00:50:16', 'Invoice added by user ID 6'),
(1573, 'procurement_requests', 115, 'INVOICE_RECEIVED', 'Latoya Gayle', '2026-02-23 00:50:16', 'Invoice #inv43 received for PO PO-2026-0003'),
(1574, 'procurement_requests', 114, 'COMMITMENT_APPROVED_', 'Deputy Government Chemist', '2026-02-23 00:51:18', 'Commitment CM003 approved by Deputy Government Chemist'),
(1575, 'commitments', 81, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-23 00:51:18', 'Approved by Deputy Government Chemist'),
(1576, 'procurement_requests', 114, 'COMMITMENT_APPROVED_', 'Latoya Gayle', '2026-02-23 00:51:46', 'Commitment CM003 approved by Finance Officer'),
(1577, 'commitments', 81, 'APPROVE_STAGE', 'Latoya Gayle', '2026-02-23 00:51:46', 'Approved by Finance Officer'),
(1578, 'procurement_requests', 114, 'COMMITMENT_FULLY_APP', 'Latoya Gayle', '2026-02-23 00:51:46', 'Commitment CM003 fully approved'),
(1579, 'commitments', 81, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-23 00:51:46', 'All approval stages complete'),
(1580, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', 'Requestor 1', '2026-02-23 16:01:16', 'Back-dating of procurement request was attempted'),
(1581, 'procurement_requests', 116, 'CREATE', 'Requestor 1', '2026-02-23 16:02:32', 'Procurement request created'),
(1582, 'procurement_requests', 116, 'EDIT', 'Requestor 1', '2026-02-23 16:03:58', 'Procurement Request #116 edited.\n\nOLD ITEMS:\n- 1 laptop | Qty: 1 | 6gb ram\n\nNEW ITEMS:\n- 1 laptop | Qty: 1 | 6gb ram\n'),
(1583, 'procurement_requests', 116, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 16:04:02', 'Draft → Submitted'),
(1584, 'procurement_requests', 116, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-23 16:04:02', 'Approval chain created: HOD'),
(1585, 'users', 21, 'ROLE_CHANGE', 'Demario Ewan', '2026-02-23 16:04:55', 'Role updated to HOD'),
(1586, 'procurement_requests', 116, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-23 16:05:41', 'Submitted → Declined by Deputy Government Chemist'),
(1587, 'procurement_requests', 116, 'DECLINED', 'Deputy Government Chemist', '2026-02-23 16:05:41', 'Request declined: no funds — by Deputy Government Chemist'),
(1588, 'procurement_requests', 116, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 16:20:30', 'Declined → Draft (Resubmitted by Requestor 1)'),
(1589, 'procurement_requests', 116, 'RESUBMITTED', 'Requestor 1', '2026-02-23 16:20:30', 'Request resubmitted after decline by Requestor 1'),
(1590, 'procurement_requests', 116, 'EDIT', 'Requestor 1', '2026-02-23 16:20:34', 'Procurement Request #116 edited.\n\nOLD ITEMS:\n- 1 laptop | Qty: 1 | 6gb ram\n\nNEW ITEMS:\n- 1 laptop | Qty: 1 | 6gb ram\n'),
(1591, 'procurement_requests', 116, 'STATUS_CHANGE', 'Requestor 1', '2026-02-23 16:20:39', 'Draft → Submitted'),
(1592, 'procurement_requests', 116, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-23 16:20:39', 'Approval chain created: HOD'),
(1593, 'procurement_requests', 116, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-23 16:21:24', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1594, 'procurement_requests', 116, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-23 16:21:24', 'Approval by Deputy Government Chemist - HOD'),
(1595, 'rfqs', 20, 'CREATE', 'Gabrielle Green', '2026-02-23 16:22:26', 'RFQ created for request ID 116'),
(1596, 'rfq_vendors', 55, 'CREATE', 'Gabrielle Green', '2026-02-23 16:22:35', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260223-116'),
(1597, 'rfq_vendors', 56, 'CREATE', 'Gabrielle Green', '2026-02-23 16:22:40', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260223-116'),
(1598, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-23 16:33:19', 'Quote uploaded for RFQ ID 20'),
(1599, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-23 16:33:41', 'Quote uploaded for RFQ ID 20'),
(1600, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-23 16:37:08', 'Quote 56 reviewed: MEETS_REQUIREMENTS by Requestor 1'),
(1601, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-23 16:37:32', 'Quote 55 reviewed: DOES_NOT_MEET by Requestor 1'),
(1602, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-23 16:38:41', 'Quote 56 selected by Finance Officer Latoya Gayle - Vendor: Intcomex Limited, Amount: $4800.00'),
(1603, 'commitments', 83, 'CREATE', 'Latoya Gayle', '2026-02-23 16:39:29', 'Approved by Finance Officer - Funds verified and commitment uploaded from GFMS'),
(1604, 'procurement_requests', 116, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-23 16:39:29', 'Finance Officer approved commitment CM005. Funds available. Ready for PO creation.'),
(1605, 'procurement_requests', 117, 'CREATE', 'Demario Ewan', '2026-02-24 01:28:03', 'Procurement request created'),
(1606, 'procurement_requests', 117, 'STATUS_CHANGE', 'Demario Ewan', '2026-02-24 01:48:57', 'Draft → Submitted'),
(1607, 'procurement_requests', 117, 'APPROVAL_CHAIN_CREAT', 'Demario Ewan', '2026-02-24 01:48:57', 'Approval chain created: Director HRM&A'),
(1608, 'request_approvals', 78, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-02-24 01:49:54', 'Approved by Director HRM&A'),
(1609, 'procurement_requests', 117, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-02-24 01:49:54', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1610, 'procurement_requests', 117, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-02-24 01:49:54', 'Approval by Director HRM&A'),
(1611, 'rfqs', 21, 'CREATE', 'Gabrielle Green', '2026-02-24 01:56:59', 'RFQ created for request ID 117. Date: 2026-02-23, Deadline: 2026-03-23T05:00'),
(1612, 'rfq_vendors', 57, 'CREATE', NULL, '2026-02-24 01:58:15', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260223-117'),
(1613, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-24 02:01:20', 'Quote uploaded for RFQ ID 21'),
(1614, 'rfqs', 21, 'UPDATE', 'Gabrielle Green', '2026-02-24 02:01:43', 'RFQ letter uploaded');
INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(1615, 'request_documents', 1, 'CREATE', 'Demario Ewan', '2026-02-24 02:03:25', 'Signed PO uploaded for request PR008'),
(1616, 'procurement_requests', 117, 'DOCUMENT_UPLOADED', 'Demario Ewan', '2026-02-24 02:03:25', 'Signed PO uploaded: sophos-msp-connect.pdf'),
(1617, 'request_documents', 2, 'CREATE', 'Demario Ewan', '2026-02-24 02:03:50', 'Signed Commitment uploaded for request PR008'),
(1618, 'procurement_requests', 117, 'DOCUMENT_UPLOADED', 'Demario Ewan', '2026-02-24 02:03:50', 'Signed Commitment uploaded: Branch_Outstanding.pdf'),
(1619, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-24 02:13:44', 'Quote 57 reviewed: MEETS_REQUIREMENTS by Demario Ewan'),
(1620, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-24 02:14:19', 'Quote 57 selected by Finance Officer Latoya Gayle - Vendor: Accu Power Limited, Amount: $10000.00'),
(1621, 'procurement_requests', 117, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-02-24 02:14:44', 'Funds verified by Finance Officer'),
(1622, 'procurement_requests', 117, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-02-24 02:14:44', 'Finance Officer verified funds are available for this request.'),
(1623, 'commitments', 84, 'CREATE', 'Latoya Gayle', '2026-02-24 02:15:26', 'Commitment uploaded by Finance Officer - Funds verified and commitment document uploaded from GFMS'),
(1624, 'procurement_requests', 117, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-24 02:15:26', 'Finance Officer uploaded commitment CM006. Ready for PO creation.'),
(1625, 'purchase_orders', 63, 'CREATE', 'Gabrielle Green', '2026-02-24 02:28:29', 'Purchase Order created'),
(1626, 'procurement_requests', 117, 'PO_CREATED', 'Gabrielle Green', '2026-02-24 02:28:29', 'PO PO-2026-0004 created, pending HOD + Finance approval'),
(1627, 'procurement_requests', 118, 'CREATE', 'Requestor 1', '2026-02-24 11:29:34', 'Procurement request created'),
(1628, 'procurement_requests', 118, 'STATUS_CHANGE', 'Requestor 1', '2026-02-24 11:30:12', 'Draft → Submitted'),
(1629, 'procurement_requests', 118, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-24 11:30:12', 'Approval chain created: HOD'),
(1630, 'procurement_requests', 118, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-24 16:47:20', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1631, 'procurement_requests', 118, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-24 16:47:20', 'Approval by Deputy Government Chemist - HOD'),
(1632, 'rfqs', 22, 'CREATE', 'Gabrielle Green', '2026-02-24 17:23:01', 'RFQ created for request ID 118. Date: 2026-02-24, Deadline: 2026-02-28T12:21'),
(1633, 'rfq_vendors', 58, 'CREATE', NULL, '2026-02-24 17:23:35', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260224-118'),
(1634, 'rfq_vendors', 59, 'CREATE', NULL, '2026-02-24 17:23:40', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260224-118'),
(1635, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-24 17:25:08', 'Quote uploaded for RFQ ID 22'),
(1636, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-24 17:25:30', 'Quote uploaded for RFQ ID 22'),
(1637, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-24 17:27:12', 'Quote 58 reviewed: DOES_NOT_MEET by Requestor 1'),
(1638, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-24 17:27:23', 'Quote 59 reviewed: MEETS_REQUIREMENTS by Requestor 1'),
(1639, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-24 17:29:17', 'Quote 59 selected by Finance Officer Latoya Gayle - Vendor: Accu Power Limited, Amount: $56.00'),
(1640, 'procurement_requests', 118, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-02-24 17:29:46', 'Funds verified by Finance Officer'),
(1641, 'procurement_requests', 118, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-02-24 17:29:46', 'Finance Officer verified funds are available for this request.'),
(1642, 'commitments', 85, 'CREATE', 'Latoya Gayle', '2026-02-24 17:30:18', 'Commitment uploaded by Finance Officer - Funds verified and commitment document uploaded from GFMS'),
(1643, 'procurement_requests', 118, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-02-24 17:30:18', 'Finance Officer uploaded commitment CM007. Ready for PO creation.'),
(1644, 'purchase_orders', 64, 'CREATE', 'Gabrielle Green', '2026-02-25 01:11:20', 'Purchase Order created'),
(1645, 'procurement_requests', 118, 'PO_CREATED', 'Gabrielle Green', '2026-02-25 01:11:20', 'PO PO-2026-0005 created and auto-approved'),
(1646, 'purchase_orders', 65, 'CREATE', 'Gabrielle Green', '2026-02-25 01:19:53', 'Purchase Order created'),
(1647, 'procurement_requests', 116, 'PO_CREATED', 'Gabrielle Green', '2026-02-25 01:19:53', 'PO PO-2026-0006 created and auto-approved'),
(1648, 'invoices', 66, 'CREATE', 'Latoya Gayle', '2026-02-25 02:10:58', 'Invoice added by user ID 6'),
(1649, 'procurement_requests', 118, 'INVOICE_RECEIVED', 'Latoya Gayle', '2026-02-25 02:10:58', 'Invoice #inv21 received for PO PO-2026-0005'),
(1650, 'invoices', 67, 'CREATE', 'Latoya Gayle', '2026-02-25 02:11:40', 'Invoice added by user ID 6'),
(1651, 'procurement_requests', 116, 'INVOICE_RECEIVED', 'Latoya Gayle', '2026-02-25 02:11:40', 'Invoice #inv22 received for PO PO-2026-0006'),
(1652, 'invoices', 68, 'CREATE', 'Latoya Gayle', '2026-02-25 02:12:20', 'Invoice added by user ID 6'),
(1653, 'procurement_requests', 117, 'INVOICE_RECEIVED', 'Latoya Gayle', '2026-02-25 02:12:20', 'Invoice #inv20 received for PO PO-2026-0004'),
(1654, 'invoices', 69, 'CREATE', 'Latoya Gayle', '2026-02-25 02:14:32', 'Invoice added by user ID 6'),
(1655, 'procurement_requests', 117, 'INVOICE_RECEIVED', 'Latoya Gayle', '2026-02-25 02:14:32', 'Invoice #inv24 received for PO PO-2026-0004'),
(1656, 'payments', 64, 'CREATE', 'Requestor 1', '2026-02-25 02:21:08', 'Payment recorded'),
(1657, 'payments', 65, 'CREATE', 'Requestor 1', '2026-02-25 02:21:34', 'Payment recorded'),
(1658, 'procurement_requests', 116, 'COMPLETED', 'Requestor 1', '2026-02-25 02:21:34', 'All invoices fully paid. Procurement process completed.'),
(1659, 'payments', 66, 'CREATE', 'Requestor 1', '2026-02-25 02:22:07', 'Payment recorded'),
(1660, 'procurement_requests', 117, 'COMPLETED', 'Requestor 1', '2026-02-25 02:22:07', 'All invoices fully paid. Procurement process completed.'),
(1661, 'payments', 67, 'CREATE', 'Requestor 1', '2026-02-25 02:41:04', 'Payment recorded'),
(1662, 'procurement_requests', 118, 'COMPLETED', 'Requestor 1', '2026-02-25 02:41:04', 'All invoices fully paid. Procurement process completed.'),
(1663, 'payments', 68, 'CREATE', 'Requestor 1', '2026-02-25 02:41:48', 'Payment recorded'),
(1664, 'procurement_requests', 115, 'COMPLETED', 'Requestor 1', '2026-02-25 02:41:48', 'All invoices fully paid. Procurement process completed.'),
(1665, 'users', 23, 'LOCKOUT', NULL, '2026-02-25 02:56:44', 'Account locked after failed attempts'),
(1666, 'users', 23, 'ACCOUNT_UNLOCKED', 'Demario Ewan', '2026-02-25 02:57:21', 'Account unlocked by admin (User ID: 16). Previous failed attempts: 5'),
(1667, 'procurement_requests', 119, 'CREATE', 'Requestor 1', '2026-02-25 11:37:38', 'Procurement request created'),
(1668, 'procurement_requests', 119, 'STATUS_CHANGE', 'Requestor 1', '2026-02-25 11:37:48', 'Draft → Submitted'),
(1669, 'procurement_requests', 119, 'APPROVAL_CHAIN_CREAT', 'Requestor 1', '2026-02-25 11:37:48', 'Approval chain created: Deputy Government Chemist'),
(1670, 'request_approvals', 82, 'APPROVE_STAGE', 'Deputy Government Chemist', '2026-02-25 11:42:46', 'Approved by Deputy Government Chemist'),
(1671, 'procurement_requests', 119, 'STATUS_CHANGE', 'Deputy Government Chemist', '2026-02-25 11:42:46', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Deputy Government Chemist'),
(1672, 'procurement_requests', 119, 'RFQ_LETTER_AVAILABLE', 'Deputy Government Chemist', '2026-02-25 11:42:46', 'Approval by Deputy Government Chemist'),
(1673, 'rfqs', 23, 'CREATE', 'Gabrielle Green', '2026-02-25 11:43:43', 'RFQ created for request ID 119. Date: 2026-02-25, Deadline: 2026-03-25T17:00'),
(1674, 'rfq_vendors', 60, 'CREATE', NULL, '2026-02-25 11:43:50', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260225-119'),
(1675, 'rfq_vendors', 61, 'CREATE', NULL, '2026-02-25 11:43:55', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260225-119'),
(1676, 'rfq_vendors', 62, 'CREATE', NULL, '2026-02-25 11:44:00', 'Vendor \'Printers & Office Supplies Limited\' added to RFQ RFQ-20260225-119'),
(1677, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-25 11:44:17', 'Quote uploaded for RFQ ID 23'),
(1678, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-25 11:44:32', 'Quote uploaded for RFQ ID 23'),
(1679, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-25 11:44:52', 'Quote uploaded for RFQ ID 23'),
(1680, 'users', 22, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:16', 'User \'Yanique A. Fraser\' (yanique.fraser@moh.gov.jm) deleted.'),
(1681, 'users', 21, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:23', 'User \'Deputy Government Chemist\' (d@gmail.com) deleted.'),
(1682, 'users', 9, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:30', 'User \'Gabrielle Green\' (gabreille.green@moh.gov.jm) deleted.'),
(1683, 'users', 24, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:36', 'User \'HOD\' (h@gmail.com) deleted.'),
(1684, 'users', 23, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:44', 'User \'Requestor 1\' (r@gmail.com) deleted.'),
(1685, 'users', 4, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:51', 'User \'Technical & User Support Officer\' (demarioe14@gmail.com) deleted.'),
(1686, 'users', 19, 'DELETE', 'Demario Ewan', '2026-02-25 14:52:58', 'User \'Viewer\' (v@gmail.com) deleted.'),
(1687, 'system_config', 0, 'UPDATE', 'Demario Ewan', '2026-02-25 15:03:53', 'System settings updated: enable_notifications=ON, threshold=500,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.0000'),
(1688, 'users', 25, 'CREATE', 'Demario Ewan', '2026-02-25 15:04:33', 'User \'Technical & User Support Officer\' (demarioe14@gmail.com) created by admin.'),
(1689, 'users', 27, 'CREATE', 'Demario Ewan', '2026-02-25 15:05:24', 'User \'Technical & User Support Officer\' (Demario.Ewan@moh.gov.jm) created by admin.'),
(1690, 'users', 25, 'DELETE', 'Demario Ewan', '2026-02-25 15:05:39', 'User \'Technical & User Support Officer\' (demarioe14@gmail.com) deleted.'),
(1691, 'users', 27, 'PASSWORD_CHANGE', 'Technical & User Support Officer', '2026-02-25 15:07:13', 'Password updated'),
(1692, 'users', 16, 'DELETE', 'Technical & User Support Officer', '2026-02-25 15:07:38', 'User \'Demario Ewan\' (dewan@dsitservicesja.com) deleted.'),
(1693, 'procurement_requests', 111, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:07', 'Request deleted by admin'),
(1694, 'procurement_requests', 111, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:07', 'Request deleted by admin'),
(1695, 'procurement_requests', 114, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:18', 'Request deleted by admin'),
(1696, 'procurement_requests', 114, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:18', 'Request deleted by admin'),
(1697, 'procurement_requests', 112, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:51', 'Request deleted by admin'),
(1698, 'procurement_requests', 112, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:11:51', 'Request deleted by admin'),
(1699, 'procurement_requests', 110, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:13:45', 'Request deleted by admin'),
(1700, 'procurement_requests', 110, 'DELETE', 'Technical & User Support Officer', '2026-02-25 21:13:45', 'Request deleted by admin'),
(1701, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-26 02:18:00', 'System settings updated: enable_notifications=OFF, threshold=500,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.2200'),
(1702, 'procurement_requests', 120, 'CREATE', 'Technical & User Support Officer', '2026-02-26 02:19:16', 'Procurement request created'),
(1703, 'procurement_requests', 120, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-26 02:19:23', 'Draft → Submitted'),
(1704, 'procurement_requests', 120, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-26 02:19:23', 'Approval chain created: Deputy Government Chemist'),
(1705, 'users', 28, 'CREATE', 'Technical & User Support Officer', '2026-02-26 02:20:25', 'User \'Deputy Gov Chem\' (d@gmail.com) created by admin.'),
(1706, 'users', 28, 'PASSWORD_CHANGE', 'Deputy Gov Chem', '2026-02-26 02:20:50', 'Password updated'),
(1707, 'procurement_requests', 120, 'STATUS_CHANGE', 'Deputy Gov Chem', '2026-02-26 02:22:09', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1708, 'procurement_requests', 120, 'RFQ_LETTER_AVAILABLE', 'Deputy Gov Chem', '2026-02-26 02:22:09', 'GC approval by Deputy Gov Chem'),
(1709, 'users', 29, 'CREATE', 'Technical & User Support Officer', '2026-02-26 02:23:36', 'User \'Procurement\' (p@gmail.com) created by admin.'),
(1710, 'users', 29, 'PASSWORD_CHANGE', 'Procurement', '2026-02-26 02:23:56', 'Password updated'),
(1711, 'rfqs', 24, 'CREATE', 'Procurement', '2026-02-26 02:24:47', 'RFQ created for request ID 120. Date: 2026-02-25, Deadline: 2026-03-25T00:00'),
(1712, 'rfq_vendors', 63, 'CREATE', NULL, '2026-02-26 02:25:15', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260225-120'),
(1713, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-26 02:25:48', 'Quote uploaded for RFQ ID 24'),
(1714, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-26 02:26:25', 'Quote 63 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1715, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-26 02:26:59', 'Quote 63 reviewed: DOES_NOT_MEET by Technical & User Support Officer'),
(1716, 'rfq_vendors', 64, 'CREATE', '27', '2026-02-26 02:27:14', 'Vendor \'Intcomex Limited\' added to RFQ RFQ-20260225-120'),
(1717, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-02-26 02:27:34', 'Quote uploaded for RFQ ID 24'),
(1718, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-26 02:27:42', 'Quote 64 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1719, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-02-26 02:28:19', 'Quote 64 selected by Finance Officer Latoya Gayle - Vendor: Intcomex Limited, Amount: $234.00'),
(1720, 'procurement_requests', 120, 'COMMITMENT_DECLINED', 'Latoya Gayle', '2026-02-26 02:28:49', 'Finance declined - Reason: no funds available'),
(1721, 'procurement_requests', 120, 'COMMITMENT_DECLINED', 'Latoya Gayle', '2026-02-26 02:28:49', 'Finance Officer: Funds not available. Reason: no funds available'),
(1722, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-02-26 02:29:23', 'Quote 60 reviewed: MEETS_REQUIREMENTS by Procurement'),
(1723, 'procurement_requests', 121, 'CREATE', 'Technical & User Support Officer', '2026-02-26 02:40:48', 'Procurement request created'),
(1724, 'procurement_requests', 121, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-26 02:40:56', 'Draft → Submitted'),
(1725, 'procurement_requests', 121, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-26 02:40:56', 'Approval chain created: Deputy Government Chemist'),
(1726, 'procurement_requests', 121, 'STATUS_CHANGE', 'Deputy Gov Chem', '2026-02-26 02:41:36', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1727, 'procurement_requests', 121, 'RFQ_LETTER_AVAILABLE', 'Deputy Gov Chem', '2026-02-26 02:41:36', 'GC approval by Deputy Gov Chem'),
(1728, 'procurement_requests', 122, 'CREATE', 'Technical & User Support Officer', '2026-02-26 02:43:13', 'Procurement request created'),
(1729, 'procurement_requests', 122, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-02-26 02:43:18', 'Draft → Submitted'),
(1730, 'procurement_requests', 122, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-02-26 02:43:18', 'Approval chain created: Deputy Government Chemist'),
(1731, 'procurement_requests', 122, 'STATUS_CHANGE', 'Deputy Gov Chem', '2026-02-26 02:46:37', 'GC Approved (funds certified) — Status changed to PROCUREMENT_STAGE'),
(1732, 'procurement_requests', 122, 'PROCUREMENT_STAGE', 'Deputy Gov Chem', '2026-02-26 02:46:37', 'GC approval by Deputy Gov Chem'),
(1733, 'users', 28, 'DELETE', 'Technical & User Support Officer', '2026-02-26 15:00:42', 'User \'Deputy Gov Chem\' (d@gmail.com) deleted.'),
(1734, 'users', 6, 'DELETE', 'Technical & User Support Officer', '2026-02-26 15:00:47', 'User \'Latoya Gayle\' (latoya.gayle@moh.gov.jm) deleted.'),
(1735, 'users', 18, 'DELETE', 'Technical & User Support Officer', '2026-02-26 15:00:52', 'User \'Nellesha Samuels\' (Nellesha.Samuels@moh.gov.jm) deleted.'),
(1736, 'users', 29, 'DELETE', 'Technical & User Support Officer', '2026-02-26 15:00:57', 'User \'Procurement\' (p@gmail.com) deleted.'),
(1737, 'users', 17, 'DELETE', 'Technical & User Support Officer', '2026-02-26 15:01:01', 'User \'Shermaine McKenzie\' (shermaine.mckenzie@moh.gov.jm) deleted.'),
(1738, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-26 15:02:41', 'System settings updated: enable_notifications=ON, threshold=500,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.2200'),
(1739, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-02-26 15:13:25', 'System settings updated: enable_notifications=ON, threshold=500,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.2200'),
(1740, 'users', 30, 'CREATE', 'Technical & User Support Officer', '2026-02-26 15:14:04', 'User \'Demario Ewan\' (demarioe14@gmail.com) created by admin.'),
(1741, 'users', 30, 'PASSWORD_CHANGE', 'Demario Ewan', '2026-02-26 15:17:55', 'Password updated'),
(1742, 'users', 32, 'CREATE', 'Demario Ewan', '2026-02-26 15:28:16', 'User \'Yanique A. Fraser\' (yanique.fraser@moh.gov.jm) created by admin.'),
(1743, 'users', 33, 'CREATE', 'Demario Ewan', '2026-02-26 15:29:16', 'User \'Daneika Anderson\' (Daneika.Anderson@moh.gov.jm) created by admin.'),
(1744, 'users', 34, 'CREATE', 'Demario Ewan', '2026-02-26 15:29:48', 'User \'Latoya Gayle\' (Latoya.Gayle@moh.gov.jm) created by admin.'),
(1745, 'users', 35, 'CREATE', 'Demario Ewan', '2026-02-26 15:30:15', 'User \'Nellesha Samuels\' (Nellesha.Samuels@moh.gov.jm) created by admin.'),
(1746, 'users', 36, 'CREATE', 'Demario Ewan', '2026-02-26 15:30:42', 'User \'Ryan Warburton\' (Ryan.Warburton@moh.gov.jm) created by admin.'),
(1747, 'users', 37, 'CREATE', 'Demario Ewan', '2026-02-26 15:31:09', 'User \'Shermaine McKenzie\' (Shermaine.McKenzie@moh.gov.jm) created by admin.'),
(1748, 'users', 38, 'CREATE', 'Demario Ewan', '2026-02-26 15:31:30', 'User \'Waveney Warrick\' (Waveney.Warrick@moh.gov.jm) created by admin.'),
(1749, 'users', 39, 'CREATE', 'Demario Ewan', '2026-02-26 15:32:07', 'User \'Sancia Johnally Haynes\' (Sancia.Johnally-Haynes@moh.gov.jm) created by admin.'),
(1750, 'users', 40, 'CREATE', 'Demario Ewan', '2026-02-26 15:32:30', 'User \'Alfred Bryan\' (Alfred.Bryan@moh.gov.jm) created by admin.'),
(1751, 'users', 41, 'CREATE', 'Demario Ewan', '2026-02-26 15:33:18', 'User \'Fredricka Chung\' (Fredricka.Chung@moh.gov.jm) created by admin.'),
(1752, 'users', 42, 'CREATE', 'Demario Ewan', '2026-02-26 15:33:44', 'User \'Yanique McKenzie\' (Yanique.McKenzie@moh.gov.jm) created by admin.'),
(1753, 'users', 43, 'CREATE', 'Demario Ewan', '2026-02-26 15:34:07', 'User \'Shenai McFarlane\' (Shenai.McFarlane@moh.gov.jm) created by admin.'),
(1754, 'users', 44, 'CREATE', 'Demario Ewan', '2026-02-26 15:34:42', 'User \'Gabrielle Green\' (Gabrielle.Green@moh.gov.jm) created by admin.'),
(1755, 'users', 32, 'PASSWORD_CHANGE', 'Yanique A. Fraser', '2026-02-26 15:37:45', 'Password updated'),
(1756, 'users', 37, 'PASSWORD_CHANGE', 'Shermaine McKenzie', '2026-02-26 15:52:01', 'Password updated'),
(1757, 'procurement_requests', 123, 'CREATE', 'Shermaine McKenzie', '2026-02-26 15:55:56', 'Procurement request created'),
(1758, 'procurement_requests', 123, 'STATUS_CHANGE', 'Shermaine McKenzie', '2026-02-26 15:56:09', 'Draft → Submitted'),
(1759, 'procurement_requests', 123, 'APPROVAL_CHAIN_CREAT', 'Shermaine McKenzie', '2026-02-26 15:56:09', 'Approval chain created: Deputy Government Chemist'),
(1760, 'users', 38, 'PASSWORD_CHANGE', 'Waveney Warrick', '2026-02-26 16:00:39', 'Password updated'),
(1761, 'users', 33, 'PASSWORD_CHANGE', 'Daneika Anderson', '2026-02-26 16:01:58', 'Password updated'),
(1762, 'procurement_requests', 123, 'STATUS_CHANGE', 'Daneika Anderson', '2026-02-26 16:04:04', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1763, 'procurement_requests', 123, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-02-26 16:04:04', 'GC approval by Daneika Anderson'),
(1764, 'users', 44, 'PASSWORD_CHANGE', 'Gabrielle Green', '2026-02-26 16:05:55', 'Password updated'),
(1765, 'procurement_requests', 124, 'CREATE', 'Waveney Warrick', '2026-02-26 16:06:07', 'Procurement request created'),
(1766, 'procurement_requests', 124, 'STATUS_CHANGE', 'Waveney Warrick', '2026-02-26 16:07:39', 'Draft → Submitted'),
(1767, 'procurement_requests', 124, 'APPROVAL_CHAIN_CREAT', 'Waveney Warrick', '2026-02-26 16:07:39', 'Approval chain created: Deputy Government Chemist'),
(1768, 'request_approvals', 87, 'APPROVE_STAGE', 'Daneika Anderson', '2026-02-26 16:08:20', 'Approved by Deputy Government Chemist'),
(1769, 'procurement_requests', 124, 'STATUS_CHANGE', 'Daneika Anderson', '2026-02-26 16:08:20', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Deputy Government Chemist'),
(1770, 'procurement_requests', 124, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-02-26 16:08:20', 'Approval by Deputy Government Chemist'),
(1771, 'users', 36, 'PASSWORD_CHANGE', 'Ryan Warburton', '2026-02-26 16:12:42', 'Password updated'),
(1772, 'users', 41, 'PASSWORD_CHANGE', 'Fredricka Chung', '2026-02-26 16:15:58', 'Password updated'),
(1773, 'procurement_requests', 125, 'CREATE', 'Ryan Warburton', '2026-02-26 16:16:29', 'Procurement request created'),
(1774, 'procurement_requests', 125, 'STATUS_CHANGE', 'Ryan Warburton', '2026-02-26 16:16:57', 'Draft → Submitted'),
(1775, 'procurement_requests', 125, 'APPROVAL_CHAIN_CREAT', 'Ryan Warburton', '2026-02-26 16:16:57', 'Approval chain created: HOD'),
(1776, 'procurement_requests', 126, 'CREATE', 'Fredricka Chung', '2026-02-26 16:18:23', 'Procurement request created'),
(1777, 'procurement_requests', 126, 'STATUS_CHANGE', 'Fredricka Chung', '2026-02-26 16:18:43', 'Draft → Submitted'),
(1778, 'procurement_requests', 126, 'APPROVAL_CHAIN_CREAT', 'Fredricka Chung', '2026-02-26 16:18:43', 'Approval chain created: Deputy Government Chemist'),
(1779, 'procurement_requests', 125, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-02-26 16:19:59', 'Submitted → Declined by Yanique A. Fraser'),
(1780, 'procurement_requests', 125, 'DECLINED', 'Yanique A. Fraser', '2026-02-26 16:19:59', 'Request declined: Buy me a porche EV first — by Yanique A. Fraser'),
(1781, 'procurement_requests', 127, 'CREATE', 'Ryan Warburton', '2026-02-26 16:20:53', 'Procurement request created'),
(1782, 'procurement_requests', 127, 'STATUS_CHANGE', 'Ryan Warburton', '2026-02-26 16:21:05', 'Draft → Submitted'),
(1783, 'procurement_requests', 127, 'APPROVAL_CHAIN_CREAT', 'Ryan Warburton', '2026-02-26 16:21:05', 'Approval chain created: HOD'),
(1784, 'procurement_requests', 125, 'STATUS_CHANGE', 'Ryan Warburton', '2026-02-26 16:22:11', 'Declined → Draft (Resubmitted by Ryan Warburton)'),
(1785, 'procurement_requests', 125, 'RESUBMITTED', 'Ryan Warburton', '2026-02-26 16:22:11', 'Request resubmitted after decline by Ryan Warburton'),
(1786, 'procurement_requests', 127, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-02-26 16:22:21', 'Submitted → Declined by Yanique A. Fraser'),
(1787, 'procurement_requests', 127, 'DECLINED', 'Yanique A. Fraser', '2026-02-26 16:22:21', 'Request declined: Youre pushing it — by Yanique A. Fraser'),
(1788, 'procurement_requests', 125, 'EDIT', 'Ryan Warburton', '2026-02-26 16:28:02', 'Procurement Request #125 edited.\n\nOLD ITEMS:\n- Jetour G700 | Qty: 1 | Beast\n\nNEW ITEMS:\n- Porshe EV for Yanique | Qty: 1 | Bigger Beast\n'),
(1789, 'procurement_requests', 125, 'EDIT', 'Ryan Warburton', '2026-02-26 16:29:06', 'Procurement Request #125 edited.\n\nOLD ITEMS:\n- Porshe EV for Yanique | Qty: 1 | Bigger Beast\n\nNEW ITEMS:\n- Porshe EV for Yanique | Qty: 1 | Bigger Beast\n'),
(1790, 'procurement_requests', 125, 'EDIT', 'Ryan Warburton', '2026-02-26 16:29:27', 'Procurement Request #125 edited.\n\nOLD ITEMS:\n- Porshe EV for Yanique | Qty: 1 | Bigger Beast\n\nNEW ITEMS:\n- Porshe EV for Yanique | Qty: 1 | Bigger Beast\n'),
(1791, 'procurement_requests', 125, 'STATUS_CHANGE', 'Ryan Warburton', '2026-02-26 16:29:31', 'Draft → Submitted'),
(1792, 'procurement_requests', 125, 'APPROVAL_CHAIN_CREAT', 'Ryan Warburton', '2026-02-26 16:29:31', 'Approval chain created: HOD'),
(1793, 'procurement_requests', 125, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-02-26 16:30:49', 'Approved — Funds certified & Status changed to PROCUREMENT_STAGE by HOD'),
(1794, 'procurement_requests', 125, 'PROCUREMENT_STAGE', 'Yanique A. Fraser', '2026-02-26 16:30:49', 'Approval by Yanique A. Fraser - HOD'),
(1795, 'user_permissions', 32, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-04 14:45:15', 'Permission 60 updated (granted=1)'),
(1796, 'procurement_requests', 128, 'CREATE', 'Yanique A. Fraser', '2026-03-04 14:46:43', 'Reimbursement request created'),
(1797, 'pre_authorizations', 1796, 'CREATE', 'Yanique A. Fraser', '2026-03-04 14:46:43', 'Pre-authorization created for reimbursement'),
(1798, 'procurement_requests', 128, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-04 14:46:56', 'Reimbursement Request: Draft → Submitted'),
(1799, 'procurement_requests', 128, 'APPROVAL_CHAIN_CREAT', 'Yanique A. Fraser', '2026-03-04 14:46:56', 'Reimbursement approval chain created: Finance Officer'),
(1800, 'users', 34, 'PASSWORD_CHANGE', 'Latoya Gayle', '2026-03-04 14:53:22', 'Password updated'),
(1801, 'user_permissions', 34, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-04 14:56:40', 'Permission 107 updated (granted=1)'),
(1802, 'user_permissions', 34, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-04 14:56:40', 'Permission 106 updated (granted=1)'),
(1803, 'users', 35, 'PASSWORD_CHANGE', 'Nellesha Samuels', '2026-03-04 14:59:46', 'Password updated'),
(1804, 'procurement_requests', 129, 'CREATE', 'Technical & User Support Officer', '2026-03-04 18:09:12', 'Procurement request created'),
(1805, 'procurement_requests', 130, 'CREATE', 'Technical & User Support Officer', '2026-03-04 18:10:59', 'Procurement request created'),
(1806, 'procurement_requests', 130, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 18:11:41', 'Draft → Submitted'),
(1807, 'procurement_requests', 130, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-04 18:11:41', 'Approval chain created: Director HRM&A'),
(1808, 'procurement_requests', 129, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 18:11:59', 'Draft → Submitted'),
(1809, 'procurement_requests', 129, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-04 18:11:59', 'Approval chain created: Director HRM&A'),
(1810, 'procurement_requests', 129, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-04 18:32:13', 'Submitted → Declined by Nellesha Samuels'),
(1811, 'procurement_requests', 129, 'DECLINED', 'Nellesha Samuels', '2026-03-04 18:32:13', 'Request declined: Estimate outside of budget. Budget is $76000 — by Nellesha Samuels'),
(1812, 'procurement_requests', 130, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-04 18:33:41', 'Submitted → Declined by Nellesha Samuels'),
(1813, 'procurement_requests', 130, 'DECLINED', 'Nellesha Samuels', '2026-03-04 18:33:41', 'Request declined: Estimate outside of budget. Budget is $19500. Adjust item 1 to 4 — by Nellesha Samuels'),
(1814, 'users', 39, 'PASSWORD_CHANGE', 'Sancia Johnally Haynes', '2026-03-04 20:10:33', 'Password updated'),
(1815, 'procurement_requests', 129, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 20:18:07', 'Declined → Draft (Resubmitted by Technical & User Support Officer)'),
(1816, 'procurement_requests', 129, 'RESUBMITTED', 'Technical & User Support Officer', '2026-03-04 20:18:07', 'Request resubmitted after decline by Technical & User Support Officer'),
(1817, 'procurement_requests', 129, 'EDIT', 'Technical & User Support Officer', '2026-03-04 20:40:37', 'Procurement Request #129 edited.\n\nOLD ITEMS:\n- Projector Case | Qty: 1 | Projector Travel Carrying Bag Internal Dimension 14.5\"x10.6\"x3.9\" with Adjustable Shoulder Strap & Compartment Dividers for for Acer, Epson, Benq, LG, Sony (Large)\n- USB C to HDMI Adapter | Qty: 2 | Xtech USB C to HDMI Adapter\n- Avaya Digital Phones | Qty: 2 | Avaya 9508 Digital Phone\n\nNEW ITEMS:\n- Projector Case | Qty: 1 | Projector Travel Carrying Bag Internal Dimension 14.5\"x10.6\"x3.9\" with Adjustable Shoulder Strap & Compartment Dividers for for Acer, Epson, Benq, LG, Sony (Large)\n- USB C to HDMI Adapter | Qty: 2 | Xtech USB C to HDMI Adapter\n- Avaya Digital Phones | Qty: 2 | Avaya 9508 Digital Phone\n'),
(1818, 'procurement_requests', 129, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 20:40:55', 'Draft → Submitted'),
(1819, 'procurement_requests', 129, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-04 20:40:55', 'Approval chain created: Director HRM&A'),
(1820, 'procurement_requests', 130, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 20:42:26', 'Declined → Draft (Resubmitted by Technical & User Support Officer)'),
(1821, 'procurement_requests', 130, 'RESUBMITTED', 'Technical & User Support Officer', '2026-03-04 20:42:26', 'Request resubmitted after decline by Technical & User Support Officer'),
(1822, 'procurement_requests', 130, 'EDIT', 'Technical & User Support Officer', '2026-03-04 20:42:56', 'Procurement Request #130 edited.\n\nOLD ITEMS:\n- Xtech - Mouse pad | Qty: 6 | Voyager XTA-180\n- Klip Xtreme - Mouse - 2.4 GHz | Qty: 6 | Ergonomic Mice, Rechargeable\n\nNEW ITEMS:\n- Xtech - Mouse pad | Qty: 4 | Voyager XTA-180\n- Klip Xtreme - Mouse - 2.4 GHz | Qty: 6 | Ergonomic Mice, Rechargeable\n'),
(1823, 'procurement_requests', 130, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 20:43:04', 'Draft → Submitted'),
(1824, 'procurement_requests', 130, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-04 20:43:04', 'Approval chain created: Director HRM&A'),
(1825, 'procurement_requests', 131, 'CREATE', 'Technical & User Support Officer', '2026-03-04 20:46:20', 'Procurement request created'),
(1826, 'procurement_requests', 131, 'EDIT', 'Technical & User Support Officer', '2026-03-04 20:53:11', 'Procurement Request #131 edited.\n\nOLD ITEMS:\n- Microsoft Surface Pro 13\" | Qty: 1 | 3K 120Hz OLED Touch AI Laptop, 900nits, 12-Core Snapdragon, 45 Tops NPU, 16GB RAM, 512GB SSD, USB4, Wi-Fi 7, Backlit KB, Stylus, MS 365, Win 11 Pro\n\nNEW ITEMS:\n- Microsoft Surface Pro 13\" | Qty: 1 | 3K 120Hz OLED Touch AI Laptop, 900nits, 12-Core Snapdragon, 45 Tops NPU, 16GB RAM, 512GB SSD, USB4, Wi-Fi 7, Backlit KB, Stylus, MS 365, Win 11 Pro\n- Fintie Case for 13 Inch Microsoft Surface Pro | Qty: 1 | Multiple Angle Viewing Portfolio Business Cover with Pocket & Stylus Holder, Compatible with Type Cover Keyboard, Ice Blue\n'),
(1827, 'procurement_requests', 131, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-04 20:53:17', 'Draft → Submitted'),
(1828, 'procurement_requests', 131, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-04 20:53:17', 'Approval chain created: HOD'),
(1829, 'request_approvals', 95, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-03-04 21:02:57', 'Approved by Director HRM&A'),
(1830, 'procurement_requests', 129, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-04 21:02:57', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1831, 'procurement_requests', 129, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-03-04 21:02:57', 'Approval by Director HRM&A'),
(1832, 'request_approvals', 96, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-03-04 21:03:50', 'Approved by Director HRM&A'),
(1833, 'procurement_requests', 130, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-04 21:03:50', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1834, 'procurement_requests', 130, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-03-04 21:03:50', 'Approval by Director HRM&A'),
(1835, 'request_approvals', 97, 'APPROVE_STAGE', 'Yanique A. Fraser', '2026-03-04 21:04:34', 'Approved by HOD'),
(1836, 'procurement_requests', 131, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-04 21:04:34', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by HOD'),
(1837, 'procurement_requests', 131, 'RFQ_LETTER_AVAILABLE', 'Yanique A. Fraser', '2026-03-04 21:04:34', 'Approval by HOD'),
(1838, 'users', 40, 'PASSWORD_CHANGE', 'Alfred Bryan', '2026-03-06 17:12:33', 'Password updated'),
(1839, 'procurement_requests', 132, 'CREATE', 'Alfred Bryan', '2026-03-06 17:14:45', 'Procurement request created'),
(1840, 'procurement_requests', 132, 'STATUS_CHANGE', 'Alfred Bryan', '2026-03-06 17:15:29', 'Draft → Submitted'),
(1841, 'procurement_requests', 132, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-03-06 17:15:29', 'Approval chain created: Director HRM&A'),
(1842, 'request_approvals', 98, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-03-06 17:24:09', 'Approved by Director HRM&A'),
(1843, 'procurement_requests', 132, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-06 17:24:09', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1844, 'procurement_requests', 132, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-03-06 17:24:09', 'Approval by Director HRM&A'),
(1845, 'users', 44, 'LOCKOUT', '44', '2026-03-09 16:44:43', 'Account locked after failed attempts'),
(1846, 'users', 44, 'LOCKOUT', '44', '2026-03-09 18:28:22', 'Account locked after failed attempts'),
(1847, 'users', 44, 'ACCOUNT_UNLOCKED', 'Technical & User Support Officer', '2026-03-09 18:30:02', 'Account unlocked by admin (User ID: 27). Previous failed attempts: 5'),
(1848, 'procurement_requests', 133, 'CREATE', 'Technical & User Support Officer', '2026-03-12 20:12:44', 'Procurement request created'),
(1849, 'procurement_requests', 133, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-12 20:12:51', 'Draft → Submitted'),
(1850, 'procurement_requests', 133, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-12 20:12:51', 'Approval chain created: Director HRM&A'),
(1851, 'request_approvals', 99, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-03-12 20:17:12', 'Approved by Director HRM&A'),
(1852, 'procurement_requests', 133, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-12 20:17:12', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1853, 'procurement_requests', 133, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-03-12 20:17:12', 'Approval by Director HRM&A'),
(1854, 'procurement_requests', 133, 'DELETE', 'Technical & User Support Officer', '2026-03-16 14:10:42', 'Request deleted by admin'),
(1855, 'procurement_requests', 133, 'DELETE', 'Technical & User Support Officer', '2026-03-16 14:10:42', 'Request deleted by admin'),
(1856, 'procurement_requests', 134, 'CREATE', 'Technical & User Support Officer', '2026-03-16 14:20:03', 'Procurement request created'),
(1857, 'procurement_requests', 134, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-16 14:20:13', 'Draft → Submitted'),
(1858, 'procurement_requests', 134, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-16 14:20:13', 'Approval chain created: Deputy Government Chemist'),
(1859, 'rfqs', 25, 'CREATE', 'Gabrielle Green', '2026-03-16 17:51:59', 'RFQ created for request ID 131. Date: 2026-03-16, Deadline: 2026-03-23T04:51'),
(1860, 'rfqs', 26, 'CREATE', 'Gabrielle Green', '2026-03-16 20:31:08', 'RFQ created for request ID 132. Date: 2026-03-16, Deadline: 2026-03-23T15:31'),
(1861, 'procurement_requests', 135, 'CREATE', 'Technical & User Support Officer', '2026-03-17 14:29:45', 'Procurement request created'),
(1862, 'procurement_requests', 135, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 14:29:58', 'Draft → Submitted'),
(1863, 'procurement_requests', 135, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-17 14:29:58', 'Approval chain created: Deputy Government Chemist'),
(1864, 'request_approvals', 101, 'APPROVE_STAGE', 'Daneika Anderson', '2026-03-17 14:39:45', 'Approved by Deputy Government Chemist'),
(1865, 'procurement_requests', 131, 'DELETE', 'Technical & User Support Officer', '2026-03-17 15:49:23', 'Request deleted by admin'),
(1866, 'procurement_requests', 131, 'DELETE', 'Technical & User Support Officer', '2026-03-17 15:49:23', 'Request deleted by admin'),
(1867, 'procurement_requests', 135, 'DELETE', 'Technical & User Support Officer', '2026-03-17 15:51:27', 'Request deleted by admin'),
(1868, 'procurement_requests', 135, 'DELETE', 'Technical & User Support Officer', '2026-03-17 15:51:27', 'Request deleted by admin'),
(1869, 'procurement_requests', 136, 'CREATE', 'Technical & User Support Officer', '2026-03-17 15:53:09', 'Procurement request created'),
(1870, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-03-17 15:53:51', 'System settings updated: enable_notifications=ON, threshold=3,000,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.2200, hod_approval_threshold=500,000.00, committee_review_threshold=3,000,000.00'),
(1871, 'procurement_requests', 136, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 15:57:12', 'Draft → Submitted'),
(1872, 'procurement_requests', 136, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-17 15:57:12', 'Approval chain created: HOD → Deputy Government Chemist'),
(1873, 'procurement_requests', 137, 'CREATE', 'Technical & User Support Officer', '2026-03-17 15:59:36', 'Procurement request created'),
(1874, 'procurement_requests', 137, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 16:00:01', 'Draft → Submitted'),
(1875, 'procurement_requests', 137, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-17 16:00:01', 'Approval chain created: HOD'),
(1878, 'procurement_requests', 134, 'STATUS_CHANGE', 'Daneika Anderson', '2026-03-17 16:10:49', 'Submitted → Declined by Daneika Anderson'),
(1879, 'procurement_requests', 134, 'DECLINED', 'Daneika Anderson', '2026-03-17 16:10:49', 'Request declined: Fix issue — by Daneika Anderson'),
(1880, 'procurement_requests', 137, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-17 16:11:54', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(1881, 'procurement_requests', 137, 'RFQ_LETTER_AVAILABLE', 'Yanique A. Fraser', '2026-03-17 16:11:54', 'Approval by Yanique A. Fraser - HOD'),
(1882, 'procurement_requests', 127, 'UPDATE', 'Technical & User Support Officer', '2026-03-17 16:27:11', 'Signed request uploaded: FinMan Installation_Revised (1).pdf'),
(1883, 'procurement_requests', 127, 'SIGNED_REQUEST_UPLOA', 'Technical & User Support Officer', '2026-03-17 16:27:11', 'Signed request uploaded by Technical & User Support Officer: FinMan Installation_Revised (1).pdf'),
(1884, 'procurement_requests', 137, 'UPDATE', 'Yanique A. Fraser', '2026-03-17 16:29:43', 'Signed request uploaded: PR013.pdf'),
(1885, 'procurement_requests', 137, 'SIGNED_REQUEST_UPLOA', 'Yanique A. Fraser', '2026-03-17 16:29:43', 'Signed request uploaded by Yanique A. Fraser: PR013.pdf'),
(1886, 'procurement_requests', 138, 'CREATE', 'Technical & User Support Officer', '2026-03-17 16:45:56', 'Procurement request created'),
(1887, 'procurement_requests', 138, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 16:46:03', 'Draft → Submitted'),
(1888, 'procurement_requests', 138, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-17 16:46:03', 'Approval chain created: HOD → Deputy Government Chemist'),
(1891, 'procurement_requests', 138, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-17 16:47:58', 'Submitted → Declined by Yanique A. Fraser'),
(1892, 'procurement_requests', 138, 'DECLINED', 'Yanique A. Fraser', '2026-03-17 16:47:58', 'Request declined: not able to approve — by Yanique A. Fraser'),
(1893, 'rfqs', 27, 'CREATE', 'Gabrielle Green', '2026-03-17 16:53:40', 'RFQ created for request ID 137. Date: 2026-03-17, Deadline: 2026-03-19T11:00'),
(1894, 'vendors', 4, 'CREATE', '44', '2026-03-17 16:56:32', 'Vendor \'MC System\' created'),
(1895, 'rfq_vendors', 65, 'CREATE', '44', '2026-03-17 16:57:01', 'Vendor \'MC System\' added to RFQ RFQ-20260317-137'),
(1896, 'procurement_requests', 138, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 17:14:17', 'Declined → Draft (Resubmitted by Technical & User Support Officer)'),
(1897, 'procurement_requests', 138, 'RESUBMITTED', 'Technical & User Support Officer', '2026-03-17 17:14:17', 'Request resubmitted after decline by Technical & User Support Officer'),
(1898, 'procurement_requests', 138, 'EDIT', 'Technical & User Support Officer', '2026-03-17 17:14:28', 'Procurement Request #138 edited.\n\nOLD ITEMS:\n- APC Smart‑UPS On‑Line SRT 5.4 kVA | Qty: 1 | SRT5KXLTUS \n\nNEW ITEMS:\n- APC Smart‑UPS On‑Line SRT 5.4 kVA | Qty: 1 | SRT5KXLTUS \n'),
(1899, 'procurement_requests', 138, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-17 17:14:46', 'Draft → Submitted'),
(1900, 'procurement_requests', 138, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-17 17:14:46', 'Approval chain created: HOD → Deputy Government Chemist'),
(1901, 'vendors', 5, 'CREATE', '44', '2026-03-17 17:14:52', 'Vendor \'Advanced Integrated System\' created'),
(1902, 'rfq_vendors', 66, 'CREATE', '44', '2026-03-17 17:15:32', 'Vendor \'Advanced Integrated System\' added to RFQ RFQ-20260317-137'),
(1903, 'vendors', 6, 'CREATE', '44', '2026-03-17 17:16:54', 'Vendor \'Printware\' created'),
(1904, 'rfq_vendors', 67, 'CREATE', '44', '2026-03-17 17:17:38', 'Vendor \'Printware\' added to RFQ RFQ-20260317-137'),
(1905, 'procurement_requests', 138, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-17 17:27:56', 'Approved — Funds certified & Status changed to HOD_APPROVED by HOD'),
(1906, 'procurement_requests', 138, 'HOD_APPROVED', 'Yanique A. Fraser', '2026-03-17 17:27:56', 'Approval by Yanique A. Fraser - HOD'),
(1907, 'procurement_requests', 138, 'UPDATE', 'Yanique A. Fraser', '2026-03-17 17:31:10', 'Signed request uploaded: PR014.pdf'),
(1908, 'procurement_requests', 138, 'SIGNED_REQUEST_UPLOA', 'Yanique A. Fraser', '2026-03-17 17:31:10', 'Signed request uploaded by Yanique A. Fraser: PR014.pdf'),
(1909, 'procurement_requests', 138, 'STATUS_CHANGE', 'Daneika Anderson', '2026-03-17 17:59:29', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1910, 'procurement_requests', 138, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-03-17 17:59:29', 'GC approval by Daneika Anderson'),
(1911, 'vendors', 7, 'CREATE', '44', '2026-03-17 18:53:56', 'Vendor \'D&S IT Services\' created'),
(1912, 'rfq_vendors', 68, 'CREATE', '44', '2026-03-17 18:54:20', 'Vendor \'D&S IT Services\' added to RFQ RFQ-20260317-137'),
(1913, 'rfqs', 28, 'CREATE', 'Gabrielle Green', '2026-03-17 19:12:55', 'RFQ created for request ID 138. Date: 2026-03-17, Deadline: 2026-03-19T11:00'),
(1914, 'rfq_vendors', 69, 'CREATE', '44', '2026-03-17 19:13:46', 'Vendor \'Accu Power Limited\' added to RFQ RFQ-20260317-138'),
(1915, 'rfqs', 28, 'UPDATE', '44', '2026-03-17 19:46:39', 'RFQ emails sent - Total: 1, Sent: 1, Failed: 0'),
(1916, 'vendors', 8, 'CREATE', '44', '2026-03-17 19:48:10', 'Vendor \'Demario Ewan\' created'),
(1917, 'rfq_vendors', 70, 'CREATE', '44', '2026-03-17 19:50:02', 'Vendor \'Demario Ewan\' added to RFQ RFQ-20260317-138 - RFQ notification email sent to demario.ewan@moh.gov.jm'),
(1918, 'rfqs', 28, 'UPDATE', '44', '2026-03-17 19:50:12', 'RFQ emails sent - Total: 2, Sent: 2, Failed: 0'),
(1919, 'rfq_vendors', 71, 'CREATE', '44', '2026-03-17 19:54:46', 'Vendor \'Demario Ewan\' added to RFQ RFQ-20260316-132 - RFQ notification email sent to demario.ewan@moh.gov.jm'),
(1920, 'procurement_requests', 139, 'CREATE', 'Sancia Johnally Haynes', '2026-03-17 20:03:02', 'Reimbursement request created'),
(1921, 'pre_authorizations', 1920, 'CREATE', 'Sancia Johnally Haynes', '2026-03-17 20:03:02', 'Pre-authorization created for reimbursement'),
(1922, 'user_permissions', 39, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-17 20:05:21', 'Permission 103 updated (granted=1)'),
(1923, 'rfqs', 28, 'UPDATE', '27', '2026-03-17 20:06:48', 'RFQ emails sent - Total: 2, Sent: 2, Failed: 0'),
(1924, 'rfqs', 26, 'UPDATE', '27', '2026-03-17 20:10:30', 'RFQ emails sent - Total: 1, Sent: 1, Failed: 0'),
(1925, 'procurement_requests', 139, 'STATUS_CHANGE', 'Sancia Johnally Haynes', '2026-03-17 20:15:42', 'Draft → Submitted'),
(1926, 'procurement_requests', 139, 'APPROVAL_CHAIN_CREAT', 'Sancia Johnally Haynes', '2026-03-17 20:15:42', 'Approval chain created: HOD'),
(1927, 'rfqs', 26, 'UPDATE', '27', '2026-03-18 13:09:23', 'RFQ emails sent - Total: 1, Sent: 1, Failed: 0'),
(1928, 'rfqs', 26, 'UPDATE', '27', '2026-03-18 13:41:23', 'RFQ emails sent - Total: 1, Sent: 1, Failed: 0'),
(1929, 'vendors', 9, 'CREATE', '44', '2026-03-18 13:48:28', 'Vendor \'Royale Computers & Accessories Ltd\' created'),
(1930, 'rfq_vendors', 72, 'CREATE', '44', '2026-03-18 13:48:44', 'Vendor \'Royale Computers & Accessories Ltd\' added to RFQ RFQ-20260317-137 - RFQ notification email sent to Shaquille.Murray@royalecomputers.com'),
(1931, 'rfqs', 26, 'UPDATE', '27', '2026-03-18 13:50:59', 'RFQ emails sent - Total: 1, Sent: 1, Failed: 0'),
(1932, 'vendors', 8, 'UPDATE', '27', '2026-03-18 13:59:20', 'Updated: Status: ACTIVE → INACTIVE'),
(1933, 'vendors', 8, 'UPDATE', '27', '2026-03-18 13:59:32', 'Updated: Status:  → ACTIVE'),
(1934, 'rfq_vendors', 26, 'DELETE', 'Technical & User Support Officer', '2026-03-18 14:02:07', 'Vendor \"Demario Ewan\" (rfq_vendor_id=71) removed from RFQ'),
(1935, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-03-18 14:02:07', 'Quote uploaded for RFQ ID 27'),
(1936, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-03-18 14:03:15', 'Quote 65 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1937, 'rfq_vendors', 73, 'CREATE', '27', '2026-03-18 14:07:18', 'Vendor \'Demario Ewan\' added to RFQ RFQ-20260316-132 - RFQ notification email sent to demario.ewan@moh.gov.jm'),
(1938, 'vendors', 3, 'DELETE', 'Technical & User Support Officer', '2026-03-18 14:08:10', 'Vendor \"Intcomex Limited\" deleted from master list'),
(1939, 'vendors', 2, 'UPDATE', '27', '2026-03-18 14:08:30', 'Updated: Status: ACTIVE → INACTIVE'),
(1940, 'rfq_quotes', NULL, 'SELECT', NULL, '2026-03-18 14:20:21', 'Quote 65 selected by Finance Officer Latoya Gayle - Vendor: Royale Computers & Accessories Ltd, Amount: $355949.10'),
(1941, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 14:20:43', 'Funds verified by Finance Officer'),
(1942, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 14:20:43', 'Finance Officer verified funds are available for this request.'),
(1943, 'rfq_vendors', 28, 'DELETE', 'Technical & User Support Officer', '2026-03-18 14:57:45', 'Vendor \"Demario Ewan\" (rfq_vendor_id=70) removed from RFQ'),
(1944, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-03-18 15:20:30', 'Quote 65 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1945, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-03-18 15:34:03', 'Quote 65 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1946, 'procurement_requests', 137, 'QUOTE_APPROVED', 'Technical & User Support Officer', '2026-03-18 15:34:03', 'Quote from Royale Computers & Accessories Ltd approved by Technical & User Support Officer. Finance notified to verify funds.'),
(1947, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 16:13:12', 'Funds verified by Finance Officer'),
(1948, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 16:13:12', 'Finance Officer verified funds are available. Procurement Officer to fill commitment form.'),
(1949, 'commitments', 86, 'CREATE', 'Gabrielle Green', '2026-03-18 16:22:55', 'Commitment form submitted by Procurement Officer (paper form submitted)'),
(1950, 'procurement_requests', 137, 'COMMITMENTS_PENDING', 'Gabrielle Green', '2026-03-18 16:22:55', 'Procurement Officer submitted commitment form CM001 (paper form submitted). Awaiting Finance to create commitment.'),
(1951, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-03-18 16:53:48', 'Quote 65 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1952, 'procurement_requests', 137, 'QUOTE_APPROVED', 'Technical & User Support Officer', '2026-03-18 16:53:48', 'Quote from Royale Computers & Accessories Ltd approved by Technical & User Support Officer. Finance notified to verify funds.'),
(1953, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 19:51:11', 'Funds verified by Finance Officer'),
(1954, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-18 19:51:11', 'Finance Officer verified funds are available. Procurement Officer to fill commitment form.'),
(1955, 'procurement_requests', 137, 'FORM_UPLOADED', 'Latoya Gayle', '2026-03-19 17:11:07', 'Commitment form uploaded by Finance Officer: /uploads/commitments/COMMIT_FORM_1773940267_69bc2e2bc7a70.pdf'),
(1956, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-19 17:11:07', 'Finance Officer uploaded commitment form. Finance to create commitment in GFMS.'),
(1957, 'procurement_requests', 137, 'FORM_SKIPPED', 'Latoya Gayle', '2026-03-19 17:11:24', 'Finance Officer skipped commitment form upload (optional step).'),
(1958, 'procurement_requests', 137, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-03-19 17:11:24', 'Finance Officer proceeded without uploading commitment form. Finance to create commitment in GFMS.'),
(1959, 'procurement_requests', 137, 'FORM_UPLOADED', 'Latoya Gayle', '2026-03-19 17:20:01', 'Commitment form uploaded by Finance Officer: /uploads/commitments/COMMIT_FORM_1773940801_69bc3041f0636.pdf'),
(1960, 'procurement_requests', 137, 'COMMITMENTS_PENDING', 'Latoya Gayle', '2026-03-19 17:20:01', 'Finance Officer uploaded commitment form. Finance to create commitment in GFMS.');
INSERT IGNORE INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(1961, 'commitments', 87, 'CREATE', 'Latoya Gayle', '2026-03-19 17:21:22', 'Commitment created by Finance Officer from GFMS and document uploaded'),
(1962, 'procurement_requests', 137, 'COMMITMENT_APPROVED', 'Latoya Gayle', '2026-03-19 17:21:22', 'Finance Officer created commitment CM001 in GFMS and uploaded commitment document. Ready for PO creation.'),
(1963, 'rfq_vendors', 74, 'CREATE', '27', '2026-03-20 16:50:45', 'Vendor \'Demario Ewan\' added to RFQ RFQ-20260317-138 - RFQ notification email sent to demario.ewan@moh.gov.jm'),
(1964, 'rfq_vendors', 28, 'DELETE', 'Technical & User Support Officer', '2026-03-20 16:50:56', 'Vendor \"Demario Ewan\" (rfq_vendor_id=74) removed from RFQ'),
(1965, 'procurement_requests', 140, 'CREATE', 'Technical & User Support Officer', '2026-03-24 15:27:47', 'Procurement request created'),
(1966, 'procurement_requests', 140, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-03-24 15:27:55', 'Draft → Submitted'),
(1967, 'procurement_requests', 140, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-03-24 15:27:55', 'Approval chain created: Director HRM&A'),
(1968, 'request_approvals', 110, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-03-24 16:33:26', 'Approved by Director HRM&A'),
(1969, 'procurement_requests', 140, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-03-24 16:33:26', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1970, 'procurement_requests', 140, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-03-24 16:33:26', 'Approval by Director HRM&A'),
(1971, 'rfq_vendors', 26, 'DELETE', 'Technical & User Support Officer', '2026-03-24 16:59:59', 'Vendor \"Demario Ewan\" (rfq_vendor_id=73) removed from RFQ'),
(1972, 'procurement_requests', 136, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-03-27 18:30:09', 'Submitted → Declined by Yanique A. Fraser'),
(1973, 'procurement_requests', 136, 'DECLINED', 'Yanique A. Fraser', '2026-03-27 18:30:09', 'Request declined: Previously approved — by Yanique A. Fraser'),
(1974, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-03-30 14:17:50', 'Quote uploaded for RFQ ID 28'),
(1975, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-03-30 14:17:53', 'Quote uploaded for RFQ ID 28'),
(1976, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-03-30 14:36:38', 'Quote 66 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(1977, 'procurement_requests', 138, 'QUOTE_APPROVED', 'Technical & User Support Officer', '2026-03-30 14:36:38', 'Quote from Accu Power Limited approved by Technical & User Support Officer. Finance notified to verify funds.'),
(1978, 'users', 42, 'PASSWORD_CHANGE', 'Yanique McKenzie', '2026-04-07 14:50:15', 'Password updated'),
(1979, 'rfq_vendors', 27, 'DELETE', 'Gabrielle Green', '2026-04-07 15:01:46', 'Vendor \"D&S IT Services\" (rfq_vendor_id=68) removed from RFQ'),
(1980, 'rfq_vendors', 27, 'DELETE', 'Gabrielle Green', '2026-04-07 15:01:49', 'Vendor \"Printware\" (rfq_vendor_id=67) removed from RFQ'),
(1981, 'rfq_vendors', 27, 'DELETE', 'Gabrielle Green', '2026-04-07 15:01:52', 'Vendor \"Advanced Integrated System\" (rfq_vendor_id=66) removed from RFQ'),
(1982, 'rfq_vendors', 27, 'DELETE', 'Gabrielle Green', '2026-04-07 15:01:55', 'Vendor \"MC System\" (rfq_vendor_id=65) removed from RFQ'),
(1983, 'procurement_requests', 141, 'CREATE', 'Technical & User Support Officer', '2026-04-10 13:47:58', 'Procurement request created'),
(1984, 'procurement_requests', 141, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-04-10 13:48:31', 'Draft → Submitted'),
(1985, 'procurement_requests', 141, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-04-10 13:48:31', 'Approval chain created: Director HRM&A'),
(1986, 'request_approvals', 111, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-04-10 14:14:16', 'Approved by Director HRM&A'),
(1987, 'procurement_requests', 141, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-04-10 14:14:16', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(1988, 'procurement_requests', 141, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-04-10 14:14:16', 'Approval by Director HRM&A'),
(1989, 'user_permissions', 37, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-04-17 16:47:11', 'Permission 102 updated (granted=1)'),
(1990, 'procurement_requests', 142, 'CREATE', 'Shermaine McKenzie', '2026-04-17 17:07:55', 'Procurement request created'),
(1991, 'procurement_requests', 142, 'STATUS_CHANGE', 'Shermaine McKenzie', '2026-04-17 17:08:11', 'Draft → Submitted'),
(1992, 'procurement_requests', 142, 'APPROVAL_CHAIN_CREAT', 'Shermaine McKenzie', '2026-04-17 17:08:11', 'Approval chain created: Deputy Government Chemist'),
(1993, 'procurement_requests', 142, 'STATUS_CHANGE', 'Daneika Anderson', '2026-04-17 17:45:53', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(1994, 'procurement_requests', 142, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-04-17 17:45:53', 'GC approval by Daneika Anderson'),
(1995, 'procurement_requests', 143, 'CREATE', 'Technical & User Support Officer', '2026-04-22 20:12:26', 'Procurement request created'),
(1996, 'procurement_requests', 143, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-04-22 20:12:33', 'Draft → Submitted'),
(1997, 'procurement_requests', 143, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-04-22 20:12:33', 'Approval chain created: Director HRM&A'),
(1998, 'request_approvals', 113, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-04-22 20:21:20', 'Approved by Director HRM&A'),
(1999, 'procurement_requests', 143, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-04-22 20:21:20', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2000, 'procurement_requests', 143, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-04-22 20:21:20', 'Approval by Director HRM&A'),
(2001, 'procurement_requests', 143, 'UPDATE', 'Technical & User Support Officer', '2026-04-22 20:28:00', 'Signed request uploaded: Scan2026-04-22_152717.pdf'),
(2002, 'procurement_requests', 143, 'SIGNED_REQUEST_UPLOA', 'Technical & User Support Officer', '2026-04-22 20:28:00', 'Signed request uploaded by Technical & User Support Officer: Scan2026-04-22_152717.pdf'),
(2003, 'procurement_requests', 144, 'CREATE', 'Technical & User Support Officer', '2026-04-27 17:00:15', 'Procurement request created'),
(2004, 'procurement_requests', 144, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-04-27 17:00:39', 'Draft → Submitted'),
(2005, 'procurement_requests', 144, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-04-27 17:00:39', 'Approval chain created: Director HRM&A'),
(2006, 'request_approvals', 114, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-04-27 17:11:34', 'Approved by Director HRM&A'),
(2007, 'procurement_requests', 144, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-04-27 17:11:34', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2008, 'procurement_requests', 144, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-04-27 17:11:34', 'Approval by Director HRM&A'),
(2009, 'procurement_requests', 144, 'UPDATE', 'Technical & User Support Officer', '2026-04-27 17:18:42', 'Signed request uploaded: Document_260427_121219.pdf'),
(2010, 'procurement_requests', 144, 'SIGNED_REQUEST_UPLOA', 'Technical & User Support Officer', '2026-04-27 17:18:42', 'Signed request uploaded by Technical & User Support Officer: Document_260427_121219.pdf'),
(2011, 'rfqs', 29, 'CREATE', 'Gabrielle Green', '2026-04-27 17:33:44', 'RFQ created for request ID 144. Date: 2026-04-08, Deadline: 2026-04-15T11:00'),
(2012, 'rfq_vendors', 75, 'CREATE', '44', '2026-04-27 17:34:41', 'Vendor \'Royale Computers & Accessories Ltd\' added to RFQ RFQ-20260427-144 - RFQ notification email sent to Shaquille.Murray@royalecomputers.com'),
(2013, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-04-27 17:35:19', 'Quote uploaded for RFQ ID 29'),
(2014, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-04-27 17:38:24', 'Quote 68 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(2015, 'procurement_requests', 144, 'QUOTE_APPROVED', 'Technical & User Support Officer', '2026-04-27 17:38:24', 'Quote from Royale Computers & Accessories Ltd approved by Technical & User Support Officer. Finance notified to verify funds.'),
(2016, 'procurement_requests', 144, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-04-27 18:42:27', 'Funds verified by Finance Officer'),
(2017, 'procurement_requests', 144, 'FUNDS_VERIFIED', 'Latoya Gayle', '2026-04-27 18:42:27', 'Finance Officer verified funds are available. Procurement Officer to fill commitment form.'),
(2018, 'procurement_requests', 145, 'CREATE', 'Shermaine McKenzie', '2026-04-30 18:41:31', 'Procurement request created'),
(2019, 'procurement_requests', 145, 'STATUS_CHANGE', 'Shermaine McKenzie', '2026-04-30 18:41:44', 'Draft → Submitted'),
(2020, 'procurement_requests', 145, 'APPROVAL_CHAIN_CREAT', 'Shermaine McKenzie', '2026-04-30 18:41:45', 'Approval chain created: Deputy Government Chemist'),
(2021, 'procurement_requests', 146, 'CREATE', 'Technical & User Support Officer', '2026-04-30 19:48:45', 'Procurement request created'),
(2022, 'procurement_requests', 146, 'STATUS_CHANGE', 'Technical & User Support Officer', '2026-04-30 19:49:04', 'Draft → Submitted'),
(2023, 'procurement_requests', 146, 'APPROVAL_CHAIN_CREAT', 'Technical & User Support Officer', '2026-04-30 19:49:04', 'Approval chain created: HOD'),
(2024, 'procurement_requests', 145, 'STATUS_CHANGE', 'Daneika Anderson', '2026-05-01 14:20:35', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(2025, 'procurement_requests', 145, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-05-01 14:20:35', 'GC approval by Daneika Anderson'),
(2026, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', '37', '2026-05-01 14:25:41', 'Back-dating of procurement request was attempted'),
(2027, 'procurement_requests', 147, 'CREATE', 'Shermaine McKenzie', '2026-05-01 14:28:30', 'Procurement request created'),
(2028, 'procurement_requests', 147, 'STATUS_CHANGE', 'Shermaine McKenzie', '2026-05-01 14:28:44', 'Draft → Submitted'),
(2029, 'procurement_requests', 147, 'APPROVAL_CHAIN_CREAT', 'Shermaine McKenzie', '2026-05-01 14:28:44', 'Approval chain created: Deputy Government Chemist'),
(2030, 'procurement_requests', 147, 'STATUS_CHANGE', 'Daneika Anderson', '2026-05-01 16:43:42', 'GC Approved (funds certified) — Status changed to RFQ_LETTER_AVAILABLE'),
(2031, 'procurement_requests', 147, 'RFQ_LETTER_AVAILABLE', 'Daneika Anderson', '2026-05-01 16:43:42', 'GC approval by Daneika Anderson'),
(2032, 'users', 42, 'ROLE_CHANGE', 'Technical & User Support Officer', '2026-05-01 17:48:06', 'Role updated to Procurement Officer'),
(2033, 'procurement_requests', 145, 'EDIT', 'Technical & User Support Officer', '2026-05-01 17:50:20', 'Procurement Request #145 edited.\n\nOLD ITEMS:\n- Hard Drive | Qty: 1 | SSD, Min. 480 GB\n- Memory Card | Qty: 1 | DDR4, 8GB\n- 27\" Monitor | Qty: 1 |  19 GHz, 19-20 refresh rate\n- Printer | Qty: 1 | Wireless Black & White All-in-One Laser Printer, Scanner, Copier\n\nNEW ITEMS:\n- Hard Drive | Qty: 1 | SSD, Min. 480 GB\n- Memory Card | Qty: 1 | DDR4, 8GB\n- 27\" Monitor | Qty: 1 | 90hz-120hz refresh rate\n- Printer | Qty: 1 | Wireless Black & White All-in-One Laser Printer, Scanner, Copier\n'),
(2034, 'procurement_requests', 145, 'UPDATE', 'Daneika Anderson', '2026-05-01 18:00:24', 'Signed request uploaded: PR021 .pdf'),
(2035, 'procurement_requests', 145, 'SIGNED_REQUEST_UPLOA', 'Daneika Anderson', '2026-05-01 18:00:24', 'Signed request uploaded by Daneika Anderson: PR021 .pdf'),
(2036, 'procurement_requests', 147, 'UPDATE', 'Daneika Anderson', '2026-05-01 18:04:45', 'Signed request uploaded: PR023.pdf'),
(2037, 'procurement_requests', 147, 'SIGNED_REQUEST_UPLOA', 'Daneika Anderson', '2026-05-01 18:04:45', 'Signed request uploaded by Daneika Anderson: PR023.pdf'),
(2038, 'procurement_requests', 146, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-05-01 22:36:38', 'Approved — Funds certified & Status changed to RFQ_LETTER_AVAILABLE by HOD'),
(2039, 'procurement_requests', 146, 'RFQ_LETTER_AVAILABLE', 'Yanique A. Fraser', '2026-05-01 22:36:38', 'Approval by Yanique A. Fraser - HOD'),
(2040, 'request_approvals', 109, 'APPROVE_STAGE', 'Yanique A. Fraser', '2026-05-01 22:37:33', 'Approved by HOD'),
(2041, 'procurement_requests', 139, 'STATUS_CHANGE', 'Yanique A. Fraser', '2026-05-01 22:37:33', 'Approved → AWARDED (funds certified) by HOD'),
(2042, 'procurement_requests', 139, 'AWARDED', 'Yanique A. Fraser', '2026-05-01 22:37:33', 'Approval by HOD'),
(2043, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', '40', '2026-05-04 14:12:28', 'Back-dating of procurement request was attempted'),
(2044, 'procurement_requests', 148, 'CREATE', 'Alfred Bryan', '2026-05-04 21:15:08', 'Procurement request created'),
(2045, 'procurement_requests', 148, 'EDIT', 'Alfred Bryan', '2026-05-04 21:30:09', 'Procurement Request #148 edited.\n\nOLD ITEMS:\n- Copy Paper | Qty: 50 | Letter Size \n- Copy Paper | Qty: 20 | Legal Size \n- 4 Quire Book | Qty: 6 | Hard Cover\n- Flag Its | Qty: 20 | Sign Here\n- Sticky Notes | Qty: 36 | 3*3\n- Stenopad | Qty: 15 | \n- Whiteboard | Qty: 1 | Length: 41 inches, width 41 inches\n- Whiteboard Markers | Qty: 4 | black, blue, red, green\n- Paper Clip  | Qty: 10 | Regular - 33mm\n\nNEW ITEMS:\n- Copy Paper | Qty: 50 | Letter Size \n- Copy Paper | Qty: 20 | Legal Size \n- 4 Quire Book | Qty: 6 | Hard Cover\n- Flag Its | Qty: 20 | Sign Here\n- Sticky Notes | Qty: 36 | 3*3\n- Stenopad | Qty: 15 | \n- Whiteboard | Qty: 1 | Length: 41 inches, width 41 inches\n- Whiteboard Markers | Qty: 4 | black, blue, red, green\n- Paper Clip  | Qty: 10 | Regular - 33mm\n- Paper Clip | Qty: 10 | Jumbo - 50mm\n- Scientific Calculator | Qty: 3 | \n- Desktop Calculator  | Qty: 3 | \n- Bull Dog Clip | Qty: 24 | 37mm\n- Bull Dog Clip | Qty: 24 | 51mm\n- Highlighter | Qty: 1 | \n- Mesh Document Tray | Qty: 1 | \n- Pen | Qty: 36 | Gel - blue - fine\n- Pen | Qty: 36 | BIC - Blue - Fine\n- Pen | Qty: 12 | BIC - Blue - Medium\n- Pen | Qty: 36 | BIC - Black- Fine\n'),
(2046, 'procurement_requests', 148, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-04 21:30:19', 'Draft → Submitted'),
(2047, 'procurement_requests', 148, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-04 21:30:19', 'Approval chain created: Director HRM&A'),
(2048, 'request_approvals', 118, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-04 21:33:42', 'Approved by Director HRM&A'),
(2049, 'procurement_requests', 148, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-04 21:33:42', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2050, 'procurement_requests', 148, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-04 21:33:42', 'Approval by Director HRM&A'),
(2051, 'rfqs', 30, 'CREATE', 'Yanique McKenzie', '2026-05-04 21:40:18', 'RFQ created for request ID 147. Date: 2026-05-01, Deadline: 2026-05-08T11:00'),
(2052, 'vendors', 10, 'CREATE', '42', '2026-05-04 21:44:20', 'Vendor \'BCB Sales and Services\' created'),
(2053, 'vendors', 11, 'CREATE', '42', '2026-05-04 21:47:29', 'Vendor \'Jam Labs\' created'),
(2054, 'rfqs', 31, 'CREATE', 'Yanique McKenzie', '2026-05-04 22:08:29', 'RFQ created for request ID 146. Date: 2026-05-04, Deadline: 2026-05-11T11:00'),
(2055, 'rfq_vendors', 76, 'CREATE', '42', '2026-05-04 22:09:21', 'Vendor \'D&S IT Services\' added to RFQ RFQ-20260504-146 - RFQ notification email sent to ssmith@dsitservicesja.com'),
(2056, 'rfqs', 32, 'CREATE', 'Yanique McKenzie', '2026-05-04 22:12:50', 'RFQ created for request ID 145. Date: 2026-05-04, Deadline: 2026-05-11T11:00'),
(2057, 'rfq_vendors', 77, 'CREATE', '42', '2026-05-04 22:13:35', 'Vendor \'Royale Computers & Accessories Ltd\' added to RFQ RFQ-20260504-145 - RFQ notification email sent to Shaquille.Murray@royalecomputers.com'),
(2058, 'rfqs', 33, 'CREATE', 'Gabrielle Green', '2026-05-04 22:17:16', 'RFQ created for request ID 143. Date: 2026-04-29, Deadline: 2026-05-26T11:00'),
(2059, 'rfqs', 33, 'UPDATE', 'Gabrielle Green', '2026-05-04 22:17:31', 'RFQ letter uploaded'),
(2060, 'rfq_vendors', 78, 'CREATE', '44', '2026-05-04 22:17:41', 'Vendor \'D&S IT Services\' added to RFQ RFQ-20260504-143 - RFQ notification email sent to ssmith@dsitservicesja.com'),
(2061, 'rfq_vendors', 79, 'CREATE', '44', '2026-05-04 22:17:53', 'Vendor \'Royale Computers & Accessories Ltd\' added to RFQ RFQ-20260504-143 - RFQ notification email sent to Shaquille.Murray@royalecomputers.com'),
(2062, 'vendors', 12, 'CREATE', '44', '2026-05-04 22:18:36', 'Vendor \'Tech Pro Business Solution\' created'),
(2063, 'rfq_vendors', 80, 'CREATE', '44', '2026-05-04 22:18:57', 'Vendor \'Tech Pro Business Solution\' added to RFQ RFQ-20260504-143 - No email address on file'),
(2064, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-04 22:21:56', 'Quote uploaded for RFQ ID 33'),
(2065, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-04 22:22:50', 'Quote uploaded for RFQ ID 33'),
(2066, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-04 22:23:36', 'Quote uploaded for RFQ ID 33'),
(2067, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-04 22:24:32', 'Quote uploaded for RFQ ID 33'),
(2068, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-04 22:24:36', 'Quote uploaded for RFQ ID 33'),
(2069, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 14:23:25', 'Quote uploaded for RFQ ID 31'),
(2070, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 14:23:26', 'Quote uploaded for RFQ ID 31'),
(2071, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 14:23:26', 'Quote uploaded for RFQ ID 31'),
(2072, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 14:23:27', 'Quote uploaded for RFQ ID 31'),
(2073, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 14:23:29', 'Quote uploaded for RFQ ID 31'),
(2074, 'rfqs', 34, 'CREATE', 'Gabrielle Green', '2026-05-05 18:42:09', 'RFQ created for request ID 142. Date: 2026-04-29, Deadline: 2026-05-06T11:00'),
(2075, 'rfqs', 34, 'UPDATE', 'Gabrielle Green', '2026-05-05 18:42:27', 'RFQ letter uploaded'),
(2076, 'vendors', 10, 'UPDATE', '44', '2026-05-05 18:43:00', 'Updated: Email: info@bcbscientifics.com → '),
(2077, 'rfq_vendors', 81, 'CREATE', '44', '2026-05-05 18:43:26', 'Vendor \'BCB Sales and Services\' added to RFQ RFQ-20260505-142 - No email address on file'),
(2078, 'rfq_vendors', 82, 'CREATE', '42', '2026-05-05 20:26:45', 'Vendor \'BCB Sales and Services\' added to RFQ RFQ-20260504-147 - No email address on file'),
(2079, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 20:28:49', 'Quote uploaded for RFQ ID 30'),
(2080, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 20:47:22', 'Quote uploaded for RFQ ID 34'),
(2081, 'rfqs', 35, 'CREATE', 'Yanique McKenzie', '2026-05-05 21:28:10', 'RFQ created for request ID 148. Date: 2026-05-05, Deadline: 2026-05-12T11:00'),
(2082, 'rfq_vendors', 83, 'CREATE', '42', '2026-05-05 21:28:31', 'Vendor \'Tech Pro Business Solution\' added to RFQ RFQ-20260505-148 - No email address on file'),
(2083, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 21:29:53', 'Quote uploaded for RFQ ID 35'),
(2084, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-05 21:29:55', 'Quote uploaded for RFQ ID 35'),
(2085, 'vendors', 11, 'UPDATE', '44', '2026-05-06 14:07:15', 'Updated: Email: araymon@jamlabssupplies.com → '),
(2086, 'rfq_vendors', 84, 'CREATE', '44', '2026-05-06 14:07:33', 'Vendor \'Jam Labs\' added to RFQ RFQ-20260505-142 - No email address on file'),
(2087, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-06 14:08:03', 'Quote uploaded for RFQ ID 34'),
(2088, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-05-06 19:28:18', 'Quote 81 reviewed: MEETS_REQUIREMENTS by Alfred Bryan'),
(2089, 'procurement_requests', 148, 'QUOTE_APPROVED', 'Alfred Bryan', '2026-05-06 19:28:18', 'Quote from Tech Pro Business Solution approved by Alfred Bryan. Finance notified to verify funds.'),
(2090, 'procurement_requests', 149, 'CREATE', 'Alfred Bryan', '2026-05-06 20:01:25', 'Procurement request created'),
(2091, 'procurement_requests', 149, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-06 20:12:05', 'Draft → Submitted'),
(2092, 'procurement_requests', 149, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-06 20:12:05', 'Approval chain created: Director HRM&A'),
(2093, 'request_approvals', 119, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-06 20:13:19', 'Approved by Director HRM&A'),
(2094, 'procurement_requests', 149, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-06 20:13:19', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2095, 'procurement_requests', 149, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-06 20:13:19', 'Approval by Director HRM&A'),
(2096, 'procurement_requests', 150, 'CREATE', 'Alfred Bryan', '2026-05-07 16:39:01', 'Procurement request created'),
(2097, 'rfqs', 36, 'CREATE', 'Yanique McKenzie', '2026-05-07 16:39:25', 'RFQ created for request ID 149. Date: 2026-05-07, Deadline: 2026-05-14T11:00'),
(2098, 'procurement_requests', 149, 'EDIT', 'Yanique McKenzie', '2026-05-07 16:47:14', 'Procurement Request #149 edited.\n\nOLD ITEMS:\n- ID CARD CASE WITH RETRACTABLE CLIP | Qty: 50 | HEAVY DUTY\n\nNEW ITEMS:\n- ID CARD CASE WITH RETRACTABLE CLIP | Qty: 50 | HEAVY DUTY\n'),
(2099, 'procurement_requests', 150, 'EDIT', 'Alfred Bryan', '2026-05-07 16:51:48', 'Procurement Request #150 edited.\n\nOLD ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to \n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n\nNEW ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to \n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n- Tee PVC | Qty: 1 | 1 inch\n- Length of Pipe PVC | Qty: 5 | 1 inch\n- Elbow PVC | Qty: 9 | 1 inch\n- Coupling PVC | Qty: 9 | 1 inch\n- Turn of Valve PVC | Qty: 4 | 1 inch\n- Length of Pipe PVC | Qty: 6 | 1/2\n- Coupling PVC | Qty: 1 | 1/2 inch with thread (female)\n- Reducer PVC | Qty: 3 | 1 inch to 1/2 inch \n- Pipe cock | Qty: 5 | Metal\n- Thread Tape | Qty: 1 | 6\n- Elbow PVC | Qty: 6 | 1/2 inch\n- Tee PVC | Qty: 1 | 1/2inch\n'),
(2100, 'procurement_requests', 150, 'EDIT', 'Alfred Bryan', '2026-05-07 17:01:47', 'Procurement Request #150 edited.\n\nOLD ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to \n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n- Tee PVC | Qty: 1 | 1 inch\n- Length of Pipe PVC | Qty: 5 | 1 inch\n- Elbow PVC | Qty: 9 | 1 inch\n- Coupling PVC | Qty: 9 | 1 inch\n- Turn of Valve PVC | Qty: 4 | 1 inch\n- Length of Pipe PVC | Qty: 6 | 1/2\n- Coupling PVC | Qty: 1 | 1/2 inch with thread (female)\n- Reducer PVC | Qty: 3 | 1 inch to 1/2 inch \n- Pipe cock | Qty: 5 | Metal\n- Thread Tape | Qty: 1 | 6\n- Elbow PVC | Qty: 6 | 1/2 inch\n- Tee PVC | Qty: 1 | 1/2inch\n\nNEW ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to \n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n- Tee PVC | Qty: 1 | 1 inch\n- Length of Pipe PVC | Qty: 5 | 1 inch\n- Elbow PVC | Qty: 9 | 1 inch\n- Coupling PVC | Qty: 9 | 1 inch\n- Turn of Valve PVC | Qty: 4 | 1 inch\n- Length of Pipe PVC | Qty: 6 | 1/2\n- Coupling PVC | Qty: 1 | 1/2 inch with thread (female)\n- Reducer PVC | Qty: 3 | 1 inch to 1/2 inch \n- Pipe cock | Qty: 5 | Metal\n- Thread Tape | Qty: 1 | 6\n- Elbow PVC | Qty: 6 | 1/2 inch\n- Tee PVC | Qty: 1 | 1/2inch\n- Flood Light | Qty: 15 | 300 Watts, Solar\n'),
(2101, 'procurement_requests', 151, 'CREATE', 'Alfred Bryan', '2026-05-07 17:19:06', 'Reimbursement request created'),
(2102, 'pre_authorizations', 2101, 'CREATE', 'Alfred Bryan', '2026-05-07 17:19:06', 'Pre-authorization created for reimbursement'),
(2103, 'procurement_requests', 150, 'EDIT', 'Alfred Bryan', '2026-05-08 13:17:13', 'Procurement Request #150 edited.\n\nOLD ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to \n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n- Tee PVC | Qty: 1 | 1 inch\n- Length of Pipe PVC | Qty: 5 | 1 inch\n- Elbow PVC | Qty: 9 | 1 inch\n- Coupling PVC | Qty: 9 | 1 inch\n- Turn of Valve PVC | Qty: 4 | 1 inch\n- Length of Pipe PVC | Qty: 6 | 1/2\n- Coupling PVC | Qty: 1 | 1/2 inch with thread (female)\n- Reducer PVC | Qty: 3 | 1 inch to 1/2 inch \n- Pipe cock | Qty: 5 | Metal\n- Thread Tape | Qty: 1 | 6\n- Elbow PVC | Qty: 6 | 1/2 inch\n- Tee PVC | Qty: 1 | 1/2inch\n- Flood Light | Qty: 15 | 300 Watts, Solar\n\nNEW ITEMS:\n- Box Cutter | Qty: 1 | \n- Cement | Qty: 12 | \n- Thinset  | Qty: 3 | \n- Hose (Garden/Water) | Qty: 3 | 100 feet\n- Pole Saw | Qty: 1 | 20 feet or closest to, electric if possible\n- Paint | Qty: 2 | White/Gallon\n- Corking Sylicone | Qty: 6 | White\n- Drywall Screw | Qty: 500 | 1 1/2inch\n- Tee PVC | Qty: 1 | 1 inch\n- Length of Pipe PVC | Qty: 5 | 1 inch\n- Elbow PVC | Qty: 9 | 1 inch\n- Coupling PVC | Qty: 9 | 1 inch\n- Turn of Valve PVC | Qty: 4 | 1 inch\n- Length of Pipe PVC | Qty: 6 | 1/2\n- Coupling PVC | Qty: 1 | 1/2 inch with thread (female)\n- Reducer PVC | Qty: 3 | 1 inch to 1/2 inch \n- Pipe cock | Qty: 5 | Metal\n- Thread Tape | Qty: 1 | 6\n- Elbow PVC | Qty: 6 | 1/2 inch\n- Tee PVC | Qty: 1 | 1/2inch\n- Flood Light | Qty: 15 | 300 Watts, Solar\n'),
(2104, 'procurement_requests', 150, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-08 13:17:16', 'Draft → Submitted'),
(2105, 'procurement_requests', 150, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-08 13:17:16', 'Approval chain created: Director HRM&A'),
(2106, 'procurement_requests', 150, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-08 20:45:25', 'Submitted → Declined by Nellesha Samuels'),
(2107, 'procurement_requests', 150, 'DECLINED', 'Nellesha Samuels', '2026-05-08 20:45:25', 'Request declined: Please speak with me regarding this request. — by Nellesha Samuels'),
(2108, 'rfq_quotes', NULL, 'REVIEW', NULL, '2026-05-11 15:11:49', 'Quote 72 reviewed: MEETS_REQUIREMENTS by Technical & User Support Officer'),
(2109, 'procurement_requests', 143, 'QUOTE_APPROVED', 'Technical & User Support Officer', '2026-05-11 15:11:49', 'Quote from Tech Pro Business Solution approved by Technical & User Support Officer. Finance notified to verify funds.'),
(2110, 'procurement_requests', 152, 'CREATE', 'Alfred Bryan', '2026-05-11 15:27:29', 'Petty cash request created'),
(2111, 'rfq_vendors', 85, 'CREATE', '42', '2026-05-11 15:49:36', 'Vendor \'D&S IT Services\' added to RFQ RFQ-20260504-145 - RFQ notification email sent to ssmith@dsitservicesja.com'),
(2112, 'rfq_vendors', 86, 'CREATE', '42', '2026-05-11 15:50:19', 'Vendor \'Tech Pro Business Solution\' added to RFQ RFQ-20260504-145 - No email address on file'),
(2113, 'procurement_requests', 153, 'CREATE', 'Alfred Bryan', '2026-05-11 20:07:00', 'Procurement request created'),
(2114, 'procurement_requests', 153, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-11 20:07:09', 'Draft → Submitted'),
(2115, 'procurement_requests', 153, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-11 20:07:09', 'Approval chain created: Director HRM&A'),
(2116, 'procurement_requests', 154, 'CREATE', 'Alfred Bryan', '2026-05-11 21:08:50', 'Procurement request created'),
(2117, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-12 14:27:48', 'Quote uploaded for RFQ ID 32'),
(2118, 'rfq_quotes', NULL, 'UPLOAD', NULL, '2026-05-12 14:29:23', 'Quote uploaded for RFQ ID 32'),
(2119, 'rfq_vendors', 32, 'DELETE', 'Gabrielle Green', '2026-05-12 14:30:30', 'Vendor \"Royale Computers & Accessories Ltd\" (rfq_vendor_id=77) removed from RFQ'),
(2120, 'procurement_requests', 155, 'CREATE', 'Alfred Bryan', '2026-05-12 19:00:26', 'Procurement request created'),
(2121, 'procurement_requests', 155, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-12 19:00:37', 'Draft → Submitted'),
(2122, 'procurement_requests', 155, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-12 19:00:37', 'Approval chain created: Director HRM&A'),
(2123, 'procurement_requests', 156, 'CREATE', 'Alfred Bryan', '2026-05-12 19:12:11', 'Procurement request created'),
(2124, 'procurement_requests', 156, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-12 19:12:18', 'Draft → Submitted'),
(2125, 'procurement_requests', 156, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-12 19:12:18', 'Approval chain created: Director HRM&A'),
(2126, 'request_approvals', 121, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-12 19:28:40', 'Approved by Director HRM&A'),
(2127, 'procurement_requests', 153, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-12 19:28:40', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2128, 'procurement_requests', 153, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-12 19:28:40', 'Approval by Director HRM&A'),
(2129, 'request_approvals', 122, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-12 19:30:32', 'Approved by Director HRM&A'),
(2130, 'procurement_requests', 155, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-12 19:30:32', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2131, 'procurement_requests', 155, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-12 19:30:32', 'Approval by Director HRM&A'),
(2132, 'procurement_requests', 156, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-12 19:32:18', 'Submitted → Declined by Nellesha Samuels'),
(2133, 'procurement_requests', 156, 'DECLINED', 'Nellesha Samuels', '2026-05-12 19:32:18', 'Request declined: Lets speak. — by Nellesha Samuels'),
(2134, 'procurement_requests', 154, 'EDIT', 'Alfred Bryan', '2026-05-12 19:48:49', 'Procurement Request #154 edited.\n\nOLD ITEMS:\n- Peppered steak | Qty: 4 | Large \n- Chicken lunch | Qty: 4 | Large \n- Fish meal  | Qty: 1 | Large \n- Soda | Qty: 1 | \n- Orange Juice | Qty: 1 | \n- Natural Juice | Qty: 7 | \n\nNEW ITEMS:\n- Peppered steak | Qty: 4 | Large \n- Chicken lunch | Qty: 4 | Large \n- Fish meal  | Qty: 2 | Large \n- Soda | Qty: 1 | \n- Orange Juice | Qty: 1 | \n- Natural Juice | Qty: 7 | \n'),
(2135, 'procurement_requests', 154, 'EDIT', 'Alfred Bryan', '2026-05-12 19:49:44', 'Procurement Request #154 edited.\n\nOLD ITEMS:\n- Peppered steak | Qty: 4 | Large \n- Chicken lunch | Qty: 4 | Large \n- Fish meal  | Qty: 2 | Large \n- Soda | Qty: 1 | \n- Orange Juice | Qty: 1 | \n- Natural Juice | Qty: 7 | \n\nNEW ITEMS:\n- Peppered steak | Qty: 4 | Large \n- Chicken lunch | Qty: 4 | Large \n- Fish meal  | Qty: 2 | Large \n- Soda | Qty: 1 | \n- Orange Juice | Qty: 1 | \n- Natural Juice | Qty: 8 | \n'),
(2136, 'procurement_requests', 154, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-12 19:49:47', 'Draft → Submitted'),
(2137, 'procurement_requests', 154, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-12 19:49:47', 'Approval chain created: Director HRM&A'),
(2138, 'rfqs', 37, 'CREATE', 'Yanique McKenzie', '2026-05-12 20:48:45', 'RFQ created for request ID 155. Date: 2026-05-12, Deadline: 2026-05-19T11:00'),
(2139, 'procurement_requests', 146, 'UPDATE', 'Technical & User Support Officer', '2026-05-12 21:06:44', 'Signed request uploaded: PR22.pdf'),
(2140, 'procurement_requests', 146, 'SIGNED_REQUEST_UPLOA', 'Technical & User Support Officer', '2026-05-12 21:06:44', 'Signed request uploaded by Technical & User Support Officer: PR22.pdf'),
(2141, 'procurement_requests', 157, 'CREATE', 'Alfred Bryan', '2026-05-13 14:19:25', 'Petty cash request created'),
(2142, 'procurement_requests', 156, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 14:27:43', 'Declined → Draft (Resubmitted by Alfred Bryan)'),
(2143, 'procurement_requests', 156, 'RESUBMITTED', 'Alfred Bryan', '2026-05-13 14:27:43', 'Request resubmitted after decline by Alfred Bryan'),
(2144, 'procurement_requests', 156, 'EDIT', 'Alfred Bryan', '2026-05-13 14:27:57', 'Procurement Request #156 edited.\n\nOLD ITEMS:\n- CHAIR (OFFICE) | Qty: 2 | \n- CHAIR (EXECUTIVE) | Qty: 3 | \n- DESK (OFFICE) | Qty: 2 | \n- DESK (EXECUTIVE) | Qty: 3 | \n- CHAIRS (BOARD ROOM/CONFERENCE ROOM) | Qty: 12 | \n- DESK (BOARD ROOM/CONFERENCE ROOM) | Qty: 1 | \n\nNEW ITEMS:\n- CHAIR (OFFICE) | Qty: 2 | \n- CHAIR (EXECUTIVE) | Qty: 3 | \n- DESK (OFFICE) | Qty: 2 | \n- DESK (EXECUTIVE) | Qty: 3 | \n- CHAIRS (BOARD ROOM/CONFERENCE ROOM) | Qty: 12 | \n- DESK (BOARD ROOM/CONFERENCE ROOM) | Qty: 1 | \n'),
(2145, 'procurement_requests', 156, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 14:28:02', 'Draft → Submitted'),
(2146, 'procurement_requests', 156, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-13 14:28:02', 'Approval chain created: Director HRM&A'),
(2147, 'procurement_requests', 151, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 15:15:01', 'Reimbursement Request: Draft → Submitted'),
(2148, 'procurement_requests', 151, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-13 15:15:01', 'Reimbursement approval chain created: Finance Officer'),
(2149, 'procurement_requests', 152, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 15:16:00', 'Petty Cash Request: Draft → Submitted'),
(2150, 'procurement_requests', 152, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-13 15:16:00', 'Petty cash approval chain created: Finance Officer'),
(2151, 'procurement_requests', 157, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 15:16:32', 'Petty Cash Request: Draft → Submitted'),
(2152, 'procurement_requests', 157, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-13 15:16:32', 'Petty cash approval chain created: Finance Officer'),
(2153, 'request_approvals', 124, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-13 15:19:50', 'Approved by Director HRM&A'),
(2154, 'procurement_requests', 154, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-13 15:19:50', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2155, 'procurement_requests', 154, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-13 15:19:50', 'Approval by Director HRM&A'),
(2156, 'request_approvals', 125, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-13 15:20:09', 'Approved by Director HRM&A'),
(2157, 'procurement_requests', 156, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-13 15:20:09', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2158, 'procurement_requests', 156, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-13 15:20:09', 'Approval by Director HRM&A'),
(2159, 'POLICY', NULL, 'BACKDATED_REQUEST_AT', '40', '2026-05-13 16:30:44', 'Back-dating of procurement request was attempted'),
(2160, 'procurement_requests', 158, 'CREATE', 'Alfred Bryan', '2026-05-13 16:39:26', 'Procurement request created'),
(2161, 'procurement_requests', 158, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-13 16:39:39', 'Draft → Submitted'),
(2162, 'procurement_requests', 158, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-13 16:39:39', 'Approval chain created: Director HRM&A'),
(2163, 'request_approvals', 92, 'APPROVE_STAGE', 'Latoya Gayle', '2026-05-13 17:22:12', 'Approved by Finance Officer'),
(2164, 'procurement_requests', 128, 'STATUS_CHANGE', 'Latoya Gayle', '2026-05-13 17:22:12', 'Approved → AWARDED (funds certified) by Finance Officer'),
(2165, 'procurement_requests', 128, 'AWARDED', 'Latoya Gayle', '2026-05-13 17:22:12', 'Approval by Finance Officer'),
(2166, 'procurement_requests', 152, 'STATUS_CHANGE', 'Latoya Gayle', '2026-05-13 17:43:36', 'Petty Cash Request: SUBMITTED → FUNDS_VERIFIED by Finance Officer'),
(2167, 'procurement_requests', 157, 'STATUS_CHANGE', 'Latoya Gayle', '2026-05-13 17:44:24', 'Petty Cash Request: SUBMITTED → FUNDS_VERIFIED by Finance Officer'),
(2168, 'procurement_requests', 151, 'STATUS_CHANGE', 'Latoya Gayle', '2026-05-13 17:44:43', 'Reimbursement Request: SUBMITTED → FUNDS_VERIFIED by Finance Officer'),
(2169, 'request_approvals', 129, 'APPROVE_STAGE', 'Nellesha Samuels', '2026-05-13 21:54:50', 'Approved by Director HRM&A'),
(2170, 'procurement_requests', 158, 'STATUS_CHANGE', 'Nellesha Samuels', '2026-05-13 21:54:50', 'Approved → RFQ_LETTER_AVAILABLE (funds certified) by Director HRM&A'),
(2171, 'procurement_requests', 158, 'RFQ_LETTER_AVAILABLE', 'Nellesha Samuels', '2026-05-13 21:54:50', 'Approval by Director HRM&A'),
(2172, 'procurement_requests', 159, 'CREATE', 'Alfred Bryan', '2026-05-14 18:19:15', 'Procurement request created'),
(2173, 'procurement_requests', 159, 'STATUS_CHANGE', 'Alfred Bryan', '2026-05-14 18:20:01', 'Draft → Submitted'),
(2174, 'procurement_requests', 159, 'APPROVAL_CHAIN_CREAT', 'Alfred Bryan', '2026-05-14 18:20:01', 'Approval chain created: Director HRM&A'),
(2175, 'MIGRATION', NULL, 'SCHEMA_FIX', 'system', '2026-05-14 21:37:14', '2026_05_14_ensure_notes_columns applied');

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE IF NOT EXISTS `branches` (
  `branch_id` int(11) NOT NULL,
  `branch_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `branches`
--

INSERT IGNORE INTO `branches` (`branch_id`, `branch_name`, `is_active`) VALUES
(1, 'Executive Branch', 1),
(5, 'HRM&A', 1),
(6, 'Analytical & Advisory', 1);

-- --------------------------------------------------------

--
-- Table structure for table `commitments`
--

CREATE TABLE IF NOT EXISTS `commitments` (
  `commitment_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `commitment_number` varchar(20) NOT NULL,
  `commitment_date` date NOT NULL,
  `commitment_total` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `approved_at` datetime DEFAULT NULL,
  `status` enum('open','closed') DEFAULT 'open',
  `parent_commitment_id` int(11) DEFAULT NULL,
  `commitment_type` enum('ORIGINAL','SUPPLEMENTARY') DEFAULT 'ORIGINAL',
  `rfq_id` int(11) DEFAULT NULL,
  `selected_quote_id` int(11) DEFAULT NULL,
  `quote_approved_at` datetime DEFAULT NULL,
  `gfms_generated` tinyint(1) DEFAULT 0,
  `gfms_commitment_number` varchar(50) DEFAULT NULL COMMENT 'Unique commitment number from GFMS system',
  `document_path` varchar(255) DEFAULT NULL COMMENT 'Path to uploaded commitment document from GFMS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `commitments`
--

INSERT IGNORE INTO `commitments` (`commitment_id`, `request_id`, `commitment_number`, `commitment_date`, `commitment_total`, `created_at`, `approved_at`, `status`, `parent_commitment_id`, `commitment_type`, `rfq_id`, `selected_quote_id`, `quote_approved_at`, `gfms_generated`, `gfms_commitment_number`, `document_path`) VALUES
(87, 137, 'CM001', '2026-03-19', 355949.10, '2026-03-19 17:21:22', '2026-03-19 12:21:22', 'closed', NULL, 'ORIGINAL', NULL, NULL, NULL, 0, 'CO7111504', '/uploads/commitments/COMMITMENT_1773940882_69bc3092de07d.pdf');

--
-- Triggers `commitments`
--
DELIMITER $$
CREATE TRIGGER `trg_block_commitment_before_acceptance` BEFORE INSERT ON `commitments` FOR EACH ROW BEGIN
    DECLARE acc_status VARCHAR(20);

    IF NEW.rfq_id IS NOT NULL THEN

        SELECT acceptance_status
        INTO acc_status
        FROM rfqs
        WHERE rfq_id = NEW.rfq_id
        LIMIT 1;

        IF acc_status IS NULL OR acc_status <> 'ACCEPTED' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vendor acceptance required before commitment';
        END IF;

    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_one_original_commitment` BEFORE INSERT ON `commitments` FOR EACH ROW BEGIN
    IF NEW.commitment_type = 'ORIGINAL' THEN
        IF EXISTS (
            SELECT 1
            FROM commitments
            WHERE request_id = NEW.request_id
              AND commitment_type = 'ORIGINAL'
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only one ORIGINAL commitment is allowed per request';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_one_original_commitment_update` BEFORE UPDATE ON `commitments` FOR EACH ROW BEGIN
    IF NEW.commitment_type = 'ORIGINAL'
       AND OLD.commitment_type <> 'ORIGINAL' THEN

        IF EXISTS (
            SELECT 1
            FROM commitments
            WHERE request_id = NEW.request_id
              AND commitment_type = 'ORIGINAL'
              AND commitment_id <> OLD.commitment_id
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only one ORIGINAL commitment is allowed per request';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_require_quote_review_for_commitment` BEFORE INSERT ON `commitments` FOR EACH ROW BEGIN
    DECLARE review_status VARCHAR(50);
    DECLARE quote_id INT;

    -- If this commitment is linked to an RFQ
    IF NEW.rfq_id IS NOT NULL AND NEW.selected_quote_id IS NOT NULL THEN
        -- Check if the quote has been marked as approved (meets requirements)
        SELECT review_status
        INTO review_status
        FROM rfq_quotes
        WHERE quote_id = NEW.selected_quote_id
        LIMIT 1;

        -- Allow commitment creation if quote is marked as meeting requirements or no review status set
        -- This gives flexibility for different approval workflows
        IF review_status = 'DOES_NOT_MEET' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create commitment from quote that does not meet requirements';
        END IF;
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `compliance_approvals`
--

CREATE TABLE IF NOT EXISTS `compliance_approvals` (
  `id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `entity_type` varchar(50) NOT NULL DEFAULT 'procurement_request',
  `approval_body` varchar(100) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Compliance approval tracking for procurement requests';

-- --------------------------------------------------------

--
-- Table structure for table `external_approvals`
--

CREATE TABLE IF NOT EXISTS `external_approvals` (
  `approval_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `approval_type` enum('PPC','CABINET') DEFAULT NULL,
  `approval_file` varchar(255) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE IF NOT EXISTS `invoices` (
  `invoice_id` int(11) NOT NULL,
  `po_id` int(11) NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `invoice_date` date NOT NULL,
  `invoice_amount` decimal(12,2) NOT NULL,
  `status` enum('Unpaid','Partially Paid','Paid') DEFAULT 'Unpaid',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `po_approved_at` datetime DEFAULT NULL,
  `gfms_generated` tinyint(1) DEFAULT 0,
  `invoice_source` enum('VENDOR_UPLOADED','SYSTEM_GENERATED','MANUAL') DEFAULT 'VENDOR_UPLOADED'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `reset_token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_reference` varchar(50) NOT NULL,
  `payment_amount` decimal(12,2) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT IGNORE INTO `permissions` (`id`, `name`, `description`) VALUES
(1, 'create_request', 'Create procurement request'),
(2, 'submit_request', 'Submit procurement request'),
(3, 'approve_request', 'Approve procurement request'),
(4, 'create_commitment', 'Create commitment'),
(5, 'approve_commitment', 'Approve commitment'),
(6, 'create_po', 'Create purchase order'),
(7, 'approve_po', 'Approve purchase order'),
(8, 'record_invoice', 'Add invoice'),
(9, 'record_payment', 'Record payment'),
(10, 'manage_users', 'Manage system users'),
(11, 'view_commitments', 'View commitment records'),
(12, 'view_requests', 'View procurement requests'),
(13, 'view_finance_dashboard', 'Access finance dashboard'),
(14, 'view_management_dashboard', 'Access management dashboard'),
(15, 'view_monthly_dashboard', 'Access monthly financial dashboard'),
(16, 'view_procurement_dashboard', 'Access procurement dashboard'),
(17, 'view_audit_dashboard', 'Access viewer/audit dashboard'),
(18, 'create_invoice', 'Add new invoice'),
(19, 'view_invoices', 'View invoice list and details'),
(20, 'create_payment', 'Record invoice payment'),
(21, 'view_payments', 'View payment records'),
(22, 'create_purchase_order', 'Create new purchase order'),
(23, 'request_po_adjustment', 'Request purchase order adjustment/variation'),
(24, 'view_purchase_orders', 'View purchase order details'),
(25, 'approve_po_adjustment', 'Approve purchase order adjustment'),
(26, 'view_audit_logs', 'View audit logs'),
(27, 'approve_purchase_order', 'Approve purchase order'),
(28, 'approve_po_excess', 'Approve purchase order excess override'),
(29, 'edit_purchase_order', 'Edit purchase order before approval'),
(31, 'view_po_adjustments', 'Allow viewing PO adjustment report'),
(32, 'print_purchase_order', 'Allow user to print purchase order PDF'),
(33, 'print_request', 'Allow user to print procurement request'),
(45, 'edit_requests', 'Test_Create RTF'),
(46, 'view_evaluation', 'View Evaluation Dashboard'),
(47, 'view_approval_analytics', 'Access approval analytics dashboard'),
(48, 'view_compliance', 'Access compliance dashboard'),
(49, 'management_dashboard', 'Access management overview dashboard'),
(50, 'monthly_metrics', 'Access monthly financial metrics dashboard'),
(51, 'view_financial_reports', 'View financial reports (branch summary/outstanding)'),
(52, 'print_invoice', 'Print invoice PDF'),
(54, 'view_own_requests', 'View Only Submitted Request'),
(55, 'manage_system_settings', 'Enable/Disable Emails Notifications'),
(56, 'approve_as_director_hrma', 'View HRM&A Director Dashboard'),
(57, 'decline_request', 'Decline/reject requests'),
(58, 'approve_reimbursement_request', 'Approve reimbursement requests'),
(59, 'approve_petty_cash_request', 'Approve petty cash requests'),
(60, 'create_reimbursement_request', 'Create reimbursement requests'),
(61, 'create_petty_cash_request', 'Create petty cash requests'),
(62, 'author_override', 'Override approval chain decisions'),
(102, 'view_reimbursement_requests', 'View all reimbursement requests'),
(103, 'view_petty_cash_requests', 'View all petty cash requests'),
(104, 'submit_own_request', 'Submit own requests'),
(105, 'resubmit_request', 'Resubmit declined requests'),
(106, 'authorize_reimbursement', 'Authorize reimbursement (Branch Head)'),
(107, 'authorize_petty_cash', 'Authorize petty cash (Branch Head)'),
(108, 'upload_commitment', 'Upload commitment documents'),
(109, 'upload_purchase_order', 'Upload PO documents'),
(110, 'manage_attachments', 'Add/remove document attachments'),
(111, 'verify_reimbursement_goods', 'Verify goods/services for reimbursement'),
(112, 'verify_petty_cash_reconciliation', 'Verify petty cash 24-hour reconciliation'),
(113, 'reconcile_petty_cash', 'Reconcile petty cash after 24h'),
(114, 'view_rfq_evaluations', 'View RFQ evaluations'),
(115, 'vote_rfq', 'Vote on RFQ evaluations'),
(116, 'manage_rfq_committee', 'Add/remove RFQ committee members'),
(117, 'award_rfq', 'Award RFQ to vendor'),
(118, 'manage_vendors', 'Add, edit, delete vendors'),
(119, 'view_vendor_history', 'View vendor performance history'),
(120, 'export_requests', 'Export request data to CSV/Excel'),
(121, 'view_director_dashboard', 'Access Director for Procurement dashboard'),
(169, 'verify_funds', 'Verify fund availability for procurement requests'),
(170, 'award_vendor', 'Award an RFQ to a selected vendor quote'),
(171, 'confirm_vendor_award', 'Accept or decline a vendor award decision'),
(172, 'upload_rfq_quote', 'Upload vendor quotation documents to an RFQ'),
(173, 'start_rfq_evaluation', 'Start the evaluation stage for an RFQ'),
(174, 'upload_rfq_report', 'Upload evaluation report for an RFQ'),
(175, 'create_rfq', 'Create a new RFQ from a procurement request'),
(176, 'add_rfq_vendor', 'Add vendors to an RFQ invitation list'),
(177, 'view_vendors', 'View vendor list and details'),
(178, 'approve_as_dgc', 'Approve requests as Deputy Government Chemist'),
(179, 'disburse_petty_cash', 'Disburse petty cash funds after authorization'),
(180, 'process_reimbursement', 'Process reimbursement payment after approval');

-- --------------------------------------------------------

--
-- Table structure for table `petty_cash_disbursements`
--

CREATE TABLE IF NOT EXISTS `petty_cash_disbursements` (
  `disburse_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `amount_authorized` decimal(15,2) NOT NULL,
  `disbursed_by` int(11) NOT NULL,
  `disbursement_date` datetime DEFAULT current_timestamp(),
  `disbursement_deadline` datetime NOT NULL,
  `status` enum('AUTHORIZED','DISBURSED','RECONCILED','VERIFIED','COMPLETED') DEFAULT 'AUTHORIZED',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Petty cash disbursement tracking with 24-hour accountability';

--
-- Dumping data for table `petty_cash_disbursements`
--

INSERT IGNORE INTO `petty_cash_disbursements` (`disburse_id`, `request_id`, `amount_authorized`, `disbursed_by`, `disbursement_date`, `disbursement_deadline`, `status`, `created_at`, `updated_at`) VALUES
(1, 152, 5000.00, 34, '2026-05-13 12:43:36', '2026-05-14 12:43:36', 'AUTHORIZED', '2026-05-13 12:43:36', '2026-05-13 12:43:36'),
(2, 157, 5000.00, 34, '2026-05-13 12:44:24', '2026-05-14 12:44:24', 'AUTHORIZED', '2026-05-13 12:44:24', '2026-05-13 12:44:24');

-- --------------------------------------------------------

--
-- Table structure for table `petty_cash_reconciliations`
--

CREATE TABLE IF NOT EXISTS `petty_cash_reconciliations` (
  `reconcile_id` int(11) NOT NULL,
  `disburse_id` int(11) NOT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `purchase_amount` decimal(15,2) NOT NULL,
  `change_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `submitted_by` int(11) NOT NULL,
  `submission_date` datetime DEFAULT current_timestamp(),
  `submission_deadline_met` tinyint(1) DEFAULT 0,
  `hours_from_disbursement` decimal(4,2) DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verification_date` datetime DEFAULT NULL,
  `reconciliation_notes` text DEFAULT NULL,
  `status` enum('PENDING_VERIFICATION','VERIFIED','DISCREPANCY','APPROVED') DEFAULT 'PENDING_VERIFICATION',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Petty cash reconciliation - tracks purchases, change, and verification';

-- --------------------------------------------------------

--
-- Table structure for table `po_adjustment_log`
--

CREATE TABLE IF NOT EXISTS `po_adjustment_log` (
  `id` int(11) NOT NULL,
  `adjustment_po_id` int(11) NOT NULL,
  `original_po_id` int(11) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `performed_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `po_items`
--

CREATE TABLE IF NOT EXISTS `po_items` (
  `po_item_id` int(11) NOT NULL,
  `po_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  `qty` decimal(10,2) NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `po_variations`
--

CREATE TABLE IF NOT EXISTS `po_variations` (
  `variation_id` int(11) NOT NULL,
  `po_id` int(11) NOT NULL,
  `variation_amount` decimal(12,2) NOT NULL,
  `reason` text NOT NULL,
  `requested_by` int(11) NOT NULL,
  `requested_at` datetime DEFAULT current_timestamp(),
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `commitment_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `po_warnings`
--

CREATE TABLE IF NOT EXISTS `po_warnings` (
  `warning_id` int(11) NOT NULL,
  `po_id` int(11) NOT NULL,
  `warning_type` varchar(50) NOT NULL,
  `message` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `po_warnings`
--

INSERT IGNORE INTO `po_warnings` (`warning_id`, `po_id`, `warning_type`, `message`, `created_at`) VALUES
(8, 50, 'PO_LIMIT_ATTEMPT', 'Invoice attempt exceeded approved PO total (including variations)', '2026-02-06 19:03:52');

-- --------------------------------------------------------

--
-- Table structure for table `pre_authorizations`
--

CREATE TABLE IF NOT EXISTS `pre_authorizations` (
  `auth_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `authorized_by` int(11) NOT NULL,
  `authorization_date` datetime DEFAULT current_timestamp(),
  `authorization_amount` decimal(15,2) NOT NULL,
  `authorization_notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Prior authorization for reimbursement requests (Branch Head approval)';

--
-- Dumping data for table `pre_authorizations`
--

INSERT IGNORE INTO `pre_authorizations` (`auth_id`, `request_id`, `authorized_by`, `authorization_date`, `authorization_amount`, `authorization_notes`, `created_at`) VALUES
(4, 128, 32, '2026-03-03 00:00:00', 2000.00, 'Pre-authorization for reimbursement request', '2026-03-04 09:46:43'),
(5, 139, 39, '2026-03-09 00:00:00', 900.00, 'Pre-authorization for reimbursement request', '2026-03-17 15:03:02'),
(6, 151, 40, '2026-05-05 00:00:00', 500.00, 'Pre-authorization for reimbursement request', '2026-05-07 12:19:06');

-- --------------------------------------------------------

--
-- Table structure for table `procurement_requests`
--

CREATE TABLE IF NOT EXISTS `procurement_requests` (
  `request_id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `request_number` varchar(20) NOT NULL,
  `request_date` date NOT NULL,
  `description` text NOT NULL,
  `request_type` enum('REGULAR','REIMBURSEMENT','PETTY_CASH') NOT NULL DEFAULT 'REGULAR' COMMENT 'Type of request: REGULAR procurement, REIMBURSEMENT, or PETTY_CASH',
  `status` varchar(30) NOT NULL DEFAULT 'DRAFT',
  `rfq_date` date DEFAULT NULL,
  `quotes_received` int(11) DEFAULT 0,
  `awardee` varchar(150) DEFAULT NULL,
  `award_date` date DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `decline_reason` text DEFAULT NULL,
  `signed_request_document_path` varchar(255) DEFAULT NULL COMMENT 'Path to uploaded signed request by branch head',
  `signed_request_received_date` datetime DEFAULT NULL COMMENT 'Date when signed request was received',
  `signed_by_user_id` int(11) DEFAULT NULL COMMENT 'User ID of person who signed the request',
  `finance_reviewed_by` int(11) DEFAULT NULL,
  `finance_reviewed_at` datetime DEFAULT NULL,
  `funds_available` tinyint(1) DEFAULT 0,
  `commitment_form_path` varchar(500) DEFAULT NULL COMMENT 'Optional scanned commitment form uploaded by Procurement Officer (Finance will create actual commitment in GFMS)',
  `procurement_method` enum('SINGLE_SOURCE','RESTRICTED_BIDDING','NATIONAL_COMPETITIVE','INTERNATIONAL_COMPETITIVE') DEFAULT NULL,
  `external_approval_required` enum('NONE','PPC','CABINET') DEFAULT NULL,
  `requires_rfq` tinyint(1) DEFAULT 0,
  `rfq_letter_generated_at` datetime DEFAULT NULL,
  `estimated_value` decimal(15,2) NOT NULL DEFAULT 0.00,
  `currency` enum('JMD','USD') NOT NULL DEFAULT 'JMD',
  `usd_rate` decimal(10,4) DEFAULT NULL COMMENT 'USD to JMD exchange rate at time of request',
  `ppc_approval_status` enum('PENDING','APPROVED','REJECTED') DEFAULT NULL,
  `cabinet_approval_status` enum('PENDING','APPROVED','REJECTED') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `procurement_requests`
--

INSERT IGNORE INTO `procurement_requests` (`request_id`, `branch_id`, `request_number`, `request_date`, `description`, `request_type`, `status`, `rfq_date`, `quotes_received`, `awardee`, `award_date`, `created_by`, `created_at`, `updated_at`, `approved_by`, `approved_at`, `decline_reason`, `signed_request_document_path`, `signed_request_received_date`, `signed_by_user_id`, `finance_reviewed_by`, `finance_reviewed_at`, `funds_available`, `commitment_form_path`, `procurement_method`, `external_approval_required`, `requires_rfq`, `rfq_letter_generated_at`, `estimated_value`, `currency`, `usd_rate`, `ppc_approval_status`, `cabinet_approval_status`) VALUES
(123, 6, 'PR001', '2026-02-26', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 37, '2026-02-26 15:55:56', '2026-02-26 10:56:09', 33, '2026-02-26 11:04:04', NULL, NULL, NULL, NULL, 33, '2026-02-26 11:04:04', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 7000.00, 'JMD', NULL, NULL, NULL),
(124, 6, 'PR002', '2026-02-26', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 38, '2026-02-26 16:06:07', '2026-02-26 11:07:39', 33, '2026-02-26 11:08:20', NULL, NULL, NULL, NULL, 33, '2026-02-26 11:08:20', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 28038.00, 'JMD', NULL, NULL, NULL),
(125, 1, 'PR003', '2026-02-26', '', 'REGULAR', 'PROCUREMENT_STAGE', NULL, 0, NULL, NULL, 36, '2026-02-26 16:16:29', '2026-02-26 11:29:31', 32, '2026-02-26 11:30:49', NULL, NULL, NULL, NULL, 32, '2026-02-26 11:30:49', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 1500000.00, 'JMD', NULL, NULL, NULL),
(126, 6, 'PR004', '2026-02-26', '', 'REGULAR', 'SUBMITTED', NULL, 0, NULL, NULL, 41, '2026-02-26 16:18:23', '2026-02-26 11:18:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 224999.10, 'JMD', NULL, NULL, NULL),
(127, 1, 'PR005', '2026-02-26', '', 'REGULAR', 'DECLINED', NULL, 0, NULL, NULL, 36, '2026-02-26 16:20:53', '2026-02-26 11:21:05', 32, '2026-02-26 11:22:21', 'Youre pushing it', '/uploads/signed_requests/SIGNED_REQUEST_127_1773764831_69b980dfe1b24.pdf', '2026-03-17 11:27:11', 27, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 15000.00, 'JMD', NULL, NULL, NULL),
(128, 1, 'PR006', '2026-03-04', 'Hostinger monthly payment', 'REIMBURSEMENT', 'AWARDED', NULL, 0, NULL, NULL, 32, '2026-03-04 14:46:43', '2026-03-04 09:46:56', 34, '2026-05-13 12:22:12', NULL, NULL, NULL, NULL, 34, '2026-05-13 12:22:12', 1, NULL, 'SINGLE_SOURCE', NULL, 0, NULL, 2000.00, 'JMD', NULL, NULL, NULL),
(129, 5, 'PR007', '2026-03-04', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-04 18:09:12', '2026-03-04 15:40:55', 35, '2026-03-04 16:02:57', NULL, NULL, NULL, NULL, 35, '2026-03-04 16:02:57', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 63000.00, 'JMD', NULL, NULL, NULL),
(130, 5, 'PR008', '2026-03-04', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-04 18:10:59', '2026-03-04 15:43:04', 35, '2026-03-04 16:03:50', NULL, NULL, NULL, NULL, 35, '2026-03-04 16:03:50', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 19000.00, 'JMD', NULL, NULL, NULL),
(132, 5, 'PR010', '2026-03-06', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-03-06 17:14:45', '2026-03-06 12:15:29', 35, '2026-03-06 12:24:09', NULL, NULL, NULL, NULL, 35, '2026-03-06 12:24:09', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 500000.00, 'JMD', NULL, NULL, NULL),
(134, 6, 'PR011', '2026-03-16', '', 'REGULAR', 'DECLINED', NULL, 0, NULL, NULL, 27, '2026-03-16 14:20:03', '2026-03-16 09:20:13', 33, '2026-03-17 11:10:49', 'Fix issue', NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 500.00, 'JMD', NULL, NULL, NULL),
(136, 6, 'PR012', '2026-03-17', '', 'REGULAR', 'DECLINED', NULL, 0, NULL, NULL, 27, '2026-03-17 15:53:09', '2026-03-17 10:57:12', 32, '2026-03-27 13:30:09', 'Previously approved', NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 579540.94, 'JMD', NULL, NULL, NULL),
(137, 1, 'PR013', '2026-03-17', '', 'REGULAR', 'COMMITMENT_APPROVED', NULL, 0, NULL, NULL, 27, '2026-03-17 15:59:36', '2026-03-17 11:00:01', 32, '2026-03-17 11:11:54', NULL, '/uploads/signed_requests/SIGNED_REQUEST_137_1773764983_69b98177a23d3.pdf', '2026-03-17 11:29:43', 32, 34, '2026-03-18 14:51:11', 1, '/uploads/commitments/COMMIT_FORM_1773940801_69bc3041f0636.pdf', 'SINGLE_SOURCE', NULL, 1, NULL, 385000.00, 'JMD', NULL, NULL, NULL),
(138, 6, 'PR014', '2026-03-17', '', 'REGULAR', 'QUOTE_APPROVED', NULL, 0, NULL, NULL, 27, '2026-03-17 16:45:56', '2026-03-17 12:14:46', 33, '2026-03-17 12:59:29', NULL, '/uploads/signed_requests/SIGNED_REQUEST_138_1773768670_69b98fde0b40b.pdf', '2026-03-17 12:31:10', 32, 33, '2026-03-17 12:59:29', 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 579540.94, 'JMD', NULL, NULL, NULL),
(139, 1, 'PR015', '2026-03-17', 'Pan Jamaica Property Company Parking Receipt dated March 10, 2026 for parking - Government Chemist attended a meeting at the MoH&W', 'REIMBURSEMENT', 'AWARDED', NULL, 0, NULL, NULL, 39, '2026-03-17 20:03:02', '2026-03-17 15:15:42', 32, '2026-05-01 17:37:33', NULL, NULL, NULL, NULL, 32, '2026-05-01 17:37:33', 1, NULL, 'SINGLE_SOURCE', NULL, 0, NULL, 900.00, 'JMD', NULL, NULL, NULL),
(140, 5, 'PR016', '2026-03-24', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-24 15:27:47', '2026-03-24 10:27:55', 35, '2026-03-24 11:33:26', NULL, NULL, NULL, NULL, 35, '2026-03-24 11:33:26', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 37000.00, 'JMD', NULL, NULL, NULL),
(141, 5, 'PR017', '2026-04-10', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-04-10 13:47:58', '2026-04-10 08:48:31', 35, '2026-04-10 09:14:16', NULL, NULL, NULL, NULL, 35, '2026-04-10 09:14:16', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 20000.00, 'JMD', NULL, NULL, NULL),
(142, 6, 'PR018', '2026-04-17', '', 'REGULAR', 'QUOTE_REVIEW_PENDING', NULL, 0, NULL, NULL, 37, '2026-04-17 17:07:55', '2026-04-17 12:08:11', 33, '2026-04-17 12:45:53', NULL, NULL, NULL, NULL, 33, '2026-04-17 12:45:53', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 208480.00, 'JMD', NULL, NULL, NULL),
(143, 5, 'PR019', '2026-04-22', '', 'REGULAR', 'QUOTE_APPROVED', NULL, 0, NULL, NULL, 27, '2026-04-22 20:12:26', '2026-04-22 15:12:33', 35, '2026-04-22 15:21:20', NULL, '/uploads/signed_requests/SIGNED_REQUEST_143_1776889680_69e92f5051dd1.pdf', '2026-04-22 15:28:00', 27, 35, '2026-04-22 15:21:20', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 19000.00, 'JMD', NULL, NULL, NULL),
(144, 5, 'PR020', '2026-04-27', '', 'REGULAR', 'FUNDS_VERIFIED', NULL, 0, NULL, NULL, 27, '2026-04-27 17:00:15', '2026-04-27 12:00:39', 35, '2026-04-27 12:11:34', NULL, '/uploads/signed_requests/SIGNED_REQUEST_144_1777310322_69ef9a72b765c.pdf', '2026-04-27 12:18:42', 27, 34, '2026-04-27 13:42:27', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 137214.00, 'JMD', NULL, NULL, NULL),
(145, 6, 'PR021', '2026-04-30', '', 'REGULAR', 'QUOTE_REVIEW_PENDING', NULL, 0, NULL, NULL, 37, '2026-04-30 18:41:31', '2026-05-01 12:50:20', 33, '2026-05-01 09:20:35', NULL, '/uploads/signed_requests/SIGNED_REQUEST_145_1777658424_69f4ea3896a07.pdf', '2026-05-01 13:00:24', 33, 33, '2026-05-01 09:20:35', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 145000.00, 'JMD', NULL, NULL, NULL),
(146, 1, 'PR022', '2026-04-30', '', 'REGULAR', 'QUOTE_REVIEW_PENDING', NULL, 0, NULL, NULL, 27, '2026-04-30 19:48:45', '2026-04-30 14:49:04', 32, '2026-05-01 17:36:38', NULL, '/uploads/signed_requests/SIGNED_REQUEST_146_1778620004_6a0396643df85.pdf', '2026-05-12 16:06:44', 27, 32, '2026-05-01 17:36:38', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 67490.00, 'JMD', NULL, NULL, NULL),
(147, 6, 'PR023', '2026-05-01', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 37, '2026-05-01 14:28:30', '2026-05-01 09:28:44', 33, '2026-05-01 11:43:42', NULL, '/uploads/signed_requests/SIGNED_REQUEST_147_1777658685_69f4eb3deef7e.pdf', '2026-05-01 13:04:45', 33, 33, '2026-05-01 11:43:42', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 57000.00, 'JMD', NULL, NULL, NULL),
(148, 5, 'PR024', '2026-05-04', '', 'REGULAR', 'QUOTE_APPROVED', NULL, 0, NULL, NULL, 40, '2026-05-04 21:15:08', '2026-05-04 16:30:19', 35, '2026-05-04 16:33:42', NULL, NULL, NULL, NULL, 35, '2026-05-04 16:33:42', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 80000.00, 'JMD', NULL, NULL, NULL),
(149, 5, 'PR025', '2026-05-06', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-06 20:01:25', '2026-05-07 11:47:14', 35, '2026-05-06 15:13:19', NULL, NULL, NULL, NULL, 35, '2026-05-06 15:13:19', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 40000.00, 'JMD', NULL, NULL, NULL),
(150, 5, 'PR026', '2026-05-07', '', 'REGULAR', 'DECLINED', NULL, 0, NULL, NULL, 40, '2026-05-07 16:39:01', '2026-05-08 08:17:16', 35, '2026-05-08 15:45:25', 'Please speak with me regarding this request.', NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 77000.00, 'JMD', NULL, NULL, NULL),
(151, 5, 'PR027', '2026-05-07', 'Purchased Land Title from National Lands Agency elandjamaica platform to update DGC records and to facilitate surveying, assessment of land for construction/building.', 'REIMBURSEMENT', 'FUNDS_VERIFIED', NULL, 0, NULL, NULL, 40, '2026-05-07 17:19:06', '2026-05-13 12:44:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 0, NULL, 500.00, 'JMD', NULL, NULL, NULL),
(152, 5, 'PR028', '2026-05-11', 'Tea Supplies for Meeting', 'PETTY_CASH', 'FUNDS_VERIFIED', NULL, 0, NULL, NULL, 40, '2026-05-11 15:27:29', '2026-05-13 12:43:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 0, NULL, 5000.00, 'JMD', NULL, NULL, NULL),
(153, 5, 'PR029', '2026-05-11', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-11 20:07:00', '2026-05-11 15:07:09', 35, '2026-05-12 14:28:40', NULL, NULL, NULL, NULL, 35, '2026-05-12 14:28:40', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 20000.00, 'JMD', NULL, NULL, NULL),
(154, 5, 'PR030', '2026-05-11', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-11 21:08:50', '2026-05-12 14:49:47', 35, '2026-05-13 10:19:50', NULL, NULL, NULL, NULL, 35, '2026-05-13 10:19:50', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 18000.00, 'JMD', NULL, NULL, NULL),
(155, 5, 'PR031', '2026-05-12', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-12 19:00:26', '2026-05-12 14:00:37', 35, '2026-05-12 14:30:32', NULL, NULL, NULL, NULL, 35, '2026-05-12 14:30:32', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 10000.00, 'JMD', NULL, NULL, NULL),
(156, 5, 'PR032', '2026-05-12', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-12 19:12:11', '2026-05-13 09:28:02', 35, '2026-05-13 10:20:09', NULL, NULL, NULL, NULL, 35, '2026-05-13 10:20:09', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 300000.00, 'JMD', NULL, NULL, NULL),
(157, 5, 'PR033', '2026-05-13', 'Gasoline 90 (Gallon)\r\nNeeded to supply weed eater and lawnmower with fuel for maintenance work', 'PETTY_CASH', 'FUNDS_VERIFIED', NULL, 0, NULL, NULL, 40, '2026-05-13 14:19:25', '2026-05-13 12:44:24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 0, NULL, 5000.00, 'JMD', NULL, NULL, NULL),
(158, 5, 'PR034', '2026-05-13', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-05-13 16:39:26', '2026-05-13 11:39:39', 35, '2026-05-13 16:54:50', NULL, NULL, NULL, NULL, 35, '2026-05-13 16:54:50', 1, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 20000.00, 'JMD', NULL, NULL, NULL),
(159, 5, 'PR035', '2026-05-14', '', 'REGULAR', 'SUBMITTED', NULL, 0, NULL, NULL, 40, '2026-05-14 18:19:15', '2026-05-14 13:20:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 'SINGLE_SOURCE', NULL, 1, NULL, 80000.00, 'JMD', NULL, NULL, NULL);

--
-- Triggers `procurement_requests`
--
DELIMITER $$
CREATE TRIGGER `lock_procurement_after_approval` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW BEGIN
  -- Only block true reversions to early-stage statuses.
  -- Allow all legitimate forward transitions (commitment, PO, invoice, etc.)
  IF OLD.status IN ('GC_APPROVED', 'AWARDED', 'COMPLETED')
     AND NEW.status IN ('DRAFT', 'SUBMITTED', 'HOD_APPROVED', 'FUNDS_VERIFIED', 'DIRECTOR_APPROVED', 'DECLINED') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Approved/Awarded/Completed requests cannot be reverted to earlier stages';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_auto_procurement_method` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW BEGIN
  IF NEW.estimated_value < 3000000 THEN
    SET NEW.procurement_method = 'SINGLE_SOURCE';
  ELSEIF NEW.estimated_value < 20000000 THEN
    SET NEW.procurement_method = 'RESTRICTED_BIDDING';
  ELSE
    SET NEW.procurement_method = 'NATIONAL_COMPETITIVE';
  END IF;

  IF NEW.estimated_value > 60000000 THEN
    SET NEW.external_approval_required = 'PPC';
  END IF;

  IF NEW.estimated_value > 150000000 THEN
    SET NEW.external_approval_required = 'CABINET';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_auto_set_requires_rfq` BEFORE INSERT ON `procurement_requests` FOR EACH ROW BEGIN
    DECLARE v_threshold DECIMAL(15,2) DEFAULT 500000.00;

    -- Read threshold dynamically from system_config
    SELECT CAST(config_value AS DECIMAL(15,2))
      INTO v_threshold
      FROM system_config
     WHERE config_key = 'direct_procurement_threshold'
     LIMIT 1;

    -- PETTY_CASH and REIMBURSEMENT never require RFQ (direct workflows)
    -- ALL REGULAR requests now require RFQ regardless of threshold,
    -- but the threshold determines simplified vs full evaluation.
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSE
        -- All regular procurement requires RFQ
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_auto_update_requires_rfq` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW BEGIN
    DECLARE v_threshold DECIMAL(15,2) DEFAULT 500000.00;

    -- Read threshold dynamically from system_config
    SELECT CAST(config_value AS DECIMAL(15,2))
      INTO v_threshold
      FROM system_config
     WHERE config_key = 'direct_procurement_threshold'
     LIMIT 1;

    -- PETTY_CASH and REIMBURSEMENT never require RFQ (direct workflows)
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSE
        -- All regular procurement requires RFQ
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_block_gc_approval_without_external` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW BEGIN

    DECLARE approval_count INT DEFAULT 0;

    IF NEW.status = 'GC_APPROVED'
       AND NEW.external_approval_required <> 'NONE' THEN

        SELECT COUNT(*)
        INTO approval_count
        FROM external_approvals
        WHERE request_id = NEW.request_id;

        IF approval_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'External approval required before GC approval';
        END IF;

    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_set_procurement_method` BEFORE INSERT ON `procurement_requests` FOR EACH ROW BEGIN

    IF NEW.estimated_value <= 3000000 THEN
        SET NEW.procurement_method = 'SINGLE_SOURCE';

    ELSEIF NEW.estimated_value > 3000000 
        AND NEW.estimated_value <= 20000000 THEN
        SET NEW.procurement_method = 'RESTRICTED_BIDDING';

    ELSE
        SET NEW.procurement_method = 'NATIONAL_COMPETITIVE';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `procurement_request_items`
--

CREATE TABLE IF NOT EXISTS `procurement_request_items` (
  `item_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `specification` text DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `procurement_request_items`
--

INSERT IGNORE INTO `procurement_request_items` (`item_id`, `request_id`, `item_name`, `specification`, `quantity`, `remarks`, `created_at`) VALUES
(127, 123, 'Methanol', 'Pharmco, HPLC Grade 4 L', 6, 'General Lab Use', '2026-02-26 15:55:56'),
(128, 124, 'Cuvette', 'Quartz, 1mL', 3, 'N/A', '2026-02-26 16:06:07'),
(130, 126, 'Telephone', '8 lines', 6, '', '2026-02-26 16:18:23'),
(131, 127, 'BK Double Whopper', 'Tender and Juicy', 10, 'w/ milkshake', '2026-02-26 16:20:53'),
(134, 125, 'Porshe EV for Yanique', 'Bigger Beast', 1, 'Quicker than fast', '2026-02-26 16:29:27'),
(140, 129, 'Projector Case', 'Projector Travel Carrying Bag Internal Dimension 14.5\"x10.6\"x3.9\" with Adjustable Shoulder Strap & Compartment Dividers for for Acer, Epson, Benq, LG, Sony (Large)', 1, 'For New Projector', '2026-03-04 20:40:37'),
(141, 129, 'USB C to HDMI Adapter', 'Xtech USB C to HDMI Adapter', 2, 'For Laptop to Monitor', '2026-03-04 20:40:37'),
(142, 129, 'Avaya Digital Phones', 'Avaya 9508 Digital Phone', 2, 'For Upgrades', '2026-03-04 20:40:37'),
(143, 130, 'Xtech - Mouse pad', 'Voyager XTA-180', 4, 'Work', '2026-03-04 20:42:56'),
(144, 130, 'Klip Xtreme - Mouse - 2.4 GHz', 'Ergonomic Mice, Rechargeable', 6, 'Work', '2026-03-04 20:42:56'),
(146, 131, 'Microsoft Surface Pro 13\"', '3K 120Hz OLED Touch AI Laptop, 900nits, 12-Core Snapdragon, 45 Tops NPU, 16GB RAM, 512GB SSD, USB4, Wi-Fi 7, Backlit KB, Stylus, MS 365, Win 11 Pro', 1, 'For Government Chemist', '2026-03-04 20:53:11'),
(147, 131, 'Fintie Case for 13 Inch Microsoft Surface Pro', 'Multiple Angle Viewing Portfolio Business Cover with Pocket & Stylus Holder, Compatible with Type Cover Keyboard, Ice Blue', 1, 'For Government Chemist', '2026-03-04 20:53:11'),
(148, 132, 'Mobile Phone', 'Samsung Galaxy S25', 1, '', '2026-03-06 17:14:45'),
(149, 132, 'Mobile Phone', 'Samsung Galaxy S25FE', 5, '', '2026-03-06 17:14:45'),
(150, 133, 'TEST Request', 'TEst', 1, '1', '2026-03-12 20:12:44'),
(151, 134, 'TEST', 'Procurement getting Notifications', 1, 'Accept Request', '2026-03-16 14:20:03'),
(152, 135, 'APC Smart‑UPS On‑Line SRT 5.4 kVA', 'SRT5KXLTUS ', 1, 'For HPLC system (Agilent 1260 DAD)', '2026-03-17 14:29:45'),
(153, 136, 'APC Smart‑UPS On‑Line SRT 5.4 kVA', 'SRT5KXLTUS ', 1, 'For HPLC system (Agilent 1260 DAD)', '2026-03-17 15:53:09'),
(154, 137, 'Microsoft Surface Pro 13\"', '3K 120Hz OLED Touch AI Laptop, 900nits, 12-Core Snapdragon, 45 Tops NPU, 16GB RAM, 512GB SSD, USB4, Wi-Fi 7, Backlit KB, Stylus, MS 365, Win 11 Pro', 1, 'For Government Chemist', '2026-03-17 15:59:36'),
(155, 137, 'Fintie Case for 13 Inch Microsoft Surface Pro', 'Multiple Angle Viewing Portfolio Business Cover with Pocket & Stylus Holder, Compatible with Type Cover Keyboard, Ice Blue', 1, 'For Government Chemist', '2026-03-17 15:59:36'),
(157, 138, 'APC Smart‑UPS On‑Line SRT 5.4 kVA', 'SRT5KXLTUS ', 1, 'For HPLC system (Agilent 1260 DAD)', '2026-03-17 17:14:28'),
(158, 140, 'Epson Wireless', 'LAN Module - Network adapter - Wi-Fi', 1, 'For Projector', '2026-03-24 15:27:47'),
(159, 141, 'Avaya Telephone', '9508 Model', 1, 'Public Procurement Officer', '2026-04-10 13:47:58'),
(160, 142, 'Chloroform with Ethanol', 'ACS, HPLC ; 4 L Amber bottle', 4, '', '2026-04-17 17:07:55'),
(161, 142, 'Methanol', 'HPLC  Grade 4 L', 6, '', '2026-04-17 17:07:55'),
(162, 142, 'Acetonitrile', 'HPLC Grade 4 L', 2, '', '2026-04-17 17:07:55'),
(163, 143, 'SSD Harddrive', '2.5 sata, 480gb', 1, 'For SMS restoration on primary server', '2026-04-22 20:12:26'),
(164, 144, 'RAM', 'Dell 1Rx8 16GB DDR5 PC5-5600 UDIMM ECC RAM Memory		', 1, 'For Server Upgrades', '2026-04-27 17:00:15'),
(169, 146, '3 in 1 Laptop Bag, 15.6 inch PU Leather Shoulder Bag Briefcase Messenger Satchel Laptop Backpack', '15-16 inch Computer Bags Handbag Bookbag, Black ', 1, 'For Gov Chem Surface Pro', '2026-04-30 19:48:45'),
(170, 146, 'New for Microsoft Surface Docking Station 11-in-1 Surface Dock 2 4K@60HZ', 'HDMI USB C Travel Dock for Microsoft Surface Pro 12/11/10/9/8/X/7/6/5/4,Surface Laptop 6/5/4/3/2/1,Laptop Go 3/2/1,Surface Book ', 1, 'For Gov Chem Surface Pro', '2026-04-30 19:48:45'),
(171, 146, '65W USB C Surface Pro Charger Compatible with Microsoft Type c Surface Pro Fast Charge', 'Compatible with Microsoft Surface Pro 11 10 9 8 7+ 7 Surface pro X Tablet & Laptop Type C Fast Charger ', 1, 'For Gov Chem Surface Pro', '2026-04-30 19:48:45'),
(172, 146, '45W Super Fast Charger USB C, Type C Chargers Fast Charging Android Phone Charger Block Samsung Galaxy S25 Ultra Chargers', '10FT Fast Charging Cord for Samsung Galaxy S26 Ultra/S26//S25/S24/S23, 2Port ', 1, 'For Gov Chem Galaxy Ultra', '2026-04-30 19:48:45'),
(173, 146, 'Privacy Screen for 13 Inch Surface Pro 11/10/9/8/X, MagicSuction™', 'Removable Anti Spy Black Protector, Glare Blue Light Filter for Microsoft Laptop Computer Monitor ', 1, 'For Gov Chem Surface Pro', '2026-04-30 19:48:45'),
(174, 147, 'Sodium Oxalate', 'Reference Material for Titrimetry', 1, 'For standardization, 25g/ bottle', '2026-05-01 14:28:30'),
(175, 147, 'Ammonium Oxalate', 'ACS Reagent', 1, 'For general lab, 50 g', '2026-05-01 14:28:30'),
(176, 147, 'NN- Dimethyl p-phenylenediamine sulphate', 'Catalog No. 186384', 1, 'For general lab use, 25 g', '2026-05-01 14:28:30'),
(177, 145, 'Hard Drive', 'SSD, Min. 480 GB', 1, 'For Agilent HPLC computer', '2026-05-01 17:50:20'),
(178, 145, 'Memory Card', 'DDR4, 8GB', 1, 'For Agilent HPLC Computer', '2026-05-01 17:50:20'),
(179, 145, '27\" Monitor', '90hz-120hz refresh rate', 1, 'For Deputy Government Chemist (brand can be Lenovo/HP/Samsung/LG,', '2026-05-01 17:50:20'),
(180, 145, 'Printer', 'Wireless Black & White All-in-One Laser Printer, Scanner, Copier', 1, 'For Senior Chemist Office, HP Laserjet Pro MFP 4101fdw', '2026-05-01 17:50:20'),
(190, 148, 'Copy Paper', 'Letter Size ', 50, 'Reams', '2026-05-04 21:30:09'),
(191, 148, 'Copy Paper', 'Legal Size ', 20, 'Reams', '2026-05-04 21:30:09'),
(192, 148, '4 Quire Book', 'Hard Cover', 6, '', '2026-05-04 21:30:09'),
(193, 148, 'Flag Its', 'Sign Here', 20, '', '2026-05-04 21:30:09'),
(194, 148, 'Sticky Notes', '3*3', 36, '3 packs', '2026-05-04 21:30:09'),
(195, 148, 'Stenopad', '', 15, '', '2026-05-04 21:30:09'),
(196, 148, 'Whiteboard', 'Length: 41 inches, width 41 inches', 1, 'closest approximate size to what is requested', '2026-05-04 21:30:09'),
(197, 148, 'Whiteboard Markers', 'black, blue, red, green', 4, '4 single whiteboard markers of the colours listed', '2026-05-04 21:30:09'),
(198, 148, 'Paper Clip ', 'Regular - 33mm', 10, 'boxes', '2026-05-04 21:30:09'),
(199, 148, 'Paper Clip', 'Jumbo - 50mm', 10, '', '2026-05-04 21:30:09'),
(200, 148, 'Scientific Calculator', '', 3, '', '2026-05-04 21:30:09'),
(201, 148, 'Desktop Calculator ', '', 3, '', '2026-05-04 21:30:09'),
(202, 148, 'Bull Dog Clip', '37mm', 24, '', '2026-05-04 21:30:09'),
(203, 148, 'Bull Dog Clip', '51mm', 24, '', '2026-05-04 21:30:09'),
(204, 148, 'Highlighter', '', 1, '2 packs - Assorted colours ', '2026-05-04 21:30:09'),
(205, 148, 'Mesh Document Tray', '', 1, '', '2026-05-04 21:30:09'),
(206, 148, 'Pen', 'Gel - blue - fine', 36, '3 Dozen', '2026-05-04 21:30:09'),
(207, 148, 'Pen', 'BIC - Blue - Fine', 36, '3 Dozen', '2026-05-04 21:30:09'),
(208, 148, 'Pen', 'BIC - Blue - Medium', 12, '1 Dozen', '2026-05-04 21:30:09'),
(209, 148, 'Pen', 'BIC - Black- Fine', 36, '3 Dozen', '2026-05-04 21:30:09'),
(219, 149, 'ID CARD CASE WITH RETRACTABLE CLIP', 'HEAVY DUTY', 50, '', '2026-05-07 16:47:14'),
(261, 150, 'Box Cutter', '', 1, '', '2026-05-08 13:17:13'),
(262, 150, 'Cement', '', 12, '', '2026-05-08 13:17:13'),
(263, 150, 'Thinset ', '', 3, '', '2026-05-08 13:17:13'),
(264, 150, 'Hose (Garden/Water)', '100 feet', 3, '', '2026-05-08 13:17:13'),
(265, 150, 'Pole Saw', '20 feet or closest to, electric if possible', 1, 'To cut tall branches from trees', '2026-05-08 13:17:13'),
(266, 150, 'Paint', 'White/Gallon', 2, '', '2026-05-08 13:17:13'),
(267, 150, 'Corking Sylicone', 'White', 6, '', '2026-05-08 13:17:13'),
(268, 150, 'Drywall Screw', '1 1/2inch', 500, '', '2026-05-08 13:17:13'),
(269, 150, 'Tee PVC', '1 inch', 1, '', '2026-05-08 13:17:13'),
(270, 150, 'Length of Pipe PVC', '1 inch', 5, '', '2026-05-08 13:17:13'),
(271, 150, 'Elbow PVC', '1 inch', 9, '', '2026-05-08 13:17:13'),
(272, 150, 'Coupling PVC', '1 inch', 9, '', '2026-05-08 13:17:13'),
(273, 150, 'Turn of Valve PVC', '1 inch', 4, '', '2026-05-08 13:17:13'),
(274, 150, 'Length of Pipe PVC', '1/2', 6, '', '2026-05-08 13:17:13'),
(275, 150, 'Coupling PVC', '1/2 inch with thread (female)', 1, '', '2026-05-08 13:17:13'),
(276, 150, 'Reducer PVC', '1 inch to 1/2 inch ', 3, '', '2026-05-08 13:17:13'),
(277, 150, 'Pipe cock', 'Metal', 5, '', '2026-05-08 13:17:13'),
(278, 150, 'Thread Tape', '6', 1, '', '2026-05-08 13:17:13'),
(279, 150, 'Elbow PVC', '1/2 inch', 6, '', '2026-05-08 13:17:13'),
(280, 150, 'Tee PVC', '1/2inch', 1, '', '2026-05-08 13:17:13'),
(281, 150, 'Flood Light', '300 Watts, Solar', 15, '', '2026-05-08 13:17:13'),
(282, 153, 'Gasoline 90', 'Gallon', 2, '', '2026-05-11 20:07:00'),
(283, 153, 'Weed Eater Line', '', 2, '', '2026-05-11 20:07:00'),
(284, 153, '2 Stroke Oil', '', 3, '', '2026-05-11 20:07:00'),
(291, 155, 'LINEN PAPER', 'LEGAL SIZE', 2, 'CREAM', '2026-05-12 19:00:26'),
(304, 154, 'Peppered steak', 'Large ', 4, '', '2026-05-12 19:49:44'),
(305, 154, 'Chicken lunch', 'Large ', 4, '', '2026-05-12 19:49:44'),
(306, 154, 'Fish meal ', 'Large ', 2, '', '2026-05-12 19:49:44'),
(307, 154, 'Soda', '', 1, '', '2026-05-12 19:49:44'),
(308, 154, 'Orange Juice', '', 1, '', '2026-05-12 19:49:44'),
(309, 154, 'Natural Juice', '', 8, '', '2026-05-12 19:49:44'),
(310, 156, 'CHAIR (OFFICE)', '', 2, 'B7-301BK Boss High Back Exec. Leather Plus Chair - Black', '2026-05-13 14:27:57'),
(311, 156, 'CHAIR (EXECUTIVE)', '', 3, 'B9-91BK Boss H/Duty Double Plush High Back Chair (400lbs) - Black', '2026-05-13 14:27:57'),
(312, 156, 'DESK (OFFICE)', '', 2, 'ED-0018BW Echo 1800x1800 Exec Desk w/Pedestal - Bk/Walnut', '2026-05-13 14:27:57'),
(313, 156, 'DESK (EXECUTIVE)', '', 3, 'ET-E1818L W Elite 1800x1800 Exec Unit w/Hutch & Pedestal - Walnut', '2026-05-13 14:27:57'),
(314, 156, 'CHAIRS (BOARD ROOM/CONFERENCE ROOM)', '', 12, 'B0-HAB72BK Boss Habanera Leather High Back Exec. Chair - Bk', '2026-05-13 14:27:57'),
(315, 156, 'DESK (BOARD ROOM/CONFERENCE ROOM)', '', 1, 'CR-656 WW 00x1200 Conference Table WW', '2026-05-13 14:27:57'),
(316, 158, 'Peppered Steak Lunch		 ', 'Large	', 4, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(317, 158, 'Chicken Lunch', 'Large		 ', 4, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(318, 158, 'Fish Lunch', 'Large		 ', 2, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(319, 158, 'Soda			 ', '', 1, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(320, 158, 'Orange Juice			 ', '', 1, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(321, 158, 'Natural Juice			', '', 8, 'Managers Training for Departmental Unit Plan', '2026-05-13 16:39:26'),
(322, 159, 'Installation of 110 volts - Circuit to facilitate printer in Accounts Department', '', 1, '', '2026-05-14 18:19:15');

-- --------------------------------------------------------

--
-- Table structure for table `procurement_verifications`
--

CREATE TABLE IF NOT EXISTS `procurement_verifications` (
  `verification_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `verification_type` enum('GOODS_RECEIVED','SERVICE_RENDERED','PETTY_CASH_PURCHASED') DEFAULT 'GOODS_RECEIVED',
  `verified_by` int(11) NOT NULL,
  `verification_date` datetime DEFAULT current_timestamp(),
  `condition_status` enum('SATISFACTORY','DEFECTIVE','INCOMPLETE','OTHER') DEFAULT 'SATISFACTORY',
  `verification_notes` text DEFAULT NULL,
  `verification_documents` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Procurement verification of goods received or services rendered';

-- --------------------------------------------------------

--
-- Table structure for table `purchase_orders`
--

CREATE TABLE IF NOT EXISTS `purchase_orders` (
  `po_id` int(11) NOT NULL,
  `commitment_id` int(11) NOT NULL,
  `po_number` varchar(50) NOT NULL,
  `po_date` date NOT NULL,
  `po_total` decimal(12,2) NOT NULL,
  `status` enum('Open','Closed','Cancelled') DEFAULT 'Open',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `excess_approved_by` int(11) DEFAULT NULL,
  `excess_approved_at` datetime DEFAULT NULL,
  `commitment_approved_at` datetime DEFAULT NULL,
  `gfms_generated` tinyint(1) DEFAULT 0,
  `po_type` enum('ORIGINAL','ADJUSTMENT') NOT NULL DEFAULT 'ORIGINAL',
  `parent_po_id` int(11) DEFAULT NULL,
  `adjustment_reason` text DEFAULT NULL,
  `gfms_po_number` varchar(50) DEFAULT NULL COMMENT 'Unique PO number from GFMS system',
  `document_path` varchar(255) DEFAULT NULL COMMENT 'Path to uploaded PO document from GFMS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `purchase_orders`
--
DELIMITER $$
CREATE TRIGGER `trg_require_committed_amount_for_po` BEFORE INSERT ON `purchase_orders` FOR EACH ROW BEGIN
    DECLARE commitment_exists INT DEFAULT 0;

    -- Check if commitment exists and is linked
    SELECT COUNT(*)
    INTO commitment_exists
    FROM commitments
    WHERE commitment_id = NEW.commitment_id
    LIMIT 1;

    IF commitment_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Commitment must exist before PO creation';
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_track_po_approval_date` BEFORE UPDATE ON `purchase_orders` FOR EACH ROW BEGIN
    -- When PO moves to approved status, set the approval timestamp
    IF NEW.approved_by IS NOT NULL AND NEW.approved_at IS NOT NULL AND OLD.approved_by IS NULL THEN
        SET NEW.commitment_approved_at = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reimbursement_invoices`
--

CREATE TABLE IF NOT EXISTS `reimbursement_invoices` (
  `reimb_invoice_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `invoice_stage` enum('COPY_TO_PROCUREMENT','ORIGINAL_TO_FINANCE') DEFAULT 'COPY_TO_PROCUREMENT',
  `invoice_amount` decimal(15,2) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `submitted_date` datetime DEFAULT current_timestamp(),
  `verified_by` int(11) DEFAULT NULL,
  `procurement_verified_date` datetime DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `goods_service_verified` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Invoice tracking for reimbursement requests (GC2 copy and GC10A original)';

-- --------------------------------------------------------

--
-- Table structure for table `reimbursement_status_history`
--

CREATE TABLE IF NOT EXISTS `reimbursement_status_history` (
  `history_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `change_date` datetime DEFAULT current_timestamp(),
  `change_notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historical record of reimbursement request status changes';

--
-- Dumping data for table `reimbursement_status_history`
--

INSERT IGNORE INTO `reimbursement_status_history` (`history_id`, `request_id`, `old_status`, `new_status`, `changed_by`, `change_date`, `change_notes`, `created_at`) VALUES
(1, 151, 'SUBMITTED', 'FUNDS_VERIFIED', 34, '2026-05-13 12:44:43', 'Funds verified by Finance', '2026-05-13 12:44:43');

-- --------------------------------------------------------

--
-- Table structure for table `request_approvals`
--

CREATE TABLE IF NOT EXISTS `request_approvals` (
  `id` int(11) NOT NULL,
  `request_id` int(11) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_at` datetime DEFAULT NULL,
  `entity_type` varchar(50) DEFAULT 'REQUEST',
  `entity_id` int(11) DEFAULT NULL,
  `stage_order` int(11) NOT NULL DEFAULT 1,
  `rejection_reason` text DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `notes` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `request_approvals`
--

INSERT IGNORE INTO `request_approvals` (`id`, `request_id`, `role`, `approved_by`, `status`, `approved_at`, `entity_type`, `entity_id`, `stage_order`, `rejection_reason`, `comments`, `created_at`, `notes`) VALUES
(86, 123, 'Deputy Government Chemist', 33, 'approved', '2026-02-26 11:04:04', 'REQUEST', 123, 1, NULL, NULL, '2026-02-26 10:56:09', NULL),
(87, 124, 'Deputy Government Chemist', 33, 'approved', '2026-02-26 11:08:20', 'REQUEST', 124, 1, NULL, NULL, '2026-02-26 11:07:39', NULL),
(89, 126, 'Deputy Government Chemist', NULL, 'pending', NULL, 'REQUEST', 126, 1, NULL, NULL, '2026-02-26 11:18:43', NULL),
(91, 125, 'HOD', 32, 'approved', '2026-02-26 11:30:49', 'REQUEST', 125, 1, NULL, NULL, '2026-02-26 11:29:31', NULL),
(92, 128, 'Finance Officer', 34, 'approved', '2026-05-13 12:22:12', 'REQUEST', 128, 1, NULL, NULL, '2026-03-04 09:46:56', NULL),
(95, 129, 'Director HRM&A', 35, 'approved', '2026-03-04 16:02:57', 'REQUEST', 129, 1, NULL, NULL, '2026-03-04 15:40:55', NULL),
(96, 130, 'Director HRM&A', 35, 'approved', '2026-03-04 16:03:50', 'REQUEST', 130, 1, NULL, NULL, '2026-03-04 15:43:04', NULL),
(97, 131, 'HOD', 32, 'approved', '2026-03-04 16:04:34', 'REQUEST', 131, 1, NULL, NULL, '2026-03-04 15:53:17', NULL),
(98, 132, 'Director HRM&A', 35, 'approved', '2026-03-06 12:24:09', 'REQUEST', 132, 1, NULL, NULL, '2026-03-06 12:15:29', NULL),
(99, 133, 'Director HRM&A', 35, 'approved', '2026-03-12 15:17:12', 'REQUEST', 133, 1, NULL, NULL, '2026-03-12 15:12:51', NULL),
(101, 135, 'Deputy Government Chemist', 33, 'approved', '2026-03-17 09:39:45', 'REQUEST', 135, 1, NULL, NULL, '2026-03-17 09:29:58', NULL),
(104, 137, 'HOD', 32, 'approved', '2026-03-17 11:11:54', 'REQUEST', 137, 1, NULL, NULL, '2026-03-17 11:00:01', NULL),
(107, 138, 'HOD', 32, 'approved', '2026-03-17 12:27:56', 'REQUEST', 138, 1, NULL, NULL, '2026-03-17 12:14:46', NULL),
(108, 138, 'Deputy Government Chemist', 33, 'approved', '2026-03-17 12:59:29', 'REQUEST', 138, 2, NULL, NULL, '2026-03-17 12:14:46', NULL),
(109, 139, 'HOD', 32, 'approved', '2026-05-01 17:37:33', 'REQUEST', 139, 1, NULL, NULL, '2026-03-17 15:15:42', NULL),
(110, 140, 'Director HRM&A', 35, 'approved', '2026-03-24 11:33:26', 'REQUEST', 140, 1, NULL, NULL, '2026-03-24 10:27:55', NULL),
(111, 141, 'Director HRM&A', 35, 'approved', '2026-04-10 09:14:16', 'REQUEST', 141, 1, NULL, NULL, '2026-04-10 08:48:31', NULL),
(112, 142, 'Deputy Government Chemist', 33, 'approved', '2026-04-17 12:45:53', 'REQUEST', 142, 1, NULL, NULL, '2026-04-17 12:08:11', NULL),
(113, 143, 'Director HRM&A', 35, 'approved', '2026-04-22 15:21:20', 'REQUEST', 143, 1, NULL, NULL, '2026-04-22 15:12:33', NULL),
(114, 144, 'Director HRM&A', 35, 'approved', '2026-04-27 12:11:34', 'REQUEST', 144, 1, NULL, NULL, '2026-04-27 12:00:39', NULL),
(115, 145, 'Deputy Government Chemist', 33, 'approved', '2026-05-01 09:20:35', 'REQUEST', 145, 1, NULL, NULL, '2026-04-30 13:41:45', NULL),
(116, 146, 'HOD', 32, 'approved', '2026-05-01 17:36:38', 'REQUEST', 146, 1, NULL, NULL, '2026-04-30 14:49:04', NULL),
(117, 147, 'Deputy Government Chemist', 33, 'approved', '2026-05-01 11:43:42', 'REQUEST', 147, 1, NULL, NULL, '2026-05-01 09:28:44', NULL),
(118, 148, 'Director HRM&A', 35, 'approved', '2026-05-04 16:33:42', 'REQUEST', 148, 1, NULL, NULL, '2026-05-04 16:30:19', NULL),
(119, 149, 'Director HRM&A', 35, 'approved', '2026-05-06 15:13:19', 'REQUEST', 149, 1, NULL, NULL, '2026-05-06 15:12:05', NULL),
(121, 153, 'Director HRM&A', 35, 'approved', '2026-05-12 14:28:40', 'REQUEST', 153, 1, NULL, NULL, '2026-05-11 15:07:09', NULL),
(122, 155, 'Director HRM&A', 35, 'approved', '2026-05-12 14:30:32', 'REQUEST', 155, 1, NULL, NULL, '2026-05-12 14:00:37', NULL),
(124, 154, 'Director HRM&A', 35, 'approved', '2026-05-13 10:19:50', 'REQUEST', 154, 1, NULL, NULL, '2026-05-12 14:49:47', NULL),
(125, 156, 'Director HRM&A', 35, 'approved', '2026-05-13 10:20:09', 'REQUEST', 156, 1, NULL, NULL, '2026-05-13 09:28:02', NULL),
(126, 151, 'Finance Officer', 34, 'approved', '2026-05-13 12:44:43', 'REQUEST', 151, 1, NULL, NULL, '2026-05-13 10:15:01', ''),
(127, 152, 'Finance Officer', 34, 'approved', '2026-05-13 12:43:36', 'REQUEST', 152, 1, NULL, NULL, '2026-05-13 10:16:00', ''),
(128, 157, 'Finance Officer', 34, 'approved', '2026-05-13 12:44:24', 'REQUEST', 157, 1, NULL, NULL, '2026-05-13 10:16:32', ''),
(129, 158, 'Director HRM&A', 35, 'approved', '2026-05-13 16:54:50', 'REQUEST', 158, 1, NULL, NULL, '2026-05-13 11:39:39', NULL),
(130, 159, 'Director HRM&A', NULL, 'pending', NULL, 'REQUEST', 159, 1, NULL, NULL, '2026-05-14 13:20:01', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `request_documents`
--

CREATE TABLE IF NOT EXISTS `request_documents` (
  `document_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `document_type` enum('SIGNED_PO','SIGNED_COMMITMENT','OTHER') NOT NULL DEFAULT 'OTHER',
  `document_name` varchar(255) NOT NULL COMMENT 'Original filename',
  `document_path` varchar(255) NOT NULL COMMENT 'Server file path',
  `uploaded_by` int(11) NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `request_documents`
--

INSERT IGNORE INTO `request_documents` (`document_id`, `request_id`, `document_type`, `document_name`, `document_path`, `uploaded_by`, `uploaded_at`, `notes`) VALUES
(3, 127, '', 'FinMan Installation_Revised (1).pdf', '/uploads/signed_requests/SIGNED_REQUEST_127_1773764831_69b980dfe1b24.pdf', 27, '2026-03-17 16:27:11', 'Signed request uploaded by Technical & User Support Officer'),
(4, 137, '', 'PR013.pdf', '/uploads/signed_requests/SIGNED_REQUEST_137_1773764983_69b98177a23d3.pdf', 32, '2026-03-17 16:29:43', 'Signed request uploaded by Yanique A. Fraser'),
(5, 138, '', 'PR014.pdf', '/uploads/signed_requests/SIGNED_REQUEST_138_1773768670_69b98fde0b40b.pdf', 32, '2026-03-17 17:31:10', 'Signed request uploaded by Yanique A. Fraser'),
(6, 143, '', 'Scan2026-04-22_152717.pdf', '/uploads/signed_requests/SIGNED_REQUEST_143_1776889680_69e92f5051dd1.pdf', 27, '2026-04-22 20:28:00', 'Signed request uploaded by Technical & User Support Officer'),
(7, 144, '', 'Document_260427_121219.pdf', '/uploads/signed_requests/SIGNED_REQUEST_144_1777310322_69ef9a72b765c.pdf', 27, '2026-04-27 17:18:42', 'Signed request uploaded by Technical & User Support Officer'),
(8, 145, '', 'PR021 .pdf', '/uploads/signed_requests/SIGNED_REQUEST_145_1777658424_69f4ea3896a07.pdf', 33, '2026-05-01 18:00:24', 'Signed request uploaded by Daneika Anderson'),
(9, 147, '', 'PR023.pdf', '/uploads/signed_requests/SIGNED_REQUEST_147_1777658685_69f4eb3deef7e.pdf', 33, '2026-05-01 18:04:45', 'Signed request uploaded by Daneika Anderson'),
(10, 146, '', 'PR22.pdf', '/uploads/signed_requests/SIGNED_REQUEST_146_1778620004_6a0396643df85.pdf', 27, '2026-05-12 21:06:44', 'Signed request uploaded by Technical & User Support Officer');

-- --------------------------------------------------------

--
-- Table structure for table `rfqs`
--

CREATE TABLE IF NOT EXISTS `rfqs` (
  `rfq_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `rfq_number` varchar(50) NOT NULL,
  `rfq_date` date NOT NULL,
  `submission_deadline` datetime NOT NULL,
  `status` enum('DRAFT','PUBLISHED','CLOSED','AWARDED') NOT NULL DEFAULT 'DRAFT',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `awarded_quote_id` int(11) DEFAULT NULL,
  `letter_of_award_file` varchar(255) DEFAULT NULL,
  `rfq_letter_file` varchar(255) DEFAULT NULL COMMENT 'Uploaded RFQ letter document path',
  `acceptance_status` enum('PENDING','ACCEPTED','REJECTED') DEFAULT 'PENDING',
  `quote_review_status` enum('PENDING','IN_REVIEW','APPROVED') DEFAULT 'PENDING',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `acceptance_received_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rfqs`
--

INSERT IGNORE INTO `rfqs` (`rfq_id`, `request_id`, `rfq_number`, `rfq_date`, `submission_deadline`, `status`, `created_by`, `created_at`, `awarded_quote_id`, `letter_of_award_file`, `rfq_letter_file`, `acceptance_status`, `quote_review_status`, `reviewed_by`, `reviewed_at`, `acceptance_received_at`) VALUES
(25, 131, 'RFQ-20260316-131', '2026-03-16', '2026-03-23 04:51:00', '', 44, '2026-03-16 17:51:59', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1773683519_69b8433fcf9c6.docx', 'PENDING', 'PENDING', NULL, NULL, NULL),
(26, 132, 'RFQ-20260316-132', '2026-03-16', '2026-03-23 15:31:00', '', 44, '2026-03-16 20:31:08', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1773693068_69b8688cb1fc8.docx', 'PENDING', 'PENDING', NULL, NULL, NULL),
(27, 137, 'RFQ-20260317-137', '2026-03-17', '2026-03-19 11:00:00', 'PUBLISHED', 44, '2026-03-17 16:53:40', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1773766420_69b987142ce58.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(28, 138, 'RFQ-20260317-138', '2026-03-17', '2026-03-19 11:00:00', 'PUBLISHED', 44, '2026-03-17 19:12:55', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1773774775_69b9a7b773bb0.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(29, 144, 'RFQ-20260427-144', '2026-04-08', '2026-04-15 11:00:00', 'PUBLISHED', 44, '2026-04-27 17:33:44', NULL, NULL, NULL, 'PENDING', 'PENDING', NULL, NULL, NULL),
(30, 147, 'RFQ-20260504-147', '2026-05-01', '2026-05-08 11:00:00', '', 42, '2026-05-04 21:40:18', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1777930818_69f91242c36eb.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(31, 146, 'RFQ-20260504-146', '2026-05-04', '2026-05-11 11:00:00', 'PUBLISHED', 42, '2026-05-04 22:08:29', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1777932509_69f918dd717ad.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(32, 145, 'RFQ-20260504-145', '2026-05-04', '2026-05-11 11:00:00', 'PUBLISHED', 42, '2026-05-04 22:12:50', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1777932770_69f919e24c439.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(33, 143, 'RFQ-20260504-143', '2026-04-29', '2026-05-26 11:00:00', 'PUBLISHED', 44, '2026-05-04 22:17:16', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1777933051_69f91afb50ac4.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(34, 142, 'RFQ-20260505-142', '2026-04-29', '2026-05-06 11:00:00', 'PUBLISHED', 44, '2026-05-05 18:42:09', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1778006547_69fa3a13883e2.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(35, 148, 'RFQ-20260505-148', '2026-05-05', '2026-05-12 11:00:00', 'PUBLISHED', 42, '2026-05-05 21:28:10', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1778016490_69fa60ea3edfe.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(36, 149, 'RFQ-20260507-149', '2026-05-07', '2026-05-14 11:00:00', '', 42, '2026-05-07 16:39:25', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1778171965_69fcc03dd202a.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL),
(37, 155, 'RFQ-20260512-155', '2026-05-12', '2026-05-19 11:00:00', '', 42, '2026-05-12 20:48:45', NULL, NULL, '/uploads/rfq_letters/RFQ_LETTER_1778618925_6a03922d88e7f.pdf', 'PENDING', 'PENDING', NULL, NULL, NULL);

--
-- Triggers `rfqs`
--
DELIMITER $$
CREATE TRIGGER `trg_block_award_without_committee` BEFORE UPDATE ON `rfqs` FOR EACH ROW BEGIN

    DECLARE committee_count INT DEFAULT 0;
    DECLARE report_count INT DEFAULT 0;

    IF NEW.status = 'AWARDED' THEN

        SELECT COUNT(*)
        INTO committee_count
        FROM rfq_evaluation_committee
        WHERE rfq_id = NEW.rfq_id;

        IF committee_count < 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Minimum 3 evaluation committee members required';
        END IF;

        SELECT COUNT(*)
        INTO report_count
        FROM rfq_evaluation_reports
        WHERE rfq_id = NEW.rfq_id;

        IF report_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tender Evaluation Report required before award';
        END IF;

    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_block_rfq_without_funds` BEFORE INSERT ON `rfqs` FOR EACH ROW BEGIN
    -- Funds verification moved to commitment stage to avoid circular dependency
    -- RFQ can now be created without pre-verification
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `rfq_evaluation_committee`
--

CREATE TABLE IF NOT EXISTS `rfq_evaluation_committee` (
  `committee_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rfq_evaluation_committee`
--

INSERT IGNORE INTO `rfq_evaluation_committee` (`committee_id`, `rfq_id`, `user_id`, `role`) VALUES
(1, 4, 16, NULL),
(2, 4, 18, NULL),
(3, 4, 17, NULL),
(5, 5, 17, NULL),
(6, 5, 16, NULL),
(7, 5, 19, NULL),
(8, 6, 16, NULL),
(9, 6, 17, NULL),
(10, 6, 19, NULL),
(11, 7, 16, NULL),
(12, 7, 17, NULL),
(13, 7, 19, NULL),
(14, 12, 17, NULL),
(15, 12, 19, NULL),
(16, 12, 4, NULL),
(17, 13, 17, NULL),
(18, 13, 4, NULL),
(19, 13, 19, NULL),
(20, 15, 17, NULL),
(21, 15, 19, NULL),
(22, 15, 4, NULL),
(23, 16, 17, NULL),
(24, 16, 4, NULL),
(25, 16, 19, NULL),
(26, 17, 17, NULL),
(27, 17, 4, NULL),
(28, 17, 19, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `rfq_evaluation_reports`
--

CREATE TABLE IF NOT EXISTS `rfq_evaluation_reports` (
  `report_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `report_file` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rfq_quotes`
--

CREATE TABLE IF NOT EXISTS `rfq_quotes` (
  `quote_id` int(11) NOT NULL,
  `rfq_vendor_id` int(11) NOT NULL,
  `quote_amount` decimal(12,2) NOT NULL,
  `currency` enum('JMD','USD') NOT NULL DEFAULT 'JMD',
  `usd_rate` decimal(10,4) DEFAULT NULL COMMENT 'USD to JMD exchange rate',
  `gct_amount` decimal(12,2) DEFAULT 0.00,
  `validity_days` int(11) DEFAULT 30,
  `quote_file` varchar(255) DEFAULT NULL,
  `is_selected` tinyint(1) DEFAULT 0,
  `review_status` enum('PENDING','MEETS_REQUIREMENTS','DOES_NOT_MEET') DEFAULT 'PENDING',
  `review_comments` text DEFAULT NULL,
  `submitted_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rfq_quotes`
--

INSERT IGNORE INTO `rfq_quotes` (`quote_id`, `rfq_vendor_id`, `quote_amount`, `currency`, `usd_rate`, `gct_amount`, `validity_days`, `quote_file`, `is_selected`, `review_status`, `review_comments`, `submitted_at`) VALUES
(65, 72, 355949.10, 'JMD', NULL, 46428.14, 30, '1773842527_Proforma Invoice -  MICROSOFT QUOTE (2).xlsx', 1, 'MEETS_REQUIREMENTS', NULL, '2026-03-18 09:02:07'),
(66, 69, 676126.19, 'JMD', NULL, 88190.37, 30, '1774880270_AJL - MOH (Government Chemist) Estimate on APC SRT 5KVA UPS System (1).pdf', 1, 'MEETS_REQUIREMENTS', NULL, '2026-03-30 09:17:50'),
(67, 69, 676126.19, 'JMD', NULL, 88190.37, 30, '1774880273_AJL - MOH (Government Chemist) Estimate on APC SRT 5KVA UPS System (1).pdf', 0, 'PENDING', NULL, '2026-03-30 09:17:53'),
(68, 75, 184995.79, 'JMD', NULL, 24129.89, 30, '1777311319_Proforma Invoice -  KINGSTON RAM (2) (2).xlsx', 1, 'MEETS_REQUIREMENTS', NULL, '2026-04-27 12:35:19'),
(69, 80, 40159.23, 'JMD', NULL, 5238.16, 30, '1777933316_Quotation - S06064.pdf', 0, 'PENDING', NULL, '2026-05-04 17:21:56'),
(70, 79, 93768.11, 'JMD', NULL, 12230.62, 30, '1777933370_Proforma Invoice -  DELL SATA  (1).xlsx', 0, 'PENDING', NULL, '2026-05-04 17:22:50'),
(71, 78, 40159.23, 'JMD', NULL, 5238.16, 30, '1777933416_QT-000052.pdf', 0, 'PENDING', NULL, '2026-05-04 17:23:36'),
(72, 80, 29785.00, 'JMD', NULL, 3885.00, 30, '1777933472_Quotation - S06064.pdf', 1, 'MEETS_REQUIREMENTS', NULL, '2026-05-04 17:24:32'),
(73, 80, 29785.00, 'JMD', NULL, 3885.00, 30, '1777933476_Quotation - S06064.pdf', 0, 'PENDING', NULL, '2026-05-04 17:24:36'),
(74, 76, 199369.36, 'JMD', NULL, 24393.83, 30, '1777991005_QT-000054.pdf', 0, 'PENDING', NULL, '2026-05-05 09:23:25'),
(75, 76, 199369.36, 'JMD', NULL, 24393.83, 30, '1777991006_QT-000054.pdf', 0, 'PENDING', NULL, '2026-05-05 09:23:26'),
(76, 76, 199369.36, 'JMD', NULL, 24393.83, 30, '1777991006_QT-000054.pdf', 0, 'PENDING', NULL, '2026-05-05 09:23:26'),
(77, 76, 199369.36, 'JMD', NULL, 24393.83, 30, '1777991007_QT-000054.pdf', 0, 'PENDING', NULL, '2026-05-05 09:23:27'),
(78, 76, 199369.36, 'JMD', NULL, 24393.83, 30, '1777991009_QT-000054.pdf', 0, 'PENDING', NULL, '2026-05-05 09:23:29'),
(79, 82, 114802.20, 'JMD', NULL, 14974.20, 30, '1778012929_quote#-18088-Gov Chem.pdf', 0, 'PENDING', NULL, '2026-05-05 15:28:49'),
(80, 81, 323033.85, 'JMD', NULL, 42134.85, 30, '1778014042_quote#-18087-Gov Chem.pdf', 0, 'PENDING', NULL, '2026-05-05 15:47:22'),
(81, 83, 105344.00, 'JMD', NULL, 15081.60, 30, '1778016593_Quotation - S06256.pdf', 1, 'MEETS_REQUIREMENTS', NULL, '2026-05-05 16:29:53'),
(82, 83, 105344.00, 'JMD', NULL, 15081.60, 30, '1778016595_Quotation - S06256.pdf', 0, 'PENDING', NULL, '2026-05-05 16:29:55'),
(83, 84, 299000.00, 'JMD', NULL, 39000.00, 30, '1778076483_No.35431.26 Government Chemist.xls', 0, 'PENDING', NULL, '2026-05-06 09:08:03'),
(84, 85, 187493.07, 'JMD', NULL, 24351.27, 30, '1778596068_QT-000057.pdf', 0, 'PENDING', NULL, '2026-05-12 09:27:48'),
(85, 86, 181438.95, 'JMD', NULL, 23665.95, 30, '1778596163_Quotation - S06329 (1).pdf', 0, 'PENDING', NULL, '2026-05-12 09:29:23');

-- --------------------------------------------------------

--
-- Table structure for table `rfq_scores`
--

CREATE TABLE IF NOT EXISTS `rfq_scores` (
  `score_id` int(11) NOT NULL,
  `rfq_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rfq_vendor_id` int(11) DEFAULT NULL,
  `technical_score` decimal(5,2) DEFAULT NULL,
  `financial_score` decimal(5,2) DEFAULT NULL,
  `total_score` decimal(5,2) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rfq_vendors`
--

CREATE TABLE IF NOT EXISTS `rfq_vendors` (
  `rfq_vendor_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `vendor_name` varchar(150) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `response_status` enum('PENDING','WILL_SUBMIT','DECLINED','SUBMITTED','SELECTED') DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rfq_vendors`
--

INSERT IGNORE INTO `rfq_vendors` (`rfq_vendor_id`, `rfq_id`, `vendor_id`, `vendor_name`, `email`, `response_status`, `created_at`) VALUES
(69, 28, 2, '', NULL, 'SUBMITTED', '2026-03-17 19:13:46'),
(72, 27, 9, '', NULL, 'SUBMITTED', '2026-03-18 13:48:42'),
(75, 29, 9, '', NULL, 'SUBMITTED', '2026-04-27 17:34:39'),
(76, 31, 7, '', NULL, 'SUBMITTED', '2026-05-04 22:09:19'),
(78, 33, 7, '', NULL, 'SUBMITTED', '2026-05-04 22:17:39'),
(79, 33, 9, '', NULL, 'SUBMITTED', '2026-05-04 22:17:51'),
(80, 33, 12, '', NULL, 'SUBMITTED', '2026-05-04 22:18:57'),
(81, 34, 10, '', NULL, 'SUBMITTED', '2026-05-05 18:43:26'),
(82, 30, 10, '', NULL, 'SUBMITTED', '2026-05-05 20:26:45'),
(83, 35, 12, '', NULL, 'SUBMITTED', '2026-05-05 21:28:31'),
(84, 34, 11, '', NULL, 'SUBMITTED', '2026-05-06 14:07:33'),
(85, 32, 7, '', NULL, 'SUBMITTED', '2026-05-11 15:49:34'),
(86, 32, 12, '', NULL, 'SUBMITTED', '2026-05-11 15:50:19');

-- --------------------------------------------------------

--
-- Table structure for table `rfq_votes`
--

CREATE TABLE IF NOT EXISTS `rfq_votes` (
  `vote_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rfq_vendor_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE IF NOT EXISTS `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT IGNORE INTO `roles` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'Viewer', 'Read only access', '2026-02-13 00:41:03'),
(2, 'Procurement Officer', 'Handles procurement operations', '2026-02-13 00:41:03'),
(3, 'Finance Officer', 'Handles financial approvals', '2026-02-13 00:41:03'),
(4, 'HOD', 'Head of Department approval authority', '2026-02-13 00:41:03'),
(5, 'Admin', 'System administrator', '2026-02-13 00:41:03'),
(6, 'SuperAdmin', 'Full system control', '2026-02-13 00:41:03'),
(7, 'Evaluation Committee Member', 'Participates in RFQ evaluation', '2026-02-14 18:20:06'),
(8, 'Procurement Committee', 'Procurement recommendation authority', '2026-02-14 18:20:06'),
(9, 'Deputy Government Chemist', 'Final approving authority', '2026-02-14 18:20:06'),
(10, 'Director HRM&A', 'Director of Human Resource Management and Administration', '2026-02-17 02:30:11'),
(11, 'Director Procurement', 'Director of Procurement Operations', '2026-02-17 02:30:11'),
(12, 'Requestor', 'Employee submitting procurement requests', '2026-02-17 02:30:11');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`) VALUES
(2, 1),
(5, 1),
(6, 1),
(12, 1),
(2, 2),
(5, 2),
(6, 2),
(12, 2),
(3, 3),
(4, 3),
(5, 3),
(6, 3),
(8, 3),
(9, 3),
(10, 3),
(11, 3),
(2, 4),
(3, 4),
(5, 4),
(6, 4),
(3, 5),
(4, 5),
(5, 5),
(6, 5),
(9, 5),
(10, 5),
(11, 5),
(2, 6),
(5, 6),
(6, 6),
(3, 7),
(4, 7),
(5, 7),
(6, 7),
(11, 7),
(3, 8),
(5, 8),
(6, 8),
(3, 9),
(5, 9),
(6, 9),
(5, 10),
(6, 10),
(1, 11),
(2, 11),
(3, 11),
(4, 11),
(5, 11),
(6, 11),
(7, 11),
(8, 11),
(9, 11),
(10, 11),
(11, 11),
(1, 12),
(2, 12),
(3, 12),
(4, 12),
(5, 12),
(6, 12),
(7, 12),
(8, 12),
(9, 12),
(10, 12),
(11, 12),
(12, 12),
(3, 13),
(4, 13),
(5, 13),
(6, 13),
(9, 13),
(10, 13),
(11, 13),
(4, 14),
(5, 14),
(6, 14),
(9, 14),
(10, 14),
(11, 14),
(3, 15),
(4, 15),
(5, 15),
(6, 15),
(9, 15),
(10, 15),
(11, 15),
(2, 16),
(4, 16),
(5, 16),
(6, 16),
(11, 16),
(1, 17),
(5, 17),
(6, 17),
(3, 18),
(5, 18),
(6, 18),
(1, 19),
(2, 19),
(3, 19),
(4, 19),
(5, 19),
(6, 19),
(9, 19),
(10, 19),
(11, 19),
(3, 20),
(5, 20),
(6, 20),
(1, 21),
(2, 21),
(3, 21),
(4, 21),
(5, 21),
(6, 21),
(9, 21),
(10, 21),
(11, 21),
(2, 22),
(5, 22),
(6, 22),
(2, 23),
(5, 23),
(6, 23),
(1, 24),
(2, 24),
(3, 24),
(4, 24),
(5, 24),
(6, 24),
(7, 24),
(8, 24),
(9, 24),
(10, 24),
(11, 24),
(3, 25),
(4, 25),
(5, 25),
(6, 25),
(11, 25),
(1, 26),
(2, 26),
(3, 26),
(4, 26),
(5, 26),
(6, 26),
(7, 26),
(8, 26),
(9, 26),
(10, 26),
(11, 26),
(3, 27),
(4, 27),
(5, 27),
(6, 27),
(11, 27),
(3, 28),
(5, 28),
(6, 28),
(2, 29),
(5, 29),
(6, 29),
(2, 31),
(5, 31),
(6, 31),
(2, 32),
(3, 32),
(4, 32),
(5, 32),
(6, 32),
(9, 32),
(10, 32),
(11, 32),
(2, 33),
(3, 33),
(4, 33),
(5, 33),
(6, 33),
(8, 33),
(9, 33),
(10, 33),
(11, 33),
(12, 33),
(2, 45),
(5, 45),
(6, 45),
(12, 45),
(6, 46),
(4, 47),
(5, 47),
(6, 47),
(9, 47),
(10, 47),
(11, 47),
(5, 48),
(6, 48),
(9, 48),
(4, 49),
(5, 49),
(6, 49),
(9, 49),
(10, 49),
(11, 49),
(3, 50),
(4, 50),
(5, 50),
(6, 50),
(9, 50),
(10, 50),
(11, 50),
(3, 51),
(4, 51),
(5, 51),
(6, 51),
(9, 51),
(10, 51),
(11, 51),
(3, 52),
(4, 52),
(5, 52),
(6, 52),
(9, 52),
(10, 52),
(11, 52),
(5, 54),
(6, 54),
(12, 54),
(5, 55),
(6, 55),
(5, 56),
(6, 56),
(10, 56),
(4, 57),
(5, 57),
(6, 57),
(9, 57),
(10, 57),
(11, 57),
(3, 58),
(4, 58),
(5, 58),
(6, 58),
(3, 59),
(4, 59),
(5, 59),
(6, 59),
(2, 60),
(5, 60),
(6, 60),
(12, 60),
(2, 61),
(5, 61),
(6, 61),
(12, 61),
(5, 62),
(6, 62),
(1, 102),
(3, 102),
(4, 102),
(5, 102),
(6, 102),
(9, 102),
(10, 102),
(11, 102),
(1, 103),
(3, 103),
(4, 103),
(5, 103),
(6, 103),
(9, 103),
(10, 103),
(11, 103),
(6, 104),
(12, 104),
(6, 105),
(12, 105),
(4, 106),
(5, 106),
(6, 106),
(10, 106),
(4, 107),
(5, 107),
(6, 107),
(10, 107),
(2, 108),
(3, 108),
(5, 108),
(6, 108),
(2, 109),
(5, 109),
(6, 109),
(2, 110),
(5, 110),
(6, 110),
(2, 111),
(3, 111),
(4, 111),
(5, 111),
(6, 111),
(10, 111),
(2, 112),
(3, 112),
(4, 112),
(5, 112),
(6, 112),
(10, 112),
(3, 113),
(5, 113),
(6, 113),
(1, 114),
(2, 114),
(3, 114),
(4, 114),
(5, 114),
(6, 114),
(7, 114),
(8, 114),
(9, 114),
(10, 114),
(11, 114),
(5, 115),
(6, 115),
(7, 115),
(2, 116),
(5, 116),
(6, 116),
(11, 116),
(2, 117),
(4, 117),
(5, 117),
(6, 117),
(8, 117),
(9, 117),
(10, 117),
(11, 117),
(2, 118),
(5, 118),
(6, 118),
(11, 118),
(2, 119),
(5, 119),
(6, 119),
(11, 119),
(3, 120),
(4, 120),
(5, 120),
(6, 120),
(9, 120),
(10, 120),
(11, 120),
(5, 121),
(6, 121),
(11, 121),
(3, 169),
(5, 169),
(6, 169),
(2, 170),
(4, 170),
(5, 170),
(6, 170),
(8, 170),
(9, 170),
(10, 170),
(11, 170),
(4, 171),
(5, 171),
(6, 171),
(8, 171),
(9, 171),
(10, 171),
(11, 171),
(2, 172),
(5, 172),
(6, 172),
(2, 173),
(5, 173),
(6, 173),
(11, 173),
(2, 174),
(5, 174),
(6, 174),
(7, 174),
(11, 174),
(2, 175),
(5, 175),
(6, 175),
(11, 175),
(2, 176),
(5, 176),
(6, 176),
(11, 176),
(1, 177),
(2, 177),
(3, 177),
(4, 177),
(5, 177),
(6, 177),
(7, 177),
(8, 177),
(9, 177),
(10, 177),
(11, 177),
(12, 177),
(6, 178),
(9, 178),
(3, 179),
(5, 179),
(6, 179),
(3, 180),
(5, 180),
(6, 180);

-- --------------------------------------------------------

--
-- Table structure for table `system_alerts`
--

CREATE TABLE IF NOT EXISTS `system_alerts` (
  `alert_id` int(11) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `alert_type` varchar(100) DEFAULT NULL,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `resolved` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_config`
--

CREATE TABLE IF NOT EXISTS `system_config` (
  `config_id` int(11) NOT NULL,
  `config_key` varchar(100) NOT NULL,
  `config_value` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System configuration parameters';

--
-- Dumping data for table `system_config`
--

INSERT IGNORE INTO `system_config` (`config_id`, `config_key`, `config_value`, `description`, `created_at`, `updated_at`) VALUES
(1, 'petty_cash_limit', '5000', 'Maximum amount for petty cash procurement without formal approval (JMD)', '2026-02-17 02:30:11', '2026-02-18 00:00:42'),
(2, 'direct_procurement_threshold', '3000000', 'Threshold value for direct procurement eligibility (JMD)', '2026-02-17 02:30:11', '2026-03-17 10:53:51'),
(7, 'enable_notifications', '1', 'Enable/disable email notifications (1=enabled, 0=disabled)', '2026-02-17 21:32:44', '2026-02-26 10:02:41'),
(19, 'usd_to_jmd_rate', '155.22', 'Current USD to JMD exchange rate for currency conversion', '2026-02-24 01:17:49', '2026-02-25 21:18:00'),
(41, 'hod_approval_threshold', '500000', 'Procurement requests above this amount require HOD approval (JMD)', '2026-03-17 10:53:51', '2026-03-17 16:25:58'),
(42, 'committee_review_threshold', '3000000', 'Procurement requests above this amount require committee review (JMD)', '2026-03-17 10:53:51', '2026-03-17 16:25:58');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role_id` int(11) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `must_change_password` tinyint(1) DEFAULT 1,
  `password_changed_at` datetime DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT 0,
  `lock_until` datetime DEFAULT NULL,
  `reset_token_hash` varchar(255) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT IGNORE INTO `users` (`user_id`, `full_name`, `email`, `role_id`, `password_hash`, `is_active`, `created_at`, `must_change_password`, `password_changed_at`, `failed_attempts`, `lock_until`, `reset_token_hash`, `reset_token_expires`) VALUES
(27, 'Technical & User Support Officer', 'Demario.Ewan@moh.gov.jm', 6, '$2y$10$genzJdfdKkzU5Jqg3LKeyeaUXPCr6BEjmPouYjbl9FUDqJFdsAS7i', 1, '2026-02-25 15:05:24', 0, '2026-02-25 10:07:13', 0, NULL, NULL, NULL),
(30, 'Demario Ewan', 'demarioe14@gmail.com', 6, '$2y$10$ElFPjESZG3kHeBMgT4ALtuysNO3h3MgxH/CZf0A3EwiVOe2Fo7UFS', 1, '2026-02-26 15:14:04', 0, '2026-02-26 10:17:55', 0, NULL, NULL, NULL),
(32, 'Yanique A. Fraser', 'yanique.fraser@moh.gov.jm', 4, '$2y$10$X/nzfCVshLBMuNGdeDFDT.CzBjxewEUzS02L8KAyTXiT53qG0eqcC', 1, '2026-02-26 15:28:16', 0, '2026-02-26 10:37:45', 0, NULL, NULL, NULL),
(33, 'Daneika Anderson', 'Daneika.Anderson@moh.gov.jm', 9, '$2y$10$2A5G.tgoFure8koXQnu8peMl.7RfmFxQ5MMx6TuutQucFOi4MlBt6', 1, '2026-02-26 15:29:16', 0, '2026-02-26 11:01:58', 0, NULL, NULL, NULL),
(34, 'Latoya Gayle', 'Latoya.Gayle@moh.gov.jm', 3, '$2y$10$JKmsjcSWwv4objXFXCjnzOfAIGG8LrbBTiBEzSaiXaeIp7RccKKZK', 1, '2026-02-26 15:29:48', 0, '2026-03-04 09:53:22', 0, NULL, NULL, NULL),
(35, 'Nellesha Samuels', 'Nellesha.Samuels@moh.gov.jm', 10, '$2y$10$QUMu2jnAN3f52X8M3B/OeOvlcVvgCmzkm23Ej4myoHWoBcrYJf/am', 1, '2026-02-26 15:30:15', 0, '2026-03-04 09:59:46', 0, NULL, NULL, NULL),
(36, 'Ryan Warburton', 'Ryan.Warburton@moh.gov.jm', 12, '$2y$10$PKQcRwWLT5v9G.9rEc9JqO9fnPleVqhd9qJLVJo2dySMCgGBCJKgK', 1, '2026-02-26 15:30:42', 0, '2026-02-26 11:12:42', 0, NULL, NULL, NULL),
(37, 'Shermaine McKenzie', 'Shermaine.McKenzie@moh.gov.jm', 12, '$2y$10$Mwx0A2LeS/8.ybVWoMQaBO/0TR6C3EazvOaujX4t5O1rrVaLrftoy', 1, '2026-02-26 15:31:09', 0, '2026-02-26 10:52:01', 0, NULL, NULL, NULL),
(38, 'Waveney Warrick', 'Waveney.Warrick@moh.gov.jm', 12, '$2y$10$8Q/iPFz5x.13NbJrYg08BeNvu8CtafdCxAxJKqGOVDfle.qd7NG5y', 1, '2026-02-26 15:31:30', 0, '2026-02-26 11:00:39', 0, NULL, NULL, NULL),
(39, 'Sancia Johnally Haynes', 'Sancia.Johnally-Haynes@moh.gov.jm', 12, '$2y$10$uEV/WQl0fMHBCesu26vvJOcWMwJlwFvRnDhNJLVp5wQ6/nuAZoKxO', 1, '2026-02-26 15:32:07', 0, '2026-03-04 15:10:33', 0, NULL, NULL, NULL),
(40, 'Alfred Bryan', 'Alfred.Bryan@moh.gov.jm', 12, '$2y$10$AmmaNjQz8dQXGyipklEy6.BCa5qUC9vjiwLyZd4mJx77U2mOrZhIq', 1, '2026-02-26 15:32:30', 0, '2026-03-06 12:12:33', 0, NULL, NULL, NULL),
(41, 'Fredricka Chung', 'Fredricka.Chung@moh.gov.jm', 12, '$2y$10$rB/iA9zKLWZOLivDI1efIOyOXQRW1hVsZDnXU.3MRuSXmXiIr4vLe', 1, '2026-02-26 15:33:18', 0, '2026-02-26 11:15:58', 0, NULL, NULL, NULL),
(42, 'Yanique McKenzie', 'Yanique.McKenzie@moh.gov.jm', 2, '$2y$10$jIxD5ymo7QezPDzq7xFOsO.yeoyUfOUWo5QoQG1lWvigK4L9uPefm', 1, '2026-02-26 15:33:44', 0, '2026-04-07 09:50:15', 0, NULL, NULL, NULL),
(43, 'Shenai McFarlane', 'Shenai.McFarlane@moh.gov.jm', 12, '$2y$10$F3ZoG92jf9GQSdj8TKtR8ey4f8uTEe.mTkh2tvaOtIlsso6t2mZhK', 1, '2026-02-26 15:34:07', 1, NULL, 0, NULL, NULL, NULL),
(44, 'Gabrielle Green', 'Gabrielle.Green@moh.gov.jm', 2, '$2y$10$WQ8rgucFRH/gztETMZjUbOPZj/W8jOtujyoj6mWRC9YyERwzVkxCK', 1, '2026-02-26 15:34:42', 0, '2026-02-26 11:05:55', 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE IF NOT EXISTS `user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `is_granted` tinyint(1) NOT NULL DEFAULT 1,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_permissions`
--

INSERT IGNORE INTO `user_permissions` (`id`, `user_id`, `permission_id`, `is_granted`, `expires_at`, `created_at`) VALUES
(97, 9, 5, 1, NULL, '2026-02-14 02:24:18'),
(98, 9, 7, 1, NULL, '2026-02-14 02:24:18'),
(99, 9, 25, 1, '2026-02-16 12:33:00', '2026-02-14 02:24:18'),
(100, 9, 28, 1, NULL, '2026-02-14 02:24:18'),
(101, 9, 27, 1, NULL, '2026-02-14 02:24:18'),
(102, 9, 3, 1, NULL, '2026-02-14 02:24:18'),
(103, 9, 4, 1, NULL, '2026-02-14 02:24:18'),
(104, 9, 18, 0, NULL, '2026-02-14 02:24:18'),
(105, 9, 20, 0, NULL, '2026-02-14 02:24:18'),
(106, 9, 6, 1, NULL, '2026-02-14 02:24:18'),
(107, 9, 22, 1, NULL, '2026-02-14 02:24:18'),
(108, 9, 1, 1, NULL, '2026-02-14 02:24:18'),
(109, 9, 29, 1, NULL, '2026-02-14 02:24:18'),
(110, 9, 10, 0, NULL, '2026-02-14 02:24:18'),
(111, 9, 32, 0, NULL, '2026-02-14 02:24:18'),
(112, 9, 33, 1, NULL, '2026-02-14 02:24:18'),
(113, 9, 8, 0, NULL, '2026-02-14 02:24:18'),
(114, 9, 9, 0, NULL, '2026-02-14 02:24:18'),
(115, 9, 23, 1, NULL, '2026-02-14 02:24:18'),
(116, 9, 2, 1, NULL, '2026-02-14 02:24:18'),
(117, 9, 17, 0, NULL, '2026-02-14 02:24:18'),
(118, 9, 26, 1, NULL, '2026-02-14 02:24:18'),
(119, 9, 11, 1, NULL, '2026-02-14 02:24:18'),
(120, 9, 13, 1, NULL, '2026-02-14 02:24:18'),
(121, 9, 19, 0, NULL, '2026-02-14 02:24:18'),
(122, 9, 14, 0, NULL, '2026-02-14 02:24:18'),
(123, 9, 15, 0, NULL, '2026-02-14 02:24:18'),
(124, 9, 21, 0, NULL, '2026-02-14 02:24:18'),
(125, 9, 31, 0, NULL, '2026-02-14 02:24:18'),
(126, 9, 16, 1, NULL, '2026-02-14 02:24:18'),
(127, 9, 24, 1, NULL, '2026-02-14 02:24:18'),
(128, 9, 12, 1, NULL, '2026-02-14 02:24:18'),
(166, 16, 24, 1, NULL, '2026-02-14 19:49:04'),
(167, 16, 12, 1, NULL, '2026-02-14 19:49:04'),
(168, 16, 1, 1, NULL, '2026-02-14 21:33:10'),
(203, 18, 12, 1, '2026-02-27 12:00:00', '2026-02-15 00:15:28'),
(281, 9, 45, 1, NULL, '2026-02-16 02:24:00'),
(334, 17, 46, 1, NULL, '2026-02-16 02:40:35'),
(336, 17, 12, 1, NULL, '2026-02-16 02:41:25'),
(337, 19, 12, 1, NULL, '2026-02-16 02:45:39'),
(338, 21, 12, 1, NULL, '2026-02-16 02:55:59'),
(339, 21, 1, 1, NULL, '2026-02-16 03:06:45'),
(341, 22, 28, 1, NULL, '2026-02-16 18:54:24'),
(342, 22, 4, 1, NULL, '2026-02-16 18:54:24'),
(343, 22, 45, 1, NULL, '2026-02-16 18:54:24'),
(344, 22, 10, 1, NULL, '2026-02-16 18:54:24'),
(345, 22, 8, 1, NULL, '2026-02-16 18:54:24'),
(346, 22, 9, 1, NULL, '2026-02-16 18:54:24'),
(347, 22, 23, 1, NULL, '2026-02-16 18:54:24'),
(348, 22, 2, 1, NULL, '2026-02-16 18:54:24'),
(349, 22, 17, 1, NULL, '2026-02-16 18:54:24'),
(350, 22, 48, 1, NULL, '2026-02-16 18:54:24'),
(351, 22, 46, 1, NULL, '2026-02-16 18:54:24'),
(352, 22, 31, 1, NULL, '2026-02-16 18:54:24'),
(354, 21, 45, 1, NULL, '2026-02-16 19:00:29'),
(359, 4, 55, 1, NULL, '2026-02-17 21:31:13'),
(360, 18, 56, 1, NULL, '2026-02-17 23:43:25'),
(363, 18, 3, 1, NULL, '2026-02-17 23:45:47'),
(365, 6, 108, 1, NULL, '2026-02-18 15:06:42'),
(366, 6, 109, 1, NULL, '2026-02-18 15:06:42'),
(368, 16, 56, 1, NULL, '2026-02-19 19:49:57'),
(369, 16, 5, 1, NULL, '2026-02-19 19:49:57'),
(370, 16, 59, 1, NULL, '2026-02-19 19:49:57'),
(371, 16, 7, 1, NULL, '2026-02-19 19:49:57'),
(372, 16, 25, 1, NULL, '2026-02-19 19:49:57'),
(373, 16, 28, 1, NULL, '2026-02-19 19:49:57'),
(374, 16, 27, 1, NULL, '2026-02-19 19:49:57'),
(375, 16, 58, 1, NULL, '2026-02-19 19:49:57'),
(376, 16, 3, 1, NULL, '2026-02-19 19:49:57'),
(377, 16, 62, 1, NULL, '2026-02-19 19:49:57'),
(378, 16, 107, 1, NULL, '2026-02-19 19:49:57'),
(379, 16, 106, 1, NULL, '2026-02-19 19:49:57'),
(380, 16, 117, 1, NULL, '2026-02-19 19:49:57'),
(381, 16, 4, 1, NULL, '2026-02-19 19:49:57'),
(382, 16, 18, 1, NULL, '2026-02-19 19:49:57'),
(383, 16, 20, 1, NULL, '2026-02-19 19:49:57'),
(384, 16, 61, 1, NULL, '2026-02-19 19:49:57'),
(385, 16, 6, 1, NULL, '2026-02-19 19:49:57'),
(386, 16, 22, 1, NULL, '2026-02-19 19:49:57'),
(387, 16, 60, 1, NULL, '2026-02-19 19:49:57'),
(389, 16, 57, 1, NULL, '2026-02-19 19:49:57'),
(390, 16, 29, 1, NULL, '2026-02-19 19:49:57'),
(391, 16, 45, 1, NULL, '2026-02-19 19:49:57'),
(392, 16, 120, 1, NULL, '2026-02-19 19:49:57'),
(393, 16, 110, 1, NULL, '2026-02-19 19:49:57'),
(394, 16, 116, 1, NULL, '2026-02-19 19:49:57'),
(395, 16, 55, 1, NULL, '2026-02-19 19:49:57'),
(396, 16, 10, 1, NULL, '2026-02-19 19:49:57'),
(397, 16, 118, 1, NULL, '2026-02-19 19:49:57'),
(398, 16, 49, 1, NULL, '2026-02-19 19:49:57'),
(399, 16, 50, 1, NULL, '2026-02-19 19:49:57'),
(400, 16, 52, 1, NULL, '2026-02-19 19:49:57'),
(401, 16, 32, 1, NULL, '2026-02-19 19:49:57'),
(402, 16, 33, 1, NULL, '2026-02-19 19:49:57'),
(403, 16, 113, 1, NULL, '2026-02-19 19:49:57'),
(404, 16, 8, 1, NULL, '2026-02-19 19:49:57'),
(405, 16, 9, 1, NULL, '2026-02-19 19:49:57'),
(406, 16, 23, 1, NULL, '2026-02-19 19:49:57'),
(407, 16, 105, 1, NULL, '2026-02-19 19:49:57'),
(408, 16, 104, 1, NULL, '2026-02-19 19:49:57'),
(409, 16, 2, 1, NULL, '2026-02-19 19:49:57'),
(410, 16, 108, 1, NULL, '2026-02-19 19:49:57'),
(411, 16, 109, 1, NULL, '2026-02-19 19:49:57'),
(412, 16, 112, 1, NULL, '2026-02-19 19:49:57'),
(413, 16, 111, 1, NULL, '2026-02-19 19:49:57'),
(414, 16, 47, 1, NULL, '2026-02-19 19:49:57'),
(415, 16, 17, 1, NULL, '2026-02-19 19:49:57'),
(416, 16, 26, 1, NULL, '2026-02-19 19:49:57'),
(417, 16, 11, 1, NULL, '2026-02-19 19:49:57'),
(418, 16, 48, 1, NULL, '2026-02-19 19:49:57'),
(419, 16, 121, 1, NULL, '2026-02-19 19:49:57'),
(420, 16, 46, 1, NULL, '2026-02-19 19:49:57'),
(421, 16, 13, 1, NULL, '2026-02-19 19:49:57'),
(422, 16, 51, 1, NULL, '2026-02-19 19:49:57'),
(423, 16, 19, 1, NULL, '2026-02-19 19:49:57'),
(424, 16, 14, 1, NULL, '2026-02-19 19:49:57'),
(425, 16, 15, 1, NULL, '2026-02-19 19:49:57'),
(426, 16, 54, 1, NULL, '2026-02-19 19:49:57'),
(427, 16, 21, 1, NULL, '2026-02-19 19:49:57'),
(428, 16, 103, 1, NULL, '2026-02-19 19:49:57'),
(429, 16, 31, 1, NULL, '2026-02-19 19:49:57'),
(430, 16, 16, 1, NULL, '2026-02-19 19:49:57'),
(432, 16, 102, 1, NULL, '2026-02-19 19:49:57'),
(434, 16, 114, 1, NULL, '2026-02-19 19:49:57'),
(435, 16, 119, 1, NULL, '2026-02-19 19:49:57'),
(436, 16, 115, 1, NULL, '2026-02-19 19:49:57'),
(437, 4, 56, 1, NULL, '2026-02-19 19:59:08'),
(438, 4, 5, 1, NULL, '2026-02-19 19:59:08'),
(439, 4, 59, 1, NULL, '2026-02-19 19:59:08'),
(440, 4, 7, 1, NULL, '2026-02-19 19:59:08'),
(441, 4, 25, 1, NULL, '2026-02-19 19:59:08'),
(442, 4, 28, 1, NULL, '2026-02-19 19:59:08'),
(443, 4, 27, 1, NULL, '2026-02-19 19:59:08'),
(444, 4, 58, 1, NULL, '2026-02-19 19:59:08'),
(445, 4, 3, 1, NULL, '2026-02-19 19:59:08'),
(446, 4, 62, 1, NULL, '2026-02-19 19:59:08'),
(447, 4, 107, 1, NULL, '2026-02-19 19:59:08'),
(448, 4, 106, 1, NULL, '2026-02-19 19:59:08'),
(449, 4, 117, 1, NULL, '2026-02-19 19:59:08'),
(450, 4, 4, 1, NULL, '2026-02-19 19:59:08'),
(451, 4, 18, 1, NULL, '2026-02-19 19:59:08'),
(452, 4, 20, 1, NULL, '2026-02-19 19:59:08'),
(453, 4, 61, 1, NULL, '2026-02-19 19:59:08'),
(454, 4, 6, 1, NULL, '2026-02-19 19:59:08'),
(455, 4, 22, 1, NULL, '2026-02-19 19:59:08'),
(456, 4, 60, 1, NULL, '2026-02-19 19:59:08'),
(457, 4, 1, 1, NULL, '2026-02-19 19:59:08'),
(458, 4, 57, 1, NULL, '2026-02-19 19:59:08'),
(459, 4, 29, 1, NULL, '2026-02-19 19:59:08'),
(460, 4, 45, 1, NULL, '2026-02-19 19:59:08'),
(461, 4, 120, 1, NULL, '2026-02-19 19:59:08'),
(462, 4, 110, 1, NULL, '2026-02-19 19:59:08'),
(463, 4, 116, 1, NULL, '2026-02-19 19:59:08'),
(465, 4, 10, 1, NULL, '2026-02-19 19:59:08'),
(466, 4, 118, 1, NULL, '2026-02-19 19:59:08'),
(467, 4, 49, 1, NULL, '2026-02-19 19:59:08'),
(468, 4, 50, 1, NULL, '2026-02-19 19:59:08'),
(469, 4, 52, 1, NULL, '2026-02-19 19:59:08'),
(470, 4, 32, 1, NULL, '2026-02-19 19:59:08'),
(471, 4, 33, 1, NULL, '2026-02-19 19:59:08'),
(472, 4, 113, 1, NULL, '2026-02-19 19:59:08'),
(473, 4, 8, 1, NULL, '2026-02-19 19:59:08'),
(474, 4, 9, 1, NULL, '2026-02-19 19:59:08'),
(475, 4, 23, 1, NULL, '2026-02-19 19:59:08'),
(476, 4, 105, 1, NULL, '2026-02-19 19:59:08'),
(477, 4, 104, 1, NULL, '2026-02-19 19:59:08'),
(478, 4, 2, 1, NULL, '2026-02-19 19:59:08'),
(479, 4, 108, 1, NULL, '2026-02-19 19:59:08'),
(480, 4, 109, 1, NULL, '2026-02-19 19:59:08'),
(481, 4, 112, 1, NULL, '2026-02-19 19:59:08'),
(482, 4, 111, 1, NULL, '2026-02-19 19:59:08'),
(483, 4, 47, 1, NULL, '2026-02-19 19:59:08'),
(484, 4, 17, 1, NULL, '2026-02-19 19:59:08'),
(485, 4, 26, 1, NULL, '2026-02-19 19:59:08'),
(486, 4, 11, 1, NULL, '2026-02-19 19:59:08'),
(487, 4, 48, 1, NULL, '2026-02-19 19:59:08'),
(488, 4, 121, 1, NULL, '2026-02-19 19:59:08'),
(489, 4, 46, 1, NULL, '2026-02-19 19:59:08'),
(490, 4, 13, 1, NULL, '2026-02-19 19:59:08'),
(491, 4, 51, 1, NULL, '2026-02-19 19:59:08'),
(492, 4, 19, 1, NULL, '2026-02-19 19:59:08'),
(493, 4, 14, 1, NULL, '2026-02-19 19:59:08'),
(494, 4, 15, 1, NULL, '2026-02-19 19:59:08'),
(495, 4, 54, 1, NULL, '2026-02-19 19:59:08'),
(496, 4, 21, 1, NULL, '2026-02-19 19:59:08'),
(497, 4, 103, 1, NULL, '2026-02-19 19:59:08'),
(498, 4, 31, 1, NULL, '2026-02-19 19:59:08'),
(499, 4, 16, 1, NULL, '2026-02-19 19:59:08'),
(500, 4, 24, 1, NULL, '2026-02-19 19:59:08'),
(501, 4, 102, 1, NULL, '2026-02-19 19:59:08'),
(502, 4, 12, 1, NULL, '2026-02-19 19:59:08'),
(503, 4, 114, 1, NULL, '2026-02-19 19:59:08'),
(504, 4, 119, 1, NULL, '2026-02-19 19:59:08'),
(505, 4, 115, 1, NULL, '2026-02-19 19:59:08'),
(518, 9, 175, 1, NULL, '2026-02-22 10:20:54'),
(540, 32, 60, 1, NULL, '2026-03-04 09:45:15'),
(541, 34, 107, 1, NULL, '2026-03-04 09:56:40'),
(542, 34, 106, 1, NULL, '2026-03-04 09:56:40'),
(543, 39, 103, 1, NULL, '2026-03-17 15:05:21'),
(544, 37, 102, 1, NULL, '2026-04-17 11:47:11');

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE IF NOT EXISTS `vendors` (
  `vendor_id` int(11) NOT NULL,
  `vendor_name` varchar(150) NOT NULL,
  `contact_person` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `status` enum('ACTIVE','BLACKLISTED') DEFAULT 'ACTIVE',
  `performance_rating` decimal(3,2) DEFAULT NULL,
  `total_awards` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendors`
--

INSERT IGNORE INTO `vendors` (`vendor_id`, `vendor_name`, `contact_person`, `email`, `phone`, `address`, `status`, `performance_rating`, `total_awards`, `created_at`) VALUES
(1, 'Printers & Office Supplies Limited', '876-868-0934', 'psltd@printersofficesupplies.com', '876-123-8790', 'Kingston\r\nJamaica', 'ACTIVE', NULL, 3, '2026-02-14 15:52:41'),
(2, 'Accu Power Limited', '876-235-4053', 'accu@accupower.com', '876-235-4053', 'Kingston \r\nJamaica', '', NULL, 3, '2026-02-14 16:09:11'),
(4, 'MC System', 'Roget Hall', 'roget.hall@mcsystems.com', '', '', 'ACTIVE', NULL, 0, '2026-03-17 16:56:32'),
(5, 'Advanced Integrated System', 'Richard Hutchinson', 'richard.hutchinson@aiswebnet.com', '', '', 'ACTIVE', NULL, 0, '2026-03-17 17:14:52'),
(6, 'Printware', '', 'Ashley@printwareonline.com', '', '', 'ACTIVE', NULL, 0, '2026-03-17 17:16:54'),
(7, 'D&S IT Services', 'Shanice Smith', 'ssmith@dsitservicesja.com', '', '', 'ACTIVE', NULL, 0, '2026-03-17 18:53:56'),
(8, 'Demario Ewan', '', 'demario.ewan@moh.gov.jm', '', '', 'ACTIVE', NULL, 0, '2026-03-17 19:48:10'),
(9, 'Royale Computers & Accessories Ltd', '', 'Shaquille.Murray@royalecomputers.com', '', '', 'ACTIVE', NULL, 0, '2026-03-18 13:48:28'),
(10, 'BCB Sales and Services', '', '', '', '', 'ACTIVE', NULL, 0, '2026-05-04 21:44:20'),
(11, 'Jam Labs', 'Ackelia Raymond', '', 'Phone: (876) 929-3513 Phone: (876) 968-5908 Phone:', '18C Lyndhurst Road, Kingston', 'ACTIVE', NULL, 0, '2026-05-04 21:47:29'),
(12, 'Tech Pro Business Solution', '', '', '', '', 'ACTIVE', NULL, 0, '2026-05-04 22:18:36');

-- --------------------------------------------------------

--
-- Table structure for table `vw_branch_outstanding`
--

CREATE TABLE IF NOT EXISTS `vw_branch_outstanding` (
  `branch_name` varchar(100) DEFAULT NULL,
  `total_invoiced` decimal(34,2) DEFAULT NULL,
  `total_paid` decimal(34,2) DEFAULT NULL,
  `outstanding` decimal(35,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vw_outstanding_balance`
--

CREATE TABLE IF NOT EXISTS `vw_outstanding_balance` (
  `balance` decimal(35,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workflow_notifications`
--

CREATE TABLE IF NOT EXISTS `workflow_notifications` (
  `notif_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `request_type` enum('REGULAR','REIMBURSEMENT','PETTY_CASH') DEFAULT 'REGULAR',
  `notification_type` enum('PENDING_AUTHORIZATION','PENDING_VERIFICATION','DEADLINE_APPROACHING','DEADLINE_EXCEEDED','STATUS_UPDATE') DEFAULT 'STATUS_UPDATE',
  `recipient_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `is_sent` tinyint(1) DEFAULT 0,
  `sent_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Workflow notifications for reimbursement and petty cash deadlines/status';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `acting_roles`
--
ALTER TABLE `acting_roles`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_user_acting_role` (`user_id`,`acting_role_id`),
  ADD KEY IF NOT EXISTS `acting_role_id` (`acting_role_id`),
  ADD KEY IF NOT EXISTS `assigned_by` (`assigned_by`);

--
-- Indexes for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD KEY IF NOT EXISTS `user_id` (`user_id`);

--
-- Indexes for table `approval_rules`
--
ALTER TABLE `approval_rules`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`);

--
-- Indexes for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`step_id`),
  ADD KEY IF NOT EXISTS `workflow_id` (`workflow_id`);

--
-- Indexes for table `approval_transactions`
--
ALTER TABLE `approval_transactions`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`transaction_id`);

--
-- Indexes for table `approval_workflows`
--
ALTER TABLE `approval_workflows`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`workflow_id`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`audit_id`),
  ADD KEY IF NOT EXISTS `changed_by` (`changed_by`),
  ADD KEY IF NOT EXISTS `idx_audit_log_table_record_date` (`table_name`,`record_id`,`change_date`);

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`branch_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_branch_name` (`branch_name`);

--
-- Indexes for table `commitments`
--
ALTER TABLE `commitments`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`commitment_id`),
  ADD UNIQUE KEY IF NOT EXISTS `commitment_number` (`commitment_number`),
  ADD UNIQUE KEY IF NOT EXISTS `gfms_commitment_number` (`gfms_commitment_number`),
  ADD KEY IF NOT EXISTS `fk_parent_commitment` (`parent_commitment_id`),
  ADD KEY IF NOT EXISTS `idx_commitments_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `commitments_ibfk_rfq` (`rfq_id`),
  ADD KEY IF NOT EXISTS `commitments_ibfk_quote` (`selected_quote_id`),
  ADD KEY IF NOT EXISTS `idx_gfms_commitment_number` (`gfms_commitment_number`),
  ADD KEY IF NOT EXISTS `idx_commitment_gfms_generated` (`gfms_generated`),
  ADD KEY IF NOT EXISTS `idx_commitments_document_path` (`document_path`);

--
-- Indexes for table `compliance_approvals`
--
ALTER TABLE `compliance_approvals`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD KEY IF NOT EXISTS `idx_entity_type` (`entity_type`),
  ADD KEY IF NOT EXISTS `idx_entity_id` (`entity_id`),
  ADD KEY IF NOT EXISTS `idx_status` (`status`),
  ADD KEY IF NOT EXISTS `idx_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `external_approvals`
--
ALTER TABLE `external_approvals`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`approval_id`),
  ADD KEY IF NOT EXISTS `request_id` (`request_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`invoice_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_invoice_number` (`invoice_number`),
  ADD KEY IF NOT EXISTS `po_id` (`po_id`),
  ADD KEY IF NOT EXISTS `idx_invoice_source` (`invoice_source`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD KEY IF NOT EXISTS `user_id` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`payment_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_payment_reference` (`payment_reference`),
  ADD KEY IF NOT EXISTS `invoice_id` (`invoice_id`),
  ADD KEY IF NOT EXISTS `created_by` (`created_by`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD UNIQUE KEY IF NOT EXISTS `name` (`name`);

--
-- Indexes for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`disburse_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_request_disburse` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_disbursed_by` (`disbursed_by`),
  ADD KEY IF NOT EXISTS `idx_disbursement_date` (`disbursement_date`),
  ADD KEY IF NOT EXISTS `idx_status` (`status`),
  ADD KEY IF NOT EXISTS `idx_petty_cash_deadline` (`disbursement_deadline`,`status`);

--
-- Indexes for table `petty_cash_reconciliations`
--
ALTER TABLE `petty_cash_reconciliations`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`reconcile_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_disburse_reconcile` (`disburse_id`),
  ADD KEY IF NOT EXISTS `idx_invoice_id` (`invoice_id`),
  ADD KEY IF NOT EXISTS `idx_submitted_by` (`submitted_by`),
  ADD KEY IF NOT EXISTS `idx_submission_date` (`submission_date`),
  ADD KEY IF NOT EXISTS `idx_verified_by` (`verified_by`),
  ADD KEY IF NOT EXISTS `idx_status` (`status`),
  ADD KEY IF NOT EXISTS `idx_reconcile_deadline` (`submission_date`,`status`);

--
-- Indexes for table `po_adjustment_log`
--
ALTER TABLE `po_adjustment_log`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`);

--
-- Indexes for table `po_items`
--
ALTER TABLE `po_items`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`po_item_id`),
  ADD KEY IF NOT EXISTS `po_id` (`po_id`);

--
-- Indexes for table `po_variations`
--
ALTER TABLE `po_variations`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`variation_id`),
  ADD KEY IF NOT EXISTS `po_id` (`po_id`),
  ADD KEY IF NOT EXISTS `requested_by` (`requested_by`),
  ADD KEY IF NOT EXISTS `approved_by` (`approved_by`);

--
-- Indexes for table `po_warnings`
--
ALTER TABLE `po_warnings`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`warning_id`),
  ADD KEY IF NOT EXISTS `idx_po_warning` (`po_id`),
  ADD KEY IF NOT EXISTS `idx_warning_type` (`warning_type`);

--
-- Indexes for table `pre_authorizations`
--
ALTER TABLE `pre_authorizations`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`auth_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_authorized_by` (`authorized_by`),
  ADD KEY IF NOT EXISTS `idx_authorization_date` (`authorization_date`);

--
-- Indexes for table `procurement_requests`
--
ALTER TABLE `procurement_requests`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`request_id`),
  ADD UNIQUE KEY IF NOT EXISTS `request_number` (`request_number`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_request_number` (`request_number`),
  ADD KEY IF NOT EXISTS `branch_id` (`branch_id`),
  ADD KEY IF NOT EXISTS `created_by` (`created_by`),
  ADD KEY IF NOT EXISTS `idx_reimb_request_type` (`request_type`,`status`,`created_at` DESC),
  ADD KEY IF NOT EXISTS `idx_pr_requires_rfq` (`requires_rfq`);

--
-- Indexes for table `procurement_request_items`
--
ALTER TABLE `procurement_request_items`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`item_id`),
  ADD KEY IF NOT EXISTS `request_id` (`request_id`);

--
-- Indexes for table `procurement_verifications`
--
ALTER TABLE `procurement_verifications`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`verification_id`),
  ADD KEY IF NOT EXISTS `idx_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_verified_by` (`verified_by`),
  ADD KEY IF NOT EXISTS `idx_verification_date` (`verification_date`);

--
-- Indexes for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`po_id`),
  ADD UNIQUE KEY IF NOT EXISTS `po_number` (`po_number`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_po_per_commitment` (`commitment_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_po_number` (`po_number`),
  ADD UNIQUE KEY IF NOT EXISTS `gfms_po_number` (`gfms_po_number`),
  ADD KEY IF NOT EXISTS `idx_gfms_po_number` (`gfms_po_number`),
  ADD KEY IF NOT EXISTS `idx_po_gfms_generated` (`gfms_generated`),
  ADD KEY IF NOT EXISTS `idx_po_document_path` (`document_path`);

--
-- Indexes for table `reimbursement_invoices`
--
ALTER TABLE `reimbursement_invoices`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`reimb_invoice_id`),
  ADD KEY IF NOT EXISTS `idx_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_invoice_id` (`invoice_id`),
  ADD KEY IF NOT EXISTS `idx_invoice_stage` (`invoice_stage`),
  ADD KEY IF NOT EXISTS `idx_submitted_by` (`submitted_by`),
  ADD KEY IF NOT EXISTS `idx_verified_by` (`verified_by`);

--
-- Indexes for table `reimbursement_status_history`
--
ALTER TABLE `reimbursement_status_history`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`history_id`),
  ADD KEY IF NOT EXISTS `idx_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_changed_by` (`changed_by`),
  ADD KEY IF NOT EXISTS `idx_change_date` (`change_date`);

--
-- Indexes for table `request_approvals`
--
ALTER TABLE `request_approvals`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD KEY IF NOT EXISTS `idx_approval_lookup` (`entity_type`,`entity_id`,`status`);

--
-- Indexes for table `request_documents`
--
ALTER TABLE `request_documents`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`document_id`),
  ADD KEY IF NOT EXISTS `idx_request_documents_request` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_request_documents_type` (`document_type`);

--
-- Indexes for table `rfqs`
--
ALTER TABLE `rfqs`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`rfq_id`),
  ADD UNIQUE KEY IF NOT EXISTS `rfq_number` (`rfq_number`),
  ADD KEY IF NOT EXISTS `request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `created_by` (`created_by`),
  ADD KEY IF NOT EXISTS `idx_rfq_status` (`status`),
  ADD KEY IF NOT EXISTS `idx_rfq_quote_review_status` (`quote_review_status`);

--
-- Indexes for table `rfq_evaluation_committee`
--
ALTER TABLE `rfq_evaluation_committee`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`committee_id`),
  ADD KEY IF NOT EXISTS `rfq_id` (`rfq_id`),
  ADD KEY IF NOT EXISTS `user_id` (`user_id`);

--
-- Indexes for table `rfq_evaluation_reports`
--
ALTER TABLE `rfq_evaluation_reports`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`report_id`),
  ADD KEY IF NOT EXISTS `rfq_id` (`rfq_id`);

--
-- Indexes for table `rfq_quotes`
--
ALTER TABLE `rfq_quotes`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`quote_id`),
  ADD KEY IF NOT EXISTS `rfq_vendor_id` (`rfq_vendor_id`),
  ADD KEY IF NOT EXISTS `idx_quote_selection` (`is_selected`),
  ADD KEY IF NOT EXISTS `idx_quote_review_status` (`review_status`);

--
-- Indexes for table `rfq_scores`
--
ALTER TABLE `rfq_scores`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`score_id`);

--
-- Indexes for table `rfq_vendors`
--
ALTER TABLE `rfq_vendors`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`rfq_vendor_id`),
  ADD KEY IF NOT EXISTS `rfq_id` (`rfq_id`),
  ADD KEY IF NOT EXISTS `fk_rfq_vendor_master` (`vendor_id`);

--
-- Indexes for table `rfq_votes`
--
ALTER TABLE `rfq_votes`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`vote_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD UNIQUE KEY IF NOT EXISTS `name` (`name`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY IF NOT EXISTS `permission_id` (`permission_id`);

--
-- Indexes for table `system_alerts`
--
ALTER TABLE `system_alerts`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`alert_id`);

--
-- Indexes for table `system_config`
--
ALTER TABLE `system_config`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`config_id`),
  ADD UNIQUE KEY IF NOT EXISTS `uq_config_key` (`config_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY IF NOT EXISTS `email` (`email`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`id`),
  ADD UNIQUE KEY IF NOT EXISTS `unique_user_permission` (`user_id`,`permission_id`),
  ADD KEY IF NOT EXISTS `permission_id` (`permission_id`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`vendor_id`);

--
-- Indexes for table `workflow_notifications`
--
ALTER TABLE `workflow_notifications`
  ADD CONSTRAINT IF NOT EXISTS PRIMARY KEY (`notif_id`),
  ADD KEY IF NOT EXISTS `idx_request_id` (`request_id`),
  ADD KEY IF NOT EXISTS `idx_recipient_id` (`recipient_id`),
  ADD KEY IF NOT EXISTS `idx_is_sent` (`is_sent`),
  ADD KEY IF NOT EXISTS `idx_request_type` (`request_type`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `acting_roles`
--
ALTER TABLE `acting_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT for table `approval_rules`
--
ALTER TABLE `approval_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `approval_steps`
--
ALTER TABLE `approval_steps`
  MODIFY `step_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `approval_transactions`
--
ALTER TABLE `approval_transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `approval_workflows`
--
ALTER TABLE `approval_workflows`
  MODIFY `workflow_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2176;

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `branch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `commitments`
--
ALTER TABLE `commitments`
  MODIFY `commitment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=88;

--
-- AUTO_INCREMENT for table `compliance_approvals`
--
ALTER TABLE `compliance_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `external_approvals`
--
ALTER TABLE `external_approvals`
  MODIFY `approval_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `invoice_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=181;

--
-- AUTO_INCREMENT for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  MODIFY `disburse_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `petty_cash_reconciliations`
--
ALTER TABLE `petty_cash_reconciliations`
  MODIFY `reconcile_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `po_adjustment_log`
--
ALTER TABLE `po_adjustment_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `po_items`
--
ALTER TABLE `po_items`
  MODIFY `po_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `po_variations`
--
ALTER TABLE `po_variations`
  MODIFY `variation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `po_warnings`
--
ALTER TABLE `po_warnings`
  MODIFY `warning_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `pre_authorizations`
--
ALTER TABLE `pre_authorizations`
  MODIFY `auth_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `procurement_requests`
--
ALTER TABLE `procurement_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=160;

--
-- AUTO_INCREMENT for table `procurement_request_items`
--
ALTER TABLE `procurement_request_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=323;

--
-- AUTO_INCREMENT for table `procurement_verifications`
--
ALTER TABLE `procurement_verifications`
  MODIFY `verification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  MODIFY `po_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `reimbursement_invoices`
--
ALTER TABLE `reimbursement_invoices`
  MODIFY `reimb_invoice_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reimbursement_status_history`
--
ALTER TABLE `reimbursement_status_history`
  MODIFY `history_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `request_approvals`
--
ALTER TABLE `request_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT for table `request_documents`
--
ALTER TABLE `request_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `rfqs`
--
ALTER TABLE `rfqs`
  MODIFY `rfq_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `rfq_evaluation_committee`
--
ALTER TABLE `rfq_evaluation_committee`
  MODIFY `committee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `rfq_evaluation_reports`
--
ALTER TABLE `rfq_evaluation_reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `rfq_quotes`
--
ALTER TABLE `rfq_quotes`
  MODIFY `quote_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `rfq_scores`
--
ALTER TABLE `rfq_scores`
  MODIFY `score_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rfq_vendors`
--
ALTER TABLE `rfq_vendors`
  MODIFY `rfq_vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT for table `rfq_votes`
--
ALTER TABLE `rfq_votes`
  MODIFY `vote_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `system_alerts`
--
ALTER TABLE `system_alerts`
  MODIFY `alert_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_config`
--
ALTER TABLE `system_config`
  MODIFY `config_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `user_permissions`
--
ALTER TABLE `user_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=545;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `workflow_notifications`
--
ALTER TABLE `workflow_notifications`
  MODIFY `notif_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `acting_roles`
--
ALTER TABLE `acting_roles`
  ADD CONSTRAINT IF NOT EXISTS `acting_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `acting_roles_ibfk_2` FOREIGN KEY (`acting_role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `acting_roles_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  ADD CONSTRAINT IF NOT EXISTS `acting_role_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  ADD CONSTRAINT IF NOT EXISTS `fk_disburse_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_disburse_user` FOREIGN KEY (`disbursed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `petty_cash_reconciliations`
--
ALTER TABLE `petty_cash_reconciliations`
  ADD CONSTRAINT IF NOT EXISTS `fk_reconcile_disburse` FOREIGN KEY (`disburse_id`) REFERENCES `petty_cash_disbursements` (`disburse_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_reconcile_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  ADD CONSTRAINT IF NOT EXISTS `fk_reconcile_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT IF NOT EXISTS `fk_reconcile_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `pre_authorizations`
--
ALTER TABLE `pre_authorizations`
  ADD CONSTRAINT IF NOT EXISTS `fk_pre_auth_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_pre_auth_user` FOREIGN KEY (`authorized_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `procurement_verifications`
--
ALTER TABLE `procurement_verifications`
  ADD CONSTRAINT IF NOT EXISTS `fk_verify_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_verify_user` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reimbursement_invoices`
--
ALTER TABLE `reimbursement_invoices`
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reimbursement_status_history`
--
ALTER TABLE `reimbursement_status_history`
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_status_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT IF NOT EXISTS `fk_reimb_status_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `request_documents`
--
ALTER TABLE `request_documents`
  ADD CONSTRAINT IF NOT EXISTS `fk_request_documents_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE;

--
-- Constraints for table `workflow_notifications`
--
ALTER TABLE `workflow_notifications`
  ADD CONSTRAINT IF NOT EXISTS `fk_notif_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT IF NOT EXISTS `fk_notif_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 001_fix_status_column.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Convert procurement_requests.status from ENUM to VARCHAR
-- and normalize all existing status values to UPPERCASE workflow stages.
-- 
-- Run this against the production database to fix blank statuses.
-- Date: 2026-02-15

-- Step 1: Drop the trigger that references old status values
DROP TRIGGER IF EXISTS `lock_procurement_after_approval`;

-- Step 2: Change ENUM to VARCHAR to support all workflow stages
ALTER TABLE `procurement_requests`
  MODIFY COLUMN `status` VARCHAR(30) NOT NULL DEFAULT 'DRAFT';

-- Step 3: Normalize all existing status values to UPPERCASE
UPDATE `procurement_requests` SET `status` = 'DRAFT'      WHERE UPPER(`status`) = 'DRAFT';
UPDATE `procurement_requests` SET `status` = 'SUBMITTED'   WHERE UPPER(`status`) = 'SUBMITTED';
UPDATE `procurement_requests` SET `status` = 'GC_APPROVED' WHERE UPPER(`status`) = 'APPROVED';
UPDATE `procurement_requests` SET `status` = 'DECLINED'    WHERE UPPER(`status`) = 'DECLINED';
UPDATE `procurement_requests` SET `status` = 'CANCELLED'   WHERE UPPER(`status`) = 'CANCELLED';

-- Step 4: Fix any rows that got written as empty string (from failed ENUM writes)
-- These were likely HOD_APPROVED, FINANCE_APPROVED, etc. attempts that got blanked.
-- Check audit_log to identify what they should be, or set to SUBMITTED as safe default:
UPDATE `procurement_requests` SET `status` = 'SUBMITTED' WHERE `status` = '' OR `status` IS NULL;

-- Step 5: Recreate the trigger using the new workflow stages
DELIMITER $$
CREATE TRIGGER `lock_procurement_after_approval` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW
BEGIN
  IF OLD.status IN ('GC_APPROVED', 'AWARDED', 'COMPLETED') 
     AND NEW.status NOT IN ('GC_APPROVED', 'AWARDED', 'COMPLETED') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Approved/Awarded/Completed requests cannot be reverted';
  END IF;
END
$$
DELIMITER ;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 002_grant_finance_approve_request.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Grant 'approve_request' permission to Finance Officer role
-- Fixes: Finance Officer unable to approve requests at HOD_APPROVED stage
-- The Finance Officer (role_id=3) needs 'approve_request' (permission_id=3)
-- to access approve_finance.php and see the approval button in view.php.

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES (3, 3);



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 003_add_gfms_commitment_number.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add GFMS Commitment Number field
-- Allows Finance Officers to input unique commitment numbers from GFMS
--
-- NOTE: If you get error #1060 "Duplicate column name", it means the column
-- already exists - this is OK and the migration has already been applied.
--
-- This script is safe to run multiple times on compatible MySQL versions.

-- Add GFMS Commitment Number column if it doesn't already exist
ALTER TABLE `commitments` 
ADD COLUMN IF NOT EXISTS `gfms_commitment_number` VARCHAR(50) NULL UNIQUE 
COMMENT 'Unique commitment number from GFMS system';

-- Create index for faster lookups (if not already present)
CREATE INDEX IF NOT EXISTS `idx_gfms_commitment_number` ON `commitments` (`gfms_commitment_number`);

-- Verification: Run this query to confirm the column was added:
-- SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'commitments' AND COLUMN_NAME = 'gfms_commitment_number';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 003_fix_legacy_request_statuses.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Advance legacy procurement_requests that have completed RFQ work
-- but are stuck at old/intermediate statuses.
--
-- Problem: Requests created before the multi-step workflow have statuses like
-- 'Approved', 'PROCUREMENT_STAGE', etc., but their RFQs already have vendors,
-- quotes, committee members, and evaluation reports. The award process requires
-- status = 'GC_APPROVED', so these requests are stuck.
--
-- This migration advances such requests to 'GC_APPROVED' so the GC can award them.
-- Date: 2026-02-16

-- Advance requests that have RFQs with evaluation work completed
-- (i.e., have committee members, quotes, and are not yet awarded)
UPDATE procurement_requests pr
SET pr.status = 'GC_APPROVED'
WHERE pr.status IN ('Approved', 'PROCUREMENT_STAGE', 'EVALUATION_STAGE', 'COMMITTEE_RECOMMENDED')
  AND EXISTS (
    SELECT 1 FROM rfqs r
    WHERE r.request_id = pr.request_id
      AND r.status <> 'AWARDED'
  )
  AND EXISTS (
    SELECT 1 FROM rfqs r
    JOIN rfq_evaluation_committee ec ON r.rfq_id = ec.rfq_id
    WHERE r.request_id = pr.request_id
    GROUP BY r.rfq_id
    HAVING COUNT(*) >= 3
  );

-- Also normalize any remaining old 'Approved' statuses to 'GC_APPROVED'
-- (requests that don't have RFQs but were approved under the old system)
UPDATE procurement_requests
SET status = 'GC_APPROVED'
WHERE UPPER(status) = 'APPROVED';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 003_populate_request_type.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Populate petty cash requests
UPDATE procurement_requests pr
SET pr.request_type = 'PETTY_CASH'
WHERE EXISTS (SELECT 1 FROM petty_cash_disbursements pcd WHERE pcd.request_id = pr.request_id)
AND (pr.request_type IS NULL OR pr.request_type = '');

-- Populate reimbursement requests
UPDATE procurement_requests pr
SET pr.request_type = 'REIMBURSEMENT'
WHERE EXISTS (SELECT 1 FROM pre_authorizations pa WHERE pa.request_id = pr.request_id)
AND (pr.request_type IS NULL OR pr.request_type = '');

-- Default remaining to REGULAR
UPDATE procurement_requests
SET request_type = 'REGULAR'
WHERE request_type IS NULL OR request_type = '';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 004_add_gfms_po_number.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add GFMS PO Number field
-- Allows Finance Officers/Procurement to input unique PO numbers from GFMS
--
-- NOTE: If you get error #1060 "Duplicate column name", it means the column
-- already exists - this is OK and the migration has already been applied.
--
-- This script is safe to run multiple times on compatible MySQL versions.

-- Add GFMS PO Number column if it doesn't already exist
ALTER TABLE `purchase_orders` 
ADD COLUMN IF NOT EXISTS `gfms_po_number` VARCHAR(50) NULL UNIQUE 
COMMENT 'Unique PO number from GFMS system';

-- Create index for faster lookups (if not already present)
CREATE INDEX IF NOT EXISTS `idx_gfms_po_number` ON `purchase_orders` (`gfms_po_number`);

-- Verification: Run this query to confirm the column was added:
-- SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'purchase_orders' AND COLUMN_NAME = 'gfms_po_number';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 004_add_selected_to_rfq_vendors.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add 'SELECTED' to rfq_vendors.response_status enum
-- 
-- Problem: award.php sets response_status = 'SELECTED' but the enum
-- only allows PENDING, WILL_SUBMIT, DECLINED, SUBMITTED.
-- The UPDATE silently fails in strict mode or stores empty string.
-- Date: 2026-02-16

ALTER TABLE `rfq_vendors`
  MODIFY COLUMN `response_status` 
  ENUM('PENDING','WILL_SUBMIT','DECLINED','SUBMITTED','SELECTED') 
  DEFAULT 'PENDING';

-- Fix any vendors that were awarded but didn't get SELECTED status
UPDATE rfq_vendors rv
JOIN rfq_quotes q ON rv.rfq_vendor_id = q.rfq_vendor_id
JOIN rfqs r ON rv.rfq_id = r.rfq_id
SET rv.response_status = 'SELECTED'
WHERE q.is_selected = 1
  AND r.status = 'AWARDED';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 005_seed_commitment_approval_chains.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Seed approval chains for legacy commitments
-- Fixes: HOD/Finance unable to approve commitments created before
--        the approval chain was added to commitments/add.php.
-- Any open commitment without request_approvals rows gets HOD → Finance stages.

-- HOD stage (stage_order = 1)
INSERT INTO request_approvals (entity_type, entity_id, role, stage_order, status)
SELECT 'COMMITMENT', c.commitment_id, 'HOD', 1, 'pending'
FROM commitments c
WHERE c.status = 'open'
  AND NOT EXISTS (
    SELECT 1 FROM request_approvals ra
    WHERE ra.entity_type = 'COMMITMENT'
      AND ra.entity_id = c.commitment_id
  );

-- Finance Officer stage (stage_order = 2)
INSERT INTO request_approvals (entity_type, entity_id, role, stage_order, status)
SELECT 'COMMITMENT', c.commitment_id, 'Finance Officer', 2, 'pending'
FROM commitments c
WHERE c.status = 'open'
  AND NOT EXISTS (
    SELECT 1 FROM request_approvals ra
    WHERE ra.entity_type = 'COMMITMENT'
      AND ra.entity_id = c.commitment_id
      AND ra.role = 'Finance Officer'
  );

-- For already-closed commitments, mark both stages as approved retroactively
INSERT INTO request_approvals (entity_type, entity_id, role, stage_order, status, approved_at)
SELECT 'COMMITMENT', c.commitment_id, 'HOD', 1, 'approved', c.approved_at
FROM commitments c
WHERE c.status = 'closed'
  AND NOT EXISTS (
    SELECT 1 FROM request_approvals ra
    WHERE ra.entity_type = 'COMMITMENT'
      AND ra.entity_id = c.commitment_id
  );

INSERT INTO request_approvals (entity_type, entity_id, role, stage_order, status, approved_at)
SELECT 'COMMITMENT', c.commitment_id, 'Finance Officer', 2, 'approved', c.approved_at
FROM commitments c
WHERE c.status = 'closed'
  AND NOT EXISTS (
    SELECT 1 FROM request_approvals ra
    WHERE ra.entity_type = 'COMMITMENT'
      AND ra.entity_id = c.commitment_id
      AND ra.role = 'Finance Officer'
  );



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 006_sop_role_permission_mapping.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration: SOP-based role ↔ permission auto-mapping
-- Purpose:   Ensure every role has the permissions it needs per SOP, and that
--            all permissions referenced by $REQUIRE_PERMISSION guards exist.
-- Safety:    Uses INSERT IGNORE — existing mappings are untouched.
-- Date:      2026-02-16
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Create any missing permissions used by page guards
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO permissions (name, description) VALUES
('edit_requests',            'Edit procurement requests, create RFQs, manage vendors'),
('view_approval_analytics',  'Access approval analytics dashboard'),
('view_compliance',          'Access compliance dashboard'),
('management_dashboard',     'Access management overview dashboard'),
('monthly_metrics',          'Access monthly financial metrics dashboard'),
('view_financial_reports',   'View financial reports (branch summary/outstanding)'),
('print_invoice',            'Print invoice PDF');


-- ═══════════════════════════════════════════════════════════
-- STEP 2: SOP role → permission mapping
-- Uses subqueries for permission IDs so it works regardless
-- of auto-increment values. INSERT IGNORE skips duplicates.
-- ═══════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────
-- Role 1: Viewer  (Read-only audit access)
-- SOP: Can view requests, commitments, POs, invoices, audit
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE name IN (
    'view_audit_dashboard',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs'
);

-- ───────────────────────────────────────────────────────────
-- Role 2: Procurement Officer
-- SOP: Create/edit/submit requests, create RFQs, manage
--      vendors, create commitments, create POs, view all
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE name IN (
    'create_request',
    'edit_requests',
    'submit_request',
    'view_requests',
    'create_commitment',
    'view_commitments',
    'create_purchase_order',
    'edit_purchase_order',
    'view_purchase_orders',
    'request_po_adjustment',
    'view_audit_logs',
    'view_procurement_dashboard',
    'view_invoices',
    'view_payments',
    'print_request',
    'print_purchase_order'
);

-- ───────────────────────────────────────────────────────────
-- Role 3: Finance Officer
-- SOP: Approve requests (finance stage), approve commitments
--      (stage 2), approve POs, invoices, payments, reports
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
    'approve_request',
    'approve_commitment',
    'approve_po',
    'approve_purchase_order',
    'approve_po_adjustment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_finance_dashboard',
    'view_monthly_dashboard',
    'view_financial_reports',
    'view_audit_logs',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'monthly_metrics'
);

-- ───────────────────────────────────────────────────────────
-- Role 4: HOD  (Head of Department)
-- SOP: Approve requests (HOD stage), approve commitments
--      (stage 1), approve POs, view dashboards
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 4, id FROM permissions WHERE name IN (
    'approve_request',
    'approve_commitment',
    'approve_po',
    'approve_purchase_order',
    'approve_po_adjustment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_management_dashboard',
    'view_procurement_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_audit_logs',
    'management_dashboard',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'view_financial_reports',
    'monthly_metrics',
    'view_approval_analytics'
);

-- ───────────────────────────────────────────────────────────
-- Role 5: Admin
-- SOP: System administration, user management, all views
-- (SuperAdmin bypasses checks, but Admin needs explicit grants)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions WHERE name IN (
    'manage_users',
    'create_request',
    'edit_requests',
    'submit_request',
    'approve_request',
    'create_commitment',
    'approve_commitment',
    'create_purchase_order',
    'edit_purchase_order',
    'approve_purchase_order',
    'approve_po',
    'approve_po_adjustment',
    'approve_po_excess',
    'request_po_adjustment',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_audit_dashboard',
    'view_finance_dashboard',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_procurement_dashboard',
    'view_po_adjustments',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);

-- ───────────────────────────────────────────────────────────
-- Role 6: SuperAdmin  (has_permission() always returns true,
--          but explicit grants keep role_permissions consistent)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions WHERE name IN (
    'manage_users',
    'create_request',
    'edit_requests',
    'submit_request',
    'approve_request',
    'create_commitment',
    'approve_commitment',
    'create_purchase_order',
    'edit_purchase_order',
    'approve_purchase_order',
    'approve_po',
    'approve_po_adjustment',
    'approve_po_excess',
    'request_po_adjustment',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_audit_dashboard',
    'view_finance_dashboard',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_procurement_dashboard',
    'view_po_adjustments',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);

-- ───────────────────────────────────────────────────────────
-- Role 7: Evaluation Committee Member
-- SOP: View requests/RFQs assigned to them, vote on evaluations
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions WHERE name IN (
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_audit_logs'
);

-- ───────────────────────────────────────────────────────────
-- Role 8: Procurement Committee
-- SOP: Recommend requests at COMMITTEE_RECOMMENDED stage,
--      view requests and procurement data
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 8, id FROM permissions WHERE name IN (
    'approve_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_audit_logs',
    'print_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 9: Deputy Government Chemist (DGC)
-- SOP: Final approval authority, external compliance checks,
--      award RFQs, view all dashboards
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 9, id FROM permissions WHERE name IN (
    'approve_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 007_seed_po_approval_chains.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration 007: Seed PO Approval Chains
-- Problem : Legacy POs have no rows in request_approvals,
--           so HOD/Finance approval always fails with
--           "Not your approval stage."
-- Fix     : Insert HOD (stage 1) + Finance Officer (stage 2)
--           for every PO that lacks an approval chain.
-- ============================================================

-- 1) Open POs that have NO approval chain → pending stages
INSERT IGNORE INTO request_approvals
    (entity_type, entity_id, role, stage_order, status)
SELECT 'PO', po.po_id, 'HOD', 1, 'pending'
FROM purchase_orders po
WHERE po.status = 'Open'
  AND NOT EXISTS (
      SELECT 1 FROM request_approvals ra
      WHERE ra.entity_type = 'PO'
        AND ra.entity_id   = po.po_id
  );

INSERT IGNORE INTO request_approvals
    (entity_type, entity_id, role, stage_order, status)
SELECT 'PO', po.po_id, 'Finance Officer', 2, 'pending'
FROM purchase_orders po
WHERE po.status = 'Open'
  AND NOT EXISTS (
      SELECT 1 FROM request_approvals ra
      WHERE ra.entity_type = 'PO'
        AND ra.entity_id   = po.po_id
        AND ra.role         = 'Finance Officer'
  );

-- 2) Closed/approved POs → mark both stages as approved
INSERT IGNORE INTO request_approvals
    (entity_type, entity_id, role, stage_order, status, approved_at)
SELECT 'PO', po.po_id, 'HOD', 1, 'approved', COALESCE(po.approved_at, po.created_at)
FROM purchase_orders po
WHERE po.status IN ('Closed', 'Cancelled')
  AND NOT EXISTS (
      SELECT 1 FROM request_approvals ra
      WHERE ra.entity_type = 'PO'
        AND ra.entity_id   = po.po_id
  );

INSERT IGNORE INTO request_approvals
    (entity_type, entity_id, role, stage_order, status, approved_at)
SELECT 'PO', po.po_id, 'Finance Officer', 2, 'approved', COALESCE(po.approved_at, po.created_at)
FROM purchase_orders po
WHERE po.status IN ('Closed', 'Cancelled')
  AND NOT EXISTS (
      SELECT 1 FROM request_approvals ra
      WHERE ra.entity_type = 'PO'
        AND ra.entity_id   = po.po_id
        AND ra.role         = 'Finance Officer'
  );



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 008_major_workflow_restructure.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration 008: Major Workflow Restructure
-- ============================================================================
-- Changes:
--   1. Add request_type to procurement_requests (REGULAR, REIMBURSEMENT, PETTY_CASH)
--   2. Add petty_cash_limit system config
--   3. Add new roles: Director HRM&A, Director Procurement
--   4. Set 3 approvers only: HOD, Director HRM&A, Deputy Government Chemist
--   5. Add file upload columns to purchase_orders (upload-based PO)
--   6. Add file upload columns to commitments (upload-based commitment)
--   7. Add direct_procurement threshold support
--   8. New permissions for new roles
--   9. Update approval workflow for new flow
-- ============================================================================

-- -------------------------------------------------------
-- 1. REQUEST TYPES on procurement_requests
-- -------------------------------------------------------
ALTER TABLE `procurement_requests`
  ADD COLUMN IF NOT EXISTS `request_type` ENUM('REGULAR','REIMBURSEMENT','PETTY_CASH') NOT NULL DEFAULT 'REGULAR'
  AFTER `status`;

-- -------------------------------------------------------
-- 2. DIRECT PROCUREMENT threshold flag
--    Requests under threshold skip RFQ and go direct
-- -------------------------------------------------------
ALTER TABLE `procurement_requests`
  ADD COLUMN IF NOT EXISTS `direct_procurement` TINYINT(1) NOT NULL DEFAULT 0
  AFTER `request_type`,
  ADD COLUMN IF NOT EXISTS `direct_procurement_reason` TEXT DEFAULT NULL
  AFTER `direct_procurement`;

-- -------------------------------------------------------
-- 3. PURCHASE ORDERS: Add upload fields (PO is now uploaded, not form-created)
-- -------------------------------------------------------
ALTER TABLE `purchase_orders`
  ADD COLUMN IF NOT EXISTS `po_file` VARCHAR(255) DEFAULT NULL AFTER `po_total`,
  ADD COLUMN IF NOT EXISTS `uploaded_by` INT(11) DEFAULT NULL AFTER `po_file`,
  ADD COLUMN IF NOT EXISTS `upload_date` DATETIME DEFAULT NULL AFTER `uploaded_by`;

-- -------------------------------------------------------
-- 4. COMMITMENTS: Add upload fields (Commitment is now uploaded by accounts)
-- -------------------------------------------------------
ALTER TABLE `commitments`
  ADD COLUMN IF NOT EXISTS `commitment_file` VARCHAR(255) DEFAULT NULL AFTER `commitment_total`,
  ADD COLUMN IF NOT EXISTS `uploaded_by` INT(11) DEFAULT NULL AFTER `commitment_file`,
  ADD COLUMN IF NOT EXISTS `responded_to_procurement` TINYINT(1) DEFAULT 0 AFTER `uploaded_by`,
  ADD COLUMN IF NOT EXISTS `response_date` DATETIME DEFAULT NULL AFTER `responded_to_procurement`;

-- -------------------------------------------------------
-- 5. NEW ROLES
-- -------------------------------------------------------
INSERT IGNORE INTO `roles` (`name`, `description`) VALUES
  ('Director HRM&A', 'Director of Human Resource Management & Administration - Approver'),
  ('Director Procurement', 'Director for Procurement operations');

-- -------------------------------------------------------
-- 6. NEW PERMISSIONS
-- -------------------------------------------------------
INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
  ('upload_purchase_order', 'Upload purchase order document'),
  ('upload_commitment', 'Upload commitment document'),
  ('verify_funds', 'Verify fund availability for procurement requests'),
  ('respond_commitment', 'Respond to procurement with commitment number'),
  ('approve_as_director_hrma', 'Approve requests as Director HRM&A'),
  ('view_director_dashboard', 'Access Director for Procurement dashboard'),
  ('direct_procurement', 'Approve direct procurement without RFQ for under-threshold requests');

-- -------------------------------------------------------
-- 7. ROLE PERMISSIONS for new roles
-- -------------------------------------------------------

-- Director HRM&A (role_id will be 10) - Approver role
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Director HRM&A'
AND p.name IN (
  'approve_request', 'approve_commitment', 'approve_po',
  'approve_purchase_order', 'approve_as_director_hrma',
  'view_requests', 'view_commitments', 'view_purchase_orders',
  'view_management_dashboard', 'view_monthly_dashboard',
  'view_audit_logs'
);

-- Director Procurement (role_id will be 11) - Operational oversight
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Director Procurement'
AND p.name IN (
  'create_request', 'submit_request', 'view_requests',
  'create_commitment', 'view_commitments',
  'create_purchase_order', 'view_purchase_orders',
  'view_procurement_dashboard', 'view_director_dashboard',
  'view_audit_logs', 'view_monthly_dashboard',
  'direct_procurement', 'upload_purchase_order', 'upload_commitment',
  'request_po_adjustment', 'edit_purchase_order',
  'print_purchase_order', 'print_request'
);

-- Finance Officer gets verify_funds, upload_commitment, respond_commitment
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Finance Officer'
AND p.name IN ('verify_funds', 'upload_commitment', 'respond_commitment');

-- Procurement Officer gets upload_purchase_order
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Procurement Officer'
AND p.name IN ('upload_purchase_order');

-- -------------------------------------------------------
-- 8. SYSTEM CONFIGURATION for thresholds
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `system_config` (
  `config_key` VARCHAR(100) NOT NULL,
  `config_value` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`) VALUES
  ('petty_cash_limit', '5000', 'Maximum amount for petty cash requests (JMD)'),
  ('direct_procurement_threshold', '500000', 'Requests under this amount can skip RFQ and go direct'),
  ('currency_symbol', 'JMD', 'Currency symbol for display');

-- -------------------------------------------------------
-- 9. UPDATE APPROVAL WORKFLOWS for 3-approver model
--    HOD → Director HRM&A → Deputy Government Chemist
-- -------------------------------------------------------

-- Clear old workflows and re-create
DELETE FROM `approval_steps`;
DELETE FROM `approval_workflows`;

INSERT IGNORE INTO `approval_workflows` (`workflow_id`, `entity_type`, `min_amount`, `max_amount`, `description`, `is_active`) VALUES
(1, 'PROCUREMENT_REQUEST', 0.00, 5000.00, 'Petty Cash Workflow (HOD only)', 1),
(2, 'PROCUREMENT_REQUEST', 5000.01, 500000.00, 'Standard Workflow (HOD → Director HRM&A)', 1),
(3, 'PROCUREMENT_REQUEST', 500000.01, NULL, 'Full Approval Workflow (HOD → Director HRM&A → DGC)', 1);

INSERT IGNORE INTO `approval_steps` (`workflow_id`, `step_order`, `role_id`, `is_mandatory`) VALUES
-- Petty Cash: HOD only
(1, 1, (SELECT id FROM roles WHERE name = 'HOD'), 1),
-- Standard: HOD → Director HRM&A
(2, 1, (SELECT id FROM roles WHERE name = 'HOD'), 1),
(2, 2, (SELECT id FROM roles WHERE name = 'Director HRM&A'), 1),
-- Full: HOD → Director HRM&A → Deputy Government Chemist
(3, 1, (SELECT id FROM roles WHERE name = 'HOD'), 1),
(3, 2, (SELECT id FROM roles WHERE name = 'Director HRM&A'), 1),
(3, 3, (SELECT id FROM roles WHERE name = 'Deputy Government Chemist'), 1);

-- -------------------------------------------------------
-- 10. UPDATE procurement_method trigger for new thresholds
-- -------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_set_procurement_method`;
DELIMITER $$
CREATE TRIGGER `trg_set_procurement_method` BEFORE INSERT ON `procurement_requests` FOR EACH ROW
BEGIN
    -- Petty Cash requests are always direct procurement
    IF NEW.request_type = 'PETTY_CASH' THEN
        SET NEW.direct_procurement = 1;
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 500000 THEN
        SET NEW.direct_procurement = 1;
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 3000000 THEN
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 20000000 THEN
        SET NEW.procurement_method = 'RESTRICTED_BIDDING';
    ELSE
        SET NEW.procurement_method = 'NATIONAL_COMPETITIVE';
    END IF;
END
$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_auto_procurement_method`;
DELIMITER $$
CREATE TRIGGER `trg_auto_procurement_method` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW
BEGIN
    IF NEW.request_type = 'PETTY_CASH' THEN
        SET NEW.direct_procurement = 1;
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 500000 THEN
        SET NEW.direct_procurement = 1;
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 3000000 THEN
        SET NEW.procurement_method = 'SINGLE_SOURCE';
    ELSEIF NEW.estimated_value <= 20000000 THEN
        SET NEW.procurement_method = 'RESTRICTED_BIDDING';
    ELSE
        SET NEW.procurement_method = 'NATIONAL_COMPETITIVE';
    END IF;

    IF NEW.estimated_value > 60000000 THEN
        SET NEW.external_approval_required = 'PPC';
    END IF;

    IF NEW.estimated_value > 150000000 THEN
        SET NEW.external_approval_required = 'CABINET';
    END IF;
END
$$
DELIMITER ;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 009_reimbursement_petty_cash_workflows.sql
-- ═══════════════════════════════════════════════════════════════════════

-- =====================================================
-- PRMS DATABASE MIGRATION: REIMBURSEMENT & PETTY CASH WORKFLOWS
-- Database Name: prms_ims
-- Generated: 2026-02-17
-- Purpose: Add tables for reimbursement and petty cash request workflows
-- =====================================================

USE `prms_ims`;

-- =====================================================
-- TABLE 1: pre_authorizations
-- Purpose: Track prior authorization for reimbursement requests
-- =====================================================
CREATE TABLE IF NOT EXISTS `pre_authorizations` (
  `auth_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `authorized_by` int(11) NOT NULL,
  `authorization_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `authorization_amount` decimal(15,2) NOT NULL,
  `authorization_notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`auth_id`),
  UNIQUE KEY `uq_request_id` (`request_id`),
  KEY `idx_authorized_by` (`authorized_by`),
  KEY `idx_authorization_date` (`authorization_date`),
  CONSTRAINT `fk_pre_auth_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pre_auth_user` FOREIGN KEY (`authorized_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Prior authorization for reimbursement requests (Branch Head approval)';

-- =====================================================
-- TABLE 2: reimbursement_invoices
-- Purpose: Track invoices submitted for reimbursement
-- =====================================================
CREATE TABLE IF NOT EXISTS `reimbursement_invoices` (
  `reimb_invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `invoice_stage` enum('COPY_TO_PROCUREMENT','ORIGINAL_TO_FINANCE') DEFAULT 'COPY_TO_PROCUREMENT',
  `invoice_amount` decimal(15,2) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `submitted_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `verified_by` int(11) DEFAULT NULL,
  `procurement_verified_date` datetime DEFAULT NULL,
  `verification_notes` text,
  `goods_service_verified` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reimb_invoice_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_invoice_id` (`invoice_id`),
  KEY `idx_invoice_stage` (`invoice_stage`),
  KEY `idx_submitted_by` (`submitted_by`),
  KEY `idx_verified_by` (`verified_by`),
  CONSTRAINT `fk_reimb_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reimb_invoice` FOREIGN KEY (`invoice_id`) 
    REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reimb_submitted_by` FOREIGN KEY (`submitted_by`) 
    REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_reimb_verified_by` FOREIGN KEY (`verified_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Invoice tracking for reimbursement requests (GC2 copy and GC10A original)';

-- =====================================================
-- TABLE 3: procurement_verifications
-- Purpose: Track procurement verification of goods/services
-- =====================================================
CREATE TABLE IF NOT EXISTS `procurement_verifications` (
  `verification_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `verification_type` enum('GOODS_RECEIVED','SERVICE_RENDERED','PETTY_CASH_PURCHASED') DEFAULT 'GOODS_RECEIVED',
  `verified_by` int(11) NOT NULL,
  `verification_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `condition_status` enum('SATISFACTORY','DEFECTIVE','INCOMPLETE','OTHER') DEFAULT 'SATISFACTORY',
  `verification_notes` text,
  `verification_documents` varchar(500),
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`verification_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_verified_by` (`verified_by`),
  KEY `idx_verification_date` (`verification_date`),
  CONSTRAINT `fk_verify_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_verify_user` FOREIGN KEY (`verified_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Procurement verification of goods received or services rendered';

-- =====================================================
-- TABLE 4: petty_cash_disbursements
-- Purpose: Track petty cash disbursement transactions
-- =====================================================
CREATE TABLE IF NOT EXISTS `petty_cash_disbursements` (
  `disburse_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `amount_authorized` decimal(15,2) NOT NULL,
  `disbursed_by` int(11) NOT NULL,
  `disbursement_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `disbursement_deadline` datetime NOT NULL,
  `status` enum('AUTHORIZED','DISBURSED','RECONCILED','VERIFIED','COMPLETED') DEFAULT 'AUTHORIZED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`disburse_id`),
  UNIQUE KEY `uq_request_disburse` (`request_id`),
  KEY `idx_disbursed_by` (`disbursed_by`),
  KEY `idx_disbursement_date` (`disbursement_date`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_disburse_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_disburse_user` FOREIGN KEY (`disbursed_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Petty cash disbursement tracking with 24-hour accountability';

-- =====================================================
-- TABLE 5: petty_cash_reconciliations
-- Purpose: Track petty cash reconciliation (purchases, change returns)
-- =====================================================
CREATE TABLE IF NOT EXISTS `petty_cash_reconciliations` (
  `reconcile_id` int(11) NOT NULL AUTO_INCREMENT,
  `disburse_id` int(11) NOT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `purchase_amount` decimal(15,2) NOT NULL,
  `change_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `submitted_by` int(11) NOT NULL,
  `submission_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `submission_deadline_met` tinyint(1) DEFAULT 0,
  `hours_from_disbursement` decimal(4,2) DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verification_date` datetime DEFAULT NULL,
  `reconciliation_notes` text,
  `status` enum('PENDING_VERIFICATION','VERIFIED','DISCREPANCY','APPROVED') DEFAULT 'PENDING_VERIFICATION',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reconcile_id`),
  UNIQUE KEY `uq_disburse_reconcile` (`disburse_id`),
  KEY `idx_invoice_id` (`invoice_id`),
  KEY `idx_submitted_by` (`submitted_by`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `idx_verified_by` (`verified_by`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_reconcile_disburse` FOREIGN KEY (`disburse_id`) 
    REFERENCES `petty_cash_disbursements` (`disburse_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reconcile_invoice` FOREIGN KEY (`invoice_id`) 
    REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reconcile_submitted_by` FOREIGN KEY (`submitted_by`) 
    REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_reconcile_verified_by` FOREIGN KEY (`verified_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Petty cash reconciliation - tracks purchases, change, and verification';

-- =====================================================
-- TABLE 6: reimbursement_statuses_history
-- Purpose: Track historical status changes for reimbursement requests
-- =====================================================
CREATE TABLE IF NOT EXISTS `reimbursement_status_history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `change_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `change_notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_changed_by` (`changed_by`),
  KEY `idx_change_date` (`change_date`),
  CONSTRAINT `fk_reimb_status_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reimb_status_user` FOREIGN KEY (`changed_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Historical record of reimbursement request status changes';

-- =====================================================
-- TABLE 7: workflow_notifications
-- Purpose: Track and queue workflow notifications for each request type
-- =====================================================
CREATE TABLE IF NOT EXISTS `workflow_notifications` (
  `notif_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `request_type` enum('REGULAR','REIMBURSEMENT','PETTY_CASH') DEFAULT 'REGULAR',
  `notification_type` enum('PENDING_AUTHORIZATION','PENDING_VERIFICATION','DEADLINE_APPROACHING','DEADLINE_EXCEEDED','STATUS_UPDATE') DEFAULT 'STATUS_UPDATE',
  `recipient_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `is_sent` tinyint(1) DEFAULT 0,
  `sent_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notif_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_is_sent` (`is_sent`),
  KEY `idx_request_type` (`request_type`),
  CONSTRAINT `fk_notif_request` FOREIGN KEY (`request_id`) 
    REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_notif_recipient` FOREIGN KEY (`recipient_id`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Workflow notifications for reimbursement and petty cash deadlines/status';

-- =====================================================
-- UPDATES TO EXISTING TABLES
-- =====================================================

-- Add reimbursement-specific status to procurement_requests status enum if not exists
-- ALTER TABLE `procurement_requests` MODIFY COLUMN `status` varchar(50) NOT NULL DEFAULT 'DRAFT';

-- =====================================================
-- INDEXES FOR COMMON QUERIES
-- =====================================================

-- Reimbursement query optimization
CREATE INDEX IF NOT EXISTS idx_reimb_request_type 
ON procurement_requests(request_type, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_petty_cash_deadline 
ON petty_cash_disbursements(disbursement_deadline, status);

CREATE INDEX IF NOT EXISTS idx_reconcile_deadline 
ON petty_cash_reconciliations(submission_date, status);

-- =====================================================
-- SAMPLE DATA / DEFAULTS (OPTIONAL)
-- =====================================================

-- Insert default workflow status values if using strict status checking
-- (Optional - only if you want to track allowed statuses)

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- To verify all tables created successfully, run:
-- SELECT TABLE_NAME FROM information_schema.TABLES 
-- WHERE TABLE_SCHEMA='prms_ims' 
-- AND TABLE_NAME IN ('pre_authorizations','reimbursement_invoices','procurement_verifications',
--                     'petty_cash_disbursements','petty_cash_reconciliations',
--                     'reimbursement_status_history','workflow_notifications');

-- Expected: 7 rows returned



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 010_add_notification_settings.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Add notification settings to system_config
INSERT INTO system_config (config_key, config_value, description, created_at)
VALUES 
    ('enable_notifications', '1', 'Enable/disable email notifications (1=enabled, 0=disabled)', NOW())
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 010_rfq_workflow_enhancement.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: RFQ Workflow Enhancement
-- Purpose: Support improved RFQ workflow with quote review stage
-- Date: 2026-02-19

-- Update rfqs table to include quote review status
ALTER TABLE `rfqs` 
ADD COLUMN IF NOT EXISTS `quote_review_status` ENUM('PENDING','IN_REVIEW','APPROVED') DEFAULT 'PENDING' AFTER `acceptance_status`,
ADD COLUMN IF NOT EXISTS `reviewed_by` INT(11) DEFAULT NULL AFTER `quote_review_status`,
ADD COLUMN IF NOT EXISTS `reviewed_at` DATETIME DEFAULT NULL AFTER `reviewed_by`;

-- Add index for workflow status queries
CREATE INDEX IF NOT EXISTS idx_rfq_status ON rfqs(status);
CREATE INDEX IF NOT EXISTS idx_rfq_quote_review_status ON rfqs(quote_review_status);

-- Update rfq_quotes table to track review status
ALTER TABLE `rfq_quotes`
ADD COLUMN IF NOT EXISTS `review_status` ENUM('PENDING','MEETS_REQUIREMENTS','DOES_NOT_MEET') DEFAULT 'PENDING' AFTER `is_selected`,
ADD COLUMN IF NOT EXISTS `review_comments` TEXT DEFAULT NULL AFTER `review_status`;

-- Add indexes for quote tracking
CREATE INDEX IF NOT EXISTS idx_quote_selection ON rfq_quotes(is_selected);
CREATE INDEX IF NOT EXISTS idx_quote_review_status ON rfq_quotes(review_status);

-- Update procurement_requests workflow documentation
-- Add column to track if request needs RFQ (computed from request type and amount)
ALTER TABLE `procurement_requests`
ADD COLUMN IF NOT EXISTS `requires_rfq` TINYINT(1) DEFAULT 0 AFTER `external_approval_required`,
ADD COLUMN IF NOT EXISTS `rfq_letter_generated_at` DATETIME DEFAULT NULL AFTER `requires_rfq`;

-- Create index for tracking RFQ requirements
CREATE INDEX IF NOT EXISTS idx_pr_requires_rfq ON procurement_requests(requires_rfq);

-- Update commitments to ensure proper workflow connection
-- Add column to track quote approval timestamp
ALTER TABLE `commitments`
ADD COLUMN IF NOT EXISTS `quote_approved_at` DATETIME DEFAULT NULL AFTER `selected_quote_id`,
ADD COLUMN IF NOT EXISTS `gfms_generated` TINYINT(1) DEFAULT 0 AFTER `quote_approved_at`;

-- Update purchase orders to track commitment approval dependency
ALTER TABLE `purchase_orders`
ADD COLUMN IF NOT EXISTS `commitment_approved_at` DATETIME DEFAULT NULL AFTER `excess_approved_at`,
ADD COLUMN IF NOT EXISTS `gfms_generated` TINYINT(1) DEFAULT 0 AFTER `commitment_approved_at`;

-- Update invoices to track PO approval dependency
ALTER TABLE `invoices`
ADD COLUMN IF NOT EXISTS `po_approved_at` DATETIME DEFAULT NULL AFTER `created_at`,
ADD COLUMN IF NOT EXISTS `gfms_generated` TINYINT(1) DEFAULT 0 AFTER `po_approved_at`,
ADD COLUMN IF NOT EXISTS `invoice_source` ENUM('VENDOR_UPLOADED','SYSTEM_GENERATED','MANUAL') DEFAULT 'VENDOR_UPLOADED' AFTER `gfms_generated`;

-- Create indexes for workflow enforcement
CREATE INDEX IF NOT EXISTS idx_commitment_gfms_generated ON commitments(gfms_generated);
CREATE INDEX IF NOT EXISTS idx_po_gfms_generated ON purchase_orders(gfms_generated);
CREATE INDEX IF NOT EXISTS idx_invoice_source ON invoices(invoice_source);

-- Update request_approvals table for RFQ-related approvals
-- This table now tracks approvals across COMMITMENT, PO, INVOICE entities
-- Ensure it has proper entity type values
-- (no schema change needed, already supports entity_type)

-- Create trigger to auto-enable requires_rfq flag based on request attributes
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `trg_auto_set_requires_rfq` BEFORE INSERT ON `procurement_requests` FOR EACH ROW
BEGIN
    -- Check if this request requires RFQ
    -- Under threshold (≤500k) or direct types (PETTY_CASH, REIMBURSEMENT) don't need RFQ
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSEIF NEW.estimated_value <= 500000 THEN
        SET NEW.requires_rfq = 0;
    ELSE
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;

-- Create trigger to auto-update requires_rfq on update
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `trg_auto_update_requires_rfq` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW
BEGIN
    -- Check if this request requires RFQ
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSEIF NEW.estimated_value <= 500000 THEN
        SET NEW.requires_rfq = 0;
    ELSE
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;

-- Add trigger to ensure quote must be reviewed before commitment
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `trg_require_quote_review_for_commitment` BEFORE INSERT ON `commitments` FOR EACH ROW
BEGIN
    DECLARE review_status VARCHAR(50);
    DECLARE quote_id INT;

    -- If this commitment is linked to an RFQ
    IF NEW.rfq_id IS NOT NULL AND NEW.selected_quote_id IS NOT NULL THEN
        -- Check if the quote has been marked as approved (meets requirements)
        SELECT review_status
        INTO review_status
        FROM rfq_quotes
        WHERE quote_id = NEW.selected_quote_id
        LIMIT 1;

        -- Allow commitment creation if quote is marked as meeting requirements or no review status set
        -- This gives flexibility for different approval workflows
        IF review_status = 'DOES_NOT_MEET' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create commitment from quote that does not meet requirements';
        END IF;
    END IF;

END
$$
DELIMITER ;

-- Add trigger to ensure PO can only be created after commitment is finalized
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `trg_require_committed_amount_for_po` BEFORE INSERT ON `purchase_orders` FOR EACH ROW
BEGIN
    DECLARE commitment_exists INT DEFAULT 0;

    -- Check if commitment exists and is linked
    SELECT COUNT(*)
    INTO commitment_exists
    FROM commitments
    WHERE commitment_id = NEW.commitment_id
    LIMIT 1;

    IF commitment_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Commitment must exist before PO creation';
    END IF;

END
$$
DELIMITER ;

-- Add trigger to track when PO approvals complete (for invoice dependency)
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `trg_track_po_approval_date` BEFORE UPDATE ON `purchase_orders` FOR EACH ROW
BEGIN
    -- When PO moves to approved status, set the approval timestamp
    IF NEW.approved_by IS NOT NULL AND NEW.approved_at IS NOT NULL AND OLD.approved_by IS NULL THEN
        SET NEW.commitment_approved_at = NOW();
    END IF;
END
$$
DELIMITER ;

-- Update audit log to include new workflow stages
-- No schema changes needed, but we'll document the new entity types:
-- entity_type can be: 'PROCUREMENT_REQUEST', 'RFQ', 'RFQ_QUOTE_REVIEW', 'COMMITMENT', 'PO', 'INVOICE', 'PO_VARIATION'

-- Commit
COMMIT;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 011_add_document_upload_fields.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add document upload fields to commitments and purchase_orders
-- Date: 2026-02-19
-- Purpose: Enable users to upload commitment and PO documents directly from the forms

-- ===================================
-- ALTER TABLE commitments
-- ===================================
ALTER TABLE commitments ADD COLUMN IF NOT EXISTS document_path VARCHAR(255) NULL COMMENT 'Path to uploaded commitment document from GFMS' AFTER gfms_commitment_number;

-- Add index for potential file retrieval queries
CREATE INDEX IF NOT EXISTS idx_commitments_document_path ON commitments(document_path);

-- ===================================
-- ALTER TABLE purchase_orders (po)
-- ===================================
ALTER TABLE purchase_orders ADD COLUMN IF NOT EXISTS document_path VARCHAR(255) NULL COMMENT 'Path to uploaded PO document from GFMS' AFTER gfms_po_number;

-- Add index for potential file retrieval queries
CREATE INDEX IF NOT EXISTS idx_po_document_path ON purchase_orders(document_path);

-- ===================================
-- AUDIT LOG ENTRIES
-- ===================================
-- Log this migration in audit_log for compliance
INSERT INTO audit_log (table_name, record_id, action, notes)
VALUES ('DATABASE', 0, 'SCHEMA_CHANGE', 'Added document_path fields to commitments and purchase_orders tables for GFMS integration');

-- ===================================
-- VERIFICATION QUERIES
-- ===================================
-- Verify the new columns exist:
-- SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'commitments' AND COLUMN_NAME = 'document_path';
-- 
-- SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'purchase_orders' AND COLUMN_NAME = 'document_path';



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 011_fix_petty_cash_and_email_settings.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Update Petty Cash Limit and Procurement Threshold to Correct Values
-- Run this query to fix both values immediately

UPDATE `system_config` 
SET `config_value` = '5000', `description` = 'Maximum amount for petty cash procurement without formal approval (JMD)'
WHERE `config_key` = 'petty_cash_limit';

UPDATE `system_config` 
SET `config_value` = '500000', `description` = 'Threshold value for direct procurement eligibility (JMD)'
WHERE `config_key` = 'direct_procurement_threshold';

-- Ensure notifications are enabled
INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`)
VALUES ('enable_notifications', '1', 'Enable/disable email notifications (1=enabled, 0=disabled)')
ON DUPLICATE KEY UPDATE `config_value` = VALUES(`config_value`);

-- Verify the changes
SELECT `config_key`, `config_value`, `description` 
FROM `system_config` 
WHERE `config_key` IN ('petty_cash_limit', 'direct_procurement_threshold', 'enable_notifications');



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 012_assign_default_role_permissions.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration: Assign Default Permissions to System Roles
-- Purpose:   Ensure all roles have appropriate default permissions based on
--            their responsibilities in the SOP
-- Safety:    Uses INSERT IGNORE - existing mappings are preserved
-- Date:      2026-02-18
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Ensure all permissions exist in permissions table
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO permissions (name, description) VALUES
('view_audit_dashboard',       'Access audit dashboard and logs'),
('view_requests',              'View procurement requests'),
('view_commitments',           'View commitments'),
('view_purchase_orders',       'View purchase orders'),
('view_invoices',              'View invoices'),
('view_payments',              'View payments'),
('view_audit_logs',            'View audit logs'),
('create_request',             'Create new procurement requests'),
('edit_requests',              'Edit procurement requests, create RFQs, manage vendors'),
('submit_request',             'Submit requests for approval'),
('approve_request',            'Approve requests at assigned stage'),
('decline_request',            'Decline/reject requests'),
('create_commitment',          'Create commitments'),
('approve_commitment',         'Approve commitments'),
('create_purchase_order',      'Create purchase orders'),
('edit_purchase_order',        'Edit purchase orders'),
('approve_purchase_order',     'Approve purchase orders'),
('approve_po',                 'Approve POs (alternate permission name)'),
('approve_po_adjustment',      'Approve PO adjustments/variations'),
('approve_po_excess',          'Approve PO excess amounts'),
('request_po_adjustment',      'Request PO adjustments'),
('view_po_adjustments',        'View PO adjustments'),
('create_invoice',             'Create invoices'),
('record_invoice',             'Record received invoices'),
('create_payment',             'Create payments'),
('record_payment',             'Record payments made'),
('manage_users',               'Manage users, roles, and permissions'),
('view_audit_dashboard',       'Access audit dashboard'),
('view_finance_dashboard',     'Access finance dashboard'),
('view_management_dashboard',  'Access management dashboard'),
('view_monthly_dashboard',     'Access monthly metrics dashboard'),
('view_procurement_dashboard', 'Access procurement dashboard'),
('view_approval_analytics',    'Access approval analytics dashboard'),
('view_compliance',            'Access compliance dashboard'),
('view_financial_reports',     'View financial reports'),
('management_dashboard',       'Access management overview dashboard'),
('monthly_metrics',            'Access monthly financial metrics dashboard'),
('print_request',              'Print procurement requests'),
('print_purchase_order',       'Print purchase orders'),
('print_invoice',              'Print invoices'),
('approve_reimbursement_request', 'Approve reimbursement requests'),
('approve_petty_cash_request',    'Approve petty cash requests'),
('create_reimbursement_request',  'Create reimbursement requests'),
('create_petty_cash_request',     'Create petty cash requests'),
('author_override',            'Override approval chain decisions');


-- ═══════════════════════════════════════════════════════════
-- STEP 2: Assign permissions to each role
-- ═══════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────
-- Role 1: Viewer (Read-only audit access)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE name IN (
    'view_audit_dashboard',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs'
);

-- ───────────────────────────────────────────────────────────
-- Role 2: Procurement Officer
-- Can create/edit/submit requests, manage RFQs, create commitments/POs
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE name IN (
    'create_request',
    'edit_requests',
    'submit_request',
    'view_requests',
    'create_commitment',
    'view_commitments',
    'create_purchase_order',
    'edit_purchase_order',
    'view_purchase_orders',
    'request_po_adjustment',
    'view_po_adjustments',
    'view_audit_logs',
    'view_procurement_dashboard',
    'view_invoices',
    'view_payments',
    'print_request',
    'print_purchase_order',
    'create_reimbursement_request',
    'create_petty_cash_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 3: Finance Officer
-- Approve requests (finance stage), invoices, payments, reports
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
    'approve_request',
    'approve_commitment',
    'approve_po',
    'approve_purchase_order',
    'approve_po_adjustment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_finance_dashboard',
    'view_monthly_dashboard',
    'view_financial_reports',
    'view_audit_logs',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'monthly_metrics',
    'approve_reimbursement_request',
    'approve_petty_cash_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 4: HOD (Head of Department)
-- Approve requests (HOD stage), commitments, POs, view dashboards
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 4, id FROM permissions WHERE name IN (
    'approve_request',
    'decline_request',
    'approve_commitment',
    'approve_po',
    'approve_purchase_order',
    'approve_po_adjustment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_management_dashboard',
    'view_procurement_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_audit_logs',
    'management_dashboard',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'view_financial_reports',
    'monthly_metrics',
    'view_approval_analytics',
    'approve_petty_cash_request',
    'approve_reimbursement_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 5: Admin
-- Full system access with explicit permission grants
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions WHERE name IN (
    'manage_users',
    'create_request',
    'edit_requests',
    'submit_request',
    'approve_request',
    'decline_request',
    'create_commitment',
    'approve_commitment',
    'create_purchase_order',
    'edit_purchase_order',
    'approve_purchase_order',
    'approve_po',
    'approve_po_adjustment',
    'approve_po_excess',
    'request_po_adjustment',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_audit_dashboard',
    'view_finance_dashboard',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_procurement_dashboard',
    'view_po_adjustments',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'author_override',
    'approve_reimbursement_request',
    'approve_petty_cash_request',
    'create_reimbursement_request',
    'create_petty_cash_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 6: SuperAdmin
-- Full system access (all permissions)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions WHERE name IN (
    'manage_users',
    'create_request',
    'edit_requests',
    'submit_request',
    'approve_request',
    'decline_request',
    'create_commitment',
    'approve_commitment',
    'create_purchase_order',
    'edit_purchase_order',
    'approve_purchase_order',
    'approve_po',
    'approve_po_adjustment',
    'approve_po_excess',
    'request_po_adjustment',
    'create_invoice',
    'record_invoice',
    'create_payment',
    'record_payment',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_audit_dashboard',
    'view_finance_dashboard',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_procurement_dashboard',
    'view_po_adjustments',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice',
    'author_override',
    'approve_reimbursement_request',
    'approve_petty_cash_request',
    'create_reimbursement_request',
    'create_petty_cash_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 7: Evaluation Committee Member
-- Limited access to view assigned requests and RFQs for evaluation
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions WHERE name IN (
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_audit_logs'
);

-- ───────────────────────────────────────────────────────────
-- Role 8: Procurement Committee
-- Approve requests at committee stage, view procurement data
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 8, id FROM permissions WHERE name IN (
    'approve_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_audit_logs',
    'print_request'
);

-- ───────────────────────────────────────────────────────────
-- Role 9: Deputy Government Chemist (DGC)
-- Final approval authority, external compliance checks
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 9, id FROM permissions WHERE name IN (
    'approve_request',
    'decline_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_financial_reports',
    'view_approval_analytics',
    'view_compliance',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);

-- ───────────────────────────────────────────────────────────
-- Role 10: Director HRM&A
-- Approval authority for HRM&A branch requests, dashboard access
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 10, id FROM permissions WHERE name IN (
    'approve_request',
    'decline_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_financial_reports',
    'view_approval_analytics',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);

-- ───────────────────────────────────────────────────────────
-- Role 11: Director Procurement
-- Director-level procurement oversight and approvals
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 11, id FROM permissions WHERE name IN (
    'approve_request',
    'approve_commitment',
    'approve_po',
    'approve_purchase_order',
    'approve_po_adjustment',
    'decline_request',
    'view_requests',
    'view_commitments',
    'view_purchase_orders',
    'view_invoices',
    'view_payments',
    'view_audit_logs',
    'view_management_dashboard',
    'view_monthly_dashboard',
    'view_finance_dashboard',
    'view_financial_reports',
    'view_approval_analytics',
    'view_procurement_dashboard',
    'management_dashboard',
    'monthly_metrics',
    'print_request',
    'print_purchase_order',
    'print_invoice'
);

-- ───────────────────────────────────────────────────────────
-- Role 12: Requestor
-- Can create and submit requests for approvals
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 12, id FROM permissions WHERE name IN (
    'create_request',
    'edit_requests',
    'submit_request',
    'view_requests',
    'print_request',
    'create_reimbursement_request',
    'create_petty_cash_request'
);


-- ═══════════════════════════════════════════════════════════
-- STEP 3: Verification Queries
-- ═══════════════════════════════════════════════════════════

-- Check that all roles have permissions assigned:
SELECT 
    r.id,
    r.name,
    COUNT(rp.permission_id) as permission_count
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
GROUP BY r.id, r.name
ORDER BY r.id;

-- Check permission counts by role type:
SELECT 
    r.name as role_name,
    COUNT(DISTINCT p.name) as unique_permissions
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
WHERE r.id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
GROUP BY r.id, r.name
ORDER BY r.id;

-- List permissions for each role (for review):
SELECT 
    r.name as role_name,
    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ', ') as permissions
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
WHERE r.id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
GROUP BY r.id, r.name
ORDER BY r.id;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 013_comprehensive_permissions_65.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration: Comprehensive Permissions System (65 Total Permissions)
-- Purpose:   Create all permissions needed for granular access control
-- Date:      2026-02-18
-- Note:      Extends migration 012 with 23 additional granular permissions
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Insert All Permissions (65 Total)
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO permissions (name, description) VALUES
-- VIEW PERMISSIONS (12)
('view_audit_dashboard',       'Access audit dashboard and logs'),
('view_requests',              'View all procurement requests'),
('view_reimbursement_requests','View all reimbursement requests'),
('view_petty_cash_requests',   'View all petty cash requests'),
('view_commitments',           'View commitments'),
('view_purchase_orders',       'View purchase orders'),
('view_invoices',              'View invoices'),
('view_payments',              'View payments'),
('view_audit_logs',            'View audit logs'),
('view_po_adjustments',        'View PO adjustments'),
('view_compliance',            'Access compliance dashboard'),
('view_financial_reports',     'View financial reports'),

-- CREATE/EDIT PERMISSIONS (9)
('create_request',             'Create new procurement requests'),
('edit_requests',              'Edit procurement requests'),
('create_reimbursement_request', 'Create reimbursement requests'),
('create_petty_cash_request',  'Create petty cash requests'),
('create_commitment',          'Create commitments'),
('create_purchase_order',      'Create purchase orders'),
('create_invoice',             'Create invoices'),
('create_payment',             'Create payments'),
('edit_purchase_order',        'Edit purchase orders'),

-- SUBMIT/MANAGEMENT PERMISSIONS (4)
('submit_request',             'Submit requests for approval'),
('submit_own_request',         'Submit own requests'),
('resubmit_request',           'Resubmit declined requests'),
('request_po_adjustment',      'Request PO adjustments'),

-- APPROVAL PERMISSIONS (8)
('approve_request',            'Approve requests at assigned stage'),
('approve_commitment',         'Approve commitments'),
('approve_purchase_order',     'Approve purchase orders'),
('approve_po',                 'Approve POs (alternate name)'),
('approve_po_excess',          'Approve PO excess amounts'),
('approve_reimbursement_request', 'Approve reimbursement requests'),
('approve_petty_cash_request', 'Approve petty cash requests'),
('decline_request',            'Decline/reject requests'),

-- AUTHORIZATION PERMISSIONS (3)
('authorize_reimbursement',    'Authorize reimbursement (Branch Head)'),
('authorize_petty_cash',       'Authorize petty cash (Branch Head)'),
('approve_po_adjustment',      'Approve PO adjustments/variations'),

-- DOCUMENT/UPLOAD PERMISSIONS (3)
('upload_commitment',          'Upload commitment documents'),
('upload_purchase_order',      'Upload PO documents'),
('manage_attachments',         'Add/remove document attachments'),

-- VERIFICATION/RECONCILIATION PERMISSIONS (3)
('verify_reimbursement_goods', 'Verify goods/services for reimbursement'),
('verify_petty_cash_reconciliation', 'Verify petty cash 24-hour reconciliation'),
('record_invoice',             'Record receipt of invoice'),

-- FINANCE/PAYMENT PERMISSIONS (2)
('record_payment',             'Record payment made'),
('reconcile_petty_cash',       'Reconcile petty cash after 24h'),

-- RFQ/EVALUATION PERMISSIONS (4)
('view_rfq_evaluations',       'View RFQ evaluations'),
('vote_rfq',                   'Vote on RFQ evaluations'),
('manage_rfq_committee',       'Add/remove RFQ committee members'),
('award_rfq',                  'Award RFQ to vendor'),

-- VENDOR MANAGEMENT PERMISSIONS (2)
('manage_vendors',             'Add, edit, delete vendors'),
('view_vendor_history',        'View vendor performance history'),

-- VIEW OWN REQUEST PERMISSIONS (1)
('view_own_requests',          'View only own submitted requests'),

-- EXPORT PERMISSIONS (1)
('export_requests',            'Export request data to CSV/Excel'),

-- DASHBOARD PERMISSIONS (6)
('view_finance_dashboard',     'Access finance dashboard'),
('view_management_dashboard',  'Access management dashboard'),
('view_monthly_dashboard',     'Access monthly metrics dashboard'),
('view_procurement_dashboard', 'Access procurement dashboard'),
('view_approval_analytics',    'Access approval analytics dashboard'),
('management_dashboard',       'Access management overview dashboard'),

-- PRINT PERMISSIONS (3)
('print_request',              'Print procurement requests'),
('print_purchase_order',       'Print purchase orders'),
('print_invoice',              'Print invoices'),

-- ADMIN PERMISSIONS (3)
('manage_users',               'Manage users, roles, and permissions'),
('manage_system_settings',     'Configure system settings'),
('author_override',            'Override approval chain decisions'),

-- SPECIAL ROLE PERMISSIONS (2)
('approve_as_director_hrma',   'Approve requests as Director HRM&A'),
('view_director_dashboard',    'Access Director for Procurement dashboard'),

-- MONTHLY METRICS (1)
('monthly_metrics',            'Access monthly financial metrics dashboard');


-- ═══════════════════════════════════════════════════════════
-- STEP 2: Map Permissions to Roles
-- ═══════════════════════════════════════════════════════════

-- Role 1: Viewer (Read-only)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE name IN (
    'view_audit_dashboard', 'view_requests', 'view_reimbursement_requests',
    'view_petty_cash_requests', 'view_commitments', 'view_purchase_orders',
    'view_invoices', 'view_payments', 'view_audit_logs'
);

-- Role 2: Procurement Officer
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE name IN (
    'create_request', 'edit_requests', 'submit_request', 'view_requests',
    'create_reimbursement_request', 'create_petty_cash_request',
    'create_commitment', 'view_commitments', 'create_purchase_order',
    'edit_purchase_order', 'view_purchase_orders', 'request_po_adjustment',
    'view_po_adjustments', 'view_audit_logs', 'view_procurement_dashboard',
    'view_invoices', 'view_payments', 'print_request', 'print_purchase_order',
    'manage_vendors', 'view_vendor_history', 'upload_commitment',
    'upload_purchase_order', 'manage_attachments'
);

-- Role 3: Finance Officer
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
    'approve_request', 'approve_commitment', 'approve_purchase_order',
    'approve_po', 'approve_po_adjustment', 'view_requests',
    'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'create_invoice', 'record_invoice', 'create_payment',
    'record_payment', 'reconcile_petty_cash', 'verify_reimbursement_goods',
    'verify_petty_cash_reconciliation', 'view_finance_dashboard',
    'view_monthly_dashboard', 'view_financial_reports', 'view_audit_logs',
    'print_request', 'print_purchase_order', 'print_invoice', 'monthly_metrics',
    'approve_reimbursement_request', 'approve_petty_cash_request',
    'export_requests'
);

-- Role 4: HOD (Head of Department)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 4, id FROM permissions WHERE name IN (
    'approve_request', 'decline_request', 'approve_commitment',
    'approve_purchase_order', 'approve_po', 'approve_po_adjustment',
    'authorize_petty_cash', 'view_requests', 'view_reimbursement_requests',
    'view_petty_cash_requests', 'view_commitments', 'view_purchase_orders',
    'view_invoices', 'view_payments', 'view_management_dashboard',
    'view_procurement_dashboard', 'view_monthly_dashboard',
    'view_finance_dashboard', 'view_audit_logs', 'management_dashboard',
    'print_request', 'print_purchase_order', 'print_invoice',
    'view_financial_reports', 'monthly_metrics', 'view_approval_analytics',
    'approve_reimbursement_request', 'approve_petty_cash_request',
    'export_requests'
);

-- Role 5: Admin
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions WHERE name IN (
    'manage_users', 'manage_system_settings', 'author_override',
    'create_request', 'edit_requests', 'submit_request', 'approve_request',
    'decline_request', 'create_reimbursement_request',
    'create_petty_cash_request', 'authorize_reimbursement',
    'authorize_petty_cash', 'create_commitment', 'approve_commitment',
    'create_purchase_order', 'edit_purchase_order', 'approve_purchase_order',
    'approve_po', 'approve_po_excess', 'request_po_adjustment',
    'approve_po_adjustment', 'create_invoice', 'record_invoice',
    'create_payment', 'record_payment', 'verify_reimbursement_goods',
    'verify_petty_cash_reconciliation', 'reconcile_petty_cash',
    'upload_commitment', 'upload_purchase_order', 'manage_attachments',
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_po_adjustments',
    'view_compliance', 'view_financial_reports', 'view_own_requests',
    'export_requests', 'view_finance_dashboard', 'view_management_dashboard',
    'view_monthly_dashboard', 'view_procurement_dashboard',
    'view_approval_analytics', 'management_dashboard', 'monthly_metrics',
    'print_request', 'print_purchase_order', 'print_invoice',
    'view_rfq_evaluations', 'vote_rfq', 'manage_rfq_committee', 'award_rfq',
    'manage_vendors', 'view_vendor_history', 'view_audit_dashboard'
);

-- Role 6: SuperAdmin (All permissions)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions;

-- Role 7: Evaluation Committee Member
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions WHERE name IN (
    'view_requests', 'view_commitments', 'view_purchase_orders',
    'view_audit_logs', 'view_rfq_evaluations', 'vote_rfq'
);

-- Role 8: Procurement Committee
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 8, id FROM permissions WHERE name IN (
    'approve_request', 'view_requests', 'view_commitments',
    'view_purchase_orders', 'view_audit_logs', 'print_request',
    'view_rfq_evaluations'
);

-- Role 9: Deputy Government Chemist (DGC)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 9, id FROM permissions WHERE name IN (
    'approve_request', 'decline_request', 'view_requests',
    'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_management_dashboard',
    'view_monthly_dashboard', 'view_finance_dashboard',
    'view_financial_reports', 'view_approval_analytics', 'view_compliance',
    'management_dashboard', 'monthly_metrics', 'print_request',
    'print_purchase_order', 'print_invoice', 'export_requests'
);

-- Role 10: Director HRM&A
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 10, id FROM permissions WHERE name IN (
    'approve_request', 'approve_as_director_hrma', 'decline_request',
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_management_dashboard',
    'view_monthly_dashboard', 'view_finance_dashboard',
    'view_financial_reports', 'view_approval_analytics', 'management_dashboard',
    'monthly_metrics', 'print_request', 'print_purchase_order',
    'print_invoice', 'export_requests'
);

-- Role 11: Director Procurement
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 11, id FROM permissions WHERE name IN (
    'approve_request', 'approve_commitment', 'approve_purchase_order',
    'approve_po', 'approve_po_adjustment', 'decline_request',
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_management_dashboard',
    'view_monthly_dashboard', 'view_finance_dashboard',
    'view_financial_reports', 'view_approval_analytics',
    'view_procurement_dashboard', 'view_director_dashboard',
    'management_dashboard', 'monthly_metrics', 'print_request',
    'print_purchase_order', 'print_invoice', 'export_requests',
    'view_rfq_evaluations', 'manage_rfq_committee', 'award_rfq',
    'manage_vendors'
);

-- Role 12: Requestor
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 12, id FROM permissions WHERE name IN (
    'create_request', 'edit_requests', 'submit_request',
    'resubmit_request', 'view_own_requests', 'create_reimbursement_request',
    'create_petty_cash_request', 'print_request'
);

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Secondary Roles (Additional permissions for specific scenarios)
-- ═══════════════════════════════════════════════════════════

-- Branch Head permissions (for supervisory staff)
-- Can authorize reimbursements and petty cash
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT role_id, p.id
FROM (SELECT id as role_id FROM roles WHERE name IN ('HOD', 'Director HRM&A')) r
JOIN permissions p ON p.name IN (
    'authorize_reimbursement', 'authorize_petty_cash',
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation'
);

-- Procurement verification staff
-- Can verify goods but not approve full requests
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT role_id, p.id
FROM (SELECT id as role_id FROM roles WHERE name = 'Procurement Officer') r
JOIN permissions p ON p.name IN (
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation',
    'award_rfq', 'manage_rfq_committee'
);

-- ═══════════════════════════════════════════════════════════
-- STEP 4: Verification Queries
-- ═══════════════════════════════════════════════════════════

-- Count total permissions created
SELECT COUNT(*) as total_permissions FROM permissions;

-- Verify all 12 roles have permissions
SELECT 
    r.id, r.name,
    COUNT(DISTINCT rp.permission_id) as permission_count
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
WHERE r.id BETWEEN 1 AND 12
GROUP BY r.id, r.name
ORDER BY r.id;

-- Show permission breakdown by category
SELECT 
    CASE 
        WHEN name LIKE 'view_%' THEN 'View'
        WHEN name LIKE 'create_%' THEN 'Create'
        WHEN name LIKE 'approve_%' THEN 'Approve'
        WHEN name LIKE 'authorize_%' THEN 'Authorize'
        WHEN name LIKE 'verify_%' THEN 'Verify'
        WHEN name LIKE 'record_%' THEN 'Record'
        WHEN name LIKE 'edit_%' THEN 'Edit'
        WHEN name LIKE 'upload_%' THEN 'Upload'
        WHEN name LIKE 'manage_%' THEN 'Manage'
        WHEN name LIKE 'vote_%' THEN 'Vote'
        WHEN name LIKE 'award_%' THEN 'Award'
        WHEN name LIKE 'print_%' THEN 'Print'
        WHEN name IN ('submit_request', 'resubmit_request', 'request_po_adjustment', 'decline_request', 'export_requests', 'reconcile_petty_cash') THEN 'Submit/Export'
        WHEN name IN ('management_dashboard', 'monthly_metrics', 'author_override') THEN 'Admin'
        ELSE 'Other'
    END as category,
    COUNT(*) as count
FROM permissions
GROUP BY category
ORDER BY count DESC;

-- List all permissions by role (for audit)
SELECT 
    r.name as role_name,
    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ', ') as permissions
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
WHERE r.id BETWEEN 1 AND 12
GROUP BY r.id, r.name
ORDER BY r.id;

-- Find permissions assigned to only one role
SELECT 
    p.name,
    COUNT(DISTINCT rp.role_id) as assigned_to_roles,
    GROUP_CONCAT(DISTINCT r.name ORDER BY r.name SEPARATOR ', ') as roles
FROM permissions p
LEFT JOIN role_permissions rp ON p.id = rp.permission_id
LEFT JOIN roles r ON rp.role_id = r.id
GROUP BY p.id, p.name
HAVING assigned_to_roles = 1
ORDER BY p.name;

-- Find orphaned permissions (not assigned to any role)
SELECT 
    p.id,
    p.name,
    p.description
FROM permissions p
WHERE NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.permission_id = p.id
)
ORDER BY p.name;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 014_fix_finance_commitment_permissions.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration 014: Fix Finance Officer Missing Permissions
-- =====================================================
-- Finance Officer (role_id=3) is missing: create_commitment, verify_funds, upload_commitment
-- Procurement Officer (role_id=2) already has: create_commitment, upload_commitment
-- This migration ensures both roles can create commitments at QUOTE_APPROVED stage.

-- Add missing permissions to Finance Officer (role_id = 3)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
    'create_commitment',
    'verify_funds',
    'upload_commitment'
);

-- Ensure verify_funds permission exists
INSERT IGNORE INTO permissions (name, description)
VALUES ('verify_funds', 'Verify fund availability for procurement requests');



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 015_dynamic_threshold_triggers.sql
-- ═══════════════════════════════════════════════════════════════════════

-- =====================================================================
-- Migration 015: Dynamic Threshold Triggers
-- =====================================================================
-- Updates the requires_rfq triggers to read the procurement threshold
-- from system_config instead of using a hardcoded 500000 value.
-- This ensures that when the threshold is changed in Admin → Settings,
-- the trigger logic adapts automatically.
-- =====================================================================

-- Drop old triggers
DROP TRIGGER IF EXISTS `trg_auto_set_requires_rfq`;
DROP TRIGGER IF EXISTS `trg_auto_update_requires_rfq`;

-- Recreate INSERT trigger reading threshold from system_config
DELIMITER $$
CREATE TRIGGER `trg_auto_set_requires_rfq` BEFORE INSERT ON `procurement_requests` FOR EACH ROW
BEGIN
    DECLARE v_threshold DECIMAL(15,2) DEFAULT 500000.00;

    -- Read threshold dynamically from system_config
    SELECT CAST(config_value AS DECIMAL(15,2))
      INTO v_threshold
      FROM system_config
     WHERE config_key = 'direct_procurement_threshold'
     LIMIT 1;

    -- PETTY_CASH and REIMBURSEMENT never require RFQ (direct workflows)
    -- ALL REGULAR requests now require RFQ regardless of threshold,
    -- but the threshold determines simplified vs full evaluation.
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSE
        -- All regular procurement requires RFQ
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;

-- Recreate UPDATE trigger reading threshold from system_config
DELIMITER $$
CREATE TRIGGER `trg_auto_update_requires_rfq` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW
BEGIN
    DECLARE v_threshold DECIMAL(15,2) DEFAULT 500000.00;

    -- Read threshold dynamically from system_config
    SELECT CAST(config_value AS DECIMAL(15,2))
      INTO v_threshold
      FROM system_config
     WHERE config_key = 'direct_procurement_threshold'
     LIMIT 1;

    -- PETTY_CASH and REIMBURSEMENT never require RFQ (direct workflows)
    IF NEW.request_type IN ('PETTY_CASH', 'REIMBURSEMENT') THEN
        SET NEW.requires_rfq = 0;
    ELSE
        -- All regular procurement requires RFQ
        SET NEW.requires_rfq = 1;
    END IF;
END
$$
DELIMITER ;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 016_granular_permissions_and_role_mapping.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration 016: Granular Permissions & Correct Role Mapping
-- ============================================================================
-- Purpose:
--   1. Add new fine-grained permissions for vendor awarding, RFQ management,
--      quote upload, evaluation, vendor management, etc.
--   2. Auto-map every permission to the correct roles so the system works
--      out of the box after running this script.
--   3. Fix the admin role bypass bug (lowercase 'admin' vs 'Admin').
--
-- New permissions created:
--   - award_vendor            : Award an RFQ to a selected vendor
--   - confirm_vendor_award    : Accept/decline vendor award decision
--   - upload_rfq_quote        : Upload vendor quotation documents
--   - start_rfq_evaluation    : Initiate the evaluation stage for an RFQ
--   - upload_rfq_report       : Upload evaluation report for an RFQ
--   - create_rfq              : Create a new RFQ from a procurement request
--   - add_rfq_vendor          : Add vendors to an RFQ invitation list
--   - view_vendors            : View vendor list and details
--   - approve_as_dgc          : Approve requests as Deputy Government Chemist
--   - disburse_petty_cash     : Disburse petty cash funds
--   - process_reimbursement   : Process reimbursement payments
--
-- Date: 2026-02-22
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Insert New Permissions (INSERT IGNORE — safe to re-run)
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO permissions (name, description) VALUES
-- Vendor Awarding (split from generic award_rfq)
('award_vendor',             'Award an RFQ to a selected vendor quote'),
('confirm_vendor_award',     'Accept or decline a vendor award decision'),

-- RFQ Lifecycle
('upload_rfq_quote',         'Upload vendor quotation documents to an RFQ'),
('start_rfq_evaluation',     'Start the evaluation stage for an RFQ'),
('upload_rfq_report',        'Upload evaluation report for an RFQ'),
('create_rfq',               'Create a new RFQ from a procurement request'),
('add_rfq_vendor',           'Add vendors to an RFQ invitation list'),

-- Vendor Management (view separated from manage)
('view_vendors',             'View vendor list and details'),

-- Role-specific approval
('approve_as_dgc',           'Approve requests as Deputy Government Chemist'),

-- Petty Cash / Reimbursement lifecycle
('disburse_petty_cash',      'Disburse petty cash funds after authorization'),
('process_reimbursement',    'Process reimbursement payment after approval');


-- ═══════════════════════════════════════════════════════════
-- STEP 2: Complete Role → Permission Mapping
-- ═══════════════════════════════════════════════════════════
-- Uses INSERT IGNORE so it's safe to re-run.
-- Each role gets exactly the permissions it needs.

-- ───────────────────────────────────────────────────────────
-- Role 1: Viewer (Read-only access)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE name IN (
    'view_audit_dashboard', 'view_requests', 'view_reimbursement_requests',
    'view_petty_cash_requests', 'view_commitments', 'view_purchase_orders',
    'view_invoices', 'view_payments', 'view_audit_logs', 'view_vendors',
    'view_rfq_evaluations'
);

-- ───────────────────────────────────────────────────────────
-- Role 2: Procurement Officer
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE name IN (
    -- Core request lifecycle
    'create_request', 'edit_requests', 'submit_request', 'view_requests',
    'create_reimbursement_request', 'create_petty_cash_request',
    -- Commitments
    'create_commitment', 'view_commitments', 'upload_commitment',
    -- Purchase Orders
    'create_purchase_order', 'edit_purchase_order', 'view_purchase_orders',
    'upload_purchase_order', 'request_po_adjustment', 'view_po_adjustments',
    -- RFQ lifecycle (Procurement Officer drives the RFQ process)
    'create_rfq', 'add_rfq_vendor', 'upload_rfq_quote',
    'start_rfq_evaluation', 'upload_rfq_report',
    'manage_rfq_committee', 'award_rfq', 'award_vendor',
    'view_rfq_evaluations',
    -- Vendor management
    'manage_vendors', 'view_vendors', 'view_vendor_history',
    -- Documents & dashboards
    'manage_attachments', 'view_audit_logs',
    'view_procurement_dashboard',
    'print_request', 'print_purchase_order',
    -- Verification
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation'
);

-- ───────────────────────────────────────────────────────────
-- Role 3: Finance Officer
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
    -- Approvals
    'approve_request', 'approve_commitment', 'approve_purchase_order',
    'approve_po', 'approve_po_adjustment', 'approve_po_excess',
    'approve_reimbursement_request', 'approve_petty_cash_request',
    -- Financial operations
    'create_invoice', 'record_invoice', 'create_payment', 'record_payment',
    'create_commitment', 'upload_commitment', 'verify_funds',
    'reconcile_petty_cash', 'disburse_petty_cash', 'process_reimbursement',
    -- Verification
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation',
    -- View everything financial
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_vendors', 'view_audit_logs',
    'view_rfq_evaluations',
    -- Dashboards & reports
    'view_finance_dashboard', 'view_monthly_dashboard',
    'view_financial_reports', 'monthly_metrics',
    -- Print & export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 4: HOD (Head of Department)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 4, id FROM permissions WHERE name IN (
    -- Approvals
    'approve_request', 'decline_request', 'approve_commitment',
    'approve_purchase_order', 'approve_po', 'approve_po_adjustment',
    'approve_reimbursement_request', 'approve_petty_cash_request',
    'authorize_petty_cash', 'authorize_reimbursement',
    -- Vendor awarding (HOD can confirm awards)
    'award_rfq', 'award_vendor', 'confirm_vendor_award',
    -- Verification
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation',
    -- View everything
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_vendors', 'view_audit_logs',
    'view_rfq_evaluations',
    -- Dashboards & reports
    'view_management_dashboard', 'view_procurement_dashboard',
    'view_monthly_dashboard', 'view_finance_dashboard',
    'view_financial_reports', 'view_approval_analytics',
    'management_dashboard', 'monthly_metrics',
    -- Print & export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 5: Admin
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions WHERE name IN (
    -- Full admin + system
    'manage_users', 'manage_system_settings', 'author_override',
    -- All request lifecycle
    'create_request', 'edit_requests', 'submit_request',
    'approve_request', 'decline_request',
    'create_reimbursement_request', 'create_petty_cash_request',
    'authorize_reimbursement', 'authorize_petty_cash',
    'approve_reimbursement_request', 'approve_petty_cash_request',
    -- All commitment
    'create_commitment', 'approve_commitment', 'upload_commitment',
    -- All PO
    'create_purchase_order', 'edit_purchase_order', 'approve_purchase_order',
    'approve_po', 'approve_po_excess', 'request_po_adjustment',
    'approve_po_adjustment', 'upload_purchase_order',
    -- All financial
    'create_invoice', 'record_invoice', 'create_payment', 'record_payment',
    'verify_funds', 'reconcile_petty_cash', 'disburse_petty_cash',
    'process_reimbursement',
    -- All verification
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation',
    -- All RFQ
    'create_rfq', 'add_rfq_vendor', 'upload_rfq_quote',
    'start_rfq_evaluation', 'upload_rfq_report',
    'manage_rfq_committee', 'award_rfq', 'award_vendor',
    'confirm_vendor_award', 'vote_rfq', 'view_rfq_evaluations',
    -- All vendor
    'manage_vendors', 'view_vendors', 'view_vendor_history',
    -- All documents
    'manage_attachments',
    -- All views
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_po_adjustments',
    'view_compliance', 'view_financial_reports', 'view_own_requests',
    -- All dashboards
    'view_finance_dashboard', 'view_management_dashboard',
    'view_monthly_dashboard', 'view_procurement_dashboard',
    'view_approval_analytics', 'management_dashboard',
    'view_audit_dashboard', 'monthly_metrics',
    'view_director_dashboard', 'approve_as_director_hrma',
    -- All print/export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 6: SuperAdmin (All permissions — automatic)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions;

-- ───────────────────────────────────────────────────────────
-- Role 7: Evaluation Committee Member
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions WHERE name IN (
    'view_requests', 'view_commitments', 'view_purchase_orders',
    'view_audit_logs', 'view_rfq_evaluations', 'vote_rfq',
    'view_vendors', 'upload_rfq_report'
);

-- ───────────────────────────────────────────────────────────
-- Role 8: Procurement Committee
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 8, id FROM permissions WHERE name IN (
    'approve_request', 'view_requests', 'view_commitments',
    'view_purchase_orders', 'view_audit_logs', 'print_request',
    'view_rfq_evaluations', 'view_vendors',
    'award_rfq', 'award_vendor', 'confirm_vendor_award'
);

-- ───────────────────────────────────────────────────────────
-- Role 9: Deputy Government Chemist (DGC)
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 9, id FROM permissions WHERE name IN (
    -- Approvals
    'approve_request', 'decline_request', 'approve_as_dgc',
    'approve_commitment',
    -- Vendor awarding (final authority)
    'award_rfq', 'award_vendor', 'confirm_vendor_award',
    -- Views
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_vendors',
    'view_rfq_evaluations',
    -- Dashboards & reports
    'view_management_dashboard', 'view_monthly_dashboard',
    'view_finance_dashboard', 'view_financial_reports',
    'view_approval_analytics', 'view_compliance',
    'management_dashboard', 'monthly_metrics',
    -- Print & export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 10: Director HRM&A
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 10, id FROM permissions WHERE name IN (
    -- Approvals
    'approve_request', 'approve_as_director_hrma', 'decline_request',
    'approve_commitment',
    -- Vendor awarding
    'award_rfq', 'award_vendor', 'confirm_vendor_award',
    -- Views
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs', 'view_vendors',
    'view_rfq_evaluations',
    -- Authorization
    'authorize_reimbursement', 'authorize_petty_cash',
    'verify_reimbursement_goods', 'verify_petty_cash_reconciliation',
    -- Dashboards & reports
    'view_management_dashboard', 'view_monthly_dashboard',
    'view_finance_dashboard', 'view_financial_reports',
    'view_approval_analytics', 'management_dashboard', 'monthly_metrics',
    -- Print & export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 11: Director Procurement
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 11, id FROM permissions WHERE name IN (
    -- Approvals
    'approve_request', 'approve_commitment', 'approve_purchase_order',
    'approve_po', 'approve_po_adjustment', 'decline_request',
    -- Full RFQ control
    'create_rfq', 'add_rfq_vendor', 'start_rfq_evaluation',
    'upload_rfq_report', 'manage_rfq_committee',
    'award_rfq', 'award_vendor', 'confirm_vendor_award',
    'view_rfq_evaluations',
    -- Vendor management
    'manage_vendors', 'view_vendors', 'view_vendor_history',
    -- Views
    'view_requests', 'view_reimbursement_requests', 'view_petty_cash_requests',
    'view_commitments', 'view_purchase_orders', 'view_invoices',
    'view_payments', 'view_audit_logs',
    -- Dashboards & reports
    'view_management_dashboard', 'view_monthly_dashboard',
    'view_finance_dashboard', 'view_financial_reports',
    'view_approval_analytics', 'view_procurement_dashboard',
    'view_director_dashboard',
    'management_dashboard', 'monthly_metrics',
    -- Print & export
    'print_request', 'print_purchase_order', 'print_invoice',
    'export_requests'
);

-- ───────────────────────────────────────────────────────────
-- Role 12: Requestor
-- ───────────────────────────────────────────────────────────
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 12, id FROM permissions WHERE name IN (
    'create_request', 'edit_requests', 'submit_request',
    'submit_own_request', 'resubmit_request', 'view_own_requests',
    'create_reimbursement_request', 'create_petty_cash_request',
    'print_request', 'view_vendors'
);


-- ═══════════════════════════════════════════════════════════
-- STEP 3: Verification Queries
-- ═══════════════════════════════════════════════════════════

-- Total permissions should now be ~76
SELECT COUNT(*) AS total_permissions FROM permissions;

-- Permissions per role
SELECT
    r.id, r.name AS role_name,
    COUNT(DISTINCT rp.permission_id) AS perm_count
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
WHERE r.id BETWEEN 1 AND 12
GROUP BY r.id, r.name
ORDER BY r.id;

-- New permissions verification
SELECT id, name, description
FROM permissions
WHERE name IN (
    'award_vendor', 'confirm_vendor_award', 'upload_rfq_quote',
    'start_rfq_evaluation', 'upload_rfq_report', 'create_rfq',
    'add_rfq_vendor', 'view_vendors', 'approve_as_dgc',
    'disburse_petty_cash', 'process_reimbursement'
)
ORDER BY name;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 017_acting_roles.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- Migration 017: Acting Role Assignments
-- ═══════════════════════════════════════════════════════════════
-- Allows users to temporarily act in another role (e.g. HOD
-- acting as Deputy GC while on leave). Admins assign acting
-- roles with optional date ranges. Users can switch between
-- their primary role and any active acting role.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `acting_roles` (
    `id`            INT AUTO_INCREMENT PRIMARY KEY,
    `user_id`       INT NOT NULL,
    `acting_role_id` INT NOT NULL COMMENT 'The role this user can act in',
    `assigned_by`   INT NOT NULL COMMENT 'Admin who created the assignment',
    `reason`        VARCHAR(255) DEFAULT NULL COMMENT 'e.g. "Leave cover for J. Smith"',
    `starts_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ends_at`       DATETIME DEFAULT NULL COMMENT 'NULL = indefinite until manually revoked',
    `is_active`     TINYINT(1) NOT NULL DEFAULT 1,
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`)        REFERENCES `users`(`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`acting_role_id`) REFERENCES `roles`(`id`)      ON DELETE CASCADE,
    FOREIGN KEY (`assigned_by`)    REFERENCES `users`(`user_id`) ON DELETE CASCADE,
    UNIQUE KEY `uq_user_acting_role` (`user_id`, `acting_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit log for every role switch
CREATE TABLE IF NOT EXISTS `acting_role_log` (
    `id`            INT AUTO_INCREMENT PRIMARY KEY,
    `user_id`       INT NOT NULL,
    `switched_from_role_id` INT NOT NULL,
    `switched_to_role_id`   INT NOT NULL,
    `is_acting`     TINYINT(1) NOT NULL COMMENT '1=switched to acting, 0=reverted to primary',
    `ip_address`    VARCHAR(45) DEFAULT NULL,
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 018_fix_lock_triggers_for_commitments.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Fix lock triggers that block legitimate forward transitions
-- from GC_APPROVED/AWARDED/COMPLETED statuses.
--
-- Problem: The `lock_procurement_after_approval` trigger only allows
-- transitions to GC_APPROVED, AWARDED, or COMPLETED. This blocks
-- Finance Officers from creating commitments (COMMITMENT_APPROVED,
-- COMMITMENT_DECLINED) for AWARDED requests.
--
-- Fix: Instead of whitelisting allowed forward statuses, blacklist
-- only the early-stage statuses that would constitute a true revert.
--
-- Also fixes `trg_lock_after_gc_approval` which incorrectly blocks
-- field-level updates (e.g., setting awardee) when status is unchanged.
--
-- Date: 2026-02-22

-- =====================================================
-- Fix 1: lock_procurement_after_approval
-- =====================================================
DROP TRIGGER IF EXISTS `lock_procurement_after_approval`;

DELIMITER $$
CREATE TRIGGER `lock_procurement_after_approval` BEFORE UPDATE ON `procurement_requests` FOR EACH ROW
BEGIN
  -- Only block true reversions to early-stage statuses.
  -- Allow all legitimate forward transitions (commitment, PO, invoice, etc.)
  IF OLD.status IN ('GC_APPROVED', 'AWARDED', 'COMPLETED')
     AND NEW.status IN ('DRAFT', 'SUBMITTED', 'HOD_APPROVED', 'FUNDS_VERIFIED', 'DIRECTOR_APPROVED', 'DECLINED') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Approved/Awarded/Completed requests cannot be reverted to earlier stages';
  END IF;
END
$$
DELIMITER ;

-- =====================================================
-- Fix 2: trg_lock_after_gc_approval
-- =====================================================
-- This trigger blocks ANY update on approved/awarded/completed requests
-- when the status stays the same. This prevents legitimate field-level
-- updates (e.g., setting awardee, award_date, updated_at).
-- Remove it — the first trigger already prevents status reversions.
DROP TRIGGER IF EXISTS `trg_lock_after_gc_approval`;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 019_inventory_management_system.sql
-- ═══════════════════════════════════════════════════════════════════════

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
INSERT IGNORE INTO `inv_categories` (`category_code`, `category_name`, `description`, `sort_order`) VALUES
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

INSERT IGNORE INTO `inv_criticality_classes` (`criticality_code`, `criticality_name`, `description`, `sort_order`) VALUES
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

INSERT IGNORE INTO `inv_risk_classes` (`risk_code`, `risk_name`, `description`, `sort_order`) VALUES
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

INSERT IGNORE INTO `inv_accounting_classes` (`acct_class_code`, `acct_class_name`, `description`, `sort_order`) VALUES
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

INSERT IGNORE INTO `inv_units_of_measure` (`uom_code`, `uom_name`) VALUES
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

INSERT IGNORE INTO `inv_roles` (`role_code`, `role_name`, `description`) VALUES
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

INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
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



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 019b_inventory_schema_alignment.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration 019b: Align inventory schema with application code
-- Adds columns expected by PHP that were missing from 019
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. inv_goods_received — add columns PHP expects
-- ============================================================
ALTER TABLE `inv_goods_received`
  ADD COLUMN IF NOT EXISTS `supplier_name` varchar(200) DEFAULT NULL AFTER `supplier_vendor_id`,
  ADD COLUMN IF NOT EXISTS `delivery_note_number` varchar(50) DEFAULT NULL AFTER `donor_source`,
  ADD COLUMN IF NOT EXISTS `invoice_number` varchar(50) DEFAULT NULL AFTER `delivery_note_number`,
  ADD COLUMN IF NOT EXISTS `receiving_location_id` int(11) DEFAULT NULL AFTER `invoice_number`,
  ADD COLUMN IF NOT EXISTS `is_non_exchange_transaction` tinyint(1) DEFAULT 0 AFTER `receiving_location_id`;

-- Expand status enum to include values used by PHP
ALTER TABLE `inv_goods_received`
  MODIFY COLUMN `status` enum('DRAFT','RECEIVED','INSPECTED','ACCEPTED','PARTIAL','REJECTED','QUARANTINE','COMPLETED','INSPECTION') DEFAULT 'DRAFT';

-- ============================================================
-- 2. inv_grn_items — add separate lot/batch and condition
-- ============================================================
ALTER TABLE `inv_grn_items`
  ADD COLUMN IF NOT EXISTS `lot_number` varchar(50) DEFAULT NULL AFTER `batch_lot_number`,
  ADD COLUMN IF NOT EXISTS `batch_number` varchar(50) DEFAULT NULL AFTER `lot_number`,
  ADD COLUMN IF NOT EXISTS `condition_on_receipt` varchar(30) DEFAULT 'GOOD' AFTER `quality_notes`;

-- ============================================================
-- 3. inv_issues — add columns PHP expects
-- ============================================================
ALTER TABLE `inv_issues`
  ADD COLUMN IF NOT EXISTS `requisition_number` varchar(30) DEFAULT NULL AFTER `requisition_id`,
  ADD COLUMN IF NOT EXISTS `from_location_id` int(11) DEFAULT NULL AFTER `issued_to_building_room`,
  ADD COLUMN IF NOT EXISTS `cost_centre` varchar(50) DEFAULT NULL AFTER `from_location_id`;

-- Expand status enum
ALTER TABLE `inv_issues`
  MODIFY COLUMN `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED','COMPLETED') DEFAULT 'DRAFT';

-- Rename issued_to_department to match PHP's issued_to_department_id
-- (Can't rename if column doesn't exist in some environments, so add alias)
ALTER TABLE `inv_issues`
  ADD COLUMN IF NOT EXISTS `issued_to_department_id` int(11) DEFAULT NULL AFTER `issued_to_department`;

-- ============================================================
-- 4. inv_issue_items — add columns PHP expects
-- ============================================================
ALTER TABLE `inv_issue_items`
  ADD COLUMN IF NOT EXISTS `quantity_requested` decimal(14,4) DEFAULT NULL AFTER `item_id`,
  ADD COLUMN IF NOT EXISTS `lot_number` varchar(50) DEFAULT NULL AFTER `batch_lot_number`,
  ADD COLUMN IF NOT EXISTS `batch_number` varchar(50) DEFAULT NULL AFTER `lot_number`;

-- ============================================================
-- 5. inv_disposals — add columns PHP expects
-- ============================================================
ALTER TABLE `inv_disposals`
  ADD COLUMN IF NOT EXISTS `survey_notes` text DEFAULT NULL AFTER `survey_assessment`,
  ADD COLUMN IF NOT EXISTS `survey_completed_by` int(11) DEFAULT NULL AFTER `survey_notes`,
  ADD COLUMN IF NOT EXISTS `survey_completed_at` datetime DEFAULT NULL AFTER `survey_completed_by`,
  ADD COLUMN IF NOT EXISTS `actual_proceeds` decimal(14,2) DEFAULT 0.00 AFTER `proceeds_amount`,
  ADD COLUMN IF NOT EXISTS `completed_at` datetime DEFAULT NULL AFTER `evidence_notes`;

-- Expand status enum
ALTER TABLE `inv_disposals`
  MODIFY COLUMN `status` enum('DRAFT','RECOMMENDED','PENDING_APPROVAL','APPROVED','COMMITTEE_REVIEW','COMPLETED','REJECTED','CANCELLED','PENDING_SURVEY','IN_PROGRESS') DEFAULT 'DRAFT';

-- Expand disposal_method enum
ALTER TABLE `inv_disposals`
  MODIFY COLUMN `disposal_method` enum('DESTRUCTION','AUCTION','TRANSFER','DONATION','RETURN_TO_SUPPLIER','SCRAP','OTHER','SALE','RECYCLING','TRADE_IN','CANNIBALIZATION') NOT NULL;

-- ============================================================
-- 6. inv_disposal_items — add estimated_value column
-- ============================================================
ALTER TABLE `inv_disposal_items`
  ADD COLUMN IF NOT EXISTS `estimated_value` decimal(14,2) DEFAULT 0.00 AFTER `total_value`;

-- ============================================================
-- 7. inv_stock_counts — add count_lead and expand enum
-- ============================================================
ALTER TABLE `inv_stock_counts`
  ADD COLUMN IF NOT EXISTS `count_lead` int(11) DEFAULT NULL AFTER `conducted_by`,
  ADD COLUMN IF NOT EXISTS `completed_at` datetime DEFAULT NULL AFTER `notes`;

-- Expand count_type enum to include ANNUAL
ALTER TABLE `inv_stock_counts`
  MODIFY COLUMN `count_type` enum('FULL','CYCLE','SPOT','ANNUAL') DEFAULT 'FULL';

-- ============================================================
-- 8. inv_stock_count_items — add variance_quantity, make counted_quantity nullable
-- ============================================================
ALTER TABLE `inv_stock_count_items`
  MODIFY COLUMN `counted_quantity` decimal(14,4) DEFAULT NULL;

ALTER TABLE `inv_stock_count_items`
  ADD COLUMN IF NOT EXISTS `variance_quantity` decimal(14,4) DEFAULT NULL AFTER `variance`;

-- ============================================================
-- 9. inv_items — add unit_cost alias column
-- ============================================================
ALTER TABLE `inv_items`
  ADD COLUMN IF NOT EXISTS `unit_cost` decimal(14,2) DEFAULT 0.00 AFTER `average_cost`;

-- ============================================================
-- 10. inv_locations — add site_name alias column
-- ============================================================
ALTER TABLE `inv_locations`
  ADD COLUMN IF NOT EXISTS `site_name` varchar(100) DEFAULT NULL AFTER `site_campus`;

-- Copy data from site_campus to site_name for any existing rows
UPDATE `inv_locations` SET `site_name` = `site_campus` WHERE `site_name` IS NULL AND `site_campus` IS NOT NULL;

-- ============================================================
-- 11. inv_transactions — expand enum
-- ============================================================
ALTER TABLE `inv_transactions`
  MODIFY COLUMN `transaction_type` enum('RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN','ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST','RETURN','RECEIPT','ADJUSTMENT_IN','ADJUSTMENT_OUT') NOT NULL;

-- ============================================================
-- 12. inv_transfers — add missing columns PHP expects
-- ============================================================
ALTER TABLE `inv_transfers`
  ADD COLUMN IF NOT EXISTS `dispatched_at` datetime DEFAULT NULL AFTER `notes`;

-- ============================================================
-- 13. inv_transfer_items — add quantity_received for receiving workflow
-- ============================================================
ALTER TABLE `inv_transfer_items`
  ADD COLUMN IF NOT EXISTS `quantity_received` decimal(14,4) DEFAULT NULL AFTER `quantity`;

-- ============================================================
-- 14. inv_adjustment_items — add system/actual/variance qty columns
-- ============================================================
ALTER TABLE `inv_adjustment_items`
  ADD COLUMN IF NOT EXISTS `quantity_system` decimal(14,4) DEFAULT NULL AFTER `item_id`,
  ADD COLUMN IF NOT EXISTS `quantity_actual` decimal(14,4) DEFAULT NULL AFTER `quantity_system`,
  ADD COLUMN IF NOT EXISTS `quantity_variance` decimal(14,4) DEFAULT NULL AFTER `quantity_actual`;

-- ============================================================
-- 15. Fix permission name mismatches
--     PHP uses these names but they weren't seeded in 019
-- ============================================================
INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
('dispose_stock', 'Create disposal/write-off requests'),
('adjust_stock', 'Create stock adjustments'),
('transfer_stock', 'Create stock transfers'),
('view_inventory_reports', 'View inventory reports')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- Grant to HOD (role 4): approve + operational permissions
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 4, id FROM `permissions` WHERE `name` IN ('view_inventory_reports', 'dispose_stock');

-- Grant to Procurement Officer (role 2)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 2, id FROM `permissions` WHERE `name` IN ('transfer_stock', 'adjust_stock', 'dispose_stock', 'view_inventory_reports');

-- Grant to Finance Officer (role 3)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 3, id FROM `permissions` WHERE `name` IN ('view_inventory_reports');

-- Grant to Requestor (role 12)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 12, id FROM `permissions` WHERE `name` IN ('view_inventory_reports');

SET FOREIGN_KEY_CHECKS = 1;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 019c_goj_compliance.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration 019c: GoJ Compliance Enhancements
-- Jamaica Government Financial Instructions, IPSAS 12,
-- Audit Requirements, Segregation of Duties
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. PERIOD-END CUT-OFF CONTROLS
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_fiscal_periods` (
  `period_id` int(11) NOT NULL AUTO_INCREMENT,
  `period_name` varchar(50) NOT NULL COMMENT 'e.g. 2024-Q1, 2024-APR',
  `fiscal_year` varchar(10) NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` enum('OPEN','CLOSING','CLOSED','LOCKED') DEFAULT 'OPEN',
  `closed_by` int(11) DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`period_id`),
  UNIQUE KEY `uk_period_name` (`period_name`),
  KEY `idx_period_dates` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Snapshot of stock values at period-end for reporting
CREATE TABLE IF NOT EXISTS `inv_period_snapshots` (
  `snapshot_id` int(11) NOT NULL AUTO_INCREMENT,
  `period_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity_on_hand` decimal(14,4) DEFAULT 0,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `nrv` decimal(14,2) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`snapshot_id`),
  KEY `idx_snap_period` (`period_id`),
  KEY `idx_snap_item` (`item_id`),
  CONSTRAINT `fk_snap_period` FOREIGN KEY (`period_id`) REFERENCES `inv_fiscal_periods` (`period_id`),
  CONSTRAINT `fk_snap_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. RECALL / WITHDRAWAL TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_recalls` (
  `recall_id` int(11) NOT NULL AUTO_INCREMENT,
  `recall_number` varchar(30) NOT NULL,
  `recall_type` enum('RECALL','WITHDRAWAL') NOT NULL DEFAULT 'RECALL',
  `item_id` int(11) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text NOT NULL,
  `severity` enum('CLASS_I','CLASS_II','CLASS_III') DEFAULT 'CLASS_II' COMMENT 'I=critical, II=moderate, III=minor',
  `status` enum('INITIATED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'INITIATED',
  `initiated_by` int(11) NOT NULL,
  `initiated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  `total_quantity_affected` decimal(14,4) DEFAULT 0,
  `total_quantity_recovered` decimal(14,4) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`recall_id`),
  UNIQUE KEY `uk_recall_number` (`recall_number`),
  KEY `idx_recall_item` (`item_id`),
  KEY `idx_recall_batch` (`batch_lot_number`),
  CONSTRAINT `fk_recall_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_recall_user` FOREIGN KEY (`initiated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Items affected by recall (traced by batch/serial from transactions)
CREATE TABLE IF NOT EXISTS `inv_recall_items` (
  `recall_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `recall_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `issued_to_user_id` int(11) DEFAULT NULL,
  `quantity_affected` decimal(14,4) DEFAULT 0,
  `quantity_recovered` decimal(14,4) DEFAULT 0,
  `status` enum('PENDING','NOTIFIED','RECOVERED','UNRECOVERABLE') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`recall_item_id`),
  CONSTRAINT `fk_rcli_recall` FOREIGN KEY (`recall_id`) REFERENCES `inv_recalls` (`recall_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. RETURN-TO-SUPPLIER TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_returns` (
  `return_id` int(11) NOT NULL AUTO_INCREMENT,
  `return_number` varchar(30) NOT NULL,
  `grn_id` int(11) DEFAULT NULL COMMENT 'Link to original GRN',
  `supplier_vendor_id` int(11) DEFAULT NULL,
  `supplier_name` varchar(200) DEFAULT NULL,
  `reason` text NOT NULL,
  `return_type` enum('DEFECTIVE','WRONG_ITEM','EXCESS','WARRANTY','OTHER') NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','DISPATCHED','COMPLETED','CANCELLED') DEFAULT 'DRAFT',
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `dispatched_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `debit_note_number` varchar(50) DEFAULT NULL,
  `rma_number` varchar(50) DEFAULT NULL COMMENT 'Return Merchandise Authorization',
  `from_location_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`return_id`),
  UNIQUE KEY `uk_return_number` (`return_number`),
  CONSTRAINT `fk_ret_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inv_return_items` (
  `return_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `return_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  PRIMARY KEY (`return_item_id`),
  CONSTRAINT `fk_reti_return` FOREIGN KEY (`return_id`) REFERENCES `inv_returns` (`return_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reti_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. INCIDENT / LOSS REPORTING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_incidents` (
  `incident_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_number` varchar(30) NOT NULL,
  `incident_type` enum('THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER') NOT NULL,
  `incident_date` date NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `status` enum('REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED') DEFAULT 'REPORTED',
  `reported_by` int(11) NOT NULL,
  `reported_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `investigator_id` int(11) DEFAULT NULL,
  `investigation_notes` text DEFAULT NULL,
  `investigation_completed_at` datetime DEFAULT NULL,
  `police_reference` varchar(100) DEFAULT NULL,
  `insurance_reference` varchar(100) DEFAULT NULL,
  `insurance_claim_amount` decimal(14,2) DEFAULT NULL,
  `total_estimated_loss` decimal(14,2) DEFAULT 0.00,
  `adjustment_id` int(11) DEFAULT NULL COMMENT 'Link to stock adjustment created from this incident',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`incident_id`),
  UNIQUE KEY `uk_incident_number` (`incident_number`),
  CONSTRAINT `fk_inc_user` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inv_incident_items` (
  `incident_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_lost` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `condition_notes` text DEFAULT NULL,
  PRIMARY KEY (`incident_item_id`),
  CONSTRAINT `fk_inci_incident` FOREIGN KEY (`incident_id`) REFERENCES `inv_incidents` (`incident_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inci_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. QUARANTINE LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_quarantine_log` (
  `quarantine_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quarantine_location_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('QUARANTINED','UNDER_INSPECTION','RELEASED','DISPOSED') DEFAULT 'QUARANTINED',
  `quarantined_by` int(11) NOT NULL,
  `quarantined_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `released_by` int(11) DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `release_decision` enum('RETURN_TO_STOCK','DISPOSE','RETURN_TO_SUPPLIER') DEFAULT NULL,
  `decision_notes` text DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`quarantine_id`),
  KEY `idx_quar_item` (`item_id`),
  CONSTRAINT `fk_quar_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_quar_user` FOREIGN KEY (`quarantined_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. WRITE-DOWN / NRV TRACKING
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_write_downs` (
  `write_down_id` int(11) NOT NULL AUTO_INCREMENT,
  `write_down_number` varchar(30) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `reason` enum('NRV_DECLINE','OBSOLESCENCE','DAMAGE','EXPIRY','OTHER') NOT NULL,
  `original_cost` decimal(14,2) NOT NULL,
  `nrv_value` decimal(14,2) NOT NULL,
  `write_down_amount` decimal(14,2) NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','REVERSED','CANCELLED') DEFAULT 'DRAFT',
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `reversal_id` int(11) DEFAULT NULL COMMENT 'Points to write-down that reverses this one',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`write_down_id`),
  UNIQUE KEY `uk_wd_number` (`write_down_number`),
  CONSTRAINT `fk_wd_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  CONSTRAINT `fk_wd_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. ADD NRV AND FAIR VALUE COLUMNS TO EXISTING TABLES
-- ============================================================
ALTER TABLE `inv_items`
  ADD COLUMN IF NOT EXISTS `nrv` decimal(14,2) DEFAULT NULL COMMENT 'Net Realisable Value (IPSAS 12)' AFTER `unit_cost`,
  ADD COLUMN IF NOT EXISTS `nrv_last_assessed` date DEFAULT NULL AFTER `nrv`,
  ADD COLUMN IF NOT EXISTS `nrv_assessed_by` int(11) DEFAULT NULL AFTER `nrv_last_assessed`;

ALTER TABLE `inv_stock`
  ADD COLUMN IF NOT EXISTS `nrv` decimal(14,2) DEFAULT NULL AFTER `unit_cost`;

-- ============================================================
-- 8. STOCK COUNT ENHANCEMENTS (blind count, freeze, variance thresholds)
-- ============================================================
ALTER TABLE `inv_stock_counts`
  ADD COLUMN IF NOT EXISTS `is_blind_count` tinyint(1) DEFAULT 1 COMMENT 'Hide system qty from counters' AFTER `count_type`,
  ADD COLUMN IF NOT EXISTS `is_frozen` tinyint(1) DEFAULT 0 COMMENT 'Block transactions during count' AFTER `is_blind_count`,
  ADD COLUMN IF NOT EXISTS `frozen_at` datetime DEFAULT NULL AFTER `is_frozen`,
  ADD COLUMN IF NOT EXISTS `unfrozen_at` datetime DEFAULT NULL AFTER `frozen_at`,
  ADD COLUMN IF NOT EXISTS `variance_threshold_pct` decimal(5,2) DEFAULT 5.00 COMMENT 'Escalation threshold %' AFTER `unfrozen_at`,
  ADD COLUMN IF NOT EXISTS `approved_by` int(11) DEFAULT NULL AFTER `completed_at`,
  ADD COLUMN IF NOT EXISTS `approved_at` datetime DEFAULT NULL AFTER `approved_by`;

-- Expand status enum to include APPROVED and ADJUSTMENT_CREATED
ALTER TABLE `inv_stock_counts`
  MODIFY COLUMN `status` enum('PLANNED','IN_PROGRESS','COMPLETED','APPROVED','ADJUSTMENT_CREATED','CANCELLED') DEFAULT 'PLANNED';

-- ============================================================
-- 9. ISSUES TABLE — ADD APPROVAL STEP
-- ============================================================
ALTER TABLE `inv_issues`
  ADD COLUMN IF NOT EXISTS `approved_by` int(11) DEFAULT NULL AFTER `status`,
  ADD COLUMN IF NOT EXISTS `approved_at` datetime DEFAULT NULL AFTER `approved_by`;

-- Ensure status supports PENDING_APPROVAL
ALTER TABLE `inv_issues`
  MODIFY COLUMN `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED','COMPLETED') DEFAULT 'DRAFT';

-- Expand transfer status for FS approval
ALTER TABLE `inv_transfers`
  MODIFY COLUMN `status` enum('DRAFT','PENDING_APPROVAL','PENDING_FS_APPROVAL','APPROVED','IN_TRANSIT','COMPLETED','CANCELLED','REJECTED') DEFAULT 'DRAFT';

-- ============================================================
-- 10. APPROVAL TRACKING TABLE (multi-level approvals)
-- ============================================================
CREATE TABLE IF NOT EXISTS `inv_approval_log` (
  `approval_log_id` int(11) NOT NULL AUTO_INCREMENT,
  `reference_type` varchar(50) NOT NULL COMMENT 'inv_requisitions, inv_transfers, etc.',
  `reference_id` int(11) NOT NULL,
  `approval_level` int(11) NOT NULL DEFAULT 1,
  `required_role_code` varchar(30) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','SKIPPED') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`approval_log_id`),
  KEY `idx_aplog_ref` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. EXPAND TRANSACTION TYPES
-- ============================================================
ALTER TABLE `inv_transactions`
  MODIFY COLUMN `transaction_type` enum(
    'RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN',
    'ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST',
    'RETURN','RECEIPT','ADJUSTMENT_IN','ADJUSTMENT_OUT',
    'QUARANTINE_IN','QUARANTINE_OUT','WRITE_DOWN','RETURN_TO_SUPPLIER'
  ) NOT NULL;

-- ============================================================
-- 12. ADD PERMISSIONS FOR NEW MODULES
-- ============================================================
INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
  ('manage_quarantine', 'Move stock into/out of quarantine'),
  ('manage_recalls', 'Initiate and manage recall/withdrawal'),
  ('manage_returns', 'Create and manage return-to-supplier'),
  ('manage_incidents', 'Report and manage incident/loss reports'),
  ('manage_write_downs', 'Create and approve write-downs (NRV)'),
  ('manage_fiscal_periods', 'Open/close fiscal periods'),
  ('approve_issue', 'Approve stock issue vouchers'),
  ('approve_stock_count', 'Approve completed stock counts'),
  ('inspect_goods', 'Inspect goods on GRN'),
  ('approve_return', 'Approve return-to-supplier requests')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- Grant to Procurement Officer (role 2)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 2, id FROM `permissions` WHERE `name` IN ('manage_returns', 'manage_quarantine', 'inspect_goods');

-- Grant to Finance Officer (role 3)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 3, id FROM `permissions` WHERE `name` IN ('manage_write_downs', 'manage_fiscal_periods');

-- Grant to HOD (role 4)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 4, id FROM `permissions` WHERE `name` IN ('approve_issue', 'approve_stock_count', 'approve_return', 'manage_incidents');

-- ============================================================
-- 13. SEED DEFAULT APPROVAL MATRIX RULES
-- ============================================================
INSERT IGNORE INTO `inv_approval_matrix` (`transaction_type`, `item_class`, `min_value`, `max_value`, `is_emergency`, `required_role_code`, `approval_level`) VALUES
  ('REQUISITION', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('REQUISITION', NULL, 50000.01, 500000, 0, 'INVENTORY_MANAGER', 1),
  ('REQUISITION', NULL, 500000.01, 999999999.99, 0, 'STORES_SUPERINTENDENT', 1),
  ('REQUISITION', NULL, 0, 999999999.99, 1, 'STOCK_CONTROLLER', 1),
  ('DISPOSAL', NULL, 0, 100000, 0, 'INVENTORY_MANAGER', 1),
  ('DISPOSAL', NULL, 100000.01, 999999999.99, 0, 'STORES_SUPERINTENDENT', 1),
  ('ADJUSTMENT', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('ADJUSTMENT', NULL, 50000.01, 999999999.99, 0, 'INVENTORY_MANAGER', 1),
  ('TRANSFER', NULL, 0, 999999999.99, 0, 'INVENTORY_MANAGER', 1),
  ('ISSUE', NULL, 0, 50000, 0, 'STOCK_CONTROLLER', 1),
  ('ISSUE', NULL, 50000.01, 999999999.99, 0, 'INVENTORY_MANAGER', 1)
ON DUPLICATE KEY UPDATE `required_role_code` = VALUES(`required_role_code`);

-- ============================================================
-- 14. DONATION ACCEPTANCE ENHANCEMENTS
-- ============================================================
ALTER TABLE `inv_goods_received`
  ADD COLUMN IF NOT EXISTS `is_donation` tinyint(1) DEFAULT 0 AFTER `is_non_exchange_transaction`,
  ADD COLUMN IF NOT EXISTS `acceptance_certificate_number` varchar(50) DEFAULT NULL AFTER `is_donation`,
  ADD COLUMN IF NOT EXISTS `fair_value_assessor` varchar(200) DEFAULT NULL AFTER `fair_value_basis`;

SET FOREIGN_KEY_CHECKS = 1;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 020_procurement_inventory_link.sql
-- ═══════════════════════════════════════════════════════════════════════

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

ALTER TABLE `inv_goods_received`
    ADD COLUMN IF NOT EXISTS `procurement_po_id` int(11) DEFAULT NULL
        COMMENT 'FK to purchase_orders.po_id when GRN originates from a PRMS PO',
    ADD KEY IF NOT EXISTS `idx_grn_po_id` (`procurement_po_id`),
    ADD CONSTRAINT IF NOT EXISTS `fk_grn_procurement_po`
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



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 021_property_management_officer_role.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration 021: Property Management Officer Role
-- ============================================================================
-- Purpose:
--   1. Add the "Property Management Officer" role (id 13).
--   2. Ensure all inventory-module permissions exist (safe INSERT IGNORE /
--      ON DUPLICATE KEY so this is idempotent alongside migrations 019, 019b,
--      019c which may or may not have run first).
--   3. Grant the new role full access to all inventory modules.
--
-- Date: 2026-05-12
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Insert the new role
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `roles` (`id`, `name`, `description`) VALUES
(13, 'Property Management Officer', 'Manages physical property, stock, and inventory operations');

-- ═══════════════════════════════════════════════════════════
-- STEP 2: Ensure all inventory permissions exist
--         (ON DUPLICATE KEY is safe — keeps existing rows)
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
-- Core inventory views
('view_inventory',              'View inventory items and stock levels'),
('view_inv_reports',            'View inventory reports'),
('view_inventory_reports',      'View inventory reports'),
-- Item & location master data
('manage_inventory_items',      'Create and edit inventory item master data'),
('manage_inventory_locations',  'Manage storage locations'),
-- Requisitions
('submit_stock_requisition',    'Submit stock requisitions'),
('approve_stock_requisition',   'Approve stock requisitions'),
-- Receiving & inspection
('receive_goods',               'Record goods received notes'),
('inspect_goods',               'Inspect goods on GRN'),
-- Issuing
('issue_stock',                 'Issue stock from stores'),
('approve_stock_issue',         'Approve stock issues for controlled items'),
('approve_issue',               'Approve stock issue vouchers'),
-- Transfers
('create_transfer',             'Create stock transfers'),
('transfer_stock',              'Create stock transfers'),
('approve_transfer',            'Approve stock transfers'),
-- Adjustments
('create_adjustment',           'Create stock adjustments'),
('adjust_stock',                'Create stock adjustments'),
('approve_adjustment',          'Approve stock adjustments'),
-- Disposals & write-downs
('create_disposal',             'Create disposal/write-off requests'),
('dispose_stock',               'Create disposal/write-off requests'),
('approve_disposal',            'Approve disposals and write-offs'),
('manage_write_downs',          'Create and approve write-downs (NRV)'),
-- Stock counts
('conduct_stock_count',         'Conduct physical stock counts'),
('approve_stock_count',         'Approve completed stock counts'),
-- Quality / compliance modules
('manage_quarantine',           'Move stock into/out of quarantine'),
('manage_recalls',              'Initiate and manage recall/withdrawal'),
('manage_returns',              'Create and manage return-to-supplier'),
('approve_return',              'Approve return-to-supplier requests'),
('manage_incidents',            'Report and manage incident/loss reports'),
-- Administration
('manage_inv_roles',            'Manage inventory user roles'),
('manage_inv_delegations',      'Manage inventory delegations'),
('inventory_admin',             'Full inventory administration access'),
('manage_fiscal_periods',       'Open/close fiscal periods')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Assign all inventory permissions to role 13
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 13, id FROM `permissions` WHERE `name` IN (
    -- Core views
    'view_inventory',
    'view_inv_reports',
    'view_inventory_reports',
    -- Item & location management
    'manage_inventory_items',
    'manage_inventory_locations',
    -- Requisitions
    'submit_stock_requisition',
    'approve_stock_requisition',
    -- Receiving & inspection
    'receive_goods',
    'inspect_goods',
    -- Issuing
    'issue_stock',
    'approve_stock_issue',
    'approve_issue',
    -- Transfers
    'create_transfer',
    'transfer_stock',
    'approve_transfer',
    -- Adjustments
    'create_adjustment',
    'adjust_stock',
    'approve_adjustment',
    -- Disposals & write-downs
    'create_disposal',
    'dispose_stock',
    'approve_disposal',
    'manage_write_downs',
    -- Stock counts
    'conduct_stock_count',
    'approve_stock_count',
    -- Quality / compliance
    'manage_quarantine',
    'manage_recalls',
    'manage_returns',
    'approve_return',
    'manage_incidents',
    -- Administration
    'manage_inv_roles',
    'manage_inv_delegations',
    'inventory_admin',
    'manage_fiscal_periods',
    -- Procurement visibility (needed to match GRNs against POs)
    'view_requests',
    'view_purchase_orders',
    'view_vendors',
    -- Print & export
    'print_request',
    'export_requests'
);

-- ═══════════════════════════════════════════════════════════
-- STEP 4: Verification
-- ═══════════════════════════════════════════════════════════

SELECT id, name, description FROM `roles` WHERE id = 13;

SELECT COUNT(*) AS inventory_permissions_assigned
FROM `role_permissions` rp
JOIN `permissions` p ON rp.permission_id = p.id
WHERE rp.role_id = 13;

SELECT p.name, p.description
FROM `role_permissions` rp
JOIN `permissions` p ON rp.permission_id = p.id
WHERE rp.role_id = 13
ORDER BY p.name;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 022_assets_category_serial_tracking.sql
-- ═══════════════════════════════════════════════════════════════════════

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



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 023_page_permissions.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration 023: Page Permissions Management
-- ============================================================================
-- Purpose:
--   1. Create page_permissions table so admins can assign/override which
--      permission is required to access each page in the system.
--   2. Seed the table with all known pages and their default permissions.
--   3. Add view_pmo_dashboard permission for the Property Management Officer
--      dashboard and assign it to role 13.
--
-- How it works:
--   - page_guard.php consults this table first; if a row exists for the
--     current page path the DB value takes precedence over the PHP constant.
--   - Admins can reassign permissions via /admin/page_permissions.php.
--
-- Date: 2026-05-13
-- ============================================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Create page_permissions table
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `page_permissions` (
    `id`              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `page_path`       VARCHAR(255)    NOT NULL COMMENT 'Relative URL, e.g. /procurement/list.php',
    `page_title`      VARCHAR(255)    NOT NULL COMMENT 'Human-readable page name',
    `permission_name` VARCHAR(100)    NOT NULL COMMENT 'permission.name required to access this page',
    `module`          VARCHAR(80)     NOT NULL DEFAULT 'general' COMMENT 'Grouping label for the admin UI',
    `is_active`       TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_page_path` (`page_path`),
    KEY `idx_permission_name` (`permission_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════
-- STEP 2: Add view_pmo_dashboard permission
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `permissions` (`name`, `description`) VALUES
('view_pmo_dashboard', 'Access the Property Management Officer dashboard');

-- Assign to role 13 (Property Management Officer) and role 5 (Admin) / 6 (SuperAdmin)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `roles` r
JOIN `permissions` p ON p.name = 'view_pmo_dashboard'
WHERE r.id IN (5, 6, 13);

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Seed all known pages with their default permissions
-- ═══════════════════════════════════════════════════════════

INSERT IGNORE INTO `page_permissions` (`page_path`, `page_title`, `permission_name`, `module`) VALUES

-- ── Administration ────────────────────────────────────────────────────
('/admin/settings.php',                  'System Settings',              'manage_system_settings', 'Administration'),
('/admin/page_permissions.php',          'Page Permissions',             'manage_users',            'Administration'),
('/users/list.php',                      'Users List',                   'manage_users',            'Administration'),
('/users/add.php',                       'Add User',                     'manage_users',            'Administration'),
('/users/view.php',                      'View User',                    'manage_users',            'Administration'),
('/users/permissions.php',              'User Permissions',             'manage_users',            'Administration'),
('/users/update_role.php',              'Update User Role',             'manage_users',            'Administration'),
('/users/toggle_status.php',            'Toggle User Status',           'manage_users',            'Administration'),
('/users/delete.php',                   'Delete User',                  'manage_users',            'Administration'),
('/users/reset_password.php',           'Reset User Password',          'manage_users',            'Administration'),
('/users/unlock.php',                   'Unlock User Account',          'manage_users',            'Administration'),
('/users/acting_roles.php',             'Acting Roles',                 'manage_users',            'Administration'),
('/admin/roles.php',                   'Role Management',              'manage_roles',            'Administration'),
('/admin/roles_edit.php',              'Edit Role & Permissions',      'manage_roles',            'Administration'),
('/admin/roles_assign.php',            'Assign Roles to Users',        'manage_roles',            'Administration'),

-- ── Dashboards ───────────────────────────────────────────────────────
('/dashboard/admin.php',                'Admin Dashboard',              'manage_users',            'Dashboards'),
('/dashboard/procurement.php',          'Procurement Dashboard',        'view_procurement_dashboard','Dashboards'),
('/dashboard/finance.php',              'Finance Dashboard',            'view_finance_dashboard',  'Dashboards'),
('/dashboard/hod.php',                  'HOD Dashboard',                'view_requests',           'Dashboards'),
('/dashboard/gc.php',                   'Deputy Govt Chemist Dashboard','view_requests',           'Dashboards'),
('/dashboard/committee.php',            'Procurement Committee',        'view_requests',           'Dashboards'),
('/dashboard/evaluation.php',           'Evaluation Dashboard',         'view_requests',           'Dashboards'),
('/dashboard/director_hrma.php',        'Director HRM&A Dashboard',     'approve_as_director_hrma','Dashboards'),
('/dashboard/director_procurement.php', 'Director Procurement Dashboard','approve_as_director_hrma','Dashboards'),
('/dashboard/property_management_officer.php','PMO Dashboard',         'view_pmo_dashboard',      'Dashboards'),
('/dashboard/requestor.php',            'Requestor Dashboard',          'view_own_requests',       'Dashboards'),
('/dashboard/viewer.php',               'Viewer Dashboard',             'view_audit_dashboard',    'Dashboards'),
('/dashboard/management.php',           'Management Dashboard',         'management_dashboard',    'Dashboards'),
('/dashboard/metrics.php',              'Finance Metrics',              'view_finance_dashboard',  'Dashboards'),
('/dashboard/monthly.php',              'Monthly Dashboard',            'monthly_metrics',         'Dashboards'),
('/dashboard/approval_analytics.php',   'Approval Analytics',           'view_approval_analytics', 'Dashboards'),
('/dashboard/approval_queue.php',       'Approval Queue',               'view_requests',           'Dashboards'),
('/dashboard/compliance.php',           'Compliance Dashboard',         'view_compliance',         'Dashboards'),

-- ── Procurement ───────────────────────────────────────────────────────
('/procurement/list.php',               'All Requests',                 'view_requests',           'Procurement'),
('/procurement/add.php',                'New Request',                  'create_request',          'Procurement'),
('/procurement/edit.php',               'Edit Request',                 'create_request',          'Procurement'),
('/procurement/view.php',               'View Request',                 'view_requests',           'Procurement'),
('/procurement/submit.php',             'Submit Request',               'submit_request',          'Procurement'),
('/procurement/resubmit.php',           'Resubmit Request',             'submit_request',          'Procurement'),
('/procurement/approve.php',            'Approve Request',              'approve_request',         'Procurement'),
('/procurement/approve_finance.php',    'Finance Approval',             'approve_request',         'Procurement'),
('/procurement/approve_hod.php',        'HOD Approval',                 'approve_request',         'Procurement'),
('/procurement/gc_approve.php',         'DGC Approval',                 'approve_request',         'Procurement'),
('/procurement/decline.php',            'Decline Request',              'approve_request',         'Procurement'),
('/procurement/recommend.php',          'Recommend Request',            'approve_request',         'Procurement'),
('/procurement/my_requests.php',        'My Requests',                  'view_own_requests',       'Procurement'),
('/procurement/start_procurement.php',  'Start Procurement',            'view_requests',           'Procurement'),
('/procurement/upload_document.php',    'Upload Document',              'view_requests',           'Procurement'),
('/procurement/upload_signed_request.php','Upload Signed Request',     'view_requests',           'Procurement'),
('/procurement/print_for_signing.php',  'Print for Signing',            'view_requests',           'Procurement'),
('/procurement/verify_funds.php',       'Verify Funds',                 'verify_funds',            'Procurement'),

-- ── Commitments ───────────────────────────────────────────────────────
('/commitments/list.php',               'Commitments List',             'view_commitments',        'Commitments'),
('/commitments/view.php',               'View Commitment',              'view_commitments',        'Commitments'),
('/commitments/add.php',                'Add Commitment',               'create_commitment',       'Commitments'),
('/commitments/add_supplementary.php',  'Add Supplementary Commitment', 'create_commitment',       'Commitments'),
('/commitments/approve.php',            'Approve Commitment',           'approve_commitment',      'Commitments'),
('/commitments/upload.php',             'Upload Commitment',            'approve_commitment',      'Commitments'),

-- ── Purchase Orders ───────────────────────────────────────────────────
('/po/list.php',                        'Purchase Orders List',         'view_purchase_orders',    'Purchase Orders'),
('/po/view.php',                        'View Purchase Order',          'view_purchase_orders',    'Purchase Orders'),
('/po/add.php',                         'Create Purchase Order',        'create_purchase_order',   'Purchase Orders'),
('/po/edit.php',                        'Edit Purchase Order',          'edit_purchase_order',     'Purchase Orders'),
('/po/approve.php',                     'Approve Purchase Order',       'approve_purchase_order',  'Purchase Orders'),
('/po/upload.php',                      'Upload PO Document',           'upload_purchase_order',   'Purchase Orders'),
('/po/excess_approve.php',              'Approve PO Excess',            'approve_po_excess',       'Purchase Orders'),
('/po/variation_queue.php',             'PO Variations Queue',          'approve_po_adjustment',   'Purchase Orders'),
('/po/variation_create.php',            'Create PO Variation',          'request_po_adjustment',   'Purchase Orders'),
('/po/variation_approve.php',           'Approve PO Variation',         'approve_po_adjustment',   'Purchase Orders'),
('/po/add_adjustment.php',              'Add PO Adjustment',            'request_po_adjustment',   'Purchase Orders'),
('/po/receive_to_inventory.php',        'Receive PO to Inventory',      'receive_goods',           'Purchase Orders'),

-- ── RFQ ───────────────────────────────────────────────────────────────
('/rfq/list.php',                       'RFQ List',                     'view_requests',           'RFQ'),
('/rfq/view.php',                       'View RFQ',                     'view_requests',           'RFQ'),
('/rfq/create.php',                     'Create RFQ',                   'create_rfq',              'RFQ'),
('/rfq/upload_rfq_letter.php',          'Upload RFQ Letter',            'create_rfq',              'RFQ'),
('/rfq/generate_rtf.php',               'Generate RFQ Document',        'create_rfq',              'RFQ'),
('/rfq/add_committee.php',              'Add Committee Member',         'manage_rfq_committee',    'RFQ'),
('/rfq/remove_committee.php',           'Remove Committee Member',      'manage_rfq_committee',    'RFQ'),
('/rfq/add_vendor.php',                 'Add Vendor to RFQ',            'add_rfq_vendor',          'RFQ'),
('/rfq/remove_vendor.php',              'Remove Vendor from RFQ',       'add_rfq_vendor',          'RFQ'),
('/rfq/send_rfq_emails.php',            'Send RFQ Emails',              'add_rfq_vendor',          'RFQ'),
('/rfq/upload_quote.php',               'Upload Vendor Quote',          'upload_rfq_quote',        'RFQ'),
('/rfq/start_evaluation.php',           'Start Evaluation',             'start_rfq_evaluation',    'RFQ'),
('/rfq/advance_evaluation.php',         'Advance Evaluation Stage',     'start_rfq_evaluation',    'RFQ'),
('/rfq/vote.php',                       'Vote on RFQ',                  'vote_rfq',                'RFQ'),
('/rfq/review_quote.php',               'Review Quote',                 'view_rfq_evaluations',    'RFQ'),
('/rfq/select_quote.php',               'Select Winning Quote',         'view_rfq_evaluations',    'RFQ'),
('/rfq/upload_report.php',              'Upload Evaluation Report',     'upload_rfq_report',       'RFQ'),
('/rfq/view_report.php',                'View Evaluation Report',       'view_rfq_evaluations',    'RFQ'),
('/rfq/generate_evaluation_summary.php','Generate Evaluation Summary',  'view_rfq_evaluations',    'RFQ'),
('/rfq/award.php',                      'Award RFQ',                    'award_vendor',            'RFQ'),
('/rfq/generate_loa.php',               'Generate LOA',                 'award_vendor',            'RFQ'),
('/rfq/accept_award.php',               'Accept/Decline Award',         'confirm_vendor_award',    'RFQ'),
('/rfq/gc_approve.php',                 'DGC Approve RFQ',              'approve_request',         'RFQ'),

-- ── Invoices & Payments ───────────────────────────────────────────────
('/invoice/list.php',                   'Invoices List',                'view_invoices',           'Finance'),
('/invoice/view.php',                   'View Invoice',                 'view_invoices',           'Finance'),
('/invoice/add.php',                    'Create Invoice',               'create_invoice',          'Finance'),
('/payment/list.php',                   'Payments List',                'view_payments',           'Finance'),
('/payment/add.php',                    'Record Payment',               'create_payment',          'Finance'),

-- ── Reimbursements ────────────────────────────────────────────────────
('/reimbursement/list.php',             'Reimbursements List',          'view_reimbursement_requests','Reimbursements'),
('/reimbursement/view.php',             'View Reimbursement',           'view_reimbursement_requests','Reimbursements'),
('/reimbursement/add.php',              'New Reimbursement',            'create_reimbursement_request','Reimbursements'),
('/reimbursement/edit.php',             'Edit Reimbursement',           'create_reimbursement_request','Reimbursements'),
('/reimbursement/submit.php',           'Submit Reimbursement',         'create_reimbursement_request','Reimbursements'),
('/reimbursement/approve.php',          'Approve Reimbursement',        'approve_reimbursement_request','Reimbursements'),
('/reimbursement/submit_invoice.php',   'Submit Reimbursement Invoice', 'view_own_requests',       'Reimbursements'),

-- ── Petty Cash ────────────────────────────────────────────────────────
('/petty_cash/list.php',                'Petty Cash List',              'view_petty_cash_requests','Petty Cash'),
('/petty_cash/view.php',                'View Petty Cash',              'view_petty_cash_requests','Petty Cash'),
('/petty_cash/add.php',                 'New Petty Cash Request',       'create_petty_cash_request','Petty Cash'),
('/petty_cash/edit.php',                'Edit Petty Cash',              'create_petty_cash_request','Petty Cash'),
('/petty_cash/submit.php',              'Submit Petty Cash',            'create_petty_cash_request','Petty Cash'),
('/petty_cash/approve.php',             'Approve Petty Cash',           'approve_petty_cash_request','Petty Cash'),

-- ── Vendors ───────────────────────────────────────────────────────────
('/vendors/list.php',                   'Vendors List',                 'view_vendors',            'Vendors'),
('/vendors/view.php',                   'View Vendor',                  'view_vendors',            'Vendors'),
('/vendors/add.php',                    'Add Vendor',                   'manage_vendors',          'Vendors'),
('/vendors/edit.php',                   'Edit Vendor',                  'manage_vendors',          'Vendors'),
('/vendors/delete.php',                 'Delete Vendor',                'manage_vendors',          'Vendors'),

-- ── Reports ───────────────────────────────────────────────────────────
('/reports/index.php',                  'Reports Home',                 'view_financial_reports',  'Reports'),
('/reports/procurement_by_status.php',  'Procurement by Status',        'view_financial_reports',  'Reports'),
('/reports/procurement_by_type.php',    'Procurement by Type',          'view_financial_reports',  'Reports'),
('/reports/procurement_by_branch.php',  'Procurement by Branch',        'view_financial_reports',  'Reports'),
('/reports/procurement_by_supplier.php','Procurement by Supplier',      'view_financial_reports',  'Reports'),
('/reports/po_status_report.php',       'PO Status Report',             'view_financial_reports',  'Reports'),
('/reports/period_reports.php',         'Period Reports',               'view_financial_reports',  'Reports'),
('/reports/amounts_paid_report.php',    'Amounts Paid Report',          'view_financial_reports',  'Reports'),
('/reports/outstanding_commitments_po.php','Outstanding Commitments',   'view_financial_reports',  'Reports'),
('/reports/branch_summary.php',         'Branch Summary',               'view_financial_reports',  'Reports'),
('/reports/branch_outstanding.php',     'Branch Outstanding',           'view_financial_reports',  'Reports'),
('/reports/po_adjustment_report.php',   'PO Adjustment Report',         'view_po_adjustments',     'Reports'),
('/reports/export_excel.php',           'Export Excel Report',          'view_management_dashboard','Reports'),
('/reports/print_request.php',          'Print Request',                'print_request',           'Reports'),
('/reports/print_po.php',               'Print Purchase Order',         'print_purchase_order',    'Reports'),
('/reports/print_invoice.php',          'Print Invoice',                'print_invoice',           'Reports'),

-- ── Audit ─────────────────────────────────────────────────────────────
('/audit/list.php',                     'Audit Logs',                   'view_audit_logs',         'Audit'),
('/audit/view.php',                     'View Audit Entry',             'view_audit_logs',         'Audit'),
('/audit/export_csv.php',               'Export Audit CSV',             'view_audit_logs',         'Audit'),
('/audit/export_pdf.php',               'Export Audit PDF',             'view_audit_logs',         'Audit'),

-- ── Inventory ─────────────────────────────────────────────────────────
('/inventory/dashboard.php',            'Inventory Dashboard',          'view_inventory',          'Inventory'),
('/inventory/items/list.php',           'Inventory Items',              'view_inventory',          'Inventory'),
('/inventory/items/view.php',           'View Item',                    'view_inventory',          'Inventory'),
('/inventory/items/add.php',            'Add Item',                     'manage_inventory_items',  'Inventory'),
('/inventory/items/edit.php',           'Edit Item',                    'manage_inventory_items',  'Inventory'),
('/inventory/locations/list.php',       'Locations',                    'view_inventory',          'Inventory'),
('/inventory/locations/add.php',        'Add Location',                 'manage_inventory_locations','Inventory'),
('/inventory/requisitions/list.php',    'Stock Requisitions',           'view_inventory',          'Inventory'),
('/inventory/requisitions/view.php',    'View Requisition',             'view_inventory',          'Inventory'),
('/inventory/requisitions/add.php',     'Submit Stock Requisition',     'submit_stock_requisition','Inventory'),
('/inventory/receiving/list.php',       'Goods Received',               'receive_goods',           'Inventory'),
('/inventory/receiving/view.php',       'View GRN',                     'receive_goods',           'Inventory'),
('/inventory/receiving/add.php',        'Record GRN',                   'receive_goods',           'Inventory'),
('/inventory/issuing/list.php',         'Stock Issues',                 'issue_stock',             'Inventory'),
('/inventory/issuing/view.php',         'View Issue',                   'issue_stock',             'Inventory'),
('/inventory/issuing/add.php',          'Issue Stock',                  'issue_stock',             'Inventory'),
('/inventory/transfers/list.php',       'Stock Transfers',              'transfer_stock',          'Inventory'),
('/inventory/transfers/view.php',       'View Transfer',                'transfer_stock',          'Inventory'),
('/inventory/transfers/add.php',        'Create Transfer',              'transfer_stock',          'Inventory'),
('/inventory/adjustments/list.php',     'Stock Adjustments',            'adjust_stock',            'Inventory'),
('/inventory/adjustments/view.php',     'View Adjustment',              'adjust_stock',            'Inventory'),
('/inventory/adjustments/add.php',      'Create Adjustment',            'adjust_stock',            'Inventory'),
('/inventory/disposal/list.php',        'Disposal Requests',            'dispose_stock',           'Inventory'),
('/inventory/disposal/view.php',        'View Disposal',                'dispose_stock',           'Inventory'),
('/inventory/disposal/add.php',         'Create Disposal',              'dispose_stock',           'Inventory'),
('/inventory/stocktake/list.php',       'Stock Counts',                 'conduct_stock_count',     'Inventory'),
('/inventory/stocktake/view.php',       'View Stock Count',             'conduct_stock_count',     'Inventory'),
('/inventory/stocktake/add.php',        'Create Stock Count',           'conduct_stock_count',     'Inventory'),
('/inventory/quarantine/list.php',      'Quarantine Items',             'manage_quarantine',       'Inventory'),
('/inventory/quarantine/view.php',      'View Quarantine',              'manage_quarantine',       'Inventory'),
('/inventory/quarantine/add.php',       'Quarantine Item',              'manage_quarantine',       'Inventory'),
('/inventory/recall/list.php',          'Recalls',                      'manage_recalls',          'Inventory'),
('/inventory/recall/view.php',          'View Recall',                  'manage_recalls',          'Inventory'),
('/inventory/recall/add.php',           'Create Recall',                'manage_recalls',          'Inventory'),
('/inventory/returns/list.php',         'Returns to Supplier',          'manage_returns',          'Inventory'),
('/inventory/returns/view.php',         'View Return',                  'manage_returns',          'Inventory'),
('/inventory/returns/add.php',          'Create Return',                'manage_returns',          'Inventory'),
('/inventory/incidents/list.php',       'Incidents / Losses',           'manage_incidents',        'Inventory'),
('/inventory/incidents/view.php',       'View Incident',                'manage_incidents',        'Inventory'),
('/inventory/incidents/add.php',        'Report Incident',              'manage_incidents',        'Inventory'),
('/inventory/writedowns/list.php',      'Write-Downs',                  'manage_write_downs',      'Inventory'),
('/inventory/writedowns/view.php',      'View Write-Down',              'manage_write_downs',      'Inventory'),
('/inventory/writedowns/add.php',       'Create Write-Down',            'manage_write_downs',      'Inventory'),

-- ── Inventory Reports ─────────────────────────────────────────────────
('/inventory/reports/index.php',               'Inventory Reports Home',       'view_inventory_reports','Inventory Reports'),
('/inventory/reports/stock_valuation.php',      'Stock Valuation',              'view_inventory_reports','Inventory Reports'),
('/inventory/reports/reorder_report.php',       'Reorder Report',               'view_inventory_reports','Inventory Reports'),
('/inventory/reports/expiry_report.php',        'Expiry Report',                'view_inventory_reports','Inventory Reports'),
('/inventory/reports/slow_moving_stock.php',    'Slow Moving Stock',            'view_inventory_reports','Inventory Reports'),
('/inventory/reports/obsolete_stock.php',       'Obsolete Stock',               'view_inventory_reports','Inventory Reports'),
('/inventory/reports/transaction_history.php',  'Transaction History',          'view_inventory_reports','Inventory Reports'),
('/inventory/reports/goods_received_register.php','Goods Received Register',    'view_inventory_reports','Inventory Reports'),
('/inventory/reports/issue_register.php',       'Issue Register',               'view_inventory_reports','Inventory Reports'),
('/inventory/reports/transfer_register.php',    'Transfer Register',            'view_inventory_reports','Inventory Reports'),
('/inventory/reports/disposal_register.php',    'Disposal Register',            'view_inventory_reports','Inventory Reports'),
('/inventory/reports/inventory_expense.php',    'Inventory Expense',            'view_inventory_reports','Inventory Reports'),
('/inventory/reports/shrinkage_loss.php',       'Shrinkage / Loss',             'view_inventory_reports','Inventory Reports'),
('/inventory/reports/write_down_report.php',    'Write-Down Report',            'view_inventory_reports','Inventory Reports'),
('/inventory/reports/traceability_report.php',  'Asset Traceability',           'view_inventory_reports','Inventory Reports'),
('/inventory/reports/audit_exceptions.php',     'Audit Exceptions',             'view_inventory_reports','Inventory Reports'),
('/inventory/reports/user_activity.php',        'User Activity',                'view_inventory_reports','Inventory Reports'),
('/inventory/reports/supplier_performance.php', 'Supplier Performance',         'view_inventory_reports','Inventory Reports'),
('/inventory/reports/approval_turnaround.php',  'Approval Turnaround',          'view_inventory_reports','Inventory Reports'),
('/inventory/reports/emergency_stock.php',      'Emergency Stock',              'view_inventory_reports','Inventory Reports'),
('/inventory/reports/donation_register.php',    'Donation Register',            'view_inventory_reports','Inventory Reports'),

-- ── Compliance ────────────────────────────────────────────────────────
('/views/compliance-detail.php',        'Compliance Detail',            'view_compliance',         'Compliance');

-- ═══════════════════════════════════════════════════════════
-- STEP 4: Verification
-- ═══════════════════════════════════════════════════════════

SELECT COUNT(*) AS total_pages_seeded FROM `page_permissions`;

SELECT module, COUNT(*) AS pages
FROM `page_permissions`
GROUP BY module
ORDER BY module;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_02_24_multi_feature_update.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration: Multi-Feature Update
-- Date: 2026-02-24
-- Features:
--   1. Audit log: changed_by stores full_name (varchar) instead of user_id (int)
--   2. Currency support: USD/JMD with exchange rate
--   3. RFQ: date, deadline, and letter upload
--   4. Request document uploads (signed POs, commitments)
-- ============================================================

-- ============================================
-- 1. AUDIT LOG: Change changed_by to store full_name
-- ============================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'audit_log' 
  AND COLUMN_NAME = 'changed_by' AND DATA_TYPE = 'varchar');
SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE `audit_log` MODIFY COLUMN `changed_by` VARCHAR(100) DEFAULT NULL COMMENT ''Full name of user who made the change''',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update existing audit_log entries to store full_name instead of user_id
UPDATE `audit_log` a
  LEFT JOIN `users` u ON a.changed_by = CAST(u.user_id AS CHAR)
  SET a.changed_by = u.full_name
  WHERE a.changed_by IS NOT NULL
    AND a.changed_by REGEXP '^[0-9]+$';

-- ============================================
-- 2. CURRENCY SUPPORT
-- ============================================

-- Add currency fields to procurement_requests
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'procurement_requests' AND COLUMN_NAME = 'currency');
SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE `procurement_requests` ADD COLUMN IF NOT EXISTS `currency` ENUM(''JMD'',''USD'') NOT NULL DEFAULT ''JMD'' AFTER `estimated_value`, ADD COLUMN IF NOT EXISTS `usd_rate` DECIMAL(10,4) DEFAULT NULL COMMENT ''USD to JMD exchange rate at time of request'' AFTER `currency`',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add currency fields to rfq_quotes
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rfq_quotes' AND COLUMN_NAME = 'currency');
SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE `rfq_quotes` ADD COLUMN IF NOT EXISTS `currency` ENUM(''JMD'',''USD'') NOT NULL DEFAULT ''JMD'' AFTER `quote_amount`, ADD COLUMN IF NOT EXISTS `usd_rate` DECIMAL(10,4) DEFAULT NULL COMMENT ''USD to JMD exchange rate'' AFTER `currency`',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add USD exchange rate to system_config
INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`)
VALUES ('usd_to_jmd_rate', '155.00', 'Current USD to JMD exchange rate for currency conversion', NOW())
ON DUPLICATE KEY UPDATE `config_value` = VALUES(`config_value`);

-- ============================================
-- 3. FINANCE WORKFLOW: Funds verification fields
-- ============================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'procurement_requests' AND COLUMN_NAME = 'funds_available');
SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE `procurement_requests` ADD COLUMN IF NOT EXISTS `funds_available` TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''1 = Finance verified funds are available'' AFTER `status`, ADD COLUMN IF NOT EXISTS `finance_reviewed_by` INT(11) DEFAULT NULL COMMENT ''Finance Officer who verified funds'' AFTER `funds_available`, ADD COLUMN IF NOT EXISTS `finance_reviewed_at` DATETIME DEFAULT NULL COMMENT ''When funds were verified'' AFTER `finance_reviewed_by`',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================
-- 4. RFQ: Letter upload field (rfq_letter_file)
-- ============================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rfqs' AND COLUMN_NAME = 'rfq_letter_file');
SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE `rfqs` ADD COLUMN IF NOT EXISTS `rfq_letter_file` VARCHAR(255) DEFAULT NULL COMMENT ''Uploaded RFQ letter document path'' AFTER `letter_of_award_file`',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================
-- 5. REQUEST DOCUMENT UPLOADS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `request_documents` (
  `document_id` INT(11) NOT NULL AUTO_INCREMENT,
  `request_id` INT(11) NOT NULL,
  `document_type` ENUM('SIGNED_PO','SIGNED_COMMITMENT','OTHER') NOT NULL DEFAULT 'OTHER',
  `document_name` VARCHAR(255) NOT NULL COMMENT 'Original filename',
  `document_path` VARCHAR(255) NOT NULL COMMENT 'Server file path',
  `uploaded_by` INT(11) NOT NULL,
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `notes` TEXT DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `idx_request_documents_request` (`request_id`),
  KEY `idx_request_documents_type` (`document_type`),
  CONSTRAINT `fk_request_documents_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Done
-- ============================================



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_02_24_remove_po_commitment_approvals.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- Migration: Remove PO and Commitment approval requirements
-- Date: 2026-02-24
-- Purpose: POs and Commitments are now auto-approved. 
--          This cleans up existing pending approval records
--          and advances any stuck POs/requests.
-- ═══════════════════════════════════════════════════════════════

-- 1. Auto-approve all pending COMMITMENT approval records
UPDATE request_approvals
SET status = 'approved',
    approved_at = NOW()
WHERE entity_type = 'COMMITMENT'
  AND status = 'pending';

-- 2. Auto-approve all pending PO approval records
UPDATE request_approvals
SET status = 'approved',
    approved_at = NOW()
WHERE entity_type = 'PO'
  AND status = 'pending';

-- 3. Set approved_at on POs that don't have it yet
UPDATE purchase_orders
SET approved_at = COALESCE(approved_at, NOW())
WHERE approved_at IS NULL
  AND status = 'Open';

-- 4. Advance any procurement requests stuck at PO_PENDING to PO_APPROVED
UPDATE procurement_requests
SET status = 'PO_APPROVED'
WHERE UPPER(status) = 'PO_PENDING';

-- 5. Advance any procurement requests stuck at COMMITMENTS_PENDING to COMMITMENT_APPROVED
UPDATE procurement_requests
SET status = 'COMMITMENT_APPROVED'
WHERE UPPER(status) = 'COMMITMENTS_PENDING';

SELECT 'Migration complete: PO and Commitment approvals removed' AS result;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_03_17_add_approval_thresholds.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add HOD Approval and Committee Review Thresholds
-- Date: 2026-03-17
-- Description: Add new system configuration for amount-based approval requirements

-- Add HOD Approval Threshold (500,000 JMD)
INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`, `updated_at`)
VALUES ('hod_approval_threshold', '500000.00', 'Procurement requests above this amount require HOD approval (JMD)', NOW(), NOW())
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

-- Add Committee Review Threshold (3,000,000 JMD)
INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`, `created_at`, `updated_at`)
VALUES ('committee_review_threshold', '3000000.00', 'Procurement requests above this amount require committee review (JMD)', NOW(), NOW())
ON DUPLICATE KEY UPDATE `updated_at` = NOW();



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_03_17_add_signed_request_support.sql
-- ═══════════════════════════════════════════════════════════════════════

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



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_03_17_fix_request_type_enum.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================================
-- Migration: Fix request_type Enum in procurement_requests Table
-- Database: prms_ims
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



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_03_18_add_commitment_form_path.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Migration: Add commitment_form_path to procurement_requests
-- Purpose: Store the optional commitment form uploaded by Procurement Officers
--          Finance will use this reference when creating the commitment in GFMS
-- Date: 2026-03-18

ALTER TABLE procurement_requests
    ADD COLUMN IF NOT EXISTS commitment_form_path VARCHAR(500) NULL DEFAULT NULL
        COMMENT 'Optional scanned commitment form uploaded by Procurement Officer (Finance will create actual commitment in GFMS)'
    AFTER funds_available;



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_05_11_schema_safety_and_indexes.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration: 2026_05_11_schema_safety_and_indexes.sql
-- Purpose  : Ensure all critical columns, defaults, and
--            performance indexes are in place.
--            Safe to run multiple times (uses IF NOT EXISTS /
--            DROP IF EXISTS patterns and IGNORE inserts).
-- ============================================================

-- ── 1. audit_log — guarantee change_date has a default ──────
ALTER TABLE `audit_log`
    MODIFY COLUMN `change_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP;

-- ── 2. users — columns required by auth/login.php ───────────
-- failed_attempts and lock_until (account lockout)
ALTER TABLE `users`
    MODIFY COLUMN `failed_attempts` int NOT NULL DEFAULT 0;

ALTER TABLE `users`
    MODIFY COLUMN `lock_until` datetime DEFAULT NULL;

-- must_change_password flag
ALTER TABLE `users`
    MODIFY COLUMN `must_change_password` tinyint(1) NOT NULL DEFAULT 0;

-- ── 3. procurement_requests — ensure request_number index ───
-- Improves generateRequestNumber() query performance
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'procurement_requests'
      AND index_name   = 'idx_request_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_request_number already exists''',
    'ALTER TABLE `procurement_requests` ADD INDEX IF NOT EXISTS `idx_request_number` (`request_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 4. commitments — ensure commitment_number index ─────────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'commitments'
      AND index_name   = 'idx_commitment_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_commitment_number already exists''',
    'ALTER TABLE `commitments` ADD INDEX IF NOT EXISTS `idx_commitment_number` (`commitment_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 5. purchase_orders — ensure po_number index ─────────────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'purchase_orders'
      AND index_name   = 'idx_po_number'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_po_number already exists''',
    'ALTER TABLE `purchase_orders` ADD INDEX IF NOT EXISTS `idx_po_number` (`po_number`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 6. audit_log — composite index for timeline queries ─────
SET @exist := (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name   = 'audit_log'
      AND index_name   = 'idx_audit_log_table_record_date'
);
SET @sql := IF(@exist > 0,
    'SELECT ''Index idx_audit_log_table_record_date already exists''',
    'ALTER TABLE `audit_log` ADD INDEX IF NOT EXISTS `idx_audit_log_table_record_date` (`table_name`, `record_id`, `change_date`)'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── 7. Log this migration ────────────────────────────────────
INSERT IGNORE INTO `audit_log` (`table_name`, `record_id`, `action`, `changed_by`, `notes`)
VALUES ('MIGRATION', NULL, 'SCHEMA_SAFETY', 'system',
        '2026_05_11_schema_safety_and_indexes applied');



-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION: 2026_05_14_ensure_notes_columns.sql
-- ═══════════════════════════════════════════════════════════════════════

-- ============================================================
-- Migration: 2026_05_14_ensure_notes_columns.sql
-- Purpose  : Ensure legacy databases include `notes` columns
--            required by current INSERT statements.
-- ============================================================

-- 1) audit_log.notes (used widely by workflow/audit inserts)
SET @has_audit_notes := (
    SELECT COUNT(1)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'audit_log'
      AND column_name = 'notes'
);
SET @sql := IF(@has_audit_notes > 0,
    'SELECT ''Column audit_log.notes already exists''',
    'ALTER TABLE `audit_log` ADD COLUMN IF NOT EXISTS `notes` TEXT NULL AFTER `change_date`'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2) request_documents.notes (used by procurement document upload)
SET @has_request_doc_notes := (
    SELECT COUNT(1)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'request_documents'
      AND column_name = 'notes'
);
SET @sql := IF(@has_request_doc_notes > 0,
    'SELECT ''Column request_documents.notes already exists''',
    'ALTER TABLE `request_documents` ADD COLUMN IF NOT EXISTS `notes` TEXT NULL AFTER `uploaded_at`'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3) Log migration
INSERT IGNORE INTO `audit_log` (`table_name`, `record_id`, `action`, `changed_by`, `notes`)
VALUES ('MIGRATION', NULL, 'SCHEMA_FIX', 'system',
        '2026_05_14_ensure_notes_columns applied');



-- =============================================================================
-- End of combined schema
-- =============================================================================
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
