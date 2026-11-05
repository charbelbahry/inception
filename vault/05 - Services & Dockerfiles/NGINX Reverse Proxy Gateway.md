---
title: "NGINX Reverse Proxy Gateway"
tags: [service, nginx, reverse-proxy, tls, gateway, dockerfile]
aliases: ["NGINX", "Gateway Service", "Web Entrypoint"]
created: 2026-11-05
type: architecture
---

# 🛡️ NGINX Reverse Proxy Gateway

> [!abstract] Architectural Profile
> - **Container Name:** `nginx`
> - **Base Image:** `debian:bullseye`
> - **Public Port:** `443` (The **ONLY** port published to the host)
> - **TLS Protocols:** `TLSv1.2` and `TLSv1.3` only
> - **Storage Mount:** `wordpress_data` -> `/var/www/wordpress` (for static asset serving)
> - **Entrypoint:** `nginx -g "daemon off;"`

---

## 🔬 Reverse Proxy & FastCGI Delegation

NGINX acts as a cryptographic shield and static asset accelerator. When an HTTPS request arrives:
1. **Static Files (.css, .js, .png):** NGINX reads directly from the shared volume `/var/www/wordpress` and responds in microseconds.
2. **Dynamic Files (.php):** NGINX forwards the request via FastCGI binary records over port 9000 to `wordpress`.

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name cbahry.42.fr;

    ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    root  /var/www/wordpress;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: What happens if someone sends an HTTP request on port 80?
> <details>
> <summary>Click to reveal answer</summary>
> The connection is immediately dropped / refused! Port 80 is not listened on by Nginx, nor is it exposed in <code>docker-compose.yml</code>. The subject strictly limits the entrypoint to port 443 with TLS only.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
