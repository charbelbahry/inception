---
title: "Named Volumes vs Bind Mounts"
tags: [storage, docker, volumes, bind-mounts, persistence]
aliases: ["Docker Volumes", "Bind Mounts", "Volumes vs Bind Mounts"]
created: 2026-11-05
type: concept
---

# 💾 Named Volumes vs. Bind Mounts

> [!abstract] Subject Mandatory Requirement
> The subject strictly mandates a comparative analysis between **Docker Volumes** and **Bind Mounts**.
> *"You must use Docker named volumes for these two persistent storages. Bind mounts are not allowed for these volumes. Both named volumes must store their data inside /home/login/data on the host machine."*

---

## 🔬 Architectural Comparison

```
┌──────────────────────────────────────────────┐     ┌──────────────────────────────────────────────┐
│             DOCKER NAMED VOLUME              │     │               HOST BIND MOUNT                │
├──────────────────────────────────────────────┤     ├──────────────────────────────────────────────┤
│ Container: /var/lib/mysql                    │     │ Container: /var/lib/mysql                    │
│      ▲                                       │     │      ▲                                       │
│      │ Mount                                 │     │      │ Raw pointer                           │
│ Docker Storage Engine Management             │     │ Arbitrary Host Path                          │
│      ▲                                       │     │ (e.g. /home/user/my_folder)                  │
│      │ Stored under Docker control           │     │                                              │
│ Host Storage (/var/lib/docker/volumes or opt)│     │ Host Storage                                 │
└──────────────────────────────────────────────┘     └──────────────────────────────────────────────┘
```

---

## 📊 Comparison Matrix

| Dimension | Docker Named Volumes | Host Bind Mounts |
|---|---|---|
| **Management** | Fully managed through Docker CLI (`docker volume ls`, `inspect`, `prune`). | Unmanaged by Docker. Just an arbitrary filesystem path on the host. |
| **Initial Population** | **Automatic!** If an empty named volume is mounted to a container directory containing files, Docker copies those image files into the volume automatically. | **Destructive/Overwriting.** A bind mount overlays the container directory, hiding all pre-existing files in the container image. |
| **Host Independence** | Highly portable. Decoupled from host OS filesystem layout. | Fragile. Hardcoded to specific host paths that must exist beforehand. |
| **Permissions** | Managed cleanly through storage driver options. | Frequently triggers host/container UID collision bugs. |
| **Subject Rule** | **MANDATORY.** | **FORBIDDEN** directly inside service definitions. |

---

## 🛠️ The Subject v5.3 Local Driver Solution

How do we satisfy both:
1. *"You must use Docker named volumes (bind mounts are not allowed)"*
2. *"Both named volumes must store their data inside /home/cbahry/data on the host machine"*

We declare a **Docker Named Volume backed by the `local` driver with `bind` options**:

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

### Why this satisfies 100% of rules:
- `docker volume ls` displays `mariadb_data` and `wordpress_data` as genuine Docker named volumes.
- Inside the service blocks, we mount them cleanly using named syntax (`mariadb_data:/var/lib/mysql`).
- Data persists permanently inside `/home/cbahry/data/...` across reboots and `docker compose down`.

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: What happens to your database data if you run `make down` (without -v)?
> <details>
> <summary>Click to reveal answer</summary>
> The containers are stopped and removed, but the named volume data remains 100% intact on the host inside <code>/home/cbahry/data/mariadb</code>. When you run <code>make up</code>, MariaDB attaches to the existing volume and reads the database without losing a single byte.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
