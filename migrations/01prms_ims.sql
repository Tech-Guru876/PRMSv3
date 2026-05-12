-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 12, 2026 at 03:48 PM
-- Server version: 11.8.6-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u153072617_prms_ims`
--

-- --------------------------------------------------------

--
-- Table structure for table `acting_roles`
--

CREATE TABLE `acting_roles` (
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

-- --------------------------------------------------------

--
-- Table structure for table `acting_role_log`
--

CREATE TABLE `acting_role_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `switched_from_role_id` int(11) NOT NULL,
  `switched_to_role_id` int(11) NOT NULL,
  `is_acting` tinyint(1) NOT NULL COMMENT '1=switched to acting, 0=reverted to primary',
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approval_rules`
--

CREATE TABLE `approval_rules` (
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

CREATE TABLE `approval_steps` (
  `step_id` int(11) NOT NULL,
  `workflow_id` int(11) NOT NULL,
  `step_order` int(11) NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_steps`
--

INSERT INTO `approval_steps` (`step_id`, `workflow_id`, `step_order`, `role_id`, `is_mandatory`) VALUES
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

CREATE TABLE `approval_transactions` (
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

CREATE TABLE `approval_workflows` (
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

INSERT INTO `approval_workflows` (`workflow_id`, `entity_type`, `min_amount`, `max_amount`, `description`, `is_active`) VALUES
(1, 'PROCUREMENT_REQUEST', 0.00, 3000000.00, 'Single Source Workflow', 1),
(2, 'PROCUREMENT_REQUEST', 3000000.01, 20000000.00, 'Restricted Bidding Workflow', 1),
(3, 'PROCUREMENT_REQUEST', 20000000.01, NULL, 'National Competitive Workflow', 1);

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
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

INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
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
INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
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
INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
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
INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
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
INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
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
(1848, 'users', 27, 'FORCE_ALL_PERMISSION', 'Technical & User Support Officer', '2026-03-11 01:09:54', 'All permissions force-enabled by Technical & User Support Officer'),
(1849, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 176 updated (granted=1)'),
(1850, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 193 updated (granted=1)'),
(1851, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 178 updated (granted=1)'),
(1852, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 56 updated (granted=1)'),
(1853, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 5 updated (granted=1)'),
(1854, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 195 updated (granted=1)'),
(1855, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 59 updated (granted=1)'),
(1856, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 7 updated (granted=1)'),
(1857, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 25 updated (granted=1)'),
(1858, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 28 updated (granted=1)'),
(1859, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 27 updated (granted=1)'),
(1860, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 58 updated (granted=1)'),
(1861, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 3 updated (granted=1)'),
(1862, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 189 updated (granted=1)'),
(1863, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 185 updated (granted=1)'),
(1864, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 191 updated (granted=1)'),
(1865, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 62 updated (granted=1)'),
(1866, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 107 updated (granted=1)'),
(1867, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 106 updated (granted=1)'),
(1868, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 117 updated (granted=1)'),
(1869, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 170 updated (granted=1)'),
(1870, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 196 updated (granted=1)'),
(1871, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 171 updated (granted=1)'),
(1872, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 192 updated (granted=1)'),
(1873, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 4 updated (granted=1)'),
(1874, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 194 updated (granted=1)'),
(1875, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 18 updated (granted=1)'),
(1876, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 20 updated (granted=1)'),
(1877, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 61 updated (granted=1)'),
(1878, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 6 updated (granted=1)'),
(1879, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 22 updated (granted=1)'),
(1880, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 60 updated (granted=1)'),
(1881, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 1 updated (granted=1)'),
(1882, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 175 updated (granted=1)'),
(1883, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 190 updated (granted=1)'),
(1884, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 57 updated (granted=1)'),
(1885, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 179 updated (granted=1)'),
(1886, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 29 updated (granted=1)'),
(1887, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 45 updated (granted=1)'),
(1888, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 120 updated (granted=1)'),
(1889, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 187 updated (granted=1)'),
(1890, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 200 updated (granted=1)'),
(1891, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 188 updated (granted=1)'),
(1892, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 110 updated (granted=1)'),
(1893, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 199 updated (granted=1)'),
(1894, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 197 updated (granted=1)'),
(1895, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 182 updated (granted=1)'),
(1896, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 183 updated (granted=1)'),
(1897, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 116 updated (granted=1)'),
(1898, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 55 updated (granted=1)'),
(1899, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 10 updated (granted=1)'),
(1900, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 118 updated (granted=1)'),
(1901, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 49 updated (granted=1)'),
(1902, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 50 updated (granted=1)'),
(1903, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 52 updated (granted=1)'),
(1904, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 32 updated (granted=1)'),
(1905, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 33 updated (granted=1)'),
(1906, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 180 updated (granted=1)'),
(1907, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 186 updated (granted=1)'),
(1908, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 113 updated (granted=1)'),
(1909, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 8 updated (granted=1)'),
(1910, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 9 updated (granted=1)'),
(1911, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 23 updated (granted=1)'),
(1912, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 105 updated (granted=1)'),
(1913, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 173 updated (granted=1)'),
(1914, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 104 updated (granted=1)'),
(1915, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 2 updated (granted=1)'),
(1916, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 184 updated (granted=1)'),
(1917, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 108 updated (granted=1)'),
(1918, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 109 updated (granted=1)'),
(1919, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 172 updated (granted=1)'),
(1920, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 174 updated (granted=1)'),
(1921, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 169 updated (granted=1)'),
(1922, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 112 updated (granted=1)'),
(1923, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 111 updated (granted=1)'),
(1924, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 47 updated (granted=1)'),
(1925, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 17 updated (granted=1)'),
(1926, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 26 updated (granted=1)'),
(1927, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 11 updated (granted=1)'),
(1928, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 48 updated (granted=1)'),
(1929, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 121 updated (granted=1)'),
(1930, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 46 updated (granted=1)'),
(1931, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 13 updated (granted=1)'),
(1932, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 51 updated (granted=1)'),
(1933, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 198 updated (granted=1)'),
(1934, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 181 updated (granted=1)'),
(1935, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 19 updated (granted=1)'),
(1936, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 14 updated (granted=1)'),
(1937, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 15 updated (granted=1)'),
(1938, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 54 updated (granted=1)'),
(1939, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 21 updated (granted=1)'),
(1940, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 103 updated (granted=1)'),
(1941, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 31 updated (granted=1)'),
(1942, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 16 updated (granted=1)'),
(1943, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 24 updated (granted=1)'),
(1944, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 102 updated (granted=1)'),
(1945, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 12 updated (granted=1)'),
(1946, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 114 updated (granted=1)'),
(1947, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 119 updated (granted=1)'),
(1948, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 177 updated (granted=1)'),
(1949, 'user_permissions', 27, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 01:10:08', 'Permission 115 updated (granted=1)'),
(1950, 'inv_items', 1, 'CREATE', 'Technical & User Support Officer', '2026-03-11 01:53:50', 'Item created: ITM-00001 - Computer'),
(1951, 'system_config', 0, 'UPDATE', 'Technical & User Support Officer', '2026-03-11 01:55:00', 'System settings updated: enable_notifications=OFF, threshold=500,000.00, petty_cash_limit=5,000.00, usd_to_jmd_rate=155.2200'),
(1952, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 187 updated (granted=1)'),
(1953, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 200 updated (granted=1)'),
(1954, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 188 updated (granted=1)'),
(1955, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 110 updated (granted=1)');
INSERT INTO `audit_log` (`audit_id`, `table_name`, `record_id`, `action`, `changed_by`, `change_date`, `notes`) VALUES
(1956, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 214 updated (granted=1)'),
(1957, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 212 updated (granted=1)'),
(1958, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 199 updated (granted=1)'),
(1959, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 197 updated (granted=1)'),
(1960, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 182 updated (granted=1)'),
(1961, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 183 updated (granted=1)'),
(1962, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 209 updated (granted=1)'),
(1963, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 210 updated (granted=1)'),
(1964, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 211 updated (granted=1)'),
(1965, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 213 updated (granted=1)'),
(1966, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 186 updated (granted=1)'),
(1967, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 184 updated (granted=1)'),
(1968, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 203 updated (granted=1)'),
(1969, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 198 updated (granted=1)'),
(1970, 'user_permissions', 40, 'PERMISSION_OVERRIDE', 'Technical & User Support Officer', '2026-03-11 13:57:43', 'Permission 181 updated (granted=1)'),
(1971, 'inv_locations', 1, 'CREATE', 'Alfred Bryan', '2026-03-11 14:45:12', 'Location created: GCST1F4'),
(1972, 'inv_items', 2, 'CREATE', 'Alfred Bryan', '2026-03-11 19:29:21', 'Item created: PC001 - Laptop'),
(1973, 'inv_items', 3, 'CREATE', 'Alfred Bryan', '2026-03-11 19:29:44', 'Item created: PC05 - Laptop'),
(1974, 'inv_items', 2, 'UPDATE', 'Alfred Bryan', '2026-03-11 19:32:26', 'Item updated: PC001'),
(1975, 'inv_items', 2, 'UPDATE', 'Alfred Bryan', '2026-03-11 19:33:21', 'Item updated: PC001'),
(1976, 'inv_requisitions', 1, 'CREATE', 'Alfred Bryan', '2026-03-11 19:39:04', 'Requisition SRQ-00001 created (SUBMITTED)');

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE `branches` (
  `branch_id` int(11) NOT NULL,
  `branch_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `branches`
--

INSERT INTO `branches` (`branch_id`, `branch_name`, `is_active`) VALUES
(1, 'Executive Branch', 1),
(5, 'HRM&A', 1),
(6, 'Analytical & Advisory', 1);

-- --------------------------------------------------------

--
-- Table structure for table `commitments`
--

CREATE TABLE `commitments` (
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

CREATE TABLE `compliance_approvals` (
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

CREATE TABLE `external_approvals` (
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

CREATE TABLE `invoices` (
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
-- Table structure for table `inv_accounting_classes`
--

CREATE TABLE `inv_accounting_classes` (
  `acct_class_id` int(11) NOT NULL,
  `acct_class_code` varchar(30) NOT NULL,
  `acct_class_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_accounting_classes`
--

INSERT INTO `inv_accounting_classes` (`acct_class_id`, `acct_class_code`, `acct_class_name`, `description`, `sort_order`) VALUES
(1, 'EXCHANGE', 'Exchange-Purchased Inventory', 'Purchased through normal procurement', 1),
(2, 'NON_EXCHANGE', 'Non-Exchange Inventory', 'Received via donations or grants', 2),
(3, 'NOMINAL_DIST', 'Inventory for Nominal/No-Charge Distribution', 'Distributed free or at nominal cost', 3),
(4, 'WRITE_DOWN', 'Write-Down Candidates', 'Items flagged for potential write-down', 4),
(5, 'DAMAGED_LOST', 'Damaged/Lost/Shrinkage Stock', 'Items damaged, lost, or shrunk', 5),
(6, 'DISPOSAL', 'Disposal Stock', 'Items designated for disposal', 6);

-- --------------------------------------------------------

--
-- Table structure for table `inv_adjustments`
--

CREATE TABLE `inv_adjustments` (
  `adjustment_id` int(11) NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_adjustment_items`
--

CREATE TABLE `inv_adjustment_items` (
  `adj_item_id` int(11) NOT NULL,
  `adjustment_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_system` decimal(14,4) DEFAULT NULL,
  `quantity_actual` decimal(14,4) DEFAULT NULL,
  `quantity_variance` decimal(14,4) DEFAULT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_cost` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_approval_log`
--

CREATE TABLE `inv_approval_log` (
  `approval_log_id` int(11) NOT NULL,
  `reference_type` varchar(50) NOT NULL COMMENT 'inv_requisitions, inv_transfers, etc.',
  `reference_id` int(11) NOT NULL,
  `approval_level` int(11) NOT NULL DEFAULT 1,
  `required_role_code` varchar(30) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','SKIPPED') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_approval_matrix`
--

CREATE TABLE `inv_approval_matrix` (
  `matrix_id` int(11) NOT NULL,
  `transaction_type` enum('REQUISITION','RECEIVING','ISSUE','TRANSFER','ADJUSTMENT','DISPOSAL','WRITE_OFF') NOT NULL,
  `item_class` varchar(30) DEFAULT NULL COMMENT 'Category or risk class code filter',
  `min_value` decimal(14,2) DEFAULT 0.00,
  `max_value` decimal(14,2) DEFAULT 999999999.99,
  `department_id` int(11) DEFAULT NULL,
  `is_emergency` tinyint(1) DEFAULT 0,
  `required_role_code` varchar(30) NOT NULL COMMENT 'inv_roles.role_code required to approve',
  `approval_level` int(11) DEFAULT 1 COMMENT 'Sequence in multi-level approval',
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_approval_matrix`
--

INSERT INTO `inv_approval_matrix` (`matrix_id`, `transaction_type`, `item_class`, `min_value`, `max_value`, `department_id`, `is_emergency`, `required_role_code`, `approval_level`, `is_active`) VALUES
(1, 'REQUISITION', NULL, 0.00, 50000.00, NULL, 0, 'STOCK_CONTROLLER', 1, 1),
(2, 'REQUISITION', NULL, 50000.01, 500000.00, NULL, 0, 'INVENTORY_MANAGER', 1, 1),
(3, 'REQUISITION', NULL, 500000.01, 999999999.99, NULL, 0, 'STORES_SUPERINTENDENT', 1, 1),
(4, 'REQUISITION', NULL, 0.00, 999999999.99, NULL, 1, 'STOCK_CONTROLLER', 1, 1),
(5, 'DISPOSAL', NULL, 0.00, 100000.00, NULL, 0, 'INVENTORY_MANAGER', 1, 1),
(6, 'DISPOSAL', NULL, 100000.01, 999999999.99, NULL, 0, 'STORES_SUPERINTENDENT', 1, 1),
(7, 'ADJUSTMENT', NULL, 0.00, 50000.00, NULL, 0, 'STOCK_CONTROLLER', 1, 1),
(8, 'ADJUSTMENT', NULL, 50000.01, 999999999.99, NULL, 0, 'INVENTORY_MANAGER', 1, 1),
(9, 'TRANSFER', NULL, 0.00, 999999999.99, NULL, 0, 'INVENTORY_MANAGER', 1, 1),
(10, 'ISSUE', NULL, 0.00, 50000.00, NULL, 0, 'STOCK_CONTROLLER', 1, 1),
(11, 'ISSUE', NULL, 50000.01, 999999999.99, NULL, 0, 'INVENTORY_MANAGER', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `inv_categories`
--

CREATE TABLE `inv_categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `category_code` varchar(20) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_category_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_categories`
--

INSERT INTO `inv_categories` (`category_id`, `category_name`, `category_code`, `description`, `parent_category_id`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'Consumables', 'CONSUMABLES', 'General consumable items', NULL, 1, 1, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(2, 'Office Supplies', 'OFFICE_SUP', 'Stationery, paper, toner, etc.', NULL, 1, 2, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(3, 'Cleaning Supplies', 'CLEANING', 'Cleaning compounds, equipment', NULL, 1, 3, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(4, 'Laboratory Supplies', 'LAB_SUP', 'Lab reagents, glassware, disposables', NULL, 1, 4, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(5, 'Chemicals and Reagents', 'CHEM_REAG', 'Chemicals, reagents, standards', NULL, 1, 5, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(6, 'PPE and Safety Items', 'PPE_SAFETY', 'Protective gear, safety equipment', NULL, 1, 6, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(7, 'Spare Parts', 'SPARE_PARTS', 'Equipment and machinery spare parts', NULL, 1, 7, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(8, 'Maintenance Stock', 'MAINT_STOCK', 'Maintenance and repair supplies', NULL, 1, 8, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(9, 'Uniforms', 'UNIFORMS', 'Staff uniforms and workwear', NULL, 1, 9, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(10, 'IT Consumables', 'IT_CONSUM', 'Cables, drives, peripherals', NULL, 1, 10, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(11, 'Printed Forms and Controlled Stationery', 'PRINT_FORMS', 'Pre-printed forms, numbered stationery', NULL, 1, 11, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(12, 'Goods Held for Distribution', 'DIST_GOODS', 'Items for distribution to clients/public', NULL, 1, 12, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(13, 'Goods Held for Resale', 'RESALE', 'Items held for resale where applicable', NULL, 1, 13, '2026-03-11 00:47:21', '2026-03-11 00:47:21'),
(14, 'Work-in-Progress / Service-Related Stock', 'WIP_SERVICE', 'Service-related stock and WIP items', NULL, 1, 14, '2026-03-11 00:47:21', '2026-03-11 00:47:21');

-- --------------------------------------------------------

--
-- Table structure for table `inv_criticality_classes`
--

CREATE TABLE `inv_criticality_classes` (
  `criticality_id` int(11) NOT NULL,
  `criticality_code` varchar(30) NOT NULL,
  `criticality_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_criticality_classes`
--

INSERT INTO `inv_criticality_classes` (`criticality_id`, `criticality_code`, `criticality_name`, `description`, `sort_order`) VALUES
(1, 'CRITICAL', 'Critical / Mission Essential', 'Items essential for core operations', 1),
(2, 'ESSENTIAL', 'Essential', 'Important items needed for normal operations', 2),
(3, 'ROUTINE', 'Routine', 'Standard items with no special urgency', 3),
(4, 'OBSOLETE', 'Obsolete / Pending Disposal', 'Items no longer needed or to be disposed', 4),
(5, 'QUARANTINE', 'Quarantined / Under Investigation', 'Items under review or investigation', 5);

-- --------------------------------------------------------

--
-- Table structure for table `inv_delegations`
--

CREATE TABLE `inv_delegations` (
  `delegation_id` int(11) NOT NULL,
  `delegator_user_id` int(11) NOT NULL,
  `delegate_user_id` int(11) NOT NULL,
  `inv_role_id` int(11) NOT NULL,
  `effective_from` datetime NOT NULL,
  `effective_to` datetime NOT NULL,
  `reason` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_disposals`
--

CREATE TABLE `inv_disposals` (
  `disposal_id` int(11) NOT NULL,
  `disposal_number` varchar(30) NOT NULL,
  `disposal_method` enum('DESTRUCTION','AUCTION','TRANSFER','DONATION','RETURN_TO_SUPPLIER','SCRAP','OTHER','SALE','RECYCLING','TRADE_IN','CANNIBALIZATION') NOT NULL,
  `reason` text NOT NULL,
  `survey_assessment` text DEFAULT NULL,
  `survey_notes` text DEFAULT NULL,
  `survey_completed_by` int(11) DEFAULT NULL,
  `survey_completed_at` datetime DEFAULT NULL,
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
  `status` enum('DRAFT','RECOMMENDED','PENDING_APPROVAL','APPROVED','COMMITTEE_REVIEW','COMPLETED','REJECTED','CANCELLED','PENDING_SURVEY','IN_PROGRESS') DEFAULT 'DRAFT',
  `proceeds_amount` decimal(14,2) DEFAULT 0.00,
  `actual_proceeds` decimal(14,2) DEFAULT 0.00,
  `proceeds_reference` varchar(100) DEFAULT NULL,
  `total_write_off_value` decimal(14,2) DEFAULT 0.00,
  `evidence_notes` text DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_disposal_items`
--

CREATE TABLE `inv_disposal_items` (
  `disp_item_id` int(11) NOT NULL,
  `disposal_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `estimated_value` decimal(14,2) DEFAULT 0.00,
  `serial_number` varchar(100) DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `condition_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_documents`
--

CREATE TABLE `inv_documents` (
  `document_id` int(11) NOT NULL,
  `document_number` varchar(30) NOT NULL,
  `document_type` enum('REQUISITION','PURCHASE_REQUEST','PURCHASE_ORDER','GOODS_RECEIVED_NOTE','INSPECTION_REPORT','BIN_CARD','STOCK_ISSUE_VOUCHER','TRANSFER_NOTE','ADJUSTMENT_NOTE','STOCK_COUNT_SHEET','VARIANCE_REPORT','QUARANTINE_NOTE','DISPOSAL_FORM','RETURN_TO_SUPPLIER','DONATION_ACCEPTANCE','INCIDENT_REPORT') NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_documents`
--

INSERT INTO `inv_documents` (`document_id`, `document_number`, `document_type`, `reference_table`, `reference_id`, `version`, `status`, `created_by`, `approved_by`, `approved_at`, `digital_signature`, `notes`, `is_locked`, `created_at`, `updated_at`) VALUES
(1, 'DOC-REQ-00001', 'REQUISITION', 'inv_requisitions', 1, 1, 'DRAFT', 40, NULL, NULL, NULL, NULL, 0, '2026-03-11 19:39:04', '2026-03-11 19:39:04');

-- --------------------------------------------------------

--
-- Table structure for table `inv_document_attachments`
--

CREATE TABLE `inv_document_attachments` (
  `attachment_id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_fiscal_periods`
--

CREATE TABLE `inv_fiscal_periods` (
  `period_id` int(11) NOT NULL,
  `period_name` varchar(50) NOT NULL COMMENT 'e.g. 2024-Q1, 2024-APR',
  `fiscal_year` varchar(10) NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` enum('OPEN','CLOSING','CLOSED','LOCKED') DEFAULT 'OPEN',
  `closed_by` int(11) DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_goods_received`
--

CREATE TABLE `inv_goods_received` (
  `grn_id` int(11) NOT NULL,
  `grn_number` varchar(30) NOT NULL,
  `po_reference` varchar(50) DEFAULT NULL COMMENT 'Link to purchase_orders.po_number',
  `contract_reference` varchar(100) DEFAULT NULL,
  `donation_reference` varchar(100) DEFAULT NULL,
  `supplier_vendor_id` int(11) DEFAULT NULL,
  `supplier_name` varchar(200) DEFAULT NULL,
  `donor_source` varchar(200) DEFAULT NULL COMMENT 'For non-exchange transactions',
  `delivery_note_number` varchar(50) DEFAULT NULL,
  `invoice_number` varchar(50) DEFAULT NULL,
  `receiving_location_id` int(11) DEFAULT NULL,
  `is_non_exchange_transaction` tinyint(1) DEFAULT 0,
  `is_donation` tinyint(1) DEFAULT 0,
  `acceptance_certificate_number` varchar(50) DEFAULT NULL,
  `received_by` int(11) NOT NULL,
  `received_date` date NOT NULL,
  `status` enum('DRAFT','RECEIVED','INSPECTED','ACCEPTED','PARTIAL','REJECTED','QUARANTINE','COMPLETED','INSPECTION') DEFAULT 'DRAFT',
  `inspected_by` int(11) DEFAULT NULL,
  `inspection_date` date DEFAULT NULL,
  `inspection_result` enum('PASS','FAIL','CONDITIONAL','PENDING') DEFAULT 'PENDING',
  `inspection_notes` text DEFAULT NULL,
  `fair_value_basis` varchar(200) DEFAULT NULL COMMENT 'IPSAS 12: valuation for donated inventory',
  `fair_value_assessor` varchar(200) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_grn_items`
--

CREATE TABLE `inv_grn_items` (
  `grn_item_id` int(11) NOT NULL,
  `grn_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_ordered` decimal(14,4) DEFAULT 0.0000,
  `quantity_received` decimal(14,4) NOT NULL,
  `quantity_accepted` decimal(14,4) DEFAULT 0.0000,
  `quantity_rejected` decimal(14,4) DEFAULT 0.0000,
  `quantity_short` decimal(14,4) DEFAULT 0.0000,
  `quantity_over` decimal(14,4) DEFAULT 0.0000,
  `quantity_damaged` decimal(14,4) DEFAULT 0.0000,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `lot_number` varchar(50) DEFAULT NULL,
  `batch_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `manufacturer_date` date DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `destination_location_id` int(11) DEFAULT NULL,
  `inspection_status` enum('PENDING','PASS','FAIL','CONDITIONAL') DEFAULT 'PENDING',
  `quality_notes` text DEFAULT NULL,
  `condition_on_receipt` varchar(30) DEFAULT 'GOOD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_incidents`
--

CREATE TABLE `inv_incidents` (
  `incident_id` int(11) NOT NULL,
  `incident_number` varchar(30) NOT NULL,
  `incident_type` enum('THEFT','DAMAGE','BREAKAGE','FIRE','FLOOD','VANDALISM','LOSS','OTHER') NOT NULL,
  `incident_date` date NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `status` enum('REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED') DEFAULT 'REPORTED',
  `reported_by` int(11) NOT NULL,
  `reported_at` datetime DEFAULT current_timestamp(),
  `investigator_id` int(11) DEFAULT NULL,
  `investigation_notes` text DEFAULT NULL,
  `investigation_completed_at` datetime DEFAULT NULL,
  `police_reference` varchar(100) DEFAULT NULL,
  `insurance_reference` varchar(100) DEFAULT NULL,
  `insurance_claim_amount` decimal(14,2) DEFAULT NULL,
  `total_estimated_loss` decimal(14,2) DEFAULT 0.00,
  `adjustment_id` int(11) DEFAULT NULL COMMENT 'Link to stock adjustment created from this incident',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_incident_items`
--

CREATE TABLE `inv_incident_items` (
  `incident_item_id` int(11) NOT NULL,
  `incident_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_lost` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `condition_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_issues`
--

CREATE TABLE `inv_issues` (
  `issue_id` int(11) NOT NULL,
  `issue_number` varchar(30) NOT NULL,
  `requisition_id` int(11) DEFAULT NULL,
  `requisition_number` varchar(30) DEFAULT NULL,
  `issued_to_user_id` int(11) DEFAULT NULL,
  `issued_to_department` int(11) DEFAULT NULL COMMENT 'branch_id',
  `issued_to_department_id` int(11) DEFAULT NULL,
  `issued_to_project` varchar(100) DEFAULT NULL,
  `issued_to_event` varchar(100) DEFAULT NULL,
  `issued_to_vehicle` varchar(50) DEFAULT NULL,
  `issued_to_building_room` varchar(100) DEFAULT NULL,
  `from_location_id` int(11) DEFAULT NULL,
  `cost_centre` varchar(50) DEFAULT NULL,
  `issue_date` date NOT NULL,
  `issued_by` int(11) NOT NULL,
  `status` enum('DRAFT','PENDING_APPROVAL','APPROVED','ISSUED','PARTIAL','CANCELLED','COMPLETED') DEFAULT 'DRAFT',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `acknowledgement_signature` text DEFAULT NULL COMMENT 'Digital signature or evidence',
  `acknowledged_at` datetime DEFAULT NULL,
  `delivery_note_number` varchar(50) DEFAULT NULL,
  `dispatch_confirmed` tinyint(1) DEFAULT 0,
  `expense_recognition_event` varchar(50) DEFAULT NULL COMMENT 'IPSAS 12: event triggering expense',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_issue_items`
--

CREATE TABLE `inv_issue_items` (
  `issue_item_id` int(11) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_requested` decimal(14,4) DEFAULT NULL,
  `stock_id` int(11) DEFAULT NULL COMMENT 'Specific stock record (batch/location)',
  `quantity_issued` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_cost` decimal(14,2) DEFAULT 0.00,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `lot_number` varchar(50) DEFAULT NULL,
  `batch_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `is_substitute` tinyint(1) DEFAULT 0,
  `original_item_id` int(11) DEFAULT NULL COMMENT 'If substitute, the originally requested item'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_items`
--

CREATE TABLE `inv_items` (
  `item_id` int(11) NOT NULL,
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
  `serial_number_flag` tinyint(1) DEFAULT 0,
  `batch_lot_flag` tinyint(1) DEFAULT 0,
  `expiry_date_flag` tinyint(1) DEFAULT 0,
  `hazard_class_flag` tinyint(1) DEFAULT 0,
  `storage_conditions` varchar(255) DEFAULT NULL,
  `shelf_life_days` int(11) DEFAULT NULL,
  `inspection_required` tinyint(1) DEFAULT 0,
  `receiving_tolerance_pct` decimal(5,2) DEFAULT 0.00,
  `preferred_supplier_ids` text DEFAULT NULL COMMENT 'JSON array of vendor IDs',
  `contract_reference` varchar(100) DEFAULT NULL,
  `procurement_method` varchar(100) DEFAULT NULL,
  `reorder_level` decimal(12,2) DEFAULT 0.00,
  `reorder_quantity` decimal(12,2) DEFAULT 0.00,
  `min_level` decimal(12,2) DEFAULT 0.00,
  `max_level` decimal(12,2) DEFAULT 0.00,
  `safety_stock` decimal(12,2) DEFAULT 0.00,
  `lead_time_days` int(11) DEFAULT 0,
  `economic_order_qty` decimal(12,2) DEFAULT NULL,
  `standard_cost` decimal(14,2) DEFAULT 0.00,
  `last_cost` decimal(14,2) DEFAULT 0.00,
  `average_cost` decimal(14,2) DEFAULT 0.00,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `nrv` decimal(14,2) DEFAULT NULL COMMENT 'Net Realisable Value (IPSAS 12)',
  `nrv_last_assessed` date DEFAULT NULL,
  `nrv_assessed_by` int(11) DEFAULT NULL,
  `valuation_method` enum('AVERAGE','FIFO','STANDARD','SPECIFIC') DEFAULT 'AVERAGE',
  `funding_source` varchar(100) DEFAULT NULL,
  `program_project_code` varchar(50) DEFAULT NULL,
  `gl_account_code` varchar(50) DEFAULT NULL,
  `criticality_id` int(11) DEFAULT NULL,
  `acct_class_id` int(11) DEFAULT NULL,
  `item_status` enum('ACTIVE','BLOCKED','OBSOLETE','QUARANTINED','DISPOSAL') DEFAULT 'ACTIVE',
  `issue_policy` enum('UNRESTRICTED','APPROVAL_REQUIRED','CONTROLLED') DEFAULT 'UNRESTRICTED',
  `asset_inventory_boundary` tinyint(1) DEFAULT 0 COMMENT 'Flag if item straddles asset/inventory line',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_items`
--

INSERT INTO `inv_items` (`item_id`, `item_code`, `item_name`, `description`, `category_id`, `subcategory_id`, `uom_id`, `pack_size`, `barcode`, `manufacturer`, `brand`, `model`, `part_number`, `serial_number_flag`, `batch_lot_flag`, `expiry_date_flag`, `hazard_class_flag`, `storage_conditions`, `shelf_life_days`, `inspection_required`, `receiving_tolerance_pct`, `preferred_supplier_ids`, `contract_reference`, `procurement_method`, `reorder_level`, `reorder_quantity`, `min_level`, `max_level`, `safety_stock`, `lead_time_days`, `economic_order_qty`, `standard_cost`, `last_cost`, `average_cost`, `unit_cost`, `nrv`, `nrv_last_assessed`, `nrv_assessed_by`, `valuation_method`, `funding_source`, `program_project_code`, `gl_account_code`, `criticality_id`, `acct_class_id`, `item_status`, `issue_policy`, `asset_inventory_boundary`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 'ITM-00001', 'Computer', 'Lenovo Desktop', 10, NULL, 1, 1.00, 'SN128878', 'Lenovo', 'lenovo', 'Ai9', 'Po22', 0, 0, 0, 0, NULL, NULL, 0, 0.00, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, 0.00, 0.00, 0.00, 0.00, NULL, NULL, NULL, 'AVERAGE', NULL, NULL, NULL, NULL, NULL, 'ACTIVE', 'UNRESTRICTED', 1, 27, NULL, '2026-03-11 01:53:50', '2026-03-11 01:53:50'),
(2, 'PC001', 'Laptop', 'ASUS ROG Strix G16 (2025)', 2, NULL, 1, 1.00, 'GCOFC2F1', 'ASUS', 'ASUS', 'ROG Strix G16 (2025)', 'NA', 1, 0, 0, 0, NULL, NULL, 1, 0.00, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, 2400.23, 0.00, 0.00, 0.00, NULL, NULL, NULL, 'AVERAGE', NULL, NULL, NULL, NULL, NULL, 'ACTIVE', 'UNRESTRICTED', 1, 40, 40, '2026-03-11 19:29:21', '2026-03-11 19:33:21'),
(3, 'PC05', 'Laptop', 'ASUS ROG Strix G16 (2025)', 2, NULL, 1, 1.00, 'GCOFC2F1', 'ASUS', 'ASUS', 'ROG Strix G16 (2025)', 'NA', 1, 0, 0, 0, NULL, NULL, 1, 0.00, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, 0.00, 0.00, 0.00, 0.00, NULL, NULL, NULL, 'AVERAGE', NULL, NULL, NULL, NULL, NULL, 'ACTIVE', 'UNRESTRICTED', 1, 40, NULL, '2026-03-11 19:29:44', '2026-03-11 19:29:44');

-- --------------------------------------------------------

--
-- Table structure for table `inv_item_risk_classes`
--

CREATE TABLE `inv_item_risk_classes` (
  `item_id` int(11) NOT NULL,
  `risk_class_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_item_risk_classes`
--

INSERT INTO `inv_item_risk_classes` (`item_id`, `risk_class_id`) VALUES
(2, 1),
(3, 1);

-- --------------------------------------------------------

--
-- Table structure for table `inv_item_suppliers`
--

CREATE TABLE `inv_item_suppliers` (
  `item_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `last_supply_date` date DEFAULT NULL,
  `last_price` decimal(14,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_locations`
--

CREATE TABLE `inv_locations` (
  `location_id` int(11) NOT NULL,
  `location_code` varchar(30) NOT NULL,
  `site_campus` varchar(100) DEFAULT NULL,
  `site_name` varchar(100) DEFAULT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_locations`
--

INSERT INTO `inv_locations` (`location_id`, `location_code`, `site_campus`, `site_name`, `building`, `floor`, `room_storage_area`, `bin_shelf_rack`, `security_level`, `temp_humidity_req`, `custodian_user_id`, `capacity`, `is_active`, `location_type`, `created_at`, `updated_at`) VALUES
(1, 'GCST1F4', 'Hope Complex, Hope Gardens  227 Old Hope Road Kingston', NULL, 'Main', '1', 'Finance & Accounts Storage Room', '1', 'RESTRICTED', 'Dry', 40, '15', 1, 'USABLE', '2026-03-11 14:45:12', '2026-03-11 14:45:12');

-- --------------------------------------------------------

--
-- Table structure for table `inv_period_snapshots`
--

CREATE TABLE `inv_period_snapshots` (
  `snapshot_id` int(11) NOT NULL,
  `period_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity_on_hand` decimal(14,4) DEFAULT 0.0000,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `total_value` decimal(14,2) DEFAULT 0.00,
  `nrv` decimal(14,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_quarantine_log`
--

CREATE TABLE `inv_quarantine_log` (
  `quarantine_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quarantine_location_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('QUARANTINED','UNDER_INSPECTION','RELEASED','DISPOSED') DEFAULT 'QUARANTINED',
  `quarantined_by` int(11) NOT NULL,
  `quarantined_at` datetime DEFAULT current_timestamp(),
  `released_by` int(11) DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `release_decision` enum('RETURN_TO_STOCK','DISPOSE','RETURN_TO_SUPPLIER') DEFAULT NULL,
  `decision_notes` text DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_recalls`
--

CREATE TABLE `inv_recalls` (
  `recall_id` int(11) NOT NULL,
  `recall_number` varchar(30) NOT NULL,
  `recall_type` enum('RECALL','WITHDRAWAL') NOT NULL DEFAULT 'RECALL',
  `item_id` int(11) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text NOT NULL,
  `severity` enum('CLASS_I','CLASS_II','CLASS_III') DEFAULT 'CLASS_II' COMMENT 'I=critical, II=moderate, III=minor',
  `status` enum('INITIATED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'INITIATED',
  `initiated_by` int(11) NOT NULL,
  `initiated_at` datetime DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  `total_quantity_affected` decimal(14,4) DEFAULT 0.0000,
  `total_quantity_recovered` decimal(14,4) DEFAULT 0.0000,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_recall_items`
--

CREATE TABLE `inv_recall_items` (
  `recall_item_id` int(11) NOT NULL,
  `recall_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `issued_to_user_id` int(11) DEFAULT NULL,
  `quantity_affected` decimal(14,4) DEFAULT 0.0000,
  `quantity_recovered` decimal(14,4) DEFAULT 0.0000,
  `status` enum('PENDING','NOTIFIED','RECOVERED','UNRECOVERABLE') DEFAULT 'PENDING',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_requisitions`
--

CREATE TABLE `inv_requisitions` (
  `requisition_id` int(11) NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_requisitions`
--

INSERT INTO `inv_requisitions` (`requisition_id`, `requisition_number`, `requester_user_id`, `department_id`, `cost_centre`, `intended_use`, `destination_location_id`, `urgency`, `justification`, `emergency_reason_code`, `status`, `approved_by`, `approved_at`, `rejection_reason`, `is_duplicate_flagged`, `procurement_trigger`, `created_at`, `updated_at`) VALUES
(1, 'SRQ-00001', 40, 5, 'hrm', 'purchase labtop', 1, 'NORMAL', 'work on the go/home', NULL, 'SUBMITTED', NULL, NULL, NULL, 0, 0, '2026-03-11 19:39:04', '2026-03-11 19:39:04');

-- --------------------------------------------------------

--
-- Table structure for table `inv_requisition_items`
--

CREATE TABLE `inv_requisition_items` (
  `req_item_id` int(11) NOT NULL,
  `requisition_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_requested` decimal(14,4) NOT NULL,
  `quantity_approved` decimal(14,4) DEFAULT NULL,
  `quantity_issued` decimal(14,4) DEFAULT 0.0000,
  `substitute_item_id` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `stock_available_at_request` decimal(14,4) DEFAULT NULL COMMENT 'Snapshot of available stock'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_requisition_items`
--

INSERT INTO `inv_requisition_items` (`req_item_id`, `requisition_id`, `item_id`, `quantity_requested`, `quantity_approved`, `quantity_issued`, `substitute_item_id`, `remarks`, `stock_available_at_request`) VALUES
(1, 1, 2, 1.0000, NULL, 0.0000, NULL, NULL, 0.0000);

-- --------------------------------------------------------

--
-- Table structure for table `inv_returns`
--

CREATE TABLE `inv_returns` (
  `return_id` int(11) NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_return_items`
--

CREATE TABLE `inv_return_items` (
  `return_item_id` int(11) NOT NULL,
  `return_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_risk_classes`
--

CREATE TABLE `inv_risk_classes` (
  `risk_class_id` int(11) NOT NULL,
  `risk_code` varchar(30) NOT NULL,
  `risk_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_risk_classes`
--

INSERT INTO `inv_risk_classes` (`risk_class_id`, `risk_code`, `risk_name`, `description`, `sort_order`) VALUES
(1, 'HIGH_VALUE', 'High-Value Items', 'Items above defined value threshold', 1),
(2, 'CONTROLLED', 'Controlled Items', 'Items with restricted access', 2),
(3, 'HAZARDOUS', 'Hazardous Items', 'Items requiring special handling', 3),
(4, 'EXPIRY_SENS', 'Expiry-Sensitive Items', 'Items with shelf life constraints', 4),
(5, 'SERIALIZED', 'Serialized Items', 'Items tracked by serial number', 5),
(6, 'REGULATED', 'Regulated Items', 'Items under regulatory control', 6),
(7, 'DONATED', 'Donated Items', 'Items received as donations/grants', 7),
(8, 'EMERG_RESERVE', 'Emergency Reserve / Contingency Stock', 'Items reserved for emergencies', 8);

-- --------------------------------------------------------

--
-- Table structure for table `inv_roles`
--

CREATE TABLE `inv_roles` (
  `inv_role_id` int(11) NOT NULL,
  `role_code` varchar(30) NOT NULL,
  `role_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_roles`
--

INSERT INTO `inv_roles` (`inv_role_id`, `role_code`, `role_name`, `description`) VALUES
(1, 'ACCT_OFFICER', 'Accounting Officer / Head of Department', 'Overall accountability for inventory'),
(2, 'ASSET_MGR', 'Asset Manager / Inventory Controller', 'Day-to-day inventory management'),
(3, 'STOREKEEPER', 'Storekeeper / Stores Clerk', 'Physical custody of stores'),
(4, 'REQ_OFFICER', 'Requisitioning Officer', 'Authorized to submit stock requisitions'),
(5, 'RCV_OFFICER', 'Receiving Officer', 'Authorized to receive goods'),
(6, 'APR_OFFICER', 'Approving Officer', 'Authorized to approve inventory transactions'),
(7, 'PROC_OFFICER', 'Procurement Officer', 'Links procurement to inventory'),
(8, 'FIN_OFFICER', 'Finance Officer', 'Financial oversight of inventory'),
(9, 'DISP_AUTH', 'Disposal / Survey / Write-off Authority', 'Authorized for disposal and write-off'),
(10, 'INT_AUDITOR', 'Internal Auditor', 'Audit and review of inventory'),
(11, 'SYS_ADMIN', 'System Administrator', 'System configuration for inventory'),
(12, 'DEPT_CUSTODIAN', 'Departmental Custodian / Location Custodian', 'Responsible for inventory at a location');

-- --------------------------------------------------------

--
-- Table structure for table `inv_stock`
--

CREATE TABLE `inv_stock` (
  `stock_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_on_hand` decimal(14,4) DEFAULT 0.0000,
  `quantity_reserved` decimal(14,4) DEFAULT 0.0000 COMMENT 'Reserved for approved requisitions',
  `quantity_available` decimal(14,4) GENERATED ALWAYS AS (`quantity_on_hand` - `quantity_reserved`) STORED,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `nrv` decimal(14,2) DEFAULT NULL,
  `stock_status` enum('USABLE','QUARANTINE','EXPIRED','DAMAGED','DISPOSAL') DEFAULT 'USABLE',
  `received_date` date DEFAULT NULL,
  `last_count_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_stock_counts`
--

CREATE TABLE `inv_stock_counts` (
  `count_id` int(11) NOT NULL,
  `count_number` varchar(30) NOT NULL,
  `count_date` date NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `count_type` enum('FULL','CYCLE','SPOT','ANNUAL') DEFAULT 'FULL',
  `is_blind_count` tinyint(1) DEFAULT 1 COMMENT 'Hide system qty from counters',
  `is_frozen` tinyint(1) DEFAULT 0 COMMENT 'Block transactions during count',
  `frozen_at` datetime DEFAULT NULL,
  `unfrozen_at` datetime DEFAULT NULL,
  `variance_threshold_pct` decimal(5,2) DEFAULT 5.00 COMMENT 'Escalation threshold %',
  `conducted_by` int(11) NOT NULL,
  `count_lead` int(11) DEFAULT NULL,
  `supervised_by` int(11) DEFAULT NULL,
  `status` enum('PLANNED','IN_PROGRESS','COMPLETED','APPROVED','ADJUSTMENT_CREATED','CANCELLED') DEFAULT 'PLANNED',
  `notes` text DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_stock_count_items`
--

CREATE TABLE `inv_stock_count_items` (
  `count_item_id` int(11) NOT NULL,
  `count_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `system_quantity` decimal(14,4) NOT NULL,
  `counted_quantity` decimal(14,4) DEFAULT NULL,
  `variance` decimal(14,4) GENERATED ALWAYS AS (`counted_quantity` - `system_quantity`) STORED,
  `variance_quantity` decimal(14,4) DEFAULT NULL,
  `variance_reason` text DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_transactions`
--

CREATE TABLE `inv_transactions` (
  `transaction_id` int(11) NOT NULL,
  `transaction_type` enum('RECEIVE','ISSUE','TRANSFER_OUT','TRANSFER_IN','ADJUSTMENT_GAIN','ADJUSTMENT_LOSS','DISPOSAL','COUNT_ADJUST','RETURN','RECEIPT','ADJUSTMENT_IN','ADJUSTMENT_OUT','QUARANTINE_IN','QUARANTINE_OUT','WRITE_DOWN','RETURN_TO_SUPPLIER') NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_transfers`
--

CREATE TABLE `inv_transfers` (
  `transfer_id` int(11) NOT NULL,
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
  `status` enum('DRAFT','PENDING_APPROVAL','PENDING_FS_APPROVAL','APPROVED','IN_TRANSIT','COMPLETED','CANCELLED','REJECTED') DEFAULT 'DRAFT',
  `received_by` int(11) DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `dispatched_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_transfer_items`
--

CREATE TABLE `inv_transfer_items` (
  `transfer_item_id` int(11) NOT NULL,
  `transfer_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `stock_id` int(11) DEFAULT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `quantity_received` decimal(14,4) DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `batch_lot_number` varchar(50) DEFAULT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `valuation_at_transfer` decimal(14,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_units_of_measure`
--

CREATE TABLE `inv_units_of_measure` (
  `uom_id` int(11) NOT NULL,
  `uom_code` varchar(10) NOT NULL,
  `uom_name` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inv_units_of_measure`
--

INSERT INTO `inv_units_of_measure` (`uom_id`, `uom_code`, `uom_name`, `is_active`) VALUES
(1, 'EA', 'Each', 1),
(2, 'PK', 'Pack', 1),
(3, 'BX', 'Box', 1),
(4, 'CS', 'Case', 1),
(5, 'RL', 'Roll', 1),
(6, 'BT', 'Bottle', 1),
(7, 'KG', 'Kilogram', 1),
(8, 'LT', 'Litre', 1),
(9, 'M', 'Metre', 1),
(10, 'PR', 'Pair', 1),
(11, 'ST', 'Set', 1),
(12, 'DZ', 'Dozen', 1),
(13, 'RM', 'Ream', 1),
(14, 'GL', 'Gallon', 1),
(15, 'TB', 'Tube', 1),
(16, 'DR', 'Drum', 1),
(17, 'CT', 'Carton', 1),
(18, 'TN', 'Tin', 1),
(19, 'SH', 'Sheet', 1),
(20, 'BAG', 'Bag', 1);

-- --------------------------------------------------------

--
-- Table structure for table `inv_user_roles`
--

CREATE TABLE `inv_user_roles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `inv_role_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL COMMENT 'Optional: scope role to a location',
  `is_active` tinyint(1) DEFAULT 1,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inv_write_downs`
--

CREATE TABLE `inv_write_downs` (
  `write_down_id` int(11) NOT NULL,
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
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
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

CREATE TABLE `payments` (
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

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `description`) VALUES
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
(180, 'process_reimbursement', 'Process reimbursement payment after approval'),
(181, 'view_inventory', 'View inventory items and stock levels'),
(182, 'manage_inventory_items', 'Create and edit inventory item master data'),
(183, 'manage_inventory_locations', 'Manage storage locations'),
(184, 'submit_stock_requisition', 'Submit stock requisitions'),
(185, 'approve_stock_requisition', 'Approve stock requisitions'),
(186, 'receive_goods', 'Record goods received notes'),
(187, 'inspect_goods', 'Inspect goods on GRN'),
(188, 'issue_stock', 'Issue stock from stores'),
(189, 'approve_stock_issue', 'Approve stock issues for controlled items'),
(190, 'create_transfer', 'Create stock transfers'),
(191, 'approve_transfer', 'Approve stock transfers'),
(192, 'create_adjustment', 'Create stock adjustments'),
(193, 'approve_adjustment', 'Approve stock adjustments'),
(194, 'create_disposal', 'Create disposal/write-off requests'),
(195, 'approve_disposal', 'Approve disposals and write-offs'),
(196, 'conduct_stock_count', 'Conduct physical stock counts'),
(197, 'manage_inv_roles', 'Manage inventory user roles'),
(198, 'view_inv_reports', 'View inventory reports'),
(199, 'manage_inv_delegations', 'Manage inventory delegations'),
(200, 'inventory_admin', 'Full inventory administration access'),
(201, 'dispose_stock', 'Create disposal/write-off requests'),
(202, 'adjust_stock', 'Create stock adjustments'),
(203, 'transfer_stock', 'Create stock transfers'),
(204, 'view_inventory_reports', 'View inventory reports'),
(209, 'manage_quarantine', 'Move stock into/out of quarantine'),
(210, 'manage_recalls', 'Initiate and manage recall/withdrawal'),
(211, 'manage_returns', 'Create and manage return-to-supplier'),
(212, 'manage_incidents', 'Report and manage incident/loss reports'),
(213, 'manage_write_downs', 'Create and approve write-downs (NRV)'),
(214, 'manage_fiscal_periods', 'Open/close fiscal periods'),
(215, 'approve_issue', 'Approve stock issue vouchers'),
(216, 'approve_stock_count', 'Approve completed stock counts'),
(217, 'approve_return', 'Approve return-to-supplier requests');

-- --------------------------------------------------------

--
-- Table structure for table `petty_cash_disbursements`
--

CREATE TABLE `petty_cash_disbursements` (
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

-- --------------------------------------------------------

--
-- Table structure for table `petty_cash_reconciliations`
--

CREATE TABLE `petty_cash_reconciliations` (
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

CREATE TABLE `po_adjustment_log` (
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

CREATE TABLE `po_items` (
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

CREATE TABLE `po_variations` (
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

CREATE TABLE `po_warnings` (
  `warning_id` int(11) NOT NULL,
  `po_id` int(11) NOT NULL,
  `warning_type` varchar(50) NOT NULL,
  `message` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `po_warnings`
--

INSERT INTO `po_warnings` (`warning_id`, `po_id`, `warning_type`, `message`, `created_at`) VALUES
(8, 50, 'PO_LIMIT_ATTEMPT', 'Invoice attempt exceeded approved PO total (including variations)', '2026-02-06 19:03:52');

-- --------------------------------------------------------

--
-- Table structure for table `pre_authorizations`
--

CREATE TABLE `pre_authorizations` (
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

INSERT INTO `pre_authorizations` (`auth_id`, `request_id`, `authorized_by`, `authorization_date`, `authorization_amount`, `authorization_notes`, `created_at`) VALUES
(4, 128, 32, '2026-03-03 00:00:00', 2000.00, 'Pre-authorization for reimbursement request', '2026-03-04 09:46:43');

-- --------------------------------------------------------

--
-- Table structure for table `procurement_requests`
--

CREATE TABLE `procurement_requests` (
  `request_id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `request_number` varchar(20) NOT NULL,
  `request_date` date NOT NULL,
  `description` text NOT NULL,
  `request_type` enum('REGULAR','EXPEDITED','EMERGENCY') DEFAULT 'REGULAR',
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

INSERT INTO `procurement_requests` (`request_id`, `branch_id`, `request_number`, `request_date`, `description`, `request_type`, `status`, `rfq_date`, `quotes_received`, `awardee`, `award_date`, `created_by`, `created_at`, `updated_at`, `approved_by`, `approved_at`, `decline_reason`, `signed_request_document_path`, `signed_request_received_date`, `signed_by_user_id`, `finance_reviewed_by`, `finance_reviewed_at`, `funds_available`, `procurement_method`, `external_approval_required`, `requires_rfq`, `rfq_letter_generated_at`, `estimated_value`, `currency`, `usd_rate`, `ppc_approval_status`, `cabinet_approval_status`) VALUES
(123, 6, 'PR001', '2026-02-26', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 37, '2026-02-26 15:55:56', '2026-02-26 10:56:09', 33, '2026-02-26 11:04:04', NULL, NULL, NULL, NULL, 33, '2026-02-26 11:04:04', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 7000.00, 'JMD', NULL, NULL, NULL),
(124, 6, 'PR002', '2026-02-26', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 38, '2026-02-26 16:06:07', '2026-02-26 11:07:39', 33, '2026-02-26 11:08:20', NULL, NULL, NULL, NULL, 33, '2026-02-26 11:08:20', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 28038.00, 'JMD', NULL, NULL, NULL),
(125, 1, 'PR003', '2026-02-26', '', 'REGULAR', 'PROCUREMENT_STAGE', NULL, 0, NULL, NULL, 36, '2026-02-26 16:16:29', '2026-02-26 11:29:31', 32, '2026-02-26 11:30:49', NULL, NULL, NULL, NULL, 32, '2026-02-26 11:30:49', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 1500000.00, 'JMD', NULL, NULL, NULL),
(126, 6, 'PR004', '2026-02-26', '', 'REGULAR', 'SUBMITTED', NULL, 0, NULL, NULL, 41, '2026-02-26 16:18:23', '2026-02-26 11:18:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'SINGLE_SOURCE', NULL, 1, NULL, 224999.10, 'JMD', NULL, NULL, NULL),
(127, 1, 'PR005', '2026-02-26', '', 'REGULAR', 'DECLINED', NULL, 0, NULL, NULL, 36, '2026-02-26 16:20:53', '2026-02-26 11:21:05', 32, '2026-02-26 11:22:21', 'Youre pushing it', NULL, NULL, NULL, NULL, NULL, 0, 'SINGLE_SOURCE', NULL, 1, NULL, 15000.00, 'JMD', NULL, NULL, NULL),
(128, 1, 'PR006', '2026-03-04', 'Hostinger monthly payment', '', 'SUBMITTED', NULL, 0, NULL, NULL, 32, '2026-03-04 14:46:43', '2026-03-04 09:46:56', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'SINGLE_SOURCE', NULL, 1, NULL, 2000.00, 'JMD', NULL, NULL, NULL),
(129, 5, 'PR007', '2026-03-04', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-04 18:09:12', '2026-03-04 15:40:55', 35, '2026-03-04 16:02:57', NULL, NULL, NULL, NULL, 35, '2026-03-04 16:02:57', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 63000.00, 'JMD', NULL, NULL, NULL),
(130, 5, 'PR008', '2026-03-04', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-04 18:10:59', '2026-03-04 15:43:04', 35, '2026-03-04 16:03:50', NULL, NULL, NULL, NULL, 35, '2026-03-04 16:03:50', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 19000.00, 'JMD', NULL, NULL, NULL),
(131, 1, 'PR009', '2026-03-04', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 27, '2026-03-04 20:46:20', '2026-03-04 15:53:17', 32, '2026-03-04 16:04:34', NULL, NULL, NULL, NULL, 32, '2026-03-04 16:04:34', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 257427.42, 'JMD', NULL, NULL, NULL),
(132, 5, 'PR010', '2026-03-06', '', 'REGULAR', 'RFQ_LETTER_AVAILABLE', NULL, 0, NULL, NULL, 40, '2026-03-06 17:14:45', '2026-03-06 12:15:29', 35, '2026-03-06 12:24:09', NULL, NULL, NULL, NULL, 35, '2026-03-06 12:24:09', 1, 'SINGLE_SOURCE', NULL, 1, NULL, 500000.00, 'JMD', NULL, NULL, NULL);

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

CREATE TABLE `procurement_request_items` (
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

INSERT INTO `procurement_request_items` (`item_id`, `request_id`, `item_name`, `specification`, `quantity`, `remarks`, `created_at`) VALUES
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
(149, 132, 'Mobile Phone', 'Samsung Galaxy S25FE', 5, '', '2026-03-06 17:14:45');

-- --------------------------------------------------------

--
-- Table structure for table `procurement_verifications`
--

CREATE TABLE `procurement_verifications` (
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

CREATE TABLE `purchase_orders` (
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

CREATE TABLE `reimbursement_invoices` (
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

CREATE TABLE `reimbursement_status_history` (
  `history_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `change_date` datetime DEFAULT current_timestamp(),
  `change_notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historical record of reimbursement request status changes';

-- --------------------------------------------------------

--
-- Table structure for table `request_approvals`
--

CREATE TABLE `request_approvals` (
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
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `request_approvals`
--

INSERT INTO `request_approvals` (`id`, `request_id`, `role`, `approved_by`, `status`, `approved_at`, `entity_type`, `entity_id`, `stage_order`, `rejection_reason`, `comments`, `created_at`) VALUES
(86, 123, 'Deputy Government Chemist', 33, 'approved', '2026-02-26 11:04:04', 'REQUEST', 123, 1, NULL, NULL, '2026-02-26 10:56:09'),
(87, 124, 'Deputy Government Chemist', 33, 'approved', '2026-02-26 11:08:20', 'REQUEST', 124, 1, NULL, NULL, '2026-02-26 11:07:39'),
(89, 126, 'Deputy Government Chemist', NULL, 'pending', NULL, 'REQUEST', 126, 1, NULL, NULL, '2026-02-26 11:18:43'),
(91, 125, 'HOD', 32, 'approved', '2026-02-26 11:30:49', 'REQUEST', 125, 1, NULL, NULL, '2026-02-26 11:29:31'),
(92, 128, 'Finance Officer', NULL, 'pending', NULL, 'REQUEST', 128, 1, NULL, NULL, '2026-03-04 09:46:56'),
(95, 129, 'Director HRM&A', 35, 'approved', '2026-03-04 16:02:57', 'REQUEST', 129, 1, NULL, NULL, '2026-03-04 15:40:55'),
(96, 130, 'Director HRM&A', 35, 'approved', '2026-03-04 16:03:50', 'REQUEST', 130, 1, NULL, NULL, '2026-03-04 15:43:04'),
(97, 131, 'HOD', 32, 'approved', '2026-03-04 16:04:34', 'REQUEST', 131, 1, NULL, NULL, '2026-03-04 15:53:17'),
(98, 132, 'Director HRM&A', 35, 'approved', '2026-03-06 12:24:09', 'REQUEST', 132, 1, NULL, NULL, '2026-03-06 12:15:29');

-- --------------------------------------------------------

--
-- Table structure for table `request_documents`
--

CREATE TABLE `request_documents` (
  `document_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `document_type` enum('SIGNED_PO','SIGNED_COMMITMENT','OTHER') NOT NULL DEFAULT 'OTHER',
  `document_name` varchar(255) NOT NULL COMMENT 'Original filename',
  `document_path` varchar(255) NOT NULL COMMENT 'Server file path',
  `uploaded_by` int(11) NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rfqs`
--

CREATE TABLE `rfqs` (
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

CREATE TABLE `rfq_evaluation_committee` (
  `committee_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rfq_evaluation_committee`
--

INSERT INTO `rfq_evaluation_committee` (`committee_id`, `rfq_id`, `user_id`, `role`) VALUES
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

CREATE TABLE `rfq_evaluation_reports` (
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

CREATE TABLE `rfq_quotes` (
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

-- --------------------------------------------------------

--
-- Table structure for table `rfq_scores`
--

CREATE TABLE `rfq_scores` (
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

CREATE TABLE `rfq_vendors` (
  `rfq_vendor_id` int(11) NOT NULL,
  `rfq_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `vendor_name` varchar(150) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `response_status` enum('PENDING','WILL_SUBMIT','DECLINED','SUBMITTED','SELECTED') DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rfq_votes`
--

CREATE TABLE `rfq_votes` (
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

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`, `created_at`) VALUES
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

CREATE TABLE `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
(6, 180),
(2, 181),
(3, 181),
(4, 181),
(12, 181),
(12, 184),
(4, 185),
(2, 186),
(2, 187),
(4, 189),
(4, 191),
(4, 193),
(2, 198),
(3, 198),
(4, 198),
(2, 201),
(4, 201),
(2, 202),
(2, 203),
(2, 204),
(3, 204),
(4, 204),
(12, 204),
(2, 209),
(2, 211),
(4, 212),
(3, 213),
(3, 214),
(4, 215),
(4, 216),
(4, 217);

-- --------------------------------------------------------

--
-- Table structure for table `system_alerts`
--

CREATE TABLE `system_alerts` (
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

CREATE TABLE `system_config` (
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

INSERT INTO `system_config` (`config_id`, `config_key`, `config_value`, `description`, `created_at`, `updated_at`) VALUES
(1, 'petty_cash_limit', '5000', 'Maximum amount for petty cash procurement without formal approval (JMD)', '2026-02-17 02:30:11', '2026-02-18 00:00:42'),
(2, 'direct_procurement_threshold', '500000', 'Threshold value for direct procurement eligibility (JMD)', '2026-02-17 02:30:11', '2026-02-18 00:00:42'),
(7, 'enable_notifications', '0', 'Enable/disable email notifications (1=enabled, 0=disabled)', '2026-02-17 21:32:44', '2026-03-10 20:55:00'),
(19, 'usd_to_jmd_rate', '155.22', 'Current USD to JMD exchange rate for currency conversion', '2026-02-24 01:17:49', '2026-02-25 21:18:00'),
(41, 'hod_approval_threshold', '500000.00', 'Procurement requests above this amount require HOD approval (JMD)', '2026-03-17 15:29:12', '2026-03-17 16:23:59'),
(42, 'committee_review_threshold', '3000000.00', 'Procurement requests above this amount require committee review (JMD)', '2026-03-17 15:29:12', '2026-03-17 16:23:59');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
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

INSERT INTO `users` (`user_id`, `full_name`, `email`, `role_id`, `password_hash`, `is_active`, `created_at`, `must_change_password`, `password_changed_at`, `failed_attempts`, `lock_until`, `reset_token_hash`, `reset_token_expires`) VALUES
(27, 'Technical & User Support Officer', 'Demario.Ewan@moh.gov.jm', 6, '$2y$10$genzJdfdKkzU5Jqg3LKeyeaUXPCr6BEjmPouYjbl9FUDqJFdsAS7i', 1, '2026-02-25 15:05:24', 0, '2026-02-25 10:07:13', 0, NULL, NULL, NULL),
(30, 'Demario Ewan', 'demarioe14@gmail.com', 6, '$2y$10$ElFPjESZG3kHeBMgT4ALtuysNO3h3MgxH/CZf0A3EwiVOe2Fo7UFS', 1, '2026-02-26 15:14:04', 0, '2026-02-26 10:17:55', 1, NULL, NULL, NULL),
(32, 'Yanique A. Fraser', 'yanique.fraser@moh.gov.jm', 4, '$2y$10$X/nzfCVshLBMuNGdeDFDT.CzBjxewEUzS02L8KAyTXiT53qG0eqcC', 1, '2026-02-26 15:28:16', 0, '2026-02-26 10:37:45', 0, NULL, NULL, NULL),
(33, 'Daneika Anderson', 'Daneika.Anderson@moh.gov.jm', 9, '$2y$10$2A5G.tgoFure8koXQnu8peMl.7RfmFxQ5MMx6TuutQucFOi4MlBt6', 1, '2026-02-26 15:29:16', 0, '2026-02-26 11:01:58', 0, NULL, NULL, NULL),
(34, 'Latoya Gayle', 'Latoya.Gayle@moh.gov.jm', 3, '$2y$10$JKmsjcSWwv4objXFXCjnzOfAIGG8LrbBTiBEzSaiXaeIp7RccKKZK', 1, '2026-02-26 15:29:48', 0, '2026-03-04 09:53:22', 0, NULL, NULL, NULL),
(35, 'Nellesha Samuels', 'Nellesha.Samuels@moh.gov.jm', 10, '$2y$10$QUMu2jnAN3f52X8M3B/OeOvlcVvgCmzkm23Ej4myoHWoBcrYJf/am', 1, '2026-02-26 15:30:15', 0, '2026-03-04 09:59:46', 0, NULL, NULL, NULL),
(36, 'Ryan Warburton', 'Ryan.Warburton@moh.gov.jm', 12, '$2y$10$PKQcRwWLT5v9G.9rEc9JqO9fnPleVqhd9qJLVJo2dySMCgGBCJKgK', 1, '2026-02-26 15:30:42', 0, '2026-02-26 11:12:42', 0, NULL, NULL, NULL),
(37, 'Shermaine McKenzie', 'Shermaine.McKenzie@moh.gov.jm', 12, '$2y$10$3G/DCM0X7ZYB1QB3P4ZC..RyVbGUfH1yIsJeNJWxn9/spDzU3beVW', 1, '2026-02-26 15:31:09', 0, '2026-02-26 10:52:01', 0, NULL, NULL, NULL),
(38, 'Waveney Warrick', 'Waveney.Warrick@moh.gov.jm', 12, '$2y$10$8Q/iPFz5x.13NbJrYg08BeNvu8CtafdCxAxJKqGOVDfle.qd7NG5y', 1, '2026-02-26 15:31:30', 0, '2026-02-26 11:00:39', 0, NULL, NULL, NULL),
(39, 'Sancia Johnally Haynes', 'Sancia.Johnally-Haynes@moh.gov.jm', 12, '$2y$10$uEV/WQl0fMHBCesu26vvJOcWMwJlwFvRnDhNJLVp5wQ6/nuAZoKxO', 1, '2026-02-26 15:32:07', 0, '2026-03-04 15:10:33', 0, NULL, NULL, NULL),
(40, 'Alfred Bryan', 'Alfred.Bryan@moh.gov.jm', 12, '$2y$10$AmmaNjQz8dQXGyipklEy6.BCa5qUC9vjiwLyZd4mJx77U2mOrZhIq', 1, '2026-02-26 15:32:30', 0, '2026-03-06 12:12:33', 0, NULL, NULL, NULL),
(41, 'Fredricka Chung', 'Fredricka.Chung@moh.gov.jm', 12, '$2y$10$rB/iA9zKLWZOLivDI1efIOyOXQRW1hVsZDnXU.3MRuSXmXiIr4vLe', 1, '2026-02-26 15:33:18', 0, '2026-02-26 11:15:58', 0, NULL, NULL, NULL),
(42, 'Yanique McKenzie', 'Yanique.McKenzie@moh.gov.jm', 12, '$2y$10$ATaBG8.wFpQ8HZHT.FtxS.phtDaieOT9bK2jvjYblgxDnNpIQSt3G', 1, '2026-02-26 15:33:44', 1, NULL, 0, NULL, NULL, NULL),
(43, 'Shenai McFarlane', 'Shenai.McFarlane@moh.gov.jm', 12, '$2y$10$F3ZoG92jf9GQSdj8TKtR8ey4f8uTEe.mTkh2tvaOtIlsso6t2mZhK', 1, '2026-02-26 15:34:07', 1, NULL, 0, NULL, NULL, NULL),
(44, 'Gabrielle Green', 'Gabrielle.Green@moh.gov.jm', 2, '$2y$10$WQ8rgucFRH/gztETMZjUbOPZj/W8jOtujyoj6mWRC9YyERwzVkxCK', 1, '2026-02-26 15:34:42', 0, '2026-02-26 11:05:55', 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
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

INSERT INTO `user_permissions` (`id`, `user_id`, `permission_id`, `is_granted`, `expires_at`, `created_at`) VALUES
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
(543, 27, 176, 1, NULL, '2026-03-10 20:09:54'),
(544, 27, 193, 1, NULL, '2026-03-10 20:09:54'),
(545, 27, 178, 1, NULL, '2026-03-10 20:09:54'),
(546, 27, 56, 1, NULL, '2026-03-10 20:09:54'),
(547, 27, 5, 1, NULL, '2026-03-10 20:09:54'),
(548, 27, 195, 1, NULL, '2026-03-10 20:09:54'),
(549, 27, 59, 1, NULL, '2026-03-10 20:09:54'),
(550, 27, 7, 1, NULL, '2026-03-10 20:09:54'),
(551, 27, 25, 1, NULL, '2026-03-10 20:09:54'),
(552, 27, 28, 1, NULL, '2026-03-10 20:09:54'),
(553, 27, 27, 1, NULL, '2026-03-10 20:09:54'),
(554, 27, 58, 1, NULL, '2026-03-10 20:09:54'),
(555, 27, 3, 1, NULL, '2026-03-10 20:09:54'),
(556, 27, 189, 1, NULL, '2026-03-10 20:09:54'),
(557, 27, 185, 1, NULL, '2026-03-10 20:09:54'),
(558, 27, 191, 1, NULL, '2026-03-10 20:09:54'),
(559, 27, 62, 1, NULL, '2026-03-10 20:09:54'),
(560, 27, 107, 1, NULL, '2026-03-10 20:09:54'),
(561, 27, 106, 1, NULL, '2026-03-10 20:09:54'),
(562, 27, 117, 1, NULL, '2026-03-10 20:09:54'),
(563, 27, 170, 1, NULL, '2026-03-10 20:09:54'),
(564, 27, 196, 1, NULL, '2026-03-10 20:09:54'),
(565, 27, 171, 1, NULL, '2026-03-10 20:09:54'),
(566, 27, 192, 1, NULL, '2026-03-10 20:09:54'),
(567, 27, 4, 1, NULL, '2026-03-10 20:09:54'),
(568, 27, 194, 1, NULL, '2026-03-10 20:09:54'),
(569, 27, 18, 1, NULL, '2026-03-10 20:09:54'),
(570, 27, 20, 1, NULL, '2026-03-10 20:09:54'),
(571, 27, 61, 1, NULL, '2026-03-10 20:09:54'),
(572, 27, 6, 1, NULL, '2026-03-10 20:09:54'),
(573, 27, 22, 1, NULL, '2026-03-10 20:09:54'),
(574, 27, 60, 1, NULL, '2026-03-10 20:09:54'),
(575, 27, 1, 1, NULL, '2026-03-10 20:09:54'),
(576, 27, 175, 1, NULL, '2026-03-10 20:09:54'),
(577, 27, 190, 1, NULL, '2026-03-10 20:09:54'),
(578, 27, 57, 1, NULL, '2026-03-10 20:09:54'),
(579, 27, 179, 1, NULL, '2026-03-10 20:09:54'),
(580, 27, 29, 1, NULL, '2026-03-10 20:09:54'),
(581, 27, 45, 1, NULL, '2026-03-10 20:09:54'),
(582, 27, 120, 1, NULL, '2026-03-10 20:09:54'),
(583, 27, 187, 1, NULL, '2026-03-10 20:09:54'),
(584, 27, 200, 1, NULL, '2026-03-10 20:09:54'),
(585, 27, 188, 1, NULL, '2026-03-10 20:09:54'),
(586, 27, 110, 1, NULL, '2026-03-10 20:09:54'),
(587, 27, 199, 1, NULL, '2026-03-10 20:09:54'),
(588, 27, 197, 1, NULL, '2026-03-10 20:09:54'),
(589, 27, 182, 1, NULL, '2026-03-10 20:09:54'),
(590, 27, 183, 1, NULL, '2026-03-10 20:09:54'),
(591, 27, 116, 1, NULL, '2026-03-10 20:09:54'),
(592, 27, 55, 1, NULL, '2026-03-10 20:09:54'),
(593, 27, 10, 1, NULL, '2026-03-10 20:09:54'),
(594, 27, 118, 1, NULL, '2026-03-10 20:09:54'),
(595, 27, 49, 1, NULL, '2026-03-10 20:09:54'),
(596, 27, 50, 1, NULL, '2026-03-10 20:09:54'),
(597, 27, 52, 1, NULL, '2026-03-10 20:09:54'),
(598, 27, 32, 1, NULL, '2026-03-10 20:09:54'),
(599, 27, 33, 1, NULL, '2026-03-10 20:09:54'),
(600, 27, 180, 1, NULL, '2026-03-10 20:09:54'),
(601, 27, 186, 1, NULL, '2026-03-10 20:09:54'),
(602, 27, 113, 1, NULL, '2026-03-10 20:09:54'),
(603, 27, 8, 1, NULL, '2026-03-10 20:09:54'),
(604, 27, 9, 1, NULL, '2026-03-10 20:09:54'),
(605, 27, 23, 1, NULL, '2026-03-10 20:09:54'),
(606, 27, 105, 1, NULL, '2026-03-10 20:09:54'),
(607, 27, 173, 1, NULL, '2026-03-10 20:09:54'),
(608, 27, 104, 1, NULL, '2026-03-10 20:09:54'),
(609, 27, 2, 1, NULL, '2026-03-10 20:09:54'),
(610, 27, 184, 1, NULL, '2026-03-10 20:09:54'),
(611, 27, 108, 1, NULL, '2026-03-10 20:09:54'),
(612, 27, 109, 1, NULL, '2026-03-10 20:09:54'),
(613, 27, 172, 1, NULL, '2026-03-10 20:09:54'),
(614, 27, 174, 1, NULL, '2026-03-10 20:09:54'),
(615, 27, 169, 1, NULL, '2026-03-10 20:09:54'),
(616, 27, 112, 1, NULL, '2026-03-10 20:09:54'),
(617, 27, 111, 1, NULL, '2026-03-10 20:09:54'),
(618, 27, 47, 1, NULL, '2026-03-10 20:09:54'),
(619, 27, 17, 1, NULL, '2026-03-10 20:09:54'),
(620, 27, 26, 1, NULL, '2026-03-10 20:09:54'),
(621, 27, 11, 1, NULL, '2026-03-10 20:09:54'),
(622, 27, 48, 1, NULL, '2026-03-10 20:09:54'),
(623, 27, 121, 1, NULL, '2026-03-10 20:09:54'),
(624, 27, 46, 1, NULL, '2026-03-10 20:09:54'),
(625, 27, 13, 1, NULL, '2026-03-10 20:09:54'),
(626, 27, 51, 1, NULL, '2026-03-10 20:09:54'),
(627, 27, 198, 1, NULL, '2026-03-10 20:09:54'),
(628, 27, 181, 1, NULL, '2026-03-10 20:09:54'),
(629, 27, 19, 1, NULL, '2026-03-10 20:09:54'),
(630, 27, 14, 1, NULL, '2026-03-10 20:09:54'),
(631, 27, 15, 1, NULL, '2026-03-10 20:09:54'),
(632, 27, 54, 1, NULL, '2026-03-10 20:09:54'),
(633, 27, 21, 1, NULL, '2026-03-10 20:09:54'),
(634, 27, 103, 1, NULL, '2026-03-10 20:09:54'),
(635, 27, 31, 1, NULL, '2026-03-10 20:09:54'),
(636, 27, 16, 1, NULL, '2026-03-10 20:09:54'),
(637, 27, 24, 1, NULL, '2026-03-10 20:09:54'),
(638, 27, 102, 1, NULL, '2026-03-10 20:09:54'),
(639, 27, 12, 1, NULL, '2026-03-10 20:09:54'),
(640, 27, 114, 1, NULL, '2026-03-10 20:09:54'),
(641, 27, 119, 1, NULL, '2026-03-10 20:09:54'),
(642, 27, 177, 1, NULL, '2026-03-10 20:09:54'),
(643, 27, 115, 1, NULL, '2026-03-10 20:09:54'),
(745, 40, 187, 1, NULL, '2026-03-11 08:57:43'),
(746, 40, 200, 1, NULL, '2026-03-11 08:57:43'),
(747, 40, 188, 1, NULL, '2026-03-11 08:57:43'),
(748, 40, 110, 1, NULL, '2026-03-11 08:57:43'),
(749, 40, 214, 1, NULL, '2026-03-11 08:57:43'),
(750, 40, 212, 1, NULL, '2026-03-11 08:57:43'),
(751, 40, 199, 1, NULL, '2026-03-11 08:57:43'),
(752, 40, 197, 1, NULL, '2026-03-11 08:57:43'),
(753, 40, 182, 1, NULL, '2026-03-11 08:57:43'),
(754, 40, 183, 1, NULL, '2026-03-11 08:57:43'),
(755, 40, 209, 1, NULL, '2026-03-11 08:57:43'),
(756, 40, 210, 1, NULL, '2026-03-11 08:57:43'),
(757, 40, 211, 1, NULL, '2026-03-11 08:57:43'),
(758, 40, 213, 1, NULL, '2026-03-11 08:57:43'),
(759, 40, 186, 1, NULL, '2026-03-11 08:57:43'),
(760, 40, 184, 1, NULL, '2026-03-11 08:57:43'),
(761, 40, 203, 1, NULL, '2026-03-11 08:57:43'),
(762, 40, 198, 1, NULL, '2026-03-11 08:57:43'),
(763, 40, 181, 1, NULL, '2026-03-11 08:57:43');

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE `vendors` (
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

INSERT INTO `vendors` (`vendor_id`, `vendor_name`, `contact_person`, `email`, `phone`, `address`, `status`, `performance_rating`, `total_awards`, `created_at`) VALUES
(1, 'Printers & Office Supplies Limited', '876-868-0934', 'psltd@printersofficesupplies.com', '876-123-8790', 'Kingston\r\nJamaica', 'ACTIVE', NULL, 3, '2026-02-14 15:52:41'),
(2, 'Accu Power Limited', '876-235-4053', 'accu@accupower.com', '876-235-4053', 'Kingston \r\nJamaica', 'ACTIVE', NULL, 3, '2026-02-14 16:09:11'),
(3, 'Intcomex Limited', '876-998-2232', 'infosupport@intcomex.com', '987-223-9922', 'Kingston \r\nJamaica', 'ACTIVE', NULL, 1, '2026-02-14 16:11:32');

-- --------------------------------------------------------

--
-- Table structure for table `vw_branch_outstanding`
--

CREATE TABLE `vw_branch_outstanding` (
  `branch_name` varchar(100) DEFAULT NULL,
  `total_invoiced` decimal(34,2) DEFAULT NULL,
  `total_paid` decimal(34,2) DEFAULT NULL,
  `outstanding` decimal(35,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vw_outstanding_balance`
--

CREATE TABLE `vw_outstanding_balance` (
  `balance` decimal(35,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workflow_notifications`
--

CREATE TABLE `workflow_notifications` (
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
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_acting_role` (`user_id`,`acting_role_id`),
  ADD KEY `acting_role_id` (`acting_role_id`),
  ADD KEY `assigned_by` (`assigned_by`);

--
-- Indexes for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `approval_rules`
--
ALTER TABLE `approval_rules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD PRIMARY KEY (`step_id`),
  ADD KEY `workflow_id` (`workflow_id`);

--
-- Indexes for table `approval_transactions`
--
ALTER TABLE `approval_transactions`
  ADD PRIMARY KEY (`transaction_id`);

--
-- Indexes for table `approval_workflows`
--
ALTER TABLE `approval_workflows`
  ADD PRIMARY KEY (`workflow_id`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`audit_id`),
  ADD KEY `changed_by` (`changed_by`),
  ADD KEY `idx_audit_log_table_record_date` (`table_name`,`record_id`,`change_date`);

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`branch_id`),
  ADD UNIQUE KEY `uq_branch_name` (`branch_name`);

--
-- Indexes for table `commitments`
--
ALTER TABLE `commitments`
  ADD PRIMARY KEY (`commitment_id`),
  ADD UNIQUE KEY `commitment_number` (`commitment_number`),
  ADD UNIQUE KEY `gfms_commitment_number` (`gfms_commitment_number`),
  ADD KEY `fk_parent_commitment` (`parent_commitment_id`),
  ADD KEY `idx_commitments_request_id` (`request_id`),
  ADD KEY `commitments_ibfk_rfq` (`rfq_id`),
  ADD KEY `commitments_ibfk_quote` (`selected_quote_id`),
  ADD KEY `idx_gfms_commitment_number` (`gfms_commitment_number`),
  ADD KEY `idx_commitment_gfms_generated` (`gfms_generated`),
  ADD KEY `idx_commitments_document_path` (`document_path`);

--
-- Indexes for table `compliance_approvals`
--
ALTER TABLE `compliance_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entity_type` (`entity_type`),
  ADD KEY `idx_entity_id` (`entity_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `external_approvals`
--
ALTER TABLE `external_approvals`
  ADD PRIMARY KEY (`approval_id`),
  ADD KEY `request_id` (`request_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`invoice_id`),
  ADD UNIQUE KEY `uq_invoice_number` (`invoice_number`),
  ADD KEY `po_id` (`po_id`),
  ADD KEY `idx_invoice_source` (`invoice_source`);

--
-- Indexes for table `inv_accounting_classes`
--
ALTER TABLE `inv_accounting_classes`
  ADD PRIMARY KEY (`acct_class_id`),
  ADD UNIQUE KEY `uk_acct_code` (`acct_class_code`);

--
-- Indexes for table `inv_adjustments`
--
ALTER TABLE `inv_adjustments`
  ADD PRIMARY KEY (`adjustment_id`),
  ADD UNIQUE KEY `uk_adj_number` (`adjustment_number`),
  ADD KEY `fk_adj_by` (`requested_by`);

--
-- Indexes for table `inv_adjustment_items`
--
ALTER TABLE `inv_adjustment_items`
  ADD PRIMARY KEY (`adj_item_id`),
  ADD KEY `fk_ai_adj` (`adjustment_id`),
  ADD KEY `fk_ai_item` (`item_id`);

--
-- Indexes for table `inv_approval_log`
--
ALTER TABLE `inv_approval_log`
  ADD PRIMARY KEY (`approval_log_id`),
  ADD KEY `idx_aplog_ref` (`reference_type`,`reference_id`);

--
-- Indexes for table `inv_approval_matrix`
--
ALTER TABLE `inv_approval_matrix`
  ADD PRIMARY KEY (`matrix_id`);

--
-- Indexes for table `inv_categories`
--
ALTER TABLE `inv_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `uk_category_code` (`category_code`),
  ADD KEY `idx_parent` (`parent_category_id`);

--
-- Indexes for table `inv_criticality_classes`
--
ALTER TABLE `inv_criticality_classes`
  ADD PRIMARY KEY (`criticality_id`),
  ADD UNIQUE KEY `uk_crit_code` (`criticality_code`);

--
-- Indexes for table `inv_delegations`
--
ALTER TABLE `inv_delegations`
  ADD PRIMARY KEY (`delegation_id`),
  ADD KEY `idx_delegate` (`delegate_user_id`),
  ADD KEY `idx_expiry` (`effective_to`),
  ADD KEY `fk_del_delegator` (`delegator_user_id`),
  ADD KEY `fk_del_role` (`inv_role_id`);

--
-- Indexes for table `inv_disposals`
--
ALTER TABLE `inv_disposals`
  ADD PRIMARY KEY (`disposal_id`),
  ADD UNIQUE KEY `uk_disp_number` (`disposal_number`),
  ADD KEY `fk_disp_by` (`requested_by`);

--
-- Indexes for table `inv_disposal_items`
--
ALTER TABLE `inv_disposal_items`
  ADD PRIMARY KEY (`disp_item_id`),
  ADD KEY `fk_di_disp` (`disposal_id`),
  ADD KEY `fk_di_item` (`item_id`);

--
-- Indexes for table `inv_documents`
--
ALTER TABLE `inv_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD UNIQUE KEY `uk_doc_number` (`document_number`),
  ADD KEY `idx_doc_type` (`document_type`),
  ADD KEY `idx_doc_ref` (`reference_table`,`reference_id`);

--
-- Indexes for table `inv_document_attachments`
--
ALTER TABLE `inv_document_attachments`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `fk_att_doc` (`document_id`);

--
-- Indexes for table `inv_fiscal_periods`
--
ALTER TABLE `inv_fiscal_periods`
  ADD PRIMARY KEY (`period_id`),
  ADD UNIQUE KEY `uk_period_name` (`period_name`),
  ADD KEY `idx_period_dates` (`period_start`,`period_end`);

--
-- Indexes for table `inv_goods_received`
--
ALTER TABLE `inv_goods_received`
  ADD PRIMARY KEY (`grn_id`),
  ADD UNIQUE KEY `uk_grn_number` (`grn_number`),
  ADD KEY `idx_grn_po` (`po_reference`),
  ADD KEY `fk_grn_receiver` (`received_by`);

--
-- Indexes for table `inv_grn_items`
--
ALTER TABLE `inv_grn_items`
  ADD PRIMARY KEY (`grn_item_id`),
  ADD KEY `fk_grni_grn` (`grn_id`),
  ADD KEY `fk_grni_item` (`item_id`);

--
-- Indexes for table `inv_incidents`
--
ALTER TABLE `inv_incidents`
  ADD PRIMARY KEY (`incident_id`),
  ADD UNIQUE KEY `uk_incident_number` (`incident_number`),
  ADD KEY `fk_inc_user` (`reported_by`);

--
-- Indexes for table `inv_incident_items`
--
ALTER TABLE `inv_incident_items`
  ADD PRIMARY KEY (`incident_item_id`),
  ADD KEY `fk_inci_incident` (`incident_id`),
  ADD KEY `fk_inci_item` (`item_id`);

--
-- Indexes for table `inv_issues`
--
ALTER TABLE `inv_issues`
  ADD PRIMARY KEY (`issue_id`),
  ADD UNIQUE KEY `uk_issue_number` (`issue_number`),
  ADD KEY `fk_iss_req` (`requisition_id`),
  ADD KEY `fk_iss_by` (`issued_by`);

--
-- Indexes for table `inv_issue_items`
--
ALTER TABLE `inv_issue_items`
  ADD PRIMARY KEY (`issue_item_id`),
  ADD KEY `fk_ii_issue` (`issue_id`),
  ADD KEY `fk_ii_item` (`item_id`);

--
-- Indexes for table `inv_items`
--
ALTER TABLE `inv_items`
  ADD PRIMARY KEY (`item_id`),
  ADD UNIQUE KEY `uk_item_code` (`item_code`),
  ADD KEY `idx_category` (`category_id`),
  ADD KEY `idx_criticality` (`criticality_id`),
  ADD KEY `idx_status` (`item_status`),
  ADD KEY `fk_item_subcategory` (`subcategory_id`),
  ADD KEY `fk_item_uom` (`uom_id`),
  ADD KEY `fk_item_acct_class` (`acct_class_id`);

--
-- Indexes for table `inv_item_risk_classes`
--
ALTER TABLE `inv_item_risk_classes`
  ADD PRIMARY KEY (`item_id`,`risk_class_id`),
  ADD KEY `fk_irc_risk` (`risk_class_id`);

--
-- Indexes for table `inv_item_suppliers`
--
ALTER TABLE `inv_item_suppliers`
  ADD PRIMARY KEY (`item_id`,`vendor_id`),
  ADD KEY `fk_is_vendor` (`vendor_id`);

--
-- Indexes for table `inv_locations`
--
ALTER TABLE `inv_locations`
  ADD PRIMARY KEY (`location_id`),
  ADD UNIQUE KEY `uk_location_code` (`location_code`),
  ADD KEY `idx_custodian` (`custodian_user_id`);

--
-- Indexes for table `inv_period_snapshots`
--
ALTER TABLE `inv_period_snapshots`
  ADD PRIMARY KEY (`snapshot_id`),
  ADD KEY `idx_snap_period` (`period_id`),
  ADD KEY `idx_snap_item` (`item_id`);

--
-- Indexes for table `inv_quarantine_log`
--
ALTER TABLE `inv_quarantine_log`
  ADD PRIMARY KEY (`quarantine_id`),
  ADD KEY `idx_quar_item` (`item_id`),
  ADD KEY `fk_quar_user` (`quarantined_by`);

--
-- Indexes for table `inv_recalls`
--
ALTER TABLE `inv_recalls`
  ADD PRIMARY KEY (`recall_id`),
  ADD UNIQUE KEY `uk_recall_number` (`recall_number`),
  ADD KEY `idx_recall_item` (`item_id`),
  ADD KEY `idx_recall_batch` (`batch_lot_number`),
  ADD KEY `fk_recall_user` (`initiated_by`);

--
-- Indexes for table `inv_recall_items`
--
ALTER TABLE `inv_recall_items`
  ADD PRIMARY KEY (`recall_item_id`),
  ADD KEY `fk_rcli_recall` (`recall_id`);

--
-- Indexes for table `inv_requisitions`
--
ALTER TABLE `inv_requisitions`
  ADD PRIMARY KEY (`requisition_id`),
  ADD UNIQUE KEY `uk_req_number` (`requisition_number`),
  ADD KEY `idx_requester` (`requester_user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `inv_requisition_items`
--
ALTER TABLE `inv_requisition_items`
  ADD PRIMARY KEY (`req_item_id`),
  ADD KEY `idx_req_id` (`requisition_id`),
  ADD KEY `fk_ri_item` (`item_id`);

--
-- Indexes for table `inv_returns`
--
ALTER TABLE `inv_returns`
  ADD PRIMARY KEY (`return_id`),
  ADD UNIQUE KEY `uk_return_number` (`return_number`),
  ADD KEY `fk_ret_user` (`requested_by`);

--
-- Indexes for table `inv_return_items`
--
ALTER TABLE `inv_return_items`
  ADD PRIMARY KEY (`return_item_id`),
  ADD KEY `fk_reti_return` (`return_id`),
  ADD KEY `fk_reti_item` (`item_id`);

--
-- Indexes for table `inv_risk_classes`
--
ALTER TABLE `inv_risk_classes`
  ADD PRIMARY KEY (`risk_class_id`),
  ADD UNIQUE KEY `uk_risk_code` (`risk_code`);

--
-- Indexes for table `inv_roles`
--
ALTER TABLE `inv_roles`
  ADD PRIMARY KEY (`inv_role_id`),
  ADD UNIQUE KEY `uk_inv_role` (`role_code`);

--
-- Indexes for table `inv_stock`
--
ALTER TABLE `inv_stock`
  ADD PRIMARY KEY (`stock_id`),
  ADD KEY `idx_item_loc` (`item_id`,`location_id`),
  ADD KEY `idx_expiry` (`expiry_date`),
  ADD KEY `idx_status` (`stock_status`),
  ADD KEY `fk_stock_location` (`location_id`);

--
-- Indexes for table `inv_stock_counts`
--
ALTER TABLE `inv_stock_counts`
  ADD PRIMARY KEY (`count_id`),
  ADD UNIQUE KEY `uk_count_number` (`count_number`),
  ADD KEY `fk_sc_by` (`conducted_by`);

--
-- Indexes for table `inv_stock_count_items`
--
ALTER TABLE `inv_stock_count_items`
  ADD PRIMARY KEY (`count_item_id`),
  ADD KEY `fk_sci_count` (`count_id`),
  ADD KEY `fk_sci_item` (`item_id`);

--
-- Indexes for table `inv_transactions`
--
ALTER TABLE `inv_transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `idx_txn_item` (`item_id`),
  ADD KEY `idx_txn_type` (`transaction_type`),
  ADD KEY `idx_txn_ref` (`reference_type`,`reference_id`),
  ADD KEY `idx_txn_date` (`created_at`);

--
-- Indexes for table `inv_transfers`
--
ALTER TABLE `inv_transfers`
  ADD PRIMARY KEY (`transfer_id`),
  ADD UNIQUE KEY `uk_transfer_number` (`transfer_number`),
  ADD KEY `fk_xfer_src` (`source_location_id`),
  ADD KEY `fk_xfer_dst` (`destination_location_id`),
  ADD KEY `fk_xfer_by` (`requested_by`);

--
-- Indexes for table `inv_transfer_items`
--
ALTER TABLE `inv_transfer_items`
  ADD PRIMARY KEY (`transfer_item_id`),
  ADD KEY `fk_ti_xfer` (`transfer_id`),
  ADD KEY `fk_ti_item` (`item_id`);

--
-- Indexes for table `inv_units_of_measure`
--
ALTER TABLE `inv_units_of_measure`
  ADD PRIMARY KEY (`uom_id`),
  ADD UNIQUE KEY `uk_uom_code` (`uom_code`);

--
-- Indexes for table `inv_user_roles`
--
ALTER TABLE `inv_user_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user_inv_role_loc` (`user_id`,`inv_role_id`,`location_id`),
  ADD KEY `fk_iur_role` (`inv_role_id`);

--
-- Indexes for table `inv_write_downs`
--
ALTER TABLE `inv_write_downs`
  ADD PRIMARY KEY (`write_down_id`),
  ADD UNIQUE KEY `uk_wd_number` (`write_down_number`),
  ADD KEY `fk_wd_item` (`item_id`),
  ADD KEY `fk_wd_user` (`requested_by`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD UNIQUE KEY `uq_payment_reference` (`payment_reference`),
  ADD KEY `invoice_id` (`invoice_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  ADD PRIMARY KEY (`disburse_id`),
  ADD UNIQUE KEY `uq_request_disburse` (`request_id`),
  ADD KEY `idx_disbursed_by` (`disbursed_by`),
  ADD KEY `idx_disbursement_date` (`disbursement_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_petty_cash_deadline` (`disbursement_deadline`,`status`);

--
-- Indexes for table `petty_cash_reconciliations`
--
ALTER TABLE `petty_cash_reconciliations`
  ADD PRIMARY KEY (`reconcile_id`),
  ADD UNIQUE KEY `uq_disburse_reconcile` (`disburse_id`),
  ADD KEY `idx_invoice_id` (`invoice_id`),
  ADD KEY `idx_submitted_by` (`submitted_by`),
  ADD KEY `idx_submission_date` (`submission_date`),
  ADD KEY `idx_verified_by` (`verified_by`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_reconcile_deadline` (`submission_date`,`status`);

--
-- Indexes for table `po_adjustment_log`
--
ALTER TABLE `po_adjustment_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `po_items`
--
ALTER TABLE `po_items`
  ADD PRIMARY KEY (`po_item_id`),
  ADD KEY `po_id` (`po_id`);

--
-- Indexes for table `po_variations`
--
ALTER TABLE `po_variations`
  ADD PRIMARY KEY (`variation_id`),
  ADD KEY `po_id` (`po_id`),
  ADD KEY `requested_by` (`requested_by`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indexes for table `po_warnings`
--
ALTER TABLE `po_warnings`
  ADD PRIMARY KEY (`warning_id`),
  ADD KEY `idx_po_warning` (`po_id`),
  ADD KEY `idx_warning_type` (`warning_type`);

--
-- Indexes for table `pre_authorizations`
--
ALTER TABLE `pre_authorizations`
  ADD PRIMARY KEY (`auth_id`),
  ADD UNIQUE KEY `uq_request_id` (`request_id`),
  ADD KEY `idx_authorized_by` (`authorized_by`),
  ADD KEY `idx_authorization_date` (`authorization_date`);

--
-- Indexes for table `procurement_requests`
--
ALTER TABLE `procurement_requests`
  ADD PRIMARY KEY (`request_id`),
  ADD UNIQUE KEY `request_number` (`request_number`),
  ADD UNIQUE KEY `uq_request_number` (`request_number`),
  ADD KEY `branch_id` (`branch_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_reimb_request_type` (`request_type`,`status`,`created_at` DESC),
  ADD KEY `idx_pr_requires_rfq` (`requires_rfq`);

--
-- Indexes for table `procurement_request_items`
--
ALTER TABLE `procurement_request_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `request_id` (`request_id`);

--
-- Indexes for table `procurement_verifications`
--
ALTER TABLE `procurement_verifications`
  ADD PRIMARY KEY (`verification_id`),
  ADD KEY `idx_request_id` (`request_id`),
  ADD KEY `idx_verified_by` (`verified_by`),
  ADD KEY `idx_verification_date` (`verification_date`);

--
-- Indexes for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD PRIMARY KEY (`po_id`),
  ADD UNIQUE KEY `po_number` (`po_number`),
  ADD UNIQUE KEY `uq_po_per_commitment` (`commitment_id`),
  ADD UNIQUE KEY `uq_po_number` (`po_number`),
  ADD UNIQUE KEY `gfms_po_number` (`gfms_po_number`),
  ADD KEY `idx_gfms_po_number` (`gfms_po_number`),
  ADD KEY `idx_po_gfms_generated` (`gfms_generated`),
  ADD KEY `idx_po_document_path` (`document_path`);

--
-- Indexes for table `reimbursement_invoices`
--
ALTER TABLE `reimbursement_invoices`
  ADD PRIMARY KEY (`reimb_invoice_id`),
  ADD KEY `idx_request_id` (`request_id`),
  ADD KEY `idx_invoice_id` (`invoice_id`),
  ADD KEY `idx_invoice_stage` (`invoice_stage`),
  ADD KEY `idx_submitted_by` (`submitted_by`),
  ADD KEY `idx_verified_by` (`verified_by`);

--
-- Indexes for table `reimbursement_status_history`
--
ALTER TABLE `reimbursement_status_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `idx_request_id` (`request_id`),
  ADD KEY `idx_changed_by` (`changed_by`),
  ADD KEY `idx_change_date` (`change_date`);

--
-- Indexes for table `request_approvals`
--
ALTER TABLE `request_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_approval_lookup` (`entity_type`,`entity_id`,`status`);

--
-- Indexes for table `request_documents`
--
ALTER TABLE `request_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `idx_request_documents_request` (`request_id`),
  ADD KEY `idx_request_documents_type` (`document_type`);

--
-- Indexes for table `rfqs`
--
ALTER TABLE `rfqs`
  ADD PRIMARY KEY (`rfq_id`),
  ADD UNIQUE KEY `rfq_number` (`rfq_number`),
  ADD KEY `request_id` (`request_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_rfq_status` (`status`),
  ADD KEY `idx_rfq_quote_review_status` (`quote_review_status`);

--
-- Indexes for table `rfq_evaluation_committee`
--
ALTER TABLE `rfq_evaluation_committee`
  ADD PRIMARY KEY (`committee_id`),
  ADD KEY `rfq_id` (`rfq_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `rfq_evaluation_reports`
--
ALTER TABLE `rfq_evaluation_reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `rfq_id` (`rfq_id`);

--
-- Indexes for table `rfq_quotes`
--
ALTER TABLE `rfq_quotes`
  ADD PRIMARY KEY (`quote_id`),
  ADD KEY `rfq_vendor_id` (`rfq_vendor_id`),
  ADD KEY `idx_quote_selection` (`is_selected`),
  ADD KEY `idx_quote_review_status` (`review_status`);

--
-- Indexes for table `rfq_scores`
--
ALTER TABLE `rfq_scores`
  ADD PRIMARY KEY (`score_id`);

--
-- Indexes for table `rfq_vendors`
--
ALTER TABLE `rfq_vendors`
  ADD PRIMARY KEY (`rfq_vendor_id`),
  ADD KEY `rfq_id` (`rfq_id`),
  ADD KEY `fk_rfq_vendor_master` (`vendor_id`);

--
-- Indexes for table `rfq_votes`
--
ALTER TABLE `rfq_votes`
  ADD PRIMARY KEY (`vote_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `permission_id` (`permission_id`);

--
-- Indexes for table `system_alerts`
--
ALTER TABLE `system_alerts`
  ADD PRIMARY KEY (`alert_id`);

--
-- Indexes for table `system_config`
--
ALTER TABLE `system_config`
  ADD PRIMARY KEY (`config_id`),
  ADD UNIQUE KEY `uq_config_key` (`config_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_permission` (`user_id`,`permission_id`),
  ADD KEY `permission_id` (`permission_id`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`vendor_id`);

--
-- Indexes for table `workflow_notifications`
--
ALTER TABLE `workflow_notifications`
  ADD PRIMARY KEY (`notif_id`),
  ADD KEY `idx_request_id` (`request_id`),
  ADD KEY `idx_recipient_id` (`recipient_id`),
  ADD KEY `idx_is_sent` (`is_sent`),
  ADD KEY `idx_request_type` (`request_type`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `acting_roles`
--
ALTER TABLE `acting_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

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
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1977;

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `branch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `commitments`
--
ALTER TABLE `commitments`
  MODIFY `commitment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

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
-- AUTO_INCREMENT for table `inv_accounting_classes`
--
ALTER TABLE `inv_accounting_classes`
  MODIFY `acct_class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `inv_adjustments`
--
ALTER TABLE `inv_adjustments`
  MODIFY `adjustment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_adjustment_items`
--
ALTER TABLE `inv_adjustment_items`
  MODIFY `adj_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_approval_log`
--
ALTER TABLE `inv_approval_log`
  MODIFY `approval_log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_approval_matrix`
--
ALTER TABLE `inv_approval_matrix`
  MODIFY `matrix_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `inv_categories`
--
ALTER TABLE `inv_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `inv_criticality_classes`
--
ALTER TABLE `inv_criticality_classes`
  MODIFY `criticality_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `inv_delegations`
--
ALTER TABLE `inv_delegations`
  MODIFY `delegation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_disposals`
--
ALTER TABLE `inv_disposals`
  MODIFY `disposal_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_disposal_items`
--
ALTER TABLE `inv_disposal_items`
  MODIFY `disp_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_documents`
--
ALTER TABLE `inv_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inv_document_attachments`
--
ALTER TABLE `inv_document_attachments`
  MODIFY `attachment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_fiscal_periods`
--
ALTER TABLE `inv_fiscal_periods`
  MODIFY `period_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_goods_received`
--
ALTER TABLE `inv_goods_received`
  MODIFY `grn_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inv_grn_items`
--
ALTER TABLE `inv_grn_items`
  MODIFY `grn_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_incidents`
--
ALTER TABLE `inv_incidents`
  MODIFY `incident_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_incident_items`
--
ALTER TABLE `inv_incident_items`
  MODIFY `incident_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_issues`
--
ALTER TABLE `inv_issues`
  MODIFY `issue_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_issue_items`
--
ALTER TABLE `inv_issue_items`
  MODIFY `issue_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_items`
--
ALTER TABLE `inv_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `inv_locations`
--
ALTER TABLE `inv_locations`
  MODIFY `location_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inv_period_snapshots`
--
ALTER TABLE `inv_period_snapshots`
  MODIFY `snapshot_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_quarantine_log`
--
ALTER TABLE `inv_quarantine_log`
  MODIFY `quarantine_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_recalls`
--
ALTER TABLE `inv_recalls`
  MODIFY `recall_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_recall_items`
--
ALTER TABLE `inv_recall_items`
  MODIFY `recall_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_requisitions`
--
ALTER TABLE `inv_requisitions`
  MODIFY `requisition_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inv_requisition_items`
--
ALTER TABLE `inv_requisition_items`
  MODIFY `req_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inv_returns`
--
ALTER TABLE `inv_returns`
  MODIFY `return_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_return_items`
--
ALTER TABLE `inv_return_items`
  MODIFY `return_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_risk_classes`
--
ALTER TABLE `inv_risk_classes`
  MODIFY `risk_class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `inv_roles`
--
ALTER TABLE `inv_roles`
  MODIFY `inv_role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `inv_stock`
--
ALTER TABLE `inv_stock`
  MODIFY `stock_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_stock_counts`
--
ALTER TABLE `inv_stock_counts`
  MODIFY `count_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_stock_count_items`
--
ALTER TABLE `inv_stock_count_items`
  MODIFY `count_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_transactions`
--
ALTER TABLE `inv_transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_transfers`
--
ALTER TABLE `inv_transfers`
  MODIFY `transfer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_transfer_items`
--
ALTER TABLE `inv_transfer_items`
  MODIFY `transfer_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_units_of_measure`
--
ALTER TABLE `inv_units_of_measure`
  MODIFY `uom_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `inv_user_roles`
--
ALTER TABLE `inv_user_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inv_write_downs`
--
ALTER TABLE `inv_write_downs`
  MODIFY `write_down_id` int(11) NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=218;

--
-- AUTO_INCREMENT for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  MODIFY `disburse_id` int(11) NOT NULL AUTO_INCREMENT;

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
  MODIFY `auth_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `procurement_requests`
--
ALTER TABLE `procurement_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `procurement_request_items`
--
ALTER TABLE `procurement_request_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150;

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
  MODIFY `history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request_approvals`
--
ALTER TABLE `request_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- AUTO_INCREMENT for table `request_documents`
--
ALTER TABLE `request_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `rfqs`
--
ALTER TABLE `rfqs`
  MODIFY `rfq_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

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
  MODIFY `quote_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `rfq_scores`
--
ALTER TABLE `rfq_scores`
  MODIFY `score_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rfq_vendors`
--
ALTER TABLE `rfq_vendors`
  MODIFY `rfq_vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=764;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  ADD CONSTRAINT `acting_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `acting_roles_ibfk_2` FOREIGN KEY (`acting_role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `acting_roles_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `acting_role_log`
--
ALTER TABLE `acting_role_log`
  ADD CONSTRAINT `acting_role_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_adjustments`
--
ALTER TABLE `inv_adjustments`
  ADD CONSTRAINT `fk_adj_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_adjustment_items`
--
ALTER TABLE `inv_adjustment_items`
  ADD CONSTRAINT `fk_ai_adj` FOREIGN KEY (`adjustment_id`) REFERENCES `inv_adjustments` (`adjustment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ai_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_delegations`
--
ALTER TABLE `inv_delegations`
  ADD CONSTRAINT `fk_del_delegate` FOREIGN KEY (`delegate_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_del_delegator` FOREIGN KEY (`delegator_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_del_role` FOREIGN KEY (`inv_role_id`) REFERENCES `inv_roles` (`inv_role_id`);

--
-- Constraints for table `inv_disposals`
--
ALTER TABLE `inv_disposals`
  ADD CONSTRAINT `fk_disp_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_disposal_items`
--
ALTER TABLE `inv_disposal_items`
  ADD CONSTRAINT `fk_di_disp` FOREIGN KEY (`disposal_id`) REFERENCES `inv_disposals` (`disposal_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_di_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_document_attachments`
--
ALTER TABLE `inv_document_attachments`
  ADD CONSTRAINT `fk_att_doc` FOREIGN KEY (`document_id`) REFERENCES `inv_documents` (`document_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_goods_received`
--
ALTER TABLE `inv_goods_received`
  ADD CONSTRAINT `fk_grn_receiver` FOREIGN KEY (`received_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_grn_items`
--
ALTER TABLE `inv_grn_items`
  ADD CONSTRAINT `fk_grni_grn` FOREIGN KEY (`grn_id`) REFERENCES `inv_goods_received` (`grn_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_grni_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_incidents`
--
ALTER TABLE `inv_incidents`
  ADD CONSTRAINT `fk_inc_user` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_incident_items`
--
ALTER TABLE `inv_incident_items`
  ADD CONSTRAINT `fk_inci_incident` FOREIGN KEY (`incident_id`) REFERENCES `inv_incidents` (`incident_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inci_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_issues`
--
ALTER TABLE `inv_issues`
  ADD CONSTRAINT `fk_iss_by` FOREIGN KEY (`issued_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_iss_req` FOREIGN KEY (`requisition_id`) REFERENCES `inv_requisitions` (`requisition_id`);

--
-- Constraints for table `inv_issue_items`
--
ALTER TABLE `inv_issue_items`
  ADD CONSTRAINT `fk_ii_issue` FOREIGN KEY (`issue_id`) REFERENCES `inv_issues` (`issue_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ii_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_items`
--
ALTER TABLE `inv_items`
  ADD CONSTRAINT `fk_item_acct_class` FOREIGN KEY (`acct_class_id`) REFERENCES `inv_accounting_classes` (`acct_class_id`),
  ADD CONSTRAINT `fk_item_category` FOREIGN KEY (`category_id`) REFERENCES `inv_categories` (`category_id`),
  ADD CONSTRAINT `fk_item_criticality` FOREIGN KEY (`criticality_id`) REFERENCES `inv_criticality_classes` (`criticality_id`),
  ADD CONSTRAINT `fk_item_subcategory` FOREIGN KEY (`subcategory_id`) REFERENCES `inv_categories` (`category_id`),
  ADD CONSTRAINT `fk_item_uom` FOREIGN KEY (`uom_id`) REFERENCES `inv_units_of_measure` (`uom_id`);

--
-- Constraints for table `inv_item_risk_classes`
--
ALTER TABLE `inv_item_risk_classes`
  ADD CONSTRAINT `fk_irc_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_irc_risk` FOREIGN KEY (`risk_class_id`) REFERENCES `inv_risk_classes` (`risk_class_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_item_suppliers`
--
ALTER TABLE `inv_item_suppliers`
  ADD CONSTRAINT `fk_is_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_is_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`vendor_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_period_snapshots`
--
ALTER TABLE `inv_period_snapshots`
  ADD CONSTRAINT `fk_snap_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_snap_period` FOREIGN KEY (`period_id`) REFERENCES `inv_fiscal_periods` (`period_id`);

--
-- Constraints for table `inv_quarantine_log`
--
ALTER TABLE `inv_quarantine_log`
  ADD CONSTRAINT `fk_quar_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_quar_user` FOREIGN KEY (`quarantined_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_recalls`
--
ALTER TABLE `inv_recalls`
  ADD CONSTRAINT `fk_recall_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_recall_user` FOREIGN KEY (`initiated_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_recall_items`
--
ALTER TABLE `inv_recall_items`
  ADD CONSTRAINT `fk_rcli_recall` FOREIGN KEY (`recall_id`) REFERENCES `inv_recalls` (`recall_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_requisitions`
--
ALTER TABLE `inv_requisitions`
  ADD CONSTRAINT `fk_req_user` FOREIGN KEY (`requester_user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_requisition_items`
--
ALTER TABLE `inv_requisition_items`
  ADD CONSTRAINT `fk_ri_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_ri_req` FOREIGN KEY (`requisition_id`) REFERENCES `inv_requisitions` (`requisition_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_returns`
--
ALTER TABLE `inv_returns`
  ADD CONSTRAINT `fk_ret_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_return_items`
--
ALTER TABLE `inv_return_items`
  ADD CONSTRAINT `fk_reti_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_reti_return` FOREIGN KEY (`return_id`) REFERENCES `inv_returns` (`return_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_stock`
--
ALTER TABLE `inv_stock`
  ADD CONSTRAINT `fk_stock_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_stock_location` FOREIGN KEY (`location_id`) REFERENCES `inv_locations` (`location_id`);

--
-- Constraints for table `inv_stock_counts`
--
ALTER TABLE `inv_stock_counts`
  ADD CONSTRAINT `fk_sc_by` FOREIGN KEY (`conducted_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `inv_stock_count_items`
--
ALTER TABLE `inv_stock_count_items`
  ADD CONSTRAINT `fk_sci_count` FOREIGN KEY (`count_id`) REFERENCES `inv_stock_counts` (`count_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sci_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_transactions`
--
ALTER TABLE `inv_transactions`
  ADD CONSTRAINT `fk_txn_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`);

--
-- Constraints for table `inv_transfers`
--
ALTER TABLE `inv_transfers`
  ADD CONSTRAINT `fk_xfer_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_xfer_dst` FOREIGN KEY (`destination_location_id`) REFERENCES `inv_locations` (`location_id`),
  ADD CONSTRAINT `fk_xfer_src` FOREIGN KEY (`source_location_id`) REFERENCES `inv_locations` (`location_id`);

--
-- Constraints for table `inv_transfer_items`
--
ALTER TABLE `inv_transfer_items`
  ADD CONSTRAINT `fk_ti_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_ti_xfer` FOREIGN KEY (`transfer_id`) REFERENCES `inv_transfers` (`transfer_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_user_roles`
--
ALTER TABLE `inv_user_roles`
  ADD CONSTRAINT `fk_iur_role` FOREIGN KEY (`inv_role_id`) REFERENCES `inv_roles` (`inv_role_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_iur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `inv_write_downs`
--
ALTER TABLE `inv_write_downs`
  ADD CONSTRAINT `fk_wd_item` FOREIGN KEY (`item_id`) REFERENCES `inv_items` (`item_id`),
  ADD CONSTRAINT `fk_wd_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `petty_cash_disbursements`
--
ALTER TABLE `petty_cash_disbursements`
  ADD CONSTRAINT `fk_disburse_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_disburse_user` FOREIGN KEY (`disbursed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `petty_cash_reconciliations`
--
ALTER TABLE `petty_cash_reconciliations`
  ADD CONSTRAINT `fk_reconcile_disburse` FOREIGN KEY (`disburse_id`) REFERENCES `petty_cash_disbursements` (`disburse_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reconcile_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_reconcile_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_reconcile_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `pre_authorizations`
--
ALTER TABLE `pre_authorizations`
  ADD CONSTRAINT `fk_pre_auth_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pre_auth_user` FOREIGN KEY (`authorized_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `procurement_verifications`
--
ALTER TABLE `procurement_verifications`
  ADD CONSTRAINT `fk_verify_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_verify_user` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reimbursement_invoices`
--
ALTER TABLE `reimbursement_invoices`
  ADD CONSTRAINT `fk_reimb_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_reimb_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reimb_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_reimb_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reimbursement_status_history`
--
ALTER TABLE `reimbursement_status_history`
  ADD CONSTRAINT `fk_reimb_status_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reimb_status_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `request_documents`
--
ALTER TABLE `request_documents`
  ADD CONSTRAINT `fk_request_documents_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE;

--
-- Constraints for table `workflow_notifications`
--
ALTER TABLE `workflow_notifications`
  ADD CONSTRAINT `fk_notif_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_notif_request` FOREIGN KEY (`request_id`) REFERENCES `procurement_requests` (`request_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
