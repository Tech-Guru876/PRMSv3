#!/usr/bin/env bash

# ============================================================================
# PERMISSION SYSTEM DEPLOYMENT SCRIPT
# Comprehensive 65-Permission System Setup
# ============================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# CONFIGURATION
# ============================================================================

APP_DIR="${APP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
ENV_FILE="$APP_DIR/.env"

# Migration directory
MIGRATION_DIR="$APP_DIR/migrations"
LOG_FILE="permission_deployment.log"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

# ============================================================================
# MAIN DEPLOYMENT
# ============================================================================

main() {
    log "=================================================="
    log "PRMS Permission System Deployment"
    log "=================================================="

    # Load DB settings from .env
    if [ ! -f "$ENV_FILE" ]; then
        error ".env not found at $ENV_FILE"
    fi

    while IFS= read -r _line || [[ -n "$_line" ]]; do
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue
        [[ "$_line" == *=* ]] || continue

        _key="${_line%%=*}"
        _value="${_line#*=}"

        case "$_key" in
            DB_HOST|DB_PORT|DB_NAME|DB_USER|DB_PASS)
                export "$_key=$_value"
                ;;
        esac
    done < "$ENV_FILE"

    : "${DB_HOST:?DB_HOST must be set in .env}"
    : "${DB_PORT:?DB_PORT must be set in .env}"
    : "${DB_NAME:?DB_NAME must be set in .env}"
    : "${DB_USER:?DB_USER must be set in .env}"
    : "${DB_PASS:?DB_PASS must be set in .env}"
    
    # Check if migration files exist
    if [ ! -f "$MIGRATION_DIR/012_assign_default_role_permissions.sql" ]; then
        error "Migration file 012 not found at $MIGRATION_DIR/012_assign_default_role_permissions.sql"
    fi
    if [ ! -f "$MIGRATION_DIR/013_comprehensive_permissions_65.sql" ]; then
        error "Migration file 013 not found at $MIGRATION_DIR/013_comprehensive_permissions_65.sql"
    fi
    success "Migration files found"
    
    # Backup database
    log "Creating database backup..."
    BACKUP_FILE="prms_backup_$(date +%Y%m%d_%H%M%S).sql"
    if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"; then
        success "Database backed up to $BACKUP_FILE"
    else
        error "Failed to backup database"
    fi
    
    # Run Migration 012 (if not already run)
    log "Checking if migration 012 has been applied..."
    if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM permissions WHERE name='view_requests';" 2>/dev/null | grep -q "[0-9]"; then
        success "Migration 012 appears to be already applied"
    else
        log "Running migration 012..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$MIGRATION_DIR/012_assign_default_role_permissions.sql" || error "Migration 012 failed"
        success "Migration 012 completed"
    fi
    
    # Run Migration 013 (Comprehensive 65 Permissions)
    log "Running migration 013 (65 comprehensive permissions)..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$MIGRATION_DIR/013_comprehensive_permissions_65.sql" || error "Migration 013 failed"
    success "Migration 013 completed"
    
    # Verification
    log "Verifying installation..."
    
    PERM_COUNT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sNe "SELECT COUNT(*) FROM permissions;")
    log "Total permissions created: $PERM_COUNT"
    if [ "$PERM_COUNT" -ge 65 ]; then
        success "Permission count verified (expected 65+, got $PERM_COUNT)"
    else
        warning "Permission count lower than expected (expected 65, got $PERM_COUNT)"
    fi
    
    ROLE_COUNT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sNe "SELECT COUNT(DISTINCT role_id) FROM role_permissions;")
    log "Roles with permissions assigned: $ROLE_COUNT"
    if [ "$ROLE_COUNT" -ge 12 ]; then
        success "All 12 roles have permissions assigned"
    else
        warning "Only $ROLE_COUNT roles have permissions (expected 12)"
    fi
    
    ORPHANED=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sNe "SELECT COUNT(*) FROM permissions p WHERE NOT EXISTS (SELECT 1 FROM role_permissions WHERE permission_id=p.id);")
    if [ "$ORPHANED" -eq 0 ]; then
        success "No orphaned permissions found"
    else
        warning "Found $ORPHANED orphaned permissions"
    fi
    
    # Display permission summary
    log "=================================================="
    log "PERMISSION SUMMARY BY ROLE"
    log "=================================================="
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT rp.permission_id) as permission_count
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
WHERE r.id BETWEEN 1 AND 12
GROUP BY r.id, r.name
ORDER BY r.id;
EOF
    
    log "=================================================="
    success "DEPLOYMENT COMPLETE"
    log "=================================================="
    log "Files modified/created:"
    log "  - /reimbursement/list.php (added REQUIRE_PERMISSION)"
    log "  - /reimbursement/view.php (added REQUIRE_PERMISSION)"
    log "  - /petty_cash/list.php (added REQUIRE_PERMISSION)"
    log "  - /petty_cash/view.php (added REQUIRE_PERMISSION)"
    log ""
    log "Documentation created:"
    log "  - docs/PERMISSION_AUDIT_FINDINGS.md"
    log "  - docs/PERMISSION_IMPLEMENTATION_GUIDE.md"
    log "  - docs/PERMISSION_SYSTEM_SUMMARY.md"
    log "  - tools/role_permission_queries.sql"
    log ""
    log "Next steps:"
    log "  1. Review the permission assignments"
    log "  2. Test user access in staging environment"
    log "  3. Run testing checklist from PERMISSION_IMPLEMENTATION_GUIDE.md"
    log "  4. Deploy to production after approval"
    log ""
    log "Backup created: $BACKUP_FILE"
    log "Deployment log: $LOG_FILE"
}

# ============================================================================
# RUN MAIN
# ============================================================================

main "$@"
