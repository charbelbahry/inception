---
title: "FastCGI Protocol and PHP-FPM"
tags: [networking, protocols, fastcgi, nginx, wordpress, php]
aliases: ["FastCGI", "PHP-FPM", "FastCGI Protocol"]
created: 2026-11-05
type: concept
---

# ⚡ FastCGI Protocol and PHP-FPM

> [!abstract] Mental Anchor
> NGINX is an elite, high-concurrency event-driven web server built in C. It is exceptionally fast at serving static assets (HTML, CSS, images) and terminating TLS, but **NGINX cannot execute PHP code**.
> 
> **PHP-FPM** (FastCGI Process Manager) is an application server that manages worker pools to interpret PHP code. **FastCGI** is the binary wire protocol connecting them.

---

## 🔬 Evolution: CGI vs FastCGI

### 1. Classic CGI (The Slow Predecessor)
In the 1990s, the Common Gateway Interface (CGI) spawned a new OS process (`fork()` + `exec()`) for *every single incoming HTTP request*. Spawning a process, initializing PHP's runtime, executing the script, and tearing down the process killed server CPU and RAM under load.

### 2. FastCGI (Persistent Worker Pools)
FastCGI solved this by keeping a pool of persistent PHP worker processes alive in memory. FastCGI communicates via a binary record-framed protocol over a persistent UNIX socket or TCP socket (`wordpress:9000`).

---

## 🔄 The FastCGI Flow in Inception

```mermaid
sequenceDiagram
    autonumber
    Client as Browser
    participant Nginx as NGINX (:443)
    participant FPM as PHP-FPM (:9000)
    participant DB as MariaDB (:3306)

    Client->>Nginx: GET /index.php (HTTPS)
    Note over Nginx: Matches location ~ \.php$
    Nginx->>FPM: FastCGI Record (FCGI_BEGIN_REQUEST)
    Nginx->>FPM: FastCGI Params (SCRIPT_FILENAME, REQUEST_URI)
    Note over FPM: Worker parses index.php
    FPM->>DB: SQL Query (Fetch blog posts)
    DB-->>FPM: SQL Rows
    Note over FPM: Renders HTML markup
    FPM-->>Nginx: FastCGI Record (FCGI_STDOUT with rendered HTML)
    FPM-->>Nginx: FastCGI Record (FCGI_END_REQUEST)
    Nginx-->>Client: HTTP 200 OK (TLS Encrypted Response)
```

---

## 🛠️ Key NGINX FastCGI Directives

```nginx
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

- `fastcgi_pass wordpress:9000;`: Directs NGINX to stream the request over TCP to the container named `wordpress` on port `9000`.
- `SCRIPT_FILENAME`: Crucial parameter telling PHP-FPM the exact filesystem path inside *its* container where the PHP script resides.

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: Why do NGINX and WordPress both need access to the WordPress volume?
> <details>
> <summary>Click to reveal answer</summary>
> NGINX needs to serve static assets (images, CSS, JavaScript) directly from disk without burdening PHP-FPM. PHP-FPM needs access to read and execute the underlying <code>.php</code> scripts.
> </details>

> [!question] Q: What file in PHP-FPM controls whether it listens on a UNIX socket or port 9000?
> <details>
> <summary>Click to reveal answer</summary>
> <code>/etc/php/7.4/fpm/pool.d/www.conf</code>. We modify <code>listen = /run/php/php7.4-fpm.sock</code> to <code>listen = 0.0.0.0:9000</code>.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
