---
title: "Inception Master Map of Content (MOC)"
tags: [inception, 42, docker, linux, moc]
aliases: ["MOC", "Inception Index"]
created: 2026-11-05
type: architecture
---

# 🌌 Inception Master Map of Content (MOC)

> [!abstract] Central Nervous System
> Welcome to your personal **Inception Knowledge Vault**. Every architectural decision, kernel primitive, cryptographic flow, and defense drill is indexed here as an atomic, interconnected node.
> 
> *Target Learner:* `cbahry` | *Target Domain:* `cbahry.42.fr` | *Host Storage:* `/home/cbahry/data`

---

## 🗺️ Knowledge Graph Navigation

```
                       [[00 - Step -1 VM Setup & Distro Codex]]
                                      │
                     ┌────────────────┴────────────────┐
                     ▼                                 ▼
   [[01 - Kernel & Runtimes/Linux Namespaces and cgroups]]    [[04 - Security & Secrets/Docker Secrets vs Environment Variables]]
                     │                                 │
                     ▼                                 ▼
   [[01 - Kernel & Runtimes/The PID 1 Law]]          [[03 - Storage & Volumes/Named Volumes vs Bind Mounts]]
                     │                                 │
                     └────────────────┬────────────────┘
                                      ▼
                        [[05 - Services & Dockerfiles]]
                   ┌──────────────────┼──────────────────┐
                   ▼                  ▼                  ▼
     [[NGINX Reverse Proxy]]   [[WordPress & PHP-FPM]]   [[MariaDB Database]]
                   │                  │                  │
                   └──────────────────┼──────────────────┘
                                      ▼
             [[02 - Networking & Protocols/FastCGI Protocol and PHP-FPM]]
             [[02 - Networking & Protocols/TLS 1.2 and 1.3 Cryptography]]
             [[02 - Networking & Protocols/Docker Bridge Network and DNS]]
                                      │
                                      ▼
             [[06 - Evaluation Defense Drills/Defense Checklist and Live Coding]]
```

---

## 🗂️ Knowledge Domains

### 0. Foundation & Infrastructure
- [[00 - Step -1 VM Setup & Distro Codex]] — Arch vs NixOS vs Void, NAT Port Forwarding, and VM provisioning.

### 1. Kernel Primitives & Container Runtimes
- [[Linux Namespaces and cgroups]] — How the Linux kernel isolates processes without virtual hardware.
- [[The PID 1 Law and Foreground Daemons]] — Signal forwarding, zombie reaping, and the ban on `tail -f`.
- [[Virtual Machines vs Containers]] — Architectural, security, and performance comparison table.

### 2. Networking & Application Protocols
- [[Docker Bridge Network and DNS]] — `veth` pairs, bridge switches, and embedded DNS at `127.0.0.11`.
- [[TLS 1.2 and 1.3 Cryptography]] — Asymmetric handshakes, symmetric encryption, and self-signed certificates.
- [[FastCGI Protocol and PHP-FPM]] — Binary record framing between NGINX and PHP workers over TCP port 9000.

### 3. Storage Subsystems & Persistence
- [[Named Volumes vs Bind Mounts]] — Docker storage drivers, local bind options, and `/home/cbahry/data` mapping.

### 4. Security & Secrets Management
- [[Docker Secrets vs Environment Variables]] — `tmpfs` virtual filesystem isolation vs `/proc/$PID/environ` leaks.

### 5. Services & Custom Dockerfiles
- [[MariaDB Database Service]] — Idempotent initialization, network binding, and SQL privilege bootstrapping.
- [[WordPress and PHP-FPM Service]] — `wp-cli` automation, pool configuration, and the strict non-admin username rule.
- [[NGINX Reverse Proxy Gateway]] — TLS termination, port 443 single entrypoint, and FastCGI proxying.

### 6. Defense & Peer-Evaluation
- [[Defense Checklist and Live Coding]] — Rapid-fire theoretical questions, debugging commands, and live modification drills.

---

## 🏷️ Active Tags
#inception #docker #linux #kernel #networking #security #mariadb #wordpress #nginx #systemd #42
