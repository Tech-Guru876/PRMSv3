#!/usr/bin/env bash
# ============================================================
# deploy/deploy.sh
# Application deployment / update script for PRMS v3
#
# Usage:
#   bash deploy/deploy.sh [--init-db] [--run-migrations]
#
# Options:
#   --init-db          Create the database and user (first time only)
#   --run-migrations   Apply all pending SQL migrations
# ============================================================
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/prms/public}"
MIGRATIONS_DIR="$APP_DIR/migrations"
ENV_FILE="$APP_DIR/.env"

INIT_DB=false
RUN_MIGRATIONS=false

for arg in "$@"; do
    case $arg in
        --init-db)         INIT_DB=true ;;
        --run-migrations)  RUN_MIGRATIONS=true ;;
    esac
done

# ── Helpers ─────────────────────────────────────────────────
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# ── Load .env ───────────────────────────────────────────────
[[ -f "$ENV_FILE" ]] || die ".env not found at $ENV_FILE"

set -o allexport
set +u  # allow unset variables while sourcing .env (values may contain $ or spaces)
# Parse .env manually: skip blank lines and comments, then export each KEY=VALUE
while IFS= read -r _line || [[ -n "$_line" ]]; do
    # Skip blank lines and comment lines (including decorative comment headers)
    [[ "$_line" =~ ^[[:space:]]*$ ]]  && continue
    [[ "$_line" =~ ^[[:space:]]*#  ]] && continue
    export "$_line"
done < "$ENV_FILE"
set -u
set +o allexport

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-prms_ims}"
DB_USER="${DB_USER:-prms_user}"
DB_PASS="${DB_PASS:?DB_PASS must be set in .env}"

MYSQL="mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS"

# ── Initialise database ─────────────────────────────────────
if [[ "$INIT_DB" == "true" ]]; then
    log "Creating database and user..."
    read -r -s -p "Enter MariaDB/MySQL root password: " ROOT_PASS; echo
    mysql -uroot -p"$ROOT_PASS" <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
SQL
    log "Database '$DB_NAME' and user '$DB_USER' created."
fi

# ── Composer dependencies ───────────────────────────────────
log "Installing Composer dependencies..."
cd "$APP_DIR"
composer install --no-dev --optimize-autoloader --quiet

# ── File permissions ────────────────────────────────────────
log "Setting file permissions..."
find "$APP_DIR" -type f -name "*.php" -exec chmod 644 {} \;
find "$APP_DIR" -type d -exec chmod 755 {} \;
chmod 640 "$ENV_FILE"
chown -R www-data:www-data "$APP_DIR/uploads" 2>/dev/null || true

# ── Run SQL migrations ──────────────────────────────────────
if [[ "$RUN_MIGRATIONS" == "true" ]]; then
    log "Running SQL migrations..."

    # Track which migrations have been applied using a simple marker file
    APPLIED_FILE="$APP_DIR/.applied_migrations"
    touch "$APPLIED_FILE"

    for sql_file in "$MIGRATIONS_DIR"/*.sql; do
        fname="$(basename "$sql_file")"
        if grep -qxF "$fname" "$APPLIED_FILE"; then
            log "  Skipping (already applied): $fname"
            continue
        fi
        log "  Applying: $fname"
        $MYSQL "$DB_NAME" < "$sql_file"
        echo "$fname" >> "$APPLIED_FILE"
    done

    log "Migrations complete."
fi

# ── Reload PHP-FPM ──────────────────────────────────────────
PHP_VER="${PHP_VER:-8.2}"
log "Reloading PHP-FPM (php${PHP_VER}-fpm)..."
systemctl reload "php${PHP_VER}-fpm" || true

log "✅  Deployment complete."
