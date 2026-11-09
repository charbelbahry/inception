---
title: "WordPress and PHP-FPM Service"
tags: [service, wordpress, php, fpm, wp-cli, dockerfile]
aliases: ["WordPress", "PHP-FPM Service"]
created: 2026-11-05
type: architecture
---

# 📝 WordPress and PHP-FPM Service

> [!abstract] Architectural Profile
> - **Container Name:** `wordpress`
> - **Base Image:** `debian:bullseye`
> - **Internal Port:** `9000` (FastCGI protocol, never exposed to host)
> - **Storage Mount:** `wordpress_data` -> `/var/www/wordpress` -> `/home/cbahry/data/wordpress`
> - **Entrypoint:** `/usr/local/bin/wp_init.sh`

---

## ⚠️ The Strict Non-Admin Username Law

> [!danger] Fatal Subject Trap
> *"In your WordPress database, there must be two users, one of them being the administrator. The administrator's username can't contain admin/Admin or administrator/Administrator (e.g., admin, administrator, Administrator, admin-123, and so forth)."*

- **Illegal Examples:** `admin`, `Admin`, `administrator`, `Administrator`, `admin-42`, `superadmin`.
- **Compliant Examples:** `cbahry_boss`, `master_cbahry`, `site_commander`.

---

## 🛠️ Automated Setup via `wp-cli`

We bypass manual browser installation wizard clicks by automating everything via the official `wp-cli` binary:

```bash
# 1. Download WordPress core files
wp core download --allow-root --path=/var/www/wordpress

# 2. Generate wp-config.php with MariaDB credentials
wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="$(cat /run/secrets/db_password)" \
    --dbhost="mariadb:3306" \
    --path=/var/www/wordpress

# 3. Install core site & create Administrator
wp core install --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception cbahry" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="$(cat /run/secrets/wp_admin_password)" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --path=/var/www/wordpress

# 4. Create the Second (Non-Admin) User
wp user create --allow-root \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="$(cat /run/secrets/wp_user_password)" \
    --role="editor" \
    --path=/var/www/wordpress
```

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: Why do we pass `--allow-root` to wp-cli?
> <details>
> <summary>Click to reveal answer</summary>
> By default, <code>wp-cli</code> prevents execution as the <code>root</code> user for security reasons. Inside the Docker build/init phase, our setup script runs as root, so <code>--allow-root</code> must be explicitly provided.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
