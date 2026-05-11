#!/usr/bin/env bash
# ============================================================
# deploy/install.sh
# One-shot server provisioning script for PRMS v3
# Tested on Ubuntu 22.04 LTS / Debian 12
#
# Run as root (or with sudo):
#   sudo bash deploy/install.sh
# ============================================================
set -euo pipefail

DEPLOY_USER="${DEPLOY_USER:-www-data}"
APP_DIR="${APP_DIR:-/var/www/prms}"
PHP_VER="${PHP_VER:-8.2}"
WEB_SERVER="${WEB_SERVER:-apache}"   # apache | nginx

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PRMS v3 — Server Installation"
echo " Web server : $WEB_SERVER"
echo " PHP version: $PHP_VER"
echo " App dir    : $APP_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── System packages ─────────────────────────────────────────
apt-get update -y
apt-get install -y \
    curl wget git unzip software-properties-common \
    certbot

# ── PHP ─────────────────────────────────────────────────────
add-apt-repository -y ppa:ondrej/php
apt-get update -y
apt-get install -y \
    "php${PHP_VER}-fpm" \
    "php${PHP_VER}-mysql" \
    "php${PHP_VER}-mbstring" \
    "php${PHP_VER}-xml" \
    "php${PHP_VER}-curl" \
    "php${PHP_VER}-zip" \
    "php${PHP_VER}-gd" \
    "php${PHP_VER}-intl" \
    "php${PHP_VER}-opcache"

# ── Web server ──────────────────────────────────────────────
if [[ "$WEB_SERVER" == "apache" ]]; then
    apt-get install -y apache2
    a2enmod rewrite headers deflate expires ssl proxy_fcgi setenvif
    a2enconf "php${PHP_VER}-fpm"
elif [[ "$WEB_SERVER" == "nginx" ]]; then
    apt-get install -y nginx
fi

# ── MariaDB ─────────────────────────────────────────────────
apt-get install -y mariadb-server
systemctl enable --now mariadb

# ── Composer ────────────────────────────────────────────────
if ! command -v composer &>/dev/null; then
    EXPECTED_CHECKSUM="$(curl -sS https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        echo "ERROR: Composer installer checksum mismatch"
        rm /tmp/composer-setup.php
        exit 1
    fi
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm /tmp/composer-setup.php
fi

# ── Application directory ───────────────────────────────────
mkdir -p "$APP_DIR/public"
chown -R "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"

# ── PHP-FPM tuning ──────────────────────────────────────────
PHP_FPM_POOL="/etc/php/${PHP_VER}/fpm/pool.d/www.conf"
if [[ -f "$PHP_FPM_POOL" ]]; then
    sed -i 's/^pm.max_children = .*/pm.max_children = 20/'    "$PHP_FPM_POOL"
    sed -i 's/^pm.start_servers = .*/pm.start_servers = 5/'   "$PHP_FPM_POOL"
    sed -i 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 2/' "$PHP_FPM_POOL"
    sed -i 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 10/' "$PHP_FPM_POOL"
fi

# ── PHP ini overrides for uploads ───────────────────────────
PHP_INI="/etc/php/${PHP_VER}/fpm/conf.d/99-prms.ini"
cat > "$PHP_INI" <<'INI'
upload_max_filesize = 50M
post_max_size       = 55M
memory_limit        = 256M
max_execution_time  = 120
date.timezone       = America/Jamaica
INI

# ── Restart services ────────────────────────────────────────
systemctl restart "php${PHP_VER}-fpm"
if [[ "$WEB_SERVER" == "apache" ]]; then
    systemctl enable --now apache2
    systemctl restart apache2
elif [[ "$WEB_SERVER" == "nginx" ]]; then
    systemctl enable --now nginx
    systemctl restart nginx
fi

echo ""
echo "✅  Installation complete."
echo ""
echo "Next steps:"
echo "  1. Create the database and user (see deploy/deploy.sh --init-db)"
echo "  2. Copy your code to $APP_DIR/public"
echo "  3. Copy .env.example to $APP_DIR/public/.env and fill in credentials"
echo "  4. Run: cd $APP_DIR/public && composer install --no-dev"
echo "  5. Run pending migrations against the database"
echo "  6. Install the virtual host:"
if [[ "$WEB_SERVER" == "apache" ]]; then
    echo "     sudo cp deploy/apache.conf /etc/apache2/sites-available/prms.conf"
    echo "     sudo a2ensite prms && sudo systemctl reload apache2"
else
    echo "     sudo cp deploy/nginx.conf /etc/nginx/sites-available/prms"
    echo "     sudo ln -s /etc/nginx/sites-available/prms /etc/nginx/sites-enabled/"
    echo "     sudo nginx -t && sudo systemctl reload nginx"
fi
echo "  7. Obtain SSL cert: sudo certbot --$WEB_SERVER -d prms.example.com"
