<?php
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/includes/header.php';

$user_id = (int)($_GET['id'] ?? 0);

if ($user_id <= 0) {
    pop("Invalid user.", "/users/list.php");
    exit;
}

/* Fetch user */
$stmt = $pdo->prepare("
    SELECT u.full_name, r.name AS role_name, u.role_id
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.user_id = ?
");
$stmt->execute([$user_id]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    pop("User not found.", "/users/list.php");
    exit;
}

/* Fetch permissions */
$permissions = $pdo->query("
    SELECT id, name
    FROM permissions
    ORDER BY name
")->fetchAll(PDO::FETCH_ASSOC);

/* Fetch role permissions */
$stmt = $pdo->prepare("
    SELECT permission_id
    FROM role_permissions
    WHERE role_id = ?
");
$stmt->execute([$user['role_id']]);
$rolePerms = array_column($stmt->fetchAll(PDO::FETCH_ASSOC), 'permission_id');

/* Fetch user overrides */
$stmt = $pdo->prepare("
    SELECT permission_id, is_granted, expires_at
    FROM user_permissions
    WHERE user_id = ?
");
$stmt->execute([$user_id]);
$userOverrides = [];
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    $userOverrides[$row['permission_id']] = $row;
}

/* ===============================
   CREATE NEW PERMISSION (Admin / SuperAdmin)
================================ */
$canCreatePermission = in_array($_SESSION['role_name'] ?? '', ['Admin', 'SuperAdmin'], true);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'create_permission') {
    if (!$canCreatePermission) {
        modalPop('Access Denied', 'You do not have permission to create permissions.', '/users/permissions.php?id='.$user_id, 'error');
        exit;
    }

    $newPermName = trim($_POST['perm_name'] ?? '');
    $newPermDesc = trim($_POST['perm_description'] ?? '');

    if ($newPermName === '') {
        modalPop('Validation Error', 'Permission name is required.', '/users/permissions.php?id='.$user_id, 'error');
        exit;
    }

    // Sanitise: lowercase, underscores only
    $newPermName = preg_replace('/[^a-z0-9_]/', '_', strtolower($newPermName));

    // Check uniqueness
    $chk = $pdo->prepare("SELECT COUNT(*) FROM permissions WHERE name = ?");
    $chk->execute([$newPermName]);
    if ($chk->fetchColumn() > 0) {
        modalPop('Duplicate', 'A permission with that name already exists.', '/users/permissions.php?id='.$user_id, 'error');
        exit;
    }

    try {
    $stmt = $pdo->prepare("INSERT INTO permissions (name, description) VALUES (?, ?)");
    $stmt->execute([$newPermName, $newPermDesc ?: null]);
    $newPermId = $pdo->lastInsertId();

    logAudit($pdo, 'permissions', (int)$newPermId, 'CREATE', "Permission '{$newPermName}' created");

    pop("Permission '{$newPermName}' created successfully.",
        '/users/permissions.php?id='.$user_id,
        1200,
        'success'
    );
    } catch (Throwable $e) {
        pop(extractDbMessage($e), '/users/permissions.php?id='.$user_id, POP_DEFAULT_DELAY_MS, 'error');
    }
    exit;
}

/* ===============================
   FETCH ALL PERMISSION OVERRIDES STATUS
================================ */
$stmt = $pdo->prepare("
    SELECT COUNT(*) as total_overrides,
           SUM(CASE WHEN is_granted = 1 THEN 1 ELSE 0 END) as granted_count
    FROM user_permissions
    WHERE user_id = ?
");
$stmt->execute([$user_id]);
$overrideStats = $stmt->fetch(PDO::FETCH_ASSOC);

// Check if all permissions are granted via override
$allPermissionsGranted = false;
if ($overrideStats['total_overrides'] == count($permissions) && 
    $overrideStats['granted_count'] == count($permissions)) {
    $allPermissionsGranted = true;
}

/* ===============================
   HANDLE TOGGLE ALL PERMISSIONS
================================ */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'toggle_all_permissions') {
    $toggleAction = $_POST['toggle_action'] ?? '';
    
    if ($toggleAction === 'enable') {
        // Enable all permissions - grant all
        $pdo->beginTransaction();
        
        foreach ($permissions as $perm) {
            $pdo->prepare("
                INSERT INTO user_permissions
                    (user_id, permission_id, is_granted, expires_at)
                VALUES (?, ?, 1, NULL)
                ON DUPLICATE KEY UPDATE
                    is_granted = 1,
                    expires_at = NULL
            ")->execute([$user_id, $perm['id']]);
        }
        
        logAudit($pdo, 'users', $user_id, 'FORCE_ALL_PERMISSIONS', 
                 "All permissions force-enabled by {$_SESSION['full_name']}");
        
        $pdo->commit();
        
        pop("✅ All permissions have been force-enabled for this user.",
            "/users/permissions.php?id={$user_id}",
            1500,
            "success"
        );
        exit;
    } 
    elseif ($toggleAction === 'revert') {
        // Delete all overrides - revert to role permissions
        $pdo->prepare("DELETE FROM user_permissions WHERE user_id = ?")->execute([$user_id]);
        
        logAudit($pdo, 'users', $user_id, 'REVERT_ALL_PERMISSIONS', 
                 "All permissions reverted to role defaults by {$_SESSION['full_name']}");
        
        pop("↩️ All permissions have been reverted to role defaults.",
            "/users/permissions.php?id={$user_id}",
            1500,
            "success"
        );
        exit;
    }
}

/* ===============================
   SAVE PERMISSION OVERRIDES
================================ */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') !== 'create_permission') {

    // Lookup manage_users permission ID for self-protection
    $muStmt = $pdo->prepare("SELECT id FROM permissions WHERE name = 'manage_users'");
    $muStmt->execute();
    $manageUsersPermissionId = (int)$muStmt->fetchColumn();

    $pdo->beginTransaction();

    foreach ($_POST['permissions'] ?? [] as $perm_id => $data) {

        $perm_id = (int)$perm_id;
        $grant = $data['grant'] ?? '';
        $expires = $data['expires'] ?? null;

        // If no override selected → delete only this override
        if ($grant === '') {

            $pdo->prepare("
                DELETE FROM user_permissions
                WHERE user_id = ?
                  AND permission_id = ?
            ")->execute([$user_id, $perm_id]);

            continue;
        }

        $is_granted = (int)$grant;
        $expires_at = !empty($expires) ? $expires : null;

        // Prevent removing your own manage_users permission
        if ($user_id == $_SESSION['user_id']
            && $perm_id === $manageUsersPermissionId
            && $is_granted === 0
        ) {
            $pdo->rollBack();
            modalPop('Error', 'You cannot remove your own manage_users permission.', '/users/permissions.php?id='.$user_id, 'error');
            exit;
        }

        // UPSERT (insert or update)
        $pdo->prepare("
            INSERT INTO user_permissions
                (user_id, permission_id, is_granted, expires_at)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                is_granted = VALUES(is_granted),
                expires_at = VALUES(expires_at)
        ")->execute([
            $user_id,
            $perm_id,
            $is_granted,
            $expires_at
        ]);

        logAudit(
            $pdo,
            'user_permissions',
            $user_id,
            'PERMISSION_OVERRIDE',
            "Permission {$perm_id} updated (granted={$is_granted})"
        );
    }

    $pdo->commit();

    pop("Permissions updated successfully.",
        "/users/permissions.php?id=".$user_id,
        1200,
        "success"
    );
    exit;
}

?>

<style>
    .gradient-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 12px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .gradient-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
    }
    .gradient-card-cyan {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        box-shadow: 0 4px 15px rgba(79, 172, 254, 0.4);
    }
    .gradient-card-cyan:hover {
        box-shadow: 0 6px 20px rgba(79, 172, 254, 0.6);
    }
    .gradient-card-green {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        box-shadow: 0 4px 15px rgba(67, 233, 123, 0.4);
    }
    .gradient-card-green:hover {
        box-shadow: 0 6px 20px rgba(67, 233, 123, 0.6);
    }
    .btn-modern {
        padding: 0.6rem 1.2rem;
        border-radius: 6px;
        font-weight: 500;
        border: none;
        transition: all 0.3s ease;
        text-decoration: none !important;
        display: inline-block;
    }
    .btn-primary-gradient {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white !important;
    }
    .btn-primary-gradient:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        color: white;
    }
    .btn-success-gradient {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        color: white !important;
    }
    .btn-success-gradient:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(67, 233, 123, 0.4);
        color: white;
    }
    .btn-secondary-gradient {
        background: white;
        color: #667eea !important;
        border: 1px solid #e0e0e0;
    }
    .btn-secondary-gradient:hover {
        background: #f8f9fa;
        border-color: #667eea;
    }
