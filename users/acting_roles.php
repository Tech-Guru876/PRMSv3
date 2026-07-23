<?php
/**
 * Admin: Manage Acting Role Assignments
 * 
 * Allows Admin/SuperAdmin to:
 *  - View all active acting role assignments
 *  - Assign a user to act in another role (with optional date range)
 *  - Revoke an assignment
 */
$REQUIRE_PERMISSION = 'manage_users';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/db.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/helper.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/header.php';

/* ─── Handle POST actions ─── */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    // ── Assign acting role ──
    if ($action === 'assign') {
        $userId       = (int)($_POST['user_id'] ?? 0);
        $actingRoleId = (int)($_POST['acting_role_id'] ?? 0);
        $reason       = trim($_POST['reason'] ?? '');
        $startsAt     = $_POST['starts_at'] ?? date('Y-m-d H:i:s');
        $endsAt       = !empty($_POST['ends_at']) ? $_POST['ends_at'] : null;

        if (!$userId || !$actingRoleId) {
            pop('Please select a user and role.', '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'error');
            exit;
        }

        // Don't allow assigning user's own primary role
        $primaryStmt = $pdo->prepare("SELECT role_id FROM users WHERE user_id = ?");
        $primaryStmt->execute([$userId]);
        $primaryRoleId = (int)$primaryStmt->fetchColumn();

        if ($primaryRoleId === $actingRoleId) {
            pop('Cannot assign a user to act in their own primary role.', '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'error');
            exit;
        }

        // Upsert (update if duplicate)
        try {
        $stmt = $pdo->prepare("
            INSERT INTO acting_roles (user_id, acting_role_id, assigned_by, reason, starts_at, ends_at, is_active)
            VALUES (?, ?, ?, ?, ?, ?, 1)
            ON DUPLICATE KEY UPDATE
                assigned_by = VALUES(assigned_by),
                reason = VALUES(reason),
                starts_at = VALUES(starts_at),
                ends_at = VALUES(ends_at),
                is_active = 1
        ");
        $stmt->execute([
            $userId,
            $actingRoleId,
            $_SESSION['user_id'],
            $reason ?: null,
            $startsAt,
            $endsAt
        ]);

        pop('Acting role assigned successfully.', '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'success');
        } catch (Throwable $e) {
            pop(extractDbMessage($e), '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'error');
        }
        exit;
    }

    // ── Revoke acting role ──
    if ($action === 'revoke') {
        $assignmentId = (int)($_POST['assignment_id'] ?? 0);
        if ($assignmentId) {
            try {
                $pdo->prepare("UPDATE acting_roles SET is_active = 0 WHERE id = ?")->execute([$assignmentId]);
                pop('Acting role revoked.', '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'success');
            } catch (Throwable $e) {
                pop(extractDbMessage($e), '/users/acting_roles.php', POP_DEFAULT_DELAY_MS, 'error');
            }
        }
        exit;
    }
}

/* ─── Fetch data ─── */
// Active assignments
$assignments = $pdo->query("
    SELECT ar.id, ar.reason, ar.starts_at, ar.ends_at,
           u.full_name AS user_name, u.user_id,
           r.name AS acting_role_name,
           admin.full_name AS assigned_by_name
    FROM acting_roles ar
    JOIN users u ON ar.user_id = u.user_id
    JOIN roles r ON ar.acting_role_id = r.id
    JOIN users admin ON ar.assigned_by = admin.user_id
    WHERE ar.is_active = 1
    ORDER BY ar.created_at DESC
")->fetchAll(PDO::FETCH_ASSOC);

// All active users
$users = $pdo->query("
    SELECT u.user_id, u.full_name, r.name AS role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.is_active = 1
    ORDER BY u.full_name ASC
")->fetchAll(PDO::FETCH_ASSOC);

// All roles
$roles = $pdo->query("SELECT id, name FROM roles ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);

// Recent switch log
$logs = $pdo->query("
    SELECT arl.created_at, arl.is_acting, arl.ip_address,
           u.full_name AS user_name,
           rf.name AS from_role,
           rt.name AS to_role
    FROM acting_role_log arl
    JOIN users u ON arl.user_id = u.user_id
    JOIN roles rf ON arl.switched_from_role_id = rf.id
    JOIN roles rt ON arl.switched_to_role_id = rt.id
    ORDER BY arl.created_at DESC
    LIMIT 50
")->fetchAll(PDO::FETCH_ASSOC);
?>

<div style="max-width: 1400px; margin: 2rem auto; padding: 0 1rem;">

    <!-- Header -->
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;">
        <div style="display: flex; align-items: center; gap: 1rem;">
            <a href="/users/list.php" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i></a>
            <h2 style="margin: 0; font-weight: 700;">⚡ Acting Role Assignments</h2>
        </div>
    </div>

    <!-- Assign New Acting Role -->
    <div style="background: white; border-radius: 12px; border: 1px solid #e0e0e0; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 1.5rem;">
        <h5 style="font-weight: 700; margin-bottom: 1rem;">➕ Assign Acting Role</h5>
        <form method="POST" action="/users/acting_roles.php">
            <input type="hidden" name="action" value="assign">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                <div>
                    <label class="form-label fw-bold" style="font-size: 0.85rem;">User</label>
                    <select name="user_id" class="form-select" required>
                        <option value="">Select user...</option>
                        <?php foreach ($users as $u): ?>
                            <option value="<?= $u['user_id'] ?>"><?= htmlspecialchars($u['full_name']) ?> (<?= htmlspecialchars($u['role_name']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="form-label fw-bold" style="font-size: 0.85rem;">Act As Role</label>
                    <select name="acting_role_id" class="form-select" required>
                        <option value="">Select role...</option>
                        <?php foreach ($roles as $r): ?>
                            <option value="<?= $r['id'] ?>"><?= htmlspecialchars($r['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="form-label fw-bold" style="font-size: 0.85rem;">Reason</label>
                    <input type="text" name="reason" class="form-control" placeholder="e.g. Leave cover for J. Smith">
                </div>
                <div>
                    <label class="form-label fw-bold" style="font-size: 0.85rem;">Starts</label>
                    <input type="datetime-local" name="starts_at" class="form-control" value="<?= date('Y-m-d\TH:i') ?>">
                </div>
                <div>
                    <label class="form-label fw-bold" style="font-size: 0.85rem;">Ends <small class="text-muted">(blank = indefinite)</small></label>
                    <input type="datetime-local" name="ends_at" class="form-control">
                </div>
                <div style="display: flex; align-items: flex-end;">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-person-plus"></i> Assign
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Active Assignments -->
    <div style="background: white; border-radius: 12px; border: 1px solid #e0e0e0; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 1.5rem;">
        <h5 style="font-weight: 700; margin-bottom: 1rem;">📋 Active Assignments <span class="badge bg-primary"><?= count($assignments) ?></span></h5>

        <?php if (empty($assignments)): ?>
            <div style="text-align: center; color: #999; padding: 2rem 0;">
                No active acting role assignments.
            </div>
        <?php else: ?>
            <div style="overflow-x: auto;">
                <table class="table table-hover mb-0" style="font-size: 0.875rem;">
                    <thead class="table-dark">
                        <tr>
                            <th>User</th>
                            <th>Acting As</th>
                            <th>Reason</th>
                            <th>Starts</th>
                            <th>Ends</th>
                            <th>Assigned By</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($assignments as $a): ?>
                            <?php
                                $expired = $a['ends_at'] && strtotime($a['ends_at']) < time();
                                $rowClass = $expired ? 'table-warning' : '';
                            ?>
                            <tr class="<?= $rowClass ?>">
                                <td class="fw-bold"><?= htmlspecialchars($a['user_name']) ?></td>
                                <td>
                                    <span class="badge bg-warning text-dark">⚡ <?= htmlspecialchars($a['acting_role_name']) ?></span>
                                </td>
                                <td class="text-muted"><?= htmlspecialchars($a['reason'] ?? '-') ?></td>
                                <td style="font-size: 0.8rem;"><?= date('d M Y H:i', strtotime($a['starts_at'])) ?></td>
                                <td style="font-size: 0.8rem;">
                                    <?php if ($a['ends_at']): ?>
                                        <?= date('d M Y H:i', strtotime($a['ends_at'])) ?>
                                        <?php if ($expired): ?>
                                            <span class="badge bg-danger">Expired</span>
                                        <?php endif; ?>
                                    <?php else: ?>
                                        <span class="text-muted">Indefinite</span>
                                    <?php endif; ?>
                                </td>
                                <td style="font-size: 0.8rem;"><?= htmlspecialchars($a['assigned_by_name']) ?></td>
                                <td class="text-center">
                                    <form method="POST" action="/users/acting_roles.php" style="display: inline;"
                                          onsubmit="return confirm('Revoke this acting role assignment?');">
                                        <input type="hidden" name="action" value="revoke">
                                        <input type="hidden" name="assignment_id" value="<?= $a['id'] ?>">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">
                                            <i class="bi bi-x-circle"></i> Revoke
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>

    <!-- Switch Audit Log -->
    <div style="background: white; border-radius: 12px; border: 1px solid #e0e0e0; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
        <h5 style="font-weight: 700; margin-bottom: 1rem;">📜 Role Switch Audit Log <small class="text-muted">(Last 50)</small></h5>

        <?php if (empty($logs)): ?>
            <div style="text-align: center; color: #999; padding: 2rem 0;">
                No role switches recorded yet.
            </div>
        <?php else: ?>
            <div style="overflow-x: auto;">
                <table class="table table-sm mb-0" style="font-size: 0.8rem;">
                    <thead class="table-dark">
                        <tr>
                            <th>When</th>
                            <th>User</th>
                            <th>Action</th>
                            <th>From Role</th>
                            <th>To Role</th>
                            <th>IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($logs as $log): ?>
                            <tr>
                                <td><?= date('d M Y H:i:s', strtotime($log['created_at'])) ?></td>
                                <td class="fw-bold"><?= htmlspecialchars($log['user_name']) ?></td>
                                <td>
                                    <?php if ($log['is_acting']): ?>
                                        <span class="badge bg-warning text-dark">⚡ Switched</span>
                                    <?php else: ?>
                                        <span class="badge bg-success">🔄 Reverted</span>
                                    <?php endif; ?>
                                </td>
                                <td><?= htmlspecialchars($log['from_role']) ?></td>
                                <td><?= htmlspecialchars($log['to_role']) ?></td>
                                <td class="text-muted"><?= htmlspecialchars($log['ip_address'] ?? '-') ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>

</div>

<?php require_once $_SERVER['DOCUMENT_ROOT'] . '/includes/footer.php'; ?>
