# Inception - User & Administrator Documentation

This document explains in clear and simple terms how an end-user or system administrator can operate, manage, and verify the Inception multi-container infrastructure.

---

## 1. Services Provided by the Stack

The infrastructure provides a production-grade Content Management System (CMS) composed of three decoupled, containerized services:

| Service | Container Name | Role & Purpose | Port Exposure |
|---|---|---|---|
| **NGINX** | `nginx` | Secure TLS reverse proxy and static asset web server. It acts as the single cryptographic entrypoint into the application. | Port **443** (HTTPS) exposed to host. Plaintext HTTP (port 80) is closed. |
| **WordPress + PHP-FPM** | `wordpress` | Dynamic CMS application engine running PHP-FPM 8.3. It processes dynamic `.php` requests received from NGINX over FastCGI. | Port **9000** (Internal network only; not exposed to host). |
| **MariaDB** | `mariadb` | Relational SQL database server storing WordPress posts, pages, user accounts, and configuration data. | Port **3306** (Internal network only; not exposed to host). |

---

## 2. Starting and Stopping the Project

The entire infrastructure lifecycle is automated via the root `Makefile`:

### Start the Infrastructure
To prepare host data directories, build images (if needed), and launch all services in the background:
```bash
make
# or
make up
```

### Stop the Infrastructure (Preserving Data)
To stop and remove containers and the internal network while keeping all website data and database records safe on disk:
```bash
make down
```

### Pause and Resume Containers
- **Pause running containers:**
  ```bash
  make stop
  ```
- **Resume stopped containers:**
  ```bash
  make start
  ```
- **Restart all services:**
  ```bash
  make restart
  ```

---

## 3. Accessing the Website and Administration Panel

### Domain Setup
Ensure the target domain is mapped to your local IP address inside `/etc/hosts`:
```bash
echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
```

### Accessing the Public Website
Open your browser and navigate to:
```text
https://cbahry.42.fr
```

> **Note on Self-Signed Certificates:** Because this project uses a locally generated self-signed TLS certificate, your web browser will display a security warning (e.g. `NET::ERR_CERT_AUTHORITY_INVALID`). Click **Advanced** and select **Proceed to cbahry.42.fr (unsafe)** to view the site.

### Accessing the WordPress Administration Dashboard
Navigate to the WordPress login screen:
```text
https://cbahry.42.fr/wp-login.php
```

Log in using the Administrator credentials detailed in the next section.

---

## 4. Locating and Managing Credentials

All passwords and sensitive credentials are encrypted/isolated from Git and stored as individual plaintext files in the `secrets/` directory on the host:

| Account / Secret | File Location | Default Username | Description |
|---|---|---|---|
| **WordPress Administrator** | `secrets/wp_admin_password.txt` | `cbahry_boss` | Full administrative privileges to manage themes, plugins, and users. *(Username strictly excludes "admin").* |
| **WordPress Regular User** | `secrets/wp_user_password.txt` | `reviewer` | Author account used to publish blog posts and leave comments. |
| **MariaDB Database User** | `secrets/db_password.txt` | `inception_user` | Application user used by WordPress to read and write database tables. |
| **MariaDB Root User** | `secrets/db_root_password.txt` | `root` | Database superuser for administrative SQL operations. |

### To View or Update a Credential:
```bash
# Read a password:
cat secrets/wp_admin_password.txt

# Update a password (before initial make):
echo "MyNewStrongPassword123!" > secrets/wp_admin_password.txt
chmod 600 secrets/wp_admin_password.txt
```

---

## 5. Checking that Services are Running Correctly

You can perform health checks at any time using the following commands:

### 1. Check Container Operational Status
```bash
make status
```
All three services (`mariadb`, `wordpress`, `nginx`) should report a status of **`Up`**.

### 2. Check Port Security & Perimeter Isolation
Ensure only port 443 is published to the host machine:
```bash
sudo ss -tlpn | grep docker
```
The output must show **only port 443**. Ports 3306 and 9000 must **not** appear.

### 3. Verify Live HTTP/TLS Response
```bash
curl -vk https://cbahry.42.fr
```
The terminal should return an HTTP `200 OK` response along with the generated WordPress HTML markup.

### 4. Inspect Live Service Logs
To monitor live logs from all containers simultaneously:
```bash
make logs
```
*(Press `Ctrl + C` to exit log streaming).*
EOF
