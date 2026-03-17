# Request Type Architecture Analysis

## Current State

### Issue Identified
Petty Cash and Reimbursement requests are currently being created in the **same `procurement_requests` table** as regular procurement requests, using a `request_type` column to distinguish them. However, there's a **schema mismatch**:

- **Database Schema (prmsv2.sql)**: `request_type` enum = `('REGULAR', 'EXPEDITED', 'EMERGENCY')`
- **PHP Code**: Attempts to insert `'PETTY_CASH'` and `'REIMBURSEMENT'` values
- **Workflow Logic**: Already supports dynamic handling via `getApprovalChain()` function

This causes **data integrity issues** and potential insert failures.

---

## Data Model Overview

### Tables Involved
1. **procurement_requests** (Main container for all request types)
   - Columns: request_id, request_number, request_type, status, description, estimated_value, etc.
   - Used for: REGULAR, REIMBURSEMENT, PETTY_CASH

2. **pre_authorizations** (Reimbursement-specific)
   - Links to procurement_requests via request_id
   - Tracks prior authorization amounts for reimbursement

3. **petty_cash_disbursements** (Petty Cash-specific)
   - Links to procurement_requests via request_id
   - Tracks disbursement details

4. **reimbursement_invoices** (Reimbursement-specific)
   - Links to procurement_requests via request_id
   - Tracks invoices submitted for reimbursement

### Request Type Locations
```
procurement_requests
├── REGULAR (traditional procurement with RFQ)
├── REIMBURSEMENT (employee reimbursement requests)
│   └── pre_authorizations (links to this request)
│   └── reimbursement_invoices (links to this request)
└── PETTY_CASH (small amount petty cash requests)
    └── petty_cash_disbursements (links to this request)
```

---

## Approval Workflow by Request Type

### Regular Procurement (REGULAR)
```
DRAFT 
→ SUBMITTED 
→ HOD_APPROVED (if amount > threshold)
→ DIRECTOR_APPROVED (if amount > committee threshold)
→ GC_APPROVED 
→ PROCUREMENT_STAGE (RFQ generation)
→ RFQ_LETTER_AVAILABLE (vendors sent RFQ)
→ QUOTE_REVIEW_PENDING (collect vendor quotes)
→ QUOTE_APPROVED (select winning vendor)
→ COMMITMENT_APPROVED (finance verification)
→ AWARDED (procurement complete)
```

### Reimbursement Request (REIMBURSEMENT)
```
DRAFT 
→ SUBMITTED 
→ FINANCE_APPROVED (Finance Officer verifies funds)
→ COMPLETED (reimbursement paid)
```

### Petty Cash Request (PETTY_CASH)
```
DRAFT 
→ SUBMITTED 
→ FINANCE_APPROVED (Finance Officer verifies funds)
→ COMPLETED (funds disbursed)
```

**Key Difference**: REIMBURSEMENT and PETTY_CASH bypass HOD/Director approvals and go directly to Finance Officer for fund verification.

---

## Implementation in Workflow Config

File: [config/workflow.php](../../config/workflow.php)

### Approval Chain Function
```php
function getApprovalChain(string $requestType, float $estimatedValue, ?int $branchId = null, ?PDO $pdo = null): array {
    // Petty cash / reimbursement: Finance Officer only (fund verification)
    if (in_array($requestType, ['PETTY_CASH', 'REIMBURSEMENT'])) {
        return ['Finance Officer'];
    }
    
    // Regular procurement: Amount-based approvals
    // ... HOD, Director, Deputy GC based on thresholds
}
```

**Status**: ✅ Already supports dynamic routing based on request_type

---

## Current Issues & Solutions

### Issue 1: Schema Mismatch
**Problem**: Database enum doesn't include REIMBURSEMENT and PETTY_CASH

**Solution**: ✅ **Created Migration 2026_03_17_fix_request_type_enum.sql**
```sql
ALTER TABLE `procurement_requests` 
MODIFY COLUMN `request_type` ENUM('REGULAR', 'REIMBURSEMENT', 'PETTY_CASH') 
NOT NULL DEFAULT 'REGULAR';
```

**Action Required**: 
- Execute migration on production database
- Verify enum was updated: `SELECT DISTINCT request_type FROM procurement_requests;`

---

### Issue 2: Workflow Confusion
**Problem**: Mixed workflows (procurement workflow for all types)