</style>

<div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
        <div class="col-lg-12">
            <a href="/users/list.php" style="display: inline-block; margin-bottom: 1rem; color: #667eea; text-decoration: none; font-weight: 500;">
                <i class="bi bi-arrow-left"></i> Back to Users
            </a>
            <h2 style="font-weight: 700; color: #1a1a1a; margin-bottom: 0.5rem;">🔐 Permission Management</h2>
            <p style="color: #666; font-size: 0.95rem; margin-bottom: 1.5rem;">Configure role-based and user-specific permission overrides</p>
        </div>
    </div>

    <!-- User Info Cards Row -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="gradient-card gradient-card">
                <div style="opacity: 0.9; font-size: 0.85rem; font-weight: 500; margin-bottom: 0.5rem;">👤 User</div>
                <div style="font-size: 1.5rem; font-weight: 700;"><?= htmlspecialchars($user['full_name']) ?></div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="gradient-card gradient-card-cyan">
                <div style="opacity: 0.9; font-size: 0.85rem; font-weight: 500; margin-bottom: 0.5rem;">🎭 Current Role</div>
                <div style="font-size: 1.5rem; font-weight: 700;"><?= htmlspecialchars($user['role_name'] ?? 'No Role') ?></div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="gradient-card gradient-card-green">
                <div style="opacity: 0.9; font-size: 0.85rem; font-weight: 500; margin-bottom: 0.5rem;">📊 Active Permissions</div>
                <div style="font-size: 1.5rem; font-weight: 700;">
                    <?php
                    $activePerms = 0;
                    foreach ($permissions as $p) {
                        if (in_array($p['id'], $rolePerms) || 
                            (isset($userOverrides[$p['id']]) && $userOverrides[$p['id']]['is_granted'] == 1)) {
                            $activePerms++;
                        }
                    }
                    echo $activePerms . ' / ' . count($permissions);
                    ?>
                </div>
            </div>
        </div>
    </div>

    <!-- Force All Permissions Toggle Card -->
    <div style="background: linear-gradient(135deg, #ff9a9e 0%, #fad0c4 100%); border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 4px 15px rgba(255, 154, 158, 0.3);">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h5 style="margin: 0 0 0.5rem 0; font-weight: 700; color: white; font-size: 1.1rem;">
                    <i class="bi bi-lightning-fill"></i> Force All Permissions
                </h5>
                <p style="margin: 0; color: rgba(255,255,255,0.9); font-size: 0.9rem;">
                    <?php if ($allPermissionsGranted): ?>
                        <i class="bi bi-check-circle"></i> <strong>Status: All Permissions Enabled</strong> — This user has access to all system permissions.
                    <?php else: ?>
                        <i class="bi bi-x-circle"></i> <strong>Status: Normal</strong> — User permissions controlled by role and overrides.
                    <?php endif; ?>
                </p>
            </div>
            <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
                <?php if (!$allPermissionsGranted): ?>
                <form method="post" style="display: inline;">
                    <input type="hidden" name="action" value="toggle_all_permissions">
                    <input type="hidden" name="toggle_action" value="enable">
                    <button type="submit" class="btn-modern btn-primary-gradient" style="background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%); color: white; border: none; cursor: pointer;" 
                            onclick="return confirm('⚠️ Enable ALL permissions for <?= htmlspecialchars($user['full_name']) ?>? This user will have access to everything.');">
                        <i class="bi bi-unlock"></i> Enable All Permissions
                    </button>
                </form>
                <?php else: ?>
                <form method="post" style="display: inline;">
                    <input type="hidden" name="action" value="toggle_all_permissions">
                    <input type="hidden" name="toggle_action" value="revert">
                    <button type="submit" class="btn-modern" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; border: none; cursor: pointer; padding: 0.6rem 1.2rem; border-radius: 6px; font-weight: 500; transition: all 0.3s ease;" 
                            onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 12px rgba(79, 172, 254, 0.4)'"
                            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none'"
                            onclick="return confirm('↩️ Revert ALL permissions to role defaults for <?= htmlspecialchars($user['full_name']) ?>?');">
                        <i class="bi bi-arrow-counterclockwise"></i> Revert to Role Defaults
                    </button>
                </form>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Info Box -->
    <div style="background: #f0f7ff; border-left: 4px solid #667eea; border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem;">
        <div style="display: flex; gap: 1rem;">
            <div style="font-size: 1.5rem;">ℹ️</div>
            <div>
                <div style="font-weight: 600; color: #1a1a1a; margin-bottom: 0.5rem;">How permissions work:</div>
                <div style="color: #666; font-size: 0.9rem;">
                    <div style="margin-bottom: 0.4rem;"><strong>Role</strong> — Permissions granted by the user's role</div>
                    <div style="margin-bottom: 0.4rem;"><strong>Override</strong> — Allow or deny individual permissions (overrides role)</div>
                    <div style="margin-bottom: 0.4rem;"><strong>Expires</strong> — Optional date when override expires (leave blank for permanent)</div>
                    <div style="margin-top: 0.6rem; padding-top: 0.6rem; border-top: 1px solid rgba(0,0,0,0.1); color: #d84315;"><strong>⚡ Quick Toggle:</strong> Use "Enable All Permissions" button above to quickly grant access to all system features, or "Revert to Role Defaults" to restore normal permissions.</div>
                </div>
            </div>
        </div>
    </div>

    <?php if ($canCreatePermission): ?>
    <!-- Create New Permission Card -->
    <div style="background: white; border-radius: 10px; border: 1px solid #e0e0e0; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);">
        <div style="margin-bottom: 1.5rem; padding-bottom: 1rem; border-bottom: 2px solid #e0e0e0;">
            <h4 style="font-weight: 600; color: #1a1a1a; margin: 0;"><i class="bi bi-plus-circle"></i> Create New Permission</h4>
        </div>
        <form method="post" style="display: grid; grid-template-columns: 1fr 1.2fr 1fr; gap: 1rem; align-items: end;">
            <input type="hidden" name="action" value="create_permission">
            <div>
                <label style="font-weight: 600; color: #1a1a1a; display: block; margin-bottom: 0.5rem;">Permission Name</label>
                <input type="text" name="perm_name" 
                       style="width: 100%; padding: 0.65rem 0.75rem; border-radius: 6px; border: 1px solid #d0d0d0; font-size: 0.9rem; transition: all 0.3s ease;"
                       placeholder="e.g. export_reports" required
                       pattern="[a-zA-Z0-9_]+" title="Letters, numbers and underscores only"
                       onmouseover="this.style.borderColor='#667eea'"
                       onmouseout="this.style.borderColor='#d0d0d0'"
                       onfocus="this.style.borderColor='#667eea'; this.style.boxShadow='0 0 0 3px rgba(102, 126, 234, 0.1)'"
                       onblur="this.style.borderColor='#d0d0d0'; this.style.boxShadow='none'">
                <small style="color: #999; display: block; margin-top: 0.3rem;">Lowercase, underscores only (auto-sanitised)</small>
            </div>
            <div>
                <label style="font-weight: 600; color: #1a1a1a; display: block; margin-bottom: 0.5rem;">Description</label>
                <input type="text" name="perm_description" 
                       style="width: 100%; padding: 0.65rem 0.75rem; border-radius: 6px; border: 1px solid #d0d0d0; font-size: 0.9rem; transition: all 0.3s ease;"
                       placeholder="e.g. Allow exporting report files"
                       onmouseover="this.style.borderColor='#667eea'"
                       onmouseout="this.style.borderColor='#d0d0d0'"
                       onfocus="this.style.borderColor='#667eea'; this.style.boxShadow='0 0 0 3px rgba(102, 126, 234, 0.1)'"
                       onblur="this.style.borderColor='#d0d0d0'; this.style.boxShadow='none'">
            </div>
            <button type="submit" class="btn-modern btn-primary-gradient" style="width: 100%;">
                <i class="bi bi-plus-lg"></i> Create Permission
            </button>
        </form>
    </div>
    <?php endif; ?>

