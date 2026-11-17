#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
. /run/secrets/credentials

cd /var/www/html

if [ ! -f wp-config.php ]; then
    if [ ! -f wp-load.php ]; then
        echo "[setup_wp] Downloading WordPress..."
        wp core download --allow-root
    fi

    echo "[setup_wp] Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost=mariadb:3306

    echo "[setup_wp] Installing WordPress..."
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    echo "[setup_wp] Creating second user..."
    wp user create --allow-root "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD"

    chown -R nobody:nobody /var/www/html
fi

echo "[setup_wp] Starting php-fpm..."
exec php-fpm84 -F
