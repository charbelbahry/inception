# Inception - Developer & System Administration Documentation

This document provides developer-oriented instructions for configuring, developing, debugging, and administering the Inception container stack from scratch.

---

## 1. Environment Setup from Scratch

### System Prerequisites
To run and develop this project, the host environment (Virtual Machine) requires:
- **Operating System:** Linux (Arch Linux, Debian 11/12, or Ubuntu 22.04+)
- **Container Engine:** Docker Engine v24.0+ and Docker Compose v2.0+
- **Toolchain:** GNU Make, OpenSSL, `curl`, `net-tools` (or `iproute2`), `git`

### Initial System Configuration
1. **Map the Local Domain:**
   Ensure `cbahry.42.fr` maps to the loopback interface inside `/etc/hosts`:
   ```bash
   echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Grant Non-Root Docker Access:**
   Add your development user to the `docker` group to avoid typing `sudo` for container commands:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **Initialize the Secrets Files:**
   Docker Compose expects secrets to be stored in `secrets/*.txt` (ignored by Git):
   ```bash
   mkdir -p secrets
   echo "mariadb_user_pass_42!" > secrets/db_password.txt
   echo "mariadb_root_pass_42!" > secrets/db_root_password.txt
   echo "wp_admin_secure_pass_42!" > secrets/wp_admin_password.txt
   echo "wp_user_regular_pass_42!" > secrets/wp_user_password.txt
   chmod 600 secrets/*.txt
   ```

4. **Initialize Environment Variables:**
   Create your local active `.env` file from the repository template:
   ```bash
   cp srcs/.env.example srcs/.env
   ```

---

## 2. Building and Launching with Makefile & Compose

The project lifecycle is fully orchestrated through the root `Makefile`:

```
make / make up       ──> Prepares data dirs + builds images + starts stack in background
make build           ──> Builds Docker images via compose without starting containers
make down            ──> Stops and removes containers and internal networks (data preserved)
make status          ──> Displays operational status of all services (docker compose ps)
make logs            ──> Streams real-time aggregated logs from all services
make clean           ──> Stops containers and prunes dangling Docker cache
make fclean          ──> Complete teardown: deletes containers, images, volumes, and host data
make re              ──> Runs fclean followed by make all (clean rebuild from zero)
```

### Direct Docker Compose Commands
If direct compose invocation is required during development:
```bash
# Build images explicitly without cache:
docker compose -f srcs/docker-compose.yml build --no-cache

# Start a specific service (e.g. MariaDB):
docker compose -f srcs/docker-compose.yml up -d mariadb

# Restart a single service:
docker compose -f srcs/docker-compose.yml restart nginx
```

---

## 3. Container & Volume Management Commands

### Interactive Shell Access
```bash
# Enter the NGINX gateway container:
docker exec -it nginx sh

# Enter the WordPress PHP-FPM container:
docker exec -it wordpress sh

# Enter the MariaDB database container:
docker exec -it mariadb sh
```

### Database Management via CLI
```bash
# Test MariaDB local connection and inspect tables:
docker exec -it mariadb mariadb -u inception_user -p'mariadb_user_pass_42!' -e "USE inception_db; SHOW TABLES;"

# Log in as root to run administrative queries:
docker exec -it mariadb mariadb -u root -p'mariadb_root_pass_42!' -e "SHOW DATABASES;"
```

### WordPress Administration via WP-CLI
```bash
# List all registered WordPress accounts:
docker exec -it wordpress wp user list --allow-root --path=/var/www/wordpress

# Create a test post programmatically:
docker exec -it wordpress wp post create \
    --post_title="Developer Test Post" \
    --post_content="Testing database persistence" \
    --post_status=publish \
    --allow-root --path=/var/www/wordpress

# Check WordPress core version and status:
docker exec -it wordpress wp core version --allow-root --path=/var/www/wordpress
```

### Inspecting Internal Network Plumbing
```bash
# Inspect the isolated bridge network:
docker network inspect inception

# View virtual ethernet interfaces and container IP allocations:
docker exec -it nginx ip addr
```

---

## 4. Data Storage & Persistence Architecture

The subject strictly mandates:
> *"You must use Docker named volumes for these two persistent storages. Bind mounts are not allowed for these volumes. Both named volumes must store their data inside /home/login/data on the host machine."*

### How Persistence is Engineered
In `srcs/docker-compose.yml`, persistence is declared using **Docker Named Volumes backed by the `local` driver with `bind` options**:

```yaml
volumes:
  mariadb_data:
    name: mariadb_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/cbahry/data/mariadb

  wordpress_data:
    name: wordpress_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/cbahry/data/wordpress
```

### Physical Storage Paths on the Host
Data persists permanently across container deletions in the following host directories:
- **MariaDB Database Data:** `/home/cbahry/data/mariadb/` (stores InnoDB tablespaces, `.ibd` files, and `inception_db/` schema files).
- **WordPress Site Files:** `/home/cbahry/data/wordpress/` (stores `wp-config.php`, core PHP scripts, themes, and uploaded media).

### Persistence Lifecycle
1. When `make down` is executed, the containers and virtual networks are deleted, but the contents of `/home/cbahry/data/` remain untouched.
2. When `make up` is subsequently executed:
   - `mariadb_init.sh` detects that `/var/lib/mysql/inception_db` already exists and skips re-initialization, preserving all tables.
   - `wp_init.sh` detects that `wp-config.php` already exists and skips re-downloading or re-installing WordPress.
3. Only `make fclean` will delete the volumes and purge the contents of `/home/cbahry/data/`.
EOF
