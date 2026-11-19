# Inception - Developer Documentation

This document describes how a developer can set up, build, manage, and understand the persistence of the Inception infrastructure, adhering strictly to Chapter VII of the subject.

---

## 1. Setting Up the Environment from Scratch

### Prerequisites
- **Operating System:** Linux Virtual Machine (Arch Linux, Debian, or Ubuntu)
- **Engine & Tools:** Docker Engine (v24+), Docker Compose (v2+), GNU Make, OpenSSL, `curl`

### Configuration Files & Domain
1. Map the domain name in `/etc/hosts`:
   ```bash
   echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
   ```
2. Create `srcs/.env` from template:
   ```bash
   cp srcs/.env.example srcs/.env
   ```
   Set configuration values:
   ```ini
   DOMAIN_NAME=cbahry.42.fr
   MYSQL_DATABASE=inception_db
   MYSQL_USER=inception_user
   WP_TITLE="Inception cbahry"
   WP_ADMIN_USER=cbahry_boss
   WP_ADMIN_EMAIL=cbahry_boss@student.42.fr
   WP_USER=reviewer
   WP_USER_EMAIL=reviewer@student.42.fr
   ```

### Secrets Configuration
Create the `secrets/` directory and required secret files (ignored by Git):
```bash
mkdir -p secrets

echo "mariadb_user_pass_42!" > secrets/db_password.txt
echo "mariadb_root_pass_42!" > secrets/db_root_password.txt

cat << 'EOF' > secrets/credentials.txt
WP_ADMIN_PASSWORD="wp_admin_secure_pass_42!"
WP_USER_PASSWORD="wp_user_regular_pass_42!"
EOF

chmod 600 secrets/*.txt
```

---

## 2. Building and Launching the Project

The build and runtime lifecycle is orchestrated via the root `Makefile` and `docker compose`:

```bash
# Build images and start all containers in detached mode:
make
# or
make up

# Stop and remove containers and network (preserving data):
make down

# Pause running containers:
make stop

# Resume stopped containers:
make start

# View container operational status:
make ps

# Inspect live aggregated logs:
make logs

# Full reset (removes containers, images, volumes, and host data):
make fclean

# Clean rebuild from zero:
make re
```

---

## 3. Managing Containers and Volumes

### Interactive Container Access
```bash
# Access NGINX container shell:
docker exec -it nginx sh

# Access WordPress container shell:
docker exec -it wordpress sh

# Access MariaDB container shell:
docker exec -it mariadb sh
```

### Database Management Commands
```bash
# Connect to MariaDB as application user:
docker exec -it mariadb mariadb -u inception_user -p"$(cat secrets/db_password.txt)" inception_db -e "SHOW TABLES;"

# Connect to MariaDB as root superuser:
docker exec -it mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)" -e "SHOW DATABASES;"
```

### WordPress Management Commands (WP-CLI)
```bash
# List users:
docker exec -it wordpress wp user list --allow-root --path=/var/www/html

# Verify core version and status:
docker exec -it wordpress wp core version --allow-root --path=/var/www/html

# Check configured database options:
docker exec -it wordpress wp option get siteurl --allow-root --path=/var/www/html
docker exec -it wordpress wp option get home --allow-root --path=/var/www/html
```

### Network & Volume Inspection
```bash
# Inspect the isolated bridge network:
docker network inspect inception

# Inspect named volume metadata:
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```

---

## 4. Storage Locations and Data Persistence

### Host Storage Locations
Persistent data is stored on the host filesystem under `/home/cbahry/data`:
- **Database Data:** `/home/cbahry/data/mariadb/` (mounted into MariaDB container at `/var/lib/mysql`).
- **Website Files:** `/home/cbahry/data/wordpress/` (mounted into WordPress and NGINX containers at `/var/www/html`).

### Persistence Mechanism
- **Docker Named Volumes with Local Bind:**
  In `srcs/docker-compose.yml`, volumes are defined using the `local` driver with `bind` options pointing to the host paths `/home/cbahry/data/mariadb` and `/home/cbahry/data/wordpress`.
- **Lifecycle:**
  - Running `make down` removes the container instances and networks, but leaves `/home/cbahry/data/` untouched.
  - On subsequent `make up`, MariaDB detects the existing `/var/lib/mysql/inception_db` directory and skips initialization; WordPress detects `/var/www/html/wp-config.php` and skips re-installation, preserving all content and user state.
  - Data is only purged when running `make fclean`, which explicitly removes host directories via `sudo rm -rf $(DATA_DIR)`.
