<?php
$REQUIRE_PERMISSION = 'manage_vendors';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';

/* ===============================
   Handle Form Submission
================================ */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $vendor_name    = trim($_POST['vendor_name'] ?? '');
    $contact_person = trim($_POST['contact_person'] ?? '');
    $email          = trim($_POST['email'] ?? '');
    $phone          = trim($_POST['phone'] ?? '');
    $address        = trim($_POST['address'] ?? '');

    if ($vendor_name === '') {
        $error = "Vendor name is required.";
    } else {

        /* Prevent duplicate vendor */
        $stmt = $pdo->prepare("
            SELECT vendor_id FROM vendors
            WHERE vendor_name = ?
        ");
        $stmt->execute([$vendor_name]);

        if ($stmt->fetch()) {
            $error = "A vendor with this name already exists.";
        } else {

            /* Insert */
            try {
            $stmt = $pdo->prepare("
                INSERT INTO vendors
                (vendor_name, contact_person, email, phone, address, status)
                VALUES (?, ?, ?, ?, ?, 'ACTIVE')
            ");

            $stmt->execute([
                $vendor_name,
                $contact_person,
                $email,
                $phone,
                $address
            ]);

            $vendor_id = $pdo->lastInsertId();

            /* Audit */
            $pdo->prepare("
                INSERT INTO audit_log
                (table_name, record_id, action, changed_by, change_date, notes)
                VALUES ('vendors', ?, 'CREATE', ?, NOW(), ?)
            ")->execute([
                $vendor_id,
                $_SESSION['user_id'],
                "Vendor '$vendor_name' created"
            ]);

            header("Location: view.php?id=$vendor_id");
            exit;
            } catch (Throwable $e) {
                require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
                $error = extractDbMessage($e);
            }
        }
    }
}

require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="section-title">➕ Add New Vendor</h3>
    <a href="/vendors/list.php" class="btn btn-secondary btn-sm">
        ← Back to List
    </a>
</div>

<?php if (isset($error)): ?>
<div class="alert alert-danger alert-dismissible fade show" role="alert">
    <strong>⚠️ Error:</strong> <?= htmlspecialchars($error) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<?php endif; ?>

<div class="row">
    <div class="col-lg-8">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-dark text-white">
                <h5 class="mb-0">📋 Vendor Information</h5>
            </div>
            <div class="card-body">

                <form method="POST">

                    <div class="mb-3">
                        <label class="form-label fw-bold">Vendor Name *</label>
                        <input type="text" name="vendor_name"
                               value="<?= htmlspecialchars($_POST['vendor_name'] ?? '') ?>"
                               class="form-control" required autofocus>
                        <small class="text-muted">Legal business name of the vendor</small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Contact Person</label>
                        <input type="text" name="contact_person"
                               value="<?= htmlspecialchars($_POST['contact_person'] ?? '') ?>"
                               class="form-control">
                        <small class="text-muted">Primary contact name for communications</small>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" name="email"
                                   value="<?= htmlspecialchars($_POST['email'] ?? '') ?>"
                                   class="form-control">
                            <small class="text-muted">Official email address</small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Phone</label>
                            <input type="text" name="phone"
                                   value="<?= htmlspecialchars($_POST['phone'] ?? '') ?>"
                                   class="form-control">
                            <small class="text-muted">Contact phone number</small>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold">Address</label>
                        <textarea name="address" rows="3" class="form-control"><?= htmlspecialchars($_POST['address'] ?? '') ?></textarea>
                        <small class="text-muted">Physical business address for correspondence</small>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-success">
                            ✨ Create Vendor
                        </button>
                        <a href="/vendors/list.php" class="btn btn-secondary">
                            Cancel
                        </a>
                    </div>

                </form>

            </div>
        </div>
    </div>

    <!-- Sidebar Guidelines -->
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm bg-light mb-3">
            <div class="card-header bg-info text-white">
                <h5 class="mb-0">📌 Required Fields</h5>
            </div>
            <div class="card-body small">
                <ul class="mb-0 ps-3">
                    <li><strong>Vendor Name</strong> — Must be unique in the system</li>
                </ul>
            </div>
        </div>

        <div class="card border-0 shadow-sm bg-light mb-3">
            <div class="card-header bg-success text-white">
                <h5 class="mb-0">💡 Best Practices</h5>
            </div>
            <div class="card-body small">
                <ul class="mb-0">
                    <li>✅ Use official business name</li>
                    <li>✅ Provide complete contact details</li>
                    <li>✅ Include physical address</li>
                    <li>✅ Use verified email/phone</li>
                </ul>
            </div>
        </div>

        <div class="alert alert-info small">
            <strong>✨ New vendors start with ACTIVE status by default.</strong> You can deactivate them later in the vendor view if needed.
        </div>
    </div>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
