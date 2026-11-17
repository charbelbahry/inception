*This project has been created as part of the 42 curriculum by cbahry.*

# Inception - System Administration & Docker Infrastructure

## Description
This project consists of designing and deploying a secure, multi-container web infrastructure on a Linux Virtual Machine using **Docker Compose**. The entire application stack is composed of three decoupled services, each running inside its own dedicated container compiled from custom Dockerfiles based on Alpine Linux 3.23 (penultimate stable version):
- **NGINX (`nginx:inception`):** Public-facing reverse proxy and web server acting as a cryptographic TLS gateway on port 443 only (TLSv1.2 / TLSv1.3).
- **WordPress + PHP-FPM (`wordpress:inception`):** Dynamic application engine running PHP-FPM 8.4, processing requests over FastCGI on port 9000, serving files from `/var/www/html`.
- **MariaDB (`mariadb:inception`):** Relational database server persisting website data on port 3306, bootstrapped securely without exposing ports.

The containers communicate over an isolated, user-defined Docker bridge network (`inception`) without exposing sensitive internal database or FastCGI ports to the host machine. Persistent data is maintained via Docker named volumes backed by the host filesystem at `/home/cbahry/data`.

---

## Instructions

### Prerequisites
- Operating System: Linux Virtual Machine (Arch Linux, Debian, or Ubuntu)
- Container Runtime: Docker Engine (v24+) and Docker Compose (v2+)
- Build Tool: GNU Make
- Utilities: `curl`, `openssl`, `sudo`

### Installation & Execution
1. **Map the domain name locally:**
   The subject requires accessing the website via `${LOGIN}.42.fr`. Add the local domain resolution to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Configure Docker Secrets:**
   Create the required secret files inside the `secrets/` directory (these files are strictly ignored by Git via `.gitignore`):
   ```bash
   mkdir -p secrets

   # MariaDB database user password
   echo "mariadb_user_pass_42!" > secrets/db_password.txt

   # MariaDB database root password
   echo "mariadb_root_pass_42!" > secrets/db_root_password.txt

   # WordPress user credentials (sourced by wp_init.sh)
   cat << 'EOF' > secrets/credentials.txt
   WP_ADMIN_PASSWORD="wp_admin_secure_pass_42!"
   WP_USER_PASSWORD="wp_user_regular_pass_42!"
   EOF

   chmod 600 secrets/*.txt
   ```

3. **Configure Environment Variables:**
   Copy the example environment configuration to `srcs/.env` and adjust if needed:
   ```bash
   cp srcs/.env.example srcs/.env
   ```
   Fill in the required non-sensitive parameters (`DOMAIN_NAME=cbahry.42.fr`, `MYSQL_DATABASE=inception_db`, `MYSQL_USER=inception_user`, `WP_TITLE=Inception`, `WP_ADMIN_USER=cbahry_boss`, `WP_ADMIN_EMAIL=cbahry_boss@student.42.fr`, `WP_USER=reviewer`, `WP_USER_EMAIL=reviewer@student.42.fr`).

4. **Build and Launch via Makefile:**
   At the root of the repository, execute:
   ```bash
   make
   ```
   This command prepares the host data directories (`/home/cbahry/data/mariadb` and `/home/cbahry/data/wordpress`), builds the Docker images, and starts the container stack in detached mode.

5. **Access the Application:**
   Open a web browser and navigate to:
   - **Public Website:** `https://cbahry.42.fr` *(or `https://cbahry.42.fr:8443` if port 8443 is mapped in `docker-compose.yml`)*
   - **WordPress Admin Dashboard:** `https://cbahry.42.fr/wp-login.php`

---

## Resources & AI Usage

