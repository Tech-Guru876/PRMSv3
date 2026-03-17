<?php

/**
 * RFQService - Handles RFQ-related operations
 * Including email notifications to vendors
 */

require_once __DIR__ . '/../config/mailer.php';

class RFQService
{
    private $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Send RFQ notification email to vendor
     * 
     * @param int $rfq_id RFQ ID
     * @param int $vendor_id Vendor ID  
     * @param string $vendor_email Vendor email address
     * @return bool Success status
     */
    public function sendRFQToVendor(int $rfq_id, int $vendor_id, string $vendor_email): bool
    {
        try {
            // Fetch RFQ details
            $rfqStmt = $this->pdo->prepare("
                SELECT 
                    r.rfq_id,
                    r.rfq_number,
                    r.submission_deadline,
                    r.status,
                    pr.request_number,
                    pr.description,
                    pr.estimated_value,
                    pr.currency
                FROM rfqs r
                JOIN procurement_requests pr ON r.request_id = pr.request_id
                WHERE r.rfq_id = ?
            ");
            $rfqStmt->execute([$rfq_id]);
            $rfq = $rfqStmt->fetch(PDO::FETCH_ASSOC);

            if (!$rfq) {
                error_log("RFQService: RFQ ID $rfq_id not found");
                return false;
            }

            // Fetch vendor details
            $vendorStmt = $this->pdo->prepare("
                SELECT vendor_name, contact_person, email
                FROM vendors
                WHERE vendor_id = ?
            ");
            $vendorStmt->execute([$vendor_id]);
            $vendor = $vendorStmt->fetch(PDO::FETCH_ASSOC);

            if (!$vendor) {
                error_log("RFQService: Vendor ID $vendor_id not found");
                return false;
            }

            // Email validation
            if (empty($vendor_email) || !filter_var($vendor_email, FILTER_VALIDATE_EMAIL)) {
                error_log("RFQService: Invalid vendor email: $vendor_email");
                return false;
            }

            // Build email content
            $subject = "Request for Quote - {$rfq['rfq_number']} - {$rfq['request_number']}";
            $html = $this->buildRFQEmailTemplate(
                $vendor['vendor_name'],
                $vendor['contact_person'],
                $rfq,
                $rfq_id,
                $vendor_id
            );

            // Send email
            if (!sendMail($vendor_email, $subject, $html)) {
                error_log("RFQService: Failed to send RFQ email to {$vendor_email}");
                return false;
            }

            error_log("RFQService: RFQ email sent successfully to {$vendor_email} for RFQ {$rfq['rfq_number']}");
            return true;

        } catch (Throwable $e) {
            error_log("RFQService: Exception in sendRFQToVendor: {$e->getMessage()}");
            return false;
        }
    }

    /**
     * Send RFQ to all vendors for a specific RFQ
     * 
     * @param int $rfq_id RFQ ID
     * @return array Results with count of sent emails
     */
    public function sendRFQToAllVendors(int $rfq_id): array
    {
        $results = [
            'total' => 0,
            'sent' => 0,
            'failed' => 0,
            'errors' => []
        ];

        try {
            // Fetch all vendors for this RFQ
            $stmt = $this->pdo->prepare("
                SELECT 
                    v.vendor_id,
                    v.vendor_name,
                    v.email
                FROM rfq_vendors rv
                JOIN vendors v ON rv.vendor_id = v.vendor_id
                WHERE rv.rfq_id = ?
                AND rv.response_status != 'DECLINED'
            ");
            $stmt->execute([$rfq_id]);
            $vendors = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $results['total'] = count($vendors);

            foreach ($vendors as $vendor) {
                if ($this->sendRFQToVendor($rfq_id, $vendor['vendor_id'], $vendor['email'])) {
                    $results['sent']++;
                } else {
                    $results['failed']++;
                    $results['errors'][] = "Failed to send to {$vendor['vendor_name']} ({$vendor['email']})";
                }
            }

        } catch (Throwable $e) {
            $results['errors'][] = $e->getMessage();
            error_log("RFQService: Exception in sendRFQToAllVendors: {$e->getMessage()}");
        }

        return $results;
    }

    /**
     * Build HTML email template for RFQ notification
     * 
     * @param string $vendor_name
     * @param string $contact_person
     * @param array $rfq
     * @param int $rfq_id
     * @param int $vendor_id
     * @return string HTML email content
     */
    private function buildRFQEmailTemplate(
        string $vendor_name,
        ?string $contact_person,
        array $rfq,
        int $rfq_id,
        int $vendor_id
    ): string
    {
        $appUrl = APP_URL;
        $deadlineFormatted = date('F d, Y H:i', strtotime($rfq['submission_deadline']));
        $estimatedValue = number_format((float)$rfq['estimated_value'], 2);
        $currency = $rfq['currency'] ?? 'JMD';
        // Preserve line breaks for better readability
        $description = nl2br(htmlspecialchars($rfq['description'] ?? 'No details provided'));
        $requestNumber = htmlspecialchars($rfq['request_number']);
        $rfqNumber = htmlspecialchars($rfq['rfq_number']);
        $logo = "$appUrl/logo/cropped-Logo.png";

        $greeting = $contact_person ? "Dear " . htmlspecialchars($contact_person) . "," : "Dear " . htmlspecialchars($vendor_name) . ",";

        return <<<HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
        }
        .email-container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
            background: linear-gradient(135deg, #0b5e2b 0%, #0d7a38 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header img {
            height: 40px;
            margin-bottom: 10px;
            filter: brightness(0) invert(1);
        }
        .header h1 {
            margin: 10px 0 0 0;
            font-size: 24px;
        }
        .content {
            padding: 30px;
        }
        .greeting {
            font-size: 16px;
            margin-bottom: 20px;
        }
        .section {
            margin: 20px 0;
            padding: 15px;
            background-color: #f9f9f9;
            border-left: 4px solid #0b5e2b;
            border-radius: 4px;
        }
        .section-title {
            font-weight: bold;
            color: #0b5e2b;
            margin-bottom: 8px;
            font-size: 14px;
            text-transform: uppercase;
        }
        .section-content {
            font-size: 14px;
        }
        table {
            width: 100%;
            margin: 15px 0;
            border-collapse: collapse;
        }
        table tr {
            border-bottom: 1px solid #ddd;
        }
        table td {
            padding: 10px;
            font-size: 14px;
        }
        table td:first-child {
            font-weight: bold;
            width: 40%;
            color: #0b5e2b;
        }
        .important-date {
            background-color: #fff3cd;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            border-left: 4px solid #c9a227;
        }
        .important-date .label {
            font-weight: bold;
            color: #856404;
            font-size: 12px;
            text-transform: uppercase;
        }
        .important-date .deadline {
            font-size: 18px;
            color: #c9a227;
            margin-top: 5px;
        }
        .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #0b5e2b 0%, #0d7a38 100%);
            color: white;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 4px;
            margin: 20px 0;
            font-weight: bold;
        }
        .cta-button:hover {
            opacity: 0.9;
        }
        .footer {
            background-color: #f1f1f1;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #666;
        }
        .footer a {
            color: #0b5e2b;
            text-decoration: none;
        }
        hr {
            border: none;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header -->
        <div class="header">
            <img src="$logo" alt="DGC Logo">
            <h1>Digital Government Chemist</h1>
            <p style="margin: 5px 0; font-size: 14px;">Procurement Management System</p>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="greeting">
                $greeting
            </div>

            <p>
                We are pleased to invite <strong>$vendor_name</strong> to submit a quotation for the procurement request detailed below.
            </p>

            <!-- RFQ Details Section -->
            <div class="section">
                <div class="section-title">[RFQ DETAILS]</div>
                <div class="section-content">
                    <table>
                        <tr>
                            <td>RFQ Number:</td>
                            <td><strong>$rfqNumber</strong></td>
                        </tr>
                        <tr>
                            <td>Request Number:</td>
                            <td><strong>$requestNumber</strong></td>
                        </tr>
                        <tr>
                            <td>Estimated Value:</td>
                            <td><strong>$currency $estimatedValue</strong></td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Request Details Section -->
            <div class="section">
                <div class="section-title">[REQUEST DESCRIPTION]</div>
                <div class="section-content" style="min-height: 40px; white-space: pre-wrap; word-wrap: break-word;">
                    $description
                </div>
            </div>

            <!-- Important Deadline -->
            <div class="important-date">
                <div class="label">Submission Deadline</div>
                <div class="deadline">$deadlineFormatted</div>
                <p style="margin: 10px 0 0 0; font-size: 12px; color: #856404;">
                    Please ensure your quotation is submitted before this deadline.
                </p>
            </div>

            <!-- Action Section -->
            <div style="text-align: center; margin: 30px 0;">
                <p style="margin-bottom: 15px; color: #666;">
                    Please click the button below to access the quotation portal and submit your quote.
                </p>
                <a href="$appUrl" class="cta-button">Access Quotation Portal</a>
            </div>

            <hr>

            <!-- Requirements Section -->
            <div class="section">
                <div class="section-title">[WHAT YOU NEED TO DO]</div>
                <div class="section-content">
                    <ol style="margin: 10px 0; padding-left: 20px;">
                        <li>Review the request details and specifications</li>
                        <li>Prepare your quotation</li>
                        <li>Submit your quote via the portal before the deadline</li>
                        <li>Ensure all required documentation is included</li>
                    </ol>
                </div>
            </div>

            <!-- Contact Section -->
            <div class="section">
                <div class="section-title">[NEED ASSISTANCE?]</div>
                <div class="section-content">
                    If you have any questions about this RFQ, please contact the Procurement Department at:
                    <br><br>
                    <strong>Email:</strong> procurement@governmentchemist.com<br>
                    <strong>Phone:</strong> +1-876-754-6088
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>
                This is an automated message from the <strong>Digital Government Chemist Procurement Management System</strong>.<br>
                Please do not reply to this email. For assistance, contact the Procurement Department at :Gabrielle.Green@moh.gov.jm.
            </p>
            <p style="margin-top: 10px; color: #999;">
                © 2026 Digital Government Chemist. All rights reserved.
            </p>
        </div>
    </div>
</body>
</html>
HTML;
    }
}
