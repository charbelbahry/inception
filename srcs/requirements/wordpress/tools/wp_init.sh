#!/bin/bash
set -e

export WP_CLI_PHP_ARGS="-d memory_limit=512M"

if [ -f "/run/secrets/db_password" ]; then
	DB_PASSWORD=$(cat /run/secrets/db_password)
else
	DB_PASSWORD="$MYSQL_PASSWORD"
fi

if [ -f "/run/secrets/wp_admin_password" ]; then
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
else
	WP_ADMIN_PASSWORD="$WP_ADMIN_PASSWORD"

fi

if [ -f "/run/secrets/wp_user_password" ]; then
	WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
else
	WP_USER_PASSWORD="$WP_USER_PASSWORD"
fi

mkdir -p /var/www/wordpress
cd /var/www/wordpress

echo "[+] waiting for MariaDB service to be reachable on mariadb:3306.."
until mariadb-admin ping -h"mariadb" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
	echo "	[-] MariaDB not ready yet. Retrying in 2 seconds..."
	sleep 2
done
echo "[+] MariaDB is ready and accepting connections"

if [ ! -f "wp-config.php" ]; then
	echo "[+] Downloading WordPress core files..."
	wp core download --allow-root --path=/var/www/wordpress

	echo "[+] Generating wp-config.php..."
	wp config create --allow-root \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="mariadb:3306" \
		--path=/var/www/wordpress

	echo "[+] Installing WordPress and creating Administrator (${WP_ADMIN_USER})..."
	wp core install --allow-root \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--path=/var/www/wordpress

	echo "[+] Creating second WordPress user (${WP_USER})..."
	wp user create --allow-root \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--path=/var/www/wordpress

	echo "[+] WordPress installation completed successfully"
else
	echo "[+] Existing WordPress installation detected. Skipping install"
fi

chown -R nobody:nobody /var/www/wordpress

echo "[+] Launching PHP-FPM in foreground..."
exec /usr/sbin/php-fpm83 -F