### References & Documentation
- [Official Docker Engine Documentation](https://docs.docker.com/engine/)
- [Docker Compose File Specification](https://docs.docker.com/compose/compose-file/)
- [NGINX Reverse Proxy & FastCGI Guide](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [MariaDB Server Knowledge Base & mysqld Options](https://mariadb.com/kb/en/mysqld-options/)
- [WP-CLI Automated Command Reference](https://developer.wordpress.org/cli/commands/)
- [OpenSSL Cryptographic Toolkit Manual](https://www.openssl.org/docs/)

### AI Usage Declaration
Artificial Intelligence was utilized during this project as an interactive pair-programming and pedagogical assistant for the following tasks:
- **Architectural Planning:** Designing the decoupled multi-service container graph, local driver volume mappings, and process dependency order.
- **Diagnostic & Debugging Assistance:** Analyzing runtime container logs to resolve PHP memory limits during WP-CLI extraction, fixing FastCGI routing and TLS parameters in NGINX, resolving Alpine Linux package dependencies (PHP 8.4), and resolving POSIX permission constraints on Docker host bind volumes.
- **Documentation & Educational Synthesis:** Formatting architectural comparisons, authoring user and developer guides, and preparing theoretical defense checklists aligned with the 42 evaluation scale.

---

## Project Description & Architectural Comparisons

### Project Design & Sources Structure
The project sources are structured strictly within the `srcs/` directory according to Chapter V of the subject:
```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── .gitkeep
│   ├── credentials.txt          (ignored by Git)
│   ├── db_password.txt          (ignored by Git)
│   └── db_root_password.txt     (ignored by Git)
└── srcs/
    ├── .env                     (ignored by Git)
    ├── .env.example
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb-server.cnf
        │   └── tools/
        │       └── mariadb_init.sh
        ├── nginx/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   └── conf/
        │       └── default.conf
        └── wordpress/
            ├── .dockerignore
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wp_init.sh
```

- `srcs/docker-compose.yml`: Declares service definitions (`mariadb`, `wordpress`, `nginx`), the user-defined bridge network (`inception`), named volumes backed by `/home/cbahry/data`, and Docker Secrets mounts.
- `srcs/.env`: Holds non-sensitive runtime parameters (domain name, database name, user names).
- `srcs/requirements/mariadb/`: Built from `alpine:3.23`. Uses `mariadb-server.cnf` to bind to `0.0.0.0` on port 3306. `mariadb_init.sh` bootstraps the database securely in single-user mode via `mariadbd --bootstrap` without exposing network ports, reading root and user passwords directly from `/run/secrets/`.
- `srcs/requirements/wordpress/`: Built from `alpine:3.23` with PHP 8.4 (`php84-fpm`). Configured via `www.conf` (listening on port 9000, `clear_env = no`). `wp_init.sh` mounts the volume at `/var/www/html`, reads `/run/secrets/credentials` and `/run/secrets/db_password`, downloads WordPress core, generates `wp-config.php`, provisions the administrator (`cbahry_boss` - strictly without `admin` in the name) and regular user (`reviewer`), and executes `php-fpm84 -F` as PID 1.
- `srcs/requirements/nginx/`: Built from `alpine:3.23`. Generates a self-signed X.509 TLS certificate during the build phase (`ARG DOMAIN_NAME`). Configured via `default.conf` (`/etc/nginx/http.d/default.conf`) to enforce TLS 1.2 and 1.3, route `.php` requests to `wordpress:9000` via FastCGI, and run directly as PID 1 (`ENTRYPOINT ["nginx", "-g", "daemon off;"]`).

---

### Comparative Analysis

#### 1. Virtual Machines vs. Docker Containers
- **Virtual Machines (VMs):** Operate through hardware virtualization managed by a hypervisor (Type-1 bare-metal or Type-2 hosted like VirtualBox). Each VM runs a complete, independent Guest Operating System with its own virtualized hardware, Linux kernel, systemd init system, device drivers, and dedicated RAM allocation. This provides strong hardware-level isolation at the expense of high CPU/RAM overhead, large disk images (gigabytes), and slow boot latency (tens of seconds).
- **Docker Containers:** Operate through operating system-level virtualization directly on the host Linux kernel. Containers isolate processes using **Linux Namespaces** (`pid`, `net`, `mnt`, `ipc`, `uts`, `user`) to restrict what a process can see, and **Control Groups (cgroups)** to meter and budget resource consumption (CPU, RAM, block I/O). Containers share the host kernel and consist only of application binaries and libraries, achieving sub-second boot times, minimal memory footprints (megabytes), and high density.

#### 2. Secrets vs. Environment Variables
- **Environment Variables (`.env`):** Passed into process memory space and stored in container configuration metadata. They are visible in plaintext to any user with Docker socket access via `docker inspect` or `/proc/<PID>/environ`. Furthermore, environment variables are automatically inherited by child processes and are frequently dumped in stack traces or crash logs, making them unsafe for sensitive credentials. They are intended solely for non-confidential configuration (e.g. `DOMAIN_NAME`, `MYSQL_DATABASE`).
- **Docker Secrets (`/run/secrets/`):** Implemented as in-memory virtual filesystems (`tmpfs`) mounted inside the container. Secrets are never written to disk image layers, are completely excluded from `docker inspect` JSON outputs, and can be restricted with POSIX file permissions (`0400`). When the container terminates, the memory pages holding the secret are wiped, preventing credential leaks.

#### 3. Docker Network vs. Host Network
- **Docker User-Defined Bridge Network:** Creates an isolated network namespace per container. Each container receives a dedicated virtual ethernet interface (`eth0`) paired with a host software bridge switch, an isolated routing table, and private IP (`172.x.x.x`). Built-in Docker DNS (`127.0.0.11`) enables automatic service discovery by container name (`mariadb:3306`, `wordpress:9000`). Only explicitly published ports (e.g., `443`) are reachable from outside, protecting internal database and application ports from host network exposure.
- **Host Network (`network: host`):** Removes network namespace isolation entirely. The container shares the host network stack, IP address, and port space directly. If a container process listens on port 8080, that port is immediately open on all host network interfaces. Multiple containers cannot bind to the same port simultaneously, container DNS is unavailable, and the security attack surface is significantly increased.

#### 4. Docker Volumes vs. Bind Mounts
- **Docker Named Volumes:** Fully managed through the Docker storage subsystem API (`docker volume ls`, `inspect`, `rm`). Named volumes feature automatic initial population: when an empty named volume is mounted into a container directory containing files, Docker automatically copies those files into the volume. They decouple storage lifecycle from host directory hierarchies and are portable across environments.
- **Host Bind Mounts:** Directly map an arbitrary host directory into a container folder. Bind mounts bypass Docker management, are dependent on host directory paths and permissions, and overwrite/hide any pre-existing files inside the container destination folder upon mount.
