---
title: "Defense Checklist and Live Coding Drills"
tags: [defense, evaluation, 42, live-coding, testing]
aliases: ["Defense Playbook", "Evaluation Drill"]
created: 2026-11-05
type: drill
---

# 🎯 Defense Checklist and Live Coding Drills

> [!abstract] Purpose
> Step-by-step diagnostic commands and simulated live-coding requests that evaluators at 42 will test during your project defense.

---

## 📋 The Evaluator's Checklist & Terminal Commands

### 1. Verify Image Names & Local Builds
```bash
docker images
```
- **Check:** Are the images named `nginx`, `wordpress`, `mariadb`?
- **Check:** Are there any `:latest` tags? (Zero allowed!)
- **Check:** Were they pulled from DockerHub? (Only `debian:bullseye` base is allowed).

### 2. Verify Port Isolation
```bash
sudo netstat -tlpn | grep docker
# or
ss -tlpn | grep docker
```
- **Check:** The **only** port listening on the host must be `443`.
- **Trap:** If you see port `3306` or `9000` listening on `0.0.0.0` on the host, you fail immediately!

### 3. Verify TLS Protocol Strictness
```bash
# Must return 200 OK:
curl -vk --tlsv1.2 https://cbahry.42.fr
curl -vk --tlsv1.3 https://cbahry.42.fr

# Must FAIL with SSL handshake error:
curl -vk --tlsv1.1 https://cbahry.42.fr
curl -vk --tlsv1.0 https://cbahry.42.fr
```

### 4. Verify PID 1 (No Hacky Loops)
```bash
docker exec -it nginx ps aux
docker exec -it wordpress ps aux
docker exec -it mariadb ps aux
```
- **Check:** Is PID 1 the genuine service daemon?
- **Trap:** If PID 1 is `tail -f`, `sleep infinity`, or `bash`, it is an automatic 0!

### 5. Verify Crash Recovery
```bash
docker kill nginx
docker ps
```
- **Check:** Does the container automatically restart within 2 seconds? (Satisfies `restart: always`).

### 6. Verify Data Persistence
```bash
# 1. Log into WordPress at https://cbahry.42.fr/wp-login.php
# 2. Publish a new test post titled "Evaluation Persistence Test"
# 3. Stop and remove containers:
make down
# 4. Restart containers:
make up
# 5. Refresh browser:
# -> The post must still exist!
```

---

## 💻 Simulated Live Coding Defense Tests

Evaluators frequently ask for a minor live code modification to verify genuine authorship:

### Scenario A: "Add a Custom Header to NGINX Responses"
- **Task:** Modify NGINX so it sends a custom HTTP header `X-Inception-Eval: 42Paris`.
- **Solution:**
  1. Open `srcs/requirements/nginx/conf/nginx.conf`.
  2. Inside the `server { ... }` block, add:
     ```nginx
     add_header X-Inception-Eval "42Paris";
     ```
  3. Reload NGINX without downtime:
     ```bash
     docker compose -f srcs/docker-compose.yml exec nginx nginx -s reload
     ```
  4. Verify:
     ```bash
     curl -I -k https://cbahry.42.fr | grep X-Inception-Eval
     ```

### Scenario B: "Create a Third WordPress User"
- **Task:** Add an additional user via WP-CLI inside the container.
- **Solution:**
  ```bash
  docker compose -f srcs/docker-compose.yml exec wordpress wp user create \
      evaluator eval@42.fr --role=author --user_pass="evalpass123" --allow-root --path=/var/www/wordpress
  ```

---
*Back to: [[00 - Inception Master MOC]]*