**Solution**: ✅ **Already Implemented**
- Workflow transitions vary by request_type
- Finance Officer approval for REIMBURSEMENT/PETTY_CASH
- Standard 3-approver model for REGULAR

**Status**: Code is ready; just needs database fix

---

### Issue 3: Data Segregation Concerns
**Problem**: Should these be separate tables?

**Analysis & Recommendation**:

#### Option A: Keep in Single Table (Current)
✅ **RECOMMENDED** - Better for:
- Unified approval workflow
- Shared audit trails
- Simpler notification system
- Unified reporting/analytics
- Type-aware workflow handling

❌ Cons:
- Table has unused columns per type
- Must handle NULL values for type-specific fields

#### Option B: Separate Tables
✅ Pros:
- Schema clarity
- Type-specific optimizations
- Reduced NULL columns

❌ Cons:
- Complex UNION queries for reporting
- Duplicated audit/notification logic
- Harder to implement unified workflows
- Migration complexity

**Recommendation**: **Keep single table with type-aware workflow** (current design)

---

## Database Schema Fix Required

### Current (INCORRECT)
```sql
`request_type` ENUM('REGULAR','EXPEDITED','EMERGENCY') DEFAULT 'REGULAR'
```

### Fixed (CORRECT)
```sql
`request_type` ENUM('REGULAR', 'REIMBURSEMENT', 'PETTY_CASH') DEFAULT 'REGULAR'
```

### Migration File
- Created: [migrations/2026_03_17_fix_request_type_enum.sql](../migrations/2026_03_17_fix_request_type_enum.sql)
- Execute this on production immediately

---

## Code Files Affected

### Creates Requests
- [petty_cash/add.php](../../petty_cash/add.php) - Sets request_type='PETTY_CASH'
- [reimbursement/add.php](../../reimbursement/add.php) - Sets request_type='REIMBURSEMENT'
- [procurement/add.php](../../procurement/add.php) - Sets request_type='REGULAR'

### Routes Based on Type
- [config/workflow.php](../../config/workflow.php) - getApprovalChain() switches on request_type
- [config/policy.php](../../config/policy.php) - May have type-specific rules

### Displays Based on Type
- [dashboard/index.php](../../dashboard/index.php) - Shows type-specific widgets
- [procurement/view.php](../../procurement/view.php) - Shows different UI elements per type

---

## Verification Checklist

After applying the migration:

- [ ] Migration executed successfully
- [ ] Run verification query: `SELECT DISTINCT request_type FROM procurement_requests;`
- [ ] Should show: REGULAR, REIMBURSEMENT, PETTY_CASH
- [ ] Create test PETTY_CASH request → should insert without errors
- [ ] Create test REIMBURSEMENT request → should insert without errors
- [ ] Create test REGULAR request → should insert without errors
- [ ] Verify workflows route correctly per type
- [ ] Check approvals go to Finance Officer for PC/REIMB
- [ ] Check approvals go to HOD/Director for REGULAR above threshold

---

## Future Enhancements (Optional)

1. **Type-Specific Views** - Separate dashboards per request type
2. **Advanced Filtering** - Filter by request_type in reports
3. **Status Mapping** - Different allowed statuses per type
4. **Bulk Operations** - Handle requests by type
5. **Analytics** - Separate metrics per request type

---

## Related Documentation

- [APPROVAL_WORKFLOW_AND_NOTIFICATIONS_ANALYSIS.md](../APPROVAL_WORKFLOW_AND_NOTIFICATIONS_ANALYSIS.md)
- [REIMBURSEMENT_IMPLEMENTATION_COMPLETE.md](../REIMBURSEMENT_IMPLEMENTATION_COMPLETE.md)
- [PENDING_ACTIONS_IMPLEMENTATION.md](../PENDING_ACTIONS_IMPLEMENTATION.md)

---

## Summary

**Current State**: ✅ Architecture is sound; dynamic workflow support exists  
**Issue**: ❌ Database schema mismatch preventing PETTY_CASH/REIMBURSEMENT inserts  
**Solution**: ✅ Migration file created to fix enum  
**Action**: Execute migration [2026_03_17_fix_request_type_enum.sql](../migrations/2026_03_17_fix_request_type_enum.sql)  
**Result**: Single table with type-aware dynamic workflows (no separate tables needed)
