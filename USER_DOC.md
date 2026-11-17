# Inception - User Documentation

This document explains how an end user or administrator can operate, manage, and verify the Inception multi-container infrastructure, adhering strictly to Chapter VII of the subject.

---

## 1. Services Provided by the Stack

The infrastructure provides three decoupled, containerized services:

| Service | Container | Role | Exposed Port |
|---|---|---|---|
| **NGINX** | `nginx` | Secure TLS reverse proxy (TLSv1.2 / TLSv1.3) serving static files from `/var/www/html` and routing dynamic PHP requests. | Port **443** (HTTPS) exposed to the host. |
| **WordPress + PHP-FPM** | `wordpress` | Dynamic CMS application engine running PHP-FPM 8.4 on `/var/www/html`. | Port **9000** (Internal network only). |
| **MariaDB** | `mariadb` | Relational SQL database storing WordPress tables, posts, and user accounts. | Port **3306** (Internal network only). |

---

## 2. Starting and Stopping the Project

The infrastructure lifecycle is controlled via the root `Makefile`:

- **Start the project:**
  ```bash
  make
  # or
  make up
  ```
- **Stop the project (preserving data):**
  ```bash
  make down
  ```
- **Pause running containers:**
  ```bash
  make stop
  ```
- **Resume stopped containers:**
  ```bash
  make start
  ```
- **View container operational status:**
  ```bash
  make ps
  ```
- **View logs:**
  ```bash
  make logs
  ```
- **Clean teardown (removes containers, images, volumes, and host data):**
  ```bash
  make fclean
  ```
- **Rebuild the project from zero:**
  ```bash
  make re
  ```

---

## 3. Accessing the Website and Administration Panel

### Domain Setup
Ensure the local domain points to your loopback IP address in `/etc/hosts`:
```bash
echo "127.0.0.1 cbahry.42.fr" | sudo tee -a /etc/hosts
```

### Public Website
Access the WordPress homepage:
```text
https://cbahry.42.fr
```
*(Bypass the self-signed certificate warning by clicking Advanced $\rightarrow$ Proceed to cbahry.42.fr)*.

### Administration Panel
Access the WordPress administrator dashboard:
```text
https://cbahry.42.fr/wp-login.php
```

---

## 4. Locating and Managing Credentials

Credentials are stored in files within the `secrets/` directory on the host:

| Secret File | Role | Description |
|---|---|---|
| `secrets/db_password.txt` | Database User | Password for MariaDB application user (`inception_user`). |
| `secrets/db_root_password.txt` | Database Root | Password for MariaDB administrative user (`root`). |
| `secrets/credentials.txt` | WordPress Users | Contains `WP_ADMIN_PASSWORD` and `WP_USER_PASSWORD`. |

### Account Credentials:
- **Administrator User:**
  - Username: `cbahry_boss` *(contains no "admin" or "administrator" substring)*
  - Password: Defined in `secrets/credentials.txt`
- **Regular User:**
  - Username: `reviewer`
  - Password: Defined in `secrets/credentials.txt`

### Modifying Credentials:
Update the respective secret file in `secrets/` before initial initialization:
```bash
echo "new_password" > secrets/db_password.txt
chmod 600 secrets/*.txt
```

---

## 5. Checking that Services are Running Correctly

Verify the health and isolation of the stack:

1. **Check Container Status:**
   ```bash
   make ps
   ```
   All containers (`mariadb`, `wordpress`, `nginx`) must display state `Up`.

2. **Verify Port Isolation:**
   ```bash
   sudo ss -tlpn | grep docker
   ```
   Ensure only port 443 is published to the host. Ports 3306 and 9000 must not be exposed.

3. **Verify Web Response:**
   ```bash
   curl -vk https://cbahry.42.fr
   ```
   Ensure an `HTTP/1.1 200 OK` or `HTTP/2 200 OK` response is returned.

4. **Inspect Container Logs:**
   ```bash
   make logs
   ```
