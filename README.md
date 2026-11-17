*This project has been created as part of the 42 curriculum by cbahry.*

# Inception - System Administration & Docker Infrastructure

## Description
This project consists of designing and deploying a secure, multi-container web infrastructure on a Linux Virtual Machine using **Docker Compose**. The entire application stack is composed of three decoupled services, each running inside its own dedicated container compiled from custom Dockerfiles based on Alpine Linux 3.23 (penultimate stable version):
- **NGINX:** Public-facing web server acting as a cryptographic TLS gateway on port 443 only.
- **WordPress + PHP-FPM:** Application engine executing dynamic PHP scripts over FastCGI on port 9000.
- **MariaDB:** Relational database server persisting website data on port 3306.

The containers are interconnected across an isolated, user-defined Docker bridge network without exposing sensitive internal ports to the host machine. Persistent data is maintained via Docker named volumes backed by the host filesystem (`/home/cbahry/data`).

---

## Instructions

### Prerequisites
- Operating System: Linux Virtual Machine (Arch Linux, Debian, or Ubuntu)
- Container Runtime: Docker Engine (v24+) and Docker Compose (v2+)
- Build Tool: GNU Make
- Utilities: `curl`, `openssl`

### Installation & Execution
1. **Map the domain name locally:**
   The subject requires accessing the website via `${LOGIN}.42.fr`. Add the local domain resolution to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Configure Secrets:**
   Create the required password files in the `secrets/` directory (these files are strictly ignored by Git):
   ```bash
   echo "mariadb_user_pass_42!" > secrets/db_password.txt
   echo "mariadb_root_pass_42!" > secrets/db_root_password.txt
   echo "wp_admin_secure_pass_42!" > secrets/wp_admin_password.txt
   echo "wp_user_regular_pass_42!" > secrets/wp_user_password.txt
   chmod 600 secrets/*.txt
   ```

3. **Configure Environment Variables:**
   Copy the example environment configuration to `.env`:
   ```bash
   cp srcs/.env.example srcs/.env
   ```

4. **Build and Launch via Makefile:**
   At the root of the repository, execute:
   ```bash
   make
   ```
   This command prepares the host data directories (`/home/cbahry/data/mariadb` and `/home/cbahry/data/wordpress`), compiles all Docker images, and starts the containers in detached mode.

5. **Access the Application:**
   Open a web browser and navigate to:
   - Public Website: `https://cbahry.42.fr`
   - WordPress Admin Dashboard: `https://cbahry.42.fr/wp-login.php`

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
- **Diagnostic & Debugging Assistance:** Analyzing runtime container logs to resolve PHP Zend Engine memory limits during WP-CLI extraction, fixing missing paths in NGINX configuration, and addressing POSIX permission constraints with container UID mappings.
- **Documentation & Educational Synthesis:** Formatting architectural comparisons, authoring user and developer guides, and preparing theoretical defense checklists aligned with the 42 evaluation scale.

---

## Project Description & Architectural Comparisons

### Project Design & Sources Structure
The project sources are structured strictly within the `srcs/` directory according to Chapter V of the subject:
- `srcs/docker-compose.yml`: Declares service definitions, the user-defined bridge network (`inception`), named volumes, and Docker Secrets mounts.
- `srcs/.env`: Holds non-sensitive runtime parameters (domain name, database name, user names).
- `srcs/requirements/mariadb/`: Contains the MariaDB `Dockerfile`, custom `mariadb-server.cnf` (binding to `0.0.0.0`), and `mariadb_init.sh` (which bootstraps the database in-memory via `--bootstrap` without exposing network ports).
- `srcs/requirements/wordpress/`: Contains the WordPress `Dockerfile`, `www.conf` (binding PHP-FPM to port 9000), and `wp_init.sh` (which automates WordPress core installation via WP-CLI and provisions the two mandatory users).
- `srcs/requirements/nginx/`: Contains the NGINX `Dockerfile`, `nginx.conf` (enforcing TLS 1.2/1.3 and FastCGI proxying), and `nginx_init.sh` (generating self-signed X.509 certificates and executing NGINX in the foreground as PID 1).

---

### Comparative Analysis

#### 1. Virtual Machines vs. Docker Containers
- **Virtual Machines (VMs):** Operate through hardware virtualization managed by a hypervisor (Type-1 bare-metal or Type-2 hosted). Each VM runs an entire, independent Guest Operating System with its own Linux kernel, systemd init system, device drivers, and dedicated virtual memory allocation. This architecture provides strong hardware-level isolation at the cost of high CPU/RAM overhead, large disk images (gigabytes), and slow boot latency (tens of seconds).
- **Docker Containers:** Operate through operating system-level virtualization directly on the host Linux kernel. Containers isolate processes using **Linux Namespaces** (`pid`, `net`, `mnt`, `ipc`, `uts`, `user`) to restrict what a process can see, and **Control Groups (cgroups)** to meter and budget resource consumption (CPU, RAM, block I/O). Containers share the host kernel and consist only of application binaries and libraries, achieving sub-second boot times, minimal memory footprints (megabytes), and high density.

#### 2. Secrets vs. Environment Variables
- **Environment Variables (`.env`):** Passed into process memory space and stored in container configuration metadata. They are visible in plaintext to any user with Docker socket access via `docker inspect` or `/proc/<PID>/environ`. Furthermore, environment variables are automatically inherited by child processes and are frequently dumped in stack traces or crash logs, making them unsafe for sensitive credentials. They are intended solely for non-confidential configuration (e.g. `DOMAIN_NAME`, `MYSQL_DATABASE`).
- **Docker Secrets (`/run/secrets/`):** Implemented as in-memory virtual filesystems (`tmpfs`) mounted inside the container. Secrets are never written to disk image layers, are completely excluded from `docker inspect` JSON outputs, and can be restricted with POSIX file permissions (`0400`). When the container terminates, the memory pages holding the secret are wiped, preventing credential leaks.

#### 3. Docker Network vs. Host Network
- **Docker User-Defined Bridge Network:** Creates an isolated network namespace per container. Each container receives a dedicated virtual ethernet interface (`eth0`) paired with a host software bridge switch, an isolated routing table, and private IP (`172.18.x.x`). Built-in Docker DNS (`127.0.0.11`) enables automatic service discovery by container name (`mariadb:3306`, `wordpress:9000`). Only explicitly published ports (`443:443`) are reachable from outside, protecting internal database and application ports from host network exposure.
- **Host Network (`network: host`):** Removes network namespace isolation entirely. The container shares the host network stack, IP address, and port space directly. If a container process listens on port 8080, that port is immediately open on all host network interfaces. Multiple containers cannot bind to the same port simultaneously, container DNS is unavailable, and the security attack surface is significantly increased.

#### 4. Docker Volumes vs. Bind Mounts
- **Docker Named Volumes:** Fully managed through the Docker storage subsystem API (`docker volume ls`, `inspect`, `rm`). Named volumes feature automatic initial population: when an empty named volume is mounted into a container directory containing files, Docker automatically copies those files into the volume. They decouple storage lifecycle from host directory hierarchies and are portable across environments.
- **Host Bind Mounts:** Directly map an arbitrary host directory into a container folder. Bind mounts bypass Docker management, are dependent on host directory paths and permissions, and overwrite/hide any pre-existing files inside the container destination folder upon mount.
EOF