<form method="post">

<div style="background: white; border-radius: 10px; border: 1px solid #e0e0e0; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05); overflow: hidden;">
    <div style="background: #f8f9fa; padding: 1rem; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; font-weight: 600; color: #1a1a1a;"><i class="bi bi-list-check"></i> Permissions Table</h5>
        <span style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 0.35rem 0.75rem; border-radius: 5px; font-size: 0.85rem; font-weight: 500;"><?= count($permissions) ?> Total</span>
    </div>

    <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background-color: #f8f9fa; border-bottom: 2px solid #e0e0e0;">
                    <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none; width: 30%;">Permission</th>
                    <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none; width: 20%;">Role Default</th>
                    <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none; width: 30%;">User Override</th>
                    <th style="padding: 1rem; text-align: left; font-weight: 600; color: #333; border: none; width: 20%;">Expires At</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($permissions as $perm):  

    $perm_id = $perm['id'];
    $roleHas = in_array($perm_id, $rolePerms);
    $override = $userOverrides[$perm_id] ?? null;

    /* Determine effective permission state */
    $effective = $roleHas; // Start with role permission
    if ($override) {
        $effective = $override['is_granted'] == 1; // Override if present
    }
    $rowBg = $override ? '#fff8f0' : 'white';

?>

                <tr style="border-bottom: 1px solid #f0f0f0; background-color: <?= $rowBg ?>; transition: background-color 0.2s ease;">
                    <td style="padding: 1rem; border: none;">
                        <code style="background: #f8f9fa; padding: 0.3rem 0.5rem; border-radius: 4px; color: #667eea; font-weight: 500;"><?= htmlspecialchars($perm['name']) ?></code>
                        <?php if ($override): ?>
                            <br><span style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); color: white; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 500; display: inline-block; margin-top: 0.3rem;"><i class="bi bi-exclamation-triangle"></i> Override Active</span>
                        <?php endif; ?>
                    </td>

                    <td style="padding: 1rem; border: none;">
                        <?php if ($roleHas): ?>
                            <span style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; padding: 0.35rem 0.75rem; border-radius: 5px; font-size: 0.85rem; font-weight: 500; display: inline-block;"><i class="bi bi-check-lg"></i> Granted</span>
                        <?php else: ?>
                            <span style="background: #e8e8e8; color: #666; padding: 0.35rem 0.75rem; border-radius: 5px; font-size: 0.85rem; font-weight: 500; display: inline-block;"><i class="bi bi-x-lg"></i> None</span>
                        <?php endif; ?>
                    </td>

                    <td style="padding: 1rem; border: none;">
                        <select name="permissions[<?= $perm_id ?>][grant]" style="width: 100%; padding: 0.65rem 0.75rem; border-radius: 6px; border: 1px solid #d0d0d0; font-size: 0.9rem; background: white; cursor: pointer; transition: all 0.3s ease;" onmouseover="this.style.borderColor='#667eea'" onmouseout="this.style.borderColor='#d0d0d0'">
                            <option value="" <?= !$override ? 'selected' : '' ?>>
                                ○ No Override
                            </option>
                            <option value="1" <?= $override && $override['is_granted']==1 ? 'selected' : '' ?>>
                                ✓ Force Allow
                            </option>
                            <option value="0" <?= $override && $override['is_granted']==0 ? 'selected' : '' ?>>
                                ✗ Force Deny
                            </option>
                        </select>
                    </td>

                    <td style="padding: 1rem; border: none;">
                        <input type="datetime-local"
                               name="permissions[<?= $perm_id ?>][expires]"
                               value="<?= $override && $override['expires_at']
                                   ? date('Y-m-d\TH:i', strtotime($override['expires_at']))
                                   : '' ?>"
                               style="width: 100%; padding: 0.65rem 0.75rem; border-radius: 6px; border: 1px solid #d0d0d0; font-size: 0.9rem; transition: all 0.3s ease;"
                               onmouseover="this.style.borderColor='#667eea'"
                               onmouseout="this.style.borderColor='#d0d0d0'"
                               onfocus="this.style.borderColor='#667eea'; this.style.boxShadow='0 0 0 3px rgba(102, 126, 234, 0.1)'"
                               onblur="this.style.borderColor='#d0d0d0'; this.style.boxShadow='none'"
                               placeholder="Optional">
                    </td>
                </tr>

                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <div style="background: #f8f9fa; padding: 1.5rem; border-top: 1px solid #e0e0e0; display: flex; gap: 1rem; flex-wrap: wrap;">
        <button type="submit" class="btn-modern btn-success-gradient">
            <i class="bi bi-check-circle"></i> Save Changes
        </button>
        <a href="/users/list.php" class="btn-modern btn-secondary-gradient" style="color: #667eea;">
            <i class="bi bi-x-circle"></i> Cancel
        </a>
    </div>
</div>

</form>
</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'].'/includes/footer.php'; ?>
