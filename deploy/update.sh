#!/usr/bin/env bash
# ============================================================
# deploy/update.sh
# Pull latest changes from git and update PRMS v3 in-place.
#
# Usage:
#   sudo bash deploy/update.sh [--run-migrations] [--branch <name>]
#
# Options:
#   --run-migrations   Apply any new SQL migrations after pulling
#   --branch <name>    Git branch to pull (default: current branch)
#
# Run from any directory; APP_DIR defaults to /var/www/prms/public.
# Override: APP_DIR=/custom/path sudo bash deploy/update.sh
# ============================================================
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/prms/public}"
MIGRATIONS_DIR="$APP_DIR/migrations"
ENV_FILE="$APP_DIR/.env"

RUN_MIGRATIONS=false
GIT_BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --run-migrations) RUN_MIGRATIONS=true ;;
        --branch)         GIT_BRANCH="$2"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

# ── Helpers ─────────────────────────────────────────────────
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# ── Validate app directory ───────────────────────────────────
[[ -d "$APP_DIR/.git" ]] || die "No git repository found at $APP_DIR"
[[ -f "$ENV_FILE" ]]     || die ".env not found at $ENV_FILE"

cd "$APP_DIR"

# ── Git safe.directory (needed when running as root/sudo over a www-data-owned tree) ──
git config --global --add safe.directory "$APP_DIR" 2>/dev/null || true

# ── Load .env ───────────────────────────────────────────────
set +u
while IFS= read -r _line || [[ -n "$_line" ]]; do
    [[ "$_line" =~ ^[[:space:]]*$  ]] && continue
    [[ "$_line" =~ ^[[:space:]]*# ]] && continue
    export "$_line"
done < "$ENV_FILE"
set -u

: "${DB_HOST:?DB_HOST must be set in .env}"
: "${DB_PORT:?DB_PORT must be set in .env}"
: "${DB_NAME:?DB_NAME must be set in .env}"
: "${DB_USER:?DB_USER must be set in .env}"
: "${DB_PASS:?DB_PASS must be set in .env}"

MYSQL="mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS"

# ── Git pull ─────────────────────────────────────────────────
log "Fetching latest changes from remote..."
git fetch --prune origin

if [[ -n "$GIT_BRANCH" ]]; then
    log "Switching to branch: $GIT_BRANCH"
    git checkout "$GIT_BRANCH"
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
log "Pulling branch: $CURRENT_BRANCH"

# ── Clear any leftover merge-conflict state ──────────────────
# This can happen if a previous stash pop or merge left unresolved files
# (e.g. vendor/ files that are now gitignored but were still in the index).
if git ls-files --unmerged | grep -q .; then
    log "  Unmerged files detected — clearing conflict state..."
    while IFS= read -r _f; do
        if git check-ignore -q "$_f" 2>/dev/null; then
            # File is now gitignored — remove it from the index entirely
            if git rm --cached -f -- "$_f" 2>/dev/null; then
                log "    Removed ignored file from index: $_f"
            elif git update-index --force-remove -- "$_f" 2>/dev/null; then
                log "    Force-removed ignored index entry: $_f"
            fi
        else
            # Tracked file — reset to the HEAD version
            if git restore --source=HEAD --staged --worktree -- "$_f" 2>/dev/null; then
                log "    Reset to HEAD: $_f"
            fi
        fi
    done < <(git ls-files --unmerged | awk '{print $4}' | sort -u)

    if git ls-files --unmerged | grep -q .; then
        die "Unmerged files are still present; resolve manually before running update (git status)."
    fi
fi

# Stash any local modifications so the pull never fails silently
if ! git diff --quiet || ! git diff --cached --quiet; then
    log "  Local modifications detected — stashing before pull..."
    git stash push -m "auto-stash before update $(date '+%Y-%m-%d %H:%M:%S')"
    STASHED=true
else
    STASHED=false
fi

git pull --ff-only origin "$CURRENT_BRANCH"

if [[ "$STASHED" == "true" ]]; then
    log "  Restoring stashed local modifications..."
    git stash pop || log "  WARNING: stash pop had conflicts — review manually."
fi

log "Git pull complete. Current commit: $(git rev-parse --short HEAD)"

# ── Composer dependencies ────────────────────────────────────
log "Installing/updating Composer dependencies..."
composer install --no-dev --optimize-autoloader --quiet

# ── File permissions ─────────────────────────────────────────
log "Setting file permissions..."
find "$APP_DIR" -type f -name "*.php" -exec chmod 644 {} \;
find "$APP_DIR" -type d -exec chmod 755 {} \;
chmod 640 "$ENV_FILE"
chown -R www-data:www-data "$APP_DIR/uploads" 2>/dev/null || true

# ── Run SQL migrations ───────────────────────────────────────
if [[ "$RUN_MIGRATIONS" == "true" ]]; then
    log "Running SQL migrations..."

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

# ── Reload PHP-FPM ───────────────────────────────────────────
PHP_VER="${PHP_VER:-8.2}"
log "Reloading PHP-FPM (php${PHP_VER}-fpm)..."
systemctl reload "php${PHP_VER}-fpm" || true

log "✅  Update complete."
