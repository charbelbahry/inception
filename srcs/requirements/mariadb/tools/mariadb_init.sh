#!/bin/bash
set -e

if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
elif [ -n "$MYSQL_PASSWORD" ]; then
    DB_PASSWORD="$MYSQL_PASSWORD"
else
    echo "[-] Error: Database user password not provided via secret or environment." >&2
    exit 1
fi

if [ -f "/run/secrets/db_root_password" ]; then
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
elif [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    DB_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
else
    echo "[-] Error: Database root password not provided via secret or environment." >&2
    exit 1
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "[+] First-time boot: Initializing system tables via mariadb-install-db..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
    echo "[+] Bootstrapping database '${MYSQL_DATABASE}' and configuring users..."
    mariadbd --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF
    echo "[+] Database initialization completed successfully."
else
    echo "[+] Existing database detected in volume. Skipping initialization."
fi

echo "[+] Launching MariaDB daemon in foreground (PID 1)..."
exec mariadbd --user=mysql --console
