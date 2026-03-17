# Workflow Approval Thresholds Implementation
## Date: March 17, 2026

### Overview
Major changes implemented to add amount-based approval requirements for procurement requests:
- Requests **over 500,000** JMD now require **HOD Approval**
- Requests **over 3,000,000** JMD now require **Committee Review**

---

## Changes Made

### 1. **Database Migration** ✅
**File:** `migrations/2026_03_17_add_approval_thresholds.sql`

New system configuration entries added:
```sql
-- HOD Approval Threshold (500,000 JMD)
INSERT INTO `system_config` (`config_key`, `config_value`, `description`)
VALUES ('hod_approval_threshold', '500000.00', 'Procurement requests above this amount require HOD approval (JMD)')

-- Committee Review Threshold (3,000,000 JMD)
INSERT INTO `system_config` (`config_key`, `config_value`, `description`)
VALUES ('committee_review_threshold', '3000000.00', 'Procurement requests above this amount require committee review (JMD)')
```

**Status:** Migration file created, ready to apply via:
```bash
mysql -u [user] -p [database] < migrations/2026_03_17_add_approval_thresholds.sql
```

---

### 2. **Workflow Logic Updates** ✅
**File:** `config/workflow.php`

#### Updated `getApprovalChain()` Function
- Now checks request amount against both thresholds
- Dynamically builds approval chain based on amount:
  - **Over 3M:** Adds Procurement Committee
  - **Over 500K:** Adds HOD (if not already present)
  - **Base:** Adds branch-specific primary approver (Director HRM&A, Deputy GC, or HOD)

#### Added Helper Functions
1. `getHODApprovalThreshold(PDO $pdo): float`
   - Returns: 500,000.00 (default)
   - Reads from system_config key: `hod_approval_threshold`

2. `getCommitteeReviewThreshold(PDO $pdo): float`
   - Returns: 3,000,000.00 (default)
   - Reads from system_config key: `committee_review_threshold`

#### Changed Behavior
**Before:**
```
Branch-based approval (single approver regardless of amount)
HOD → Finance → Deputy GC (based on branch)
```

**After:**
```
Amount-based approval chain (multiple approvers based on amount)
500K: HOD + Branch Primary
3M: Committee + 500K approvers + Branch Primary
```

---

### 3. **Settings Page Updates** ✅
**File:** `admin/settings.php`

#### Form Submission Handler (POST)
Added handling for two new POST parameters:
- `hod_approval_threshold` - Updates/creates system_config entry
- `committee_review_threshold` - Updates/creates system_config entry

#### Settings Retrieval
Added PHP variable assignments:
```php
$currentHODThreshold = getHODApprovalThreshold($pdo);
$currentCommitteeThreshold = getCommitteeReviewThreshold($pdo);
```

#### UI Form Fields
Added two new input sections in "Workflow Thresholds" card:

1. **HOD Approval Threshold (JMD)**
   - Input field: `hod_approval_threshold`
   - Default: 500,000.00
   - Help text: "Requests above this amount require HOD approval"

2. **Committee Review Threshold (JMD)**
   - Input field: `committee_review_threshold`
   - Default: 3,000,000.00
   - Help text: "Requests above this amount require committee review"

#### Updated Help Text
Changed workflow routing explanation to include:
- "Over HOD threshold: HOD approval required"
- "Over Committee threshold: Procurement Committee review required"

---

## Architecture Details

### Approval Chain Building Logic
For a request with estimated value and branch:

```
1. Check if value > COMMITTEE_THRESHOLD (3M)
   └─ YES: Add 'Procurement Committee' to chain

2. Check if value > HOD_THRESHOLD (500K)
   └─ YES: Add 'HOD' to chain (if not already present)

3. Add branch-based primary approver
   ├─ Branch 6: Deputy Government Chemist
   ├─ Branch 5: Director HRM&A
   └─ Others: HOD (avoid duplicate if already added by threshold)

Result: Ordered array of approver roles
```

### Example Scenarios

| Amount | Branch | Approval Chain |
|--------|--------|-----------------|
| 250K | 1 | [HOD] |
| 750K | 1 | [HOD, HOD] → deduplicated to [HOD] |
| 750K | 5 | [HOD, Director HRM&A] |
| 3.5M | 1 | [Procurement Committee, HOD, HOD] → [Procurement Committee, HOD] |
| 3.5M | 6 | [Procurement Committee, HOD, Deputy GC] |

---

## Files Modified

| File | Changes | Status |
|------|---------|--------|
| `config/workflow.php` | Updated `getApprovalChain()`, added helper functions | ✅ Complete |
| `admin/settings.php` | Added POST handlers, UI fields, settings retrieval | ✅ Complete |
| `migrations/2026_03_17_add_approval_thresholds.sql` | New migration | ✅ Created |
| `run_migration.php` | Migration runner script | ✅ Created |

---

## Deployment Instructions

### Step 1: Apply Database Migration
```bash
# Option A: Via command line
mysql -h localhost -u u153072617_dgc_ims -p u153072617_prms_ims < migrations/2026_03_17_add_approval_thresholds.sql

# Option B: Via PHP script
php run_migration.php
```

### Step 2: Verify Settings Page
1. Navigate to Admin → System Settings
2. Verify new fields are visible:
   - "HOD Approval Threshold (JMD)" - shows 500,000.00
   - "Committee Review Threshold (JMD)" - shows 3,000,000.00

### Step 3: Test Workflow
1. Create procurement requests with different amounts:
   - Under 500K
   - Between 500K - 3M
   - Over 3M
2. Verify correct approvers are indicated in request details

---

## Impact Analysis

### Direct Impact
- **Approval workflow:** Requests now require additional approvers based on amount
- **Database:** 2 new configuration entries added
- **Settings UI:** 2 new editable threshold fields
- **Approval chain generation:** Dynamic based on amount, not static

### Indirect Impact
- **Email notifications:** Will notify additional approvers based on new chain
- **Audit logs:** Will record approvals from Procurement Committee for large requests
- **Dashboard:** May show different approval queues based on user role and amounts

### Backward Compatibility
- Existing requests are NOT affected
- New requests will use updated logic
- All thresholds can be modified in settings without code changes
- Default values match configuration (500K, 3M)

---

## Testing Checklist

- [ ] Database migration applied successfully
- [ ] Settings page displays new fields with correct defaults
- [ ] Settings can be modified and saved
- [ ] New settings are persisted to database
- [ ] Procurement requests under 500K show correct approvers
- [ ] Procurement requests 500K-3M show HOD in approval chain
- [ ] Procurement requests over 3M show Committee + HOD in approval chain
- [ ] Notification emails sent to correct approvers
- [ ] Approval workflow functions correctly for each threshold

---

## Rollback Instructions

If needed to revert changes:
```bash
# Remove configuration entries from database
DELETE FROM system_config WHERE config_key IN ('hod_approval_threshold', 'committee_review_threshold');

# Revert code changes via git
git revert [commit-hash]
```

---

## Notes
- System defaults to 500K and 3M if configuration entries are missing
- All threshold values are stored in JMD currency
- Currency conversion (USD to JMD) happens before threshold comparison
- Thresholds are read at request time, allowing real-time updates without restart
