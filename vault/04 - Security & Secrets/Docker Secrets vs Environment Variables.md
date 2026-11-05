---
title: "Docker Secrets vs Environment Variables"
tags: [security, docker, secrets, env, comparison]
aliases: ["Secrets vs Env", "Docker Secrets", "Credential Security"]
created: 2026-11-05
type: concept
---

# 🛡️ Docker Secrets vs. Environment Variables

> [!abstract] Subject Mandatory Requirement
> The subject strictly mandates a comparative analysis between **Docker Secrets** and **Environment Variables**.
> *"Any credentials, API keys, or passwords found in your Git repository (outside of properly configured secrets) will result in project failure."*

---

## 🔬 The Core Vulnerability of Environment Variables

Many developers pass database passwords using `environment: - MYSQL_PASSWORD=mysecret`. In a production environment, this is a severe security vulnerability for three reasons:

1. **Process Memory Exposure:** Environment variables are stored directly in the process memory and can be read by any local user with access to `/proc/<PID>/environ`.
2. **Metadata Inspection:** Anyone with access to the Docker socket can run `docker inspect <container_id>` or `docker compose config` and view the password in plaintext JSON output.
3. **Child Inheritance & Crash Logs:** Child subshells inherit environment variables automatically. If an application crashes, diagnostic tools, stack traces, and error logs often dump all active environment variables into public log aggregators.

---

## 💎 How Docker Secrets Solve This

```
Host Secrets Folder (gitignored)
  └── secrets/db_password.txt
             │
             │ Docker Compose mounts as tmpfs (RAM-only)
             ▼
Container Filesystem: /run/secrets/db_password
  ├── Permissions: 0400 or 0444 (Read-Only)
  ├── Storage: In-memory virtual filesystem (tmpfs)
  └── Never written to container's disk or image layers
```

- **Hidden from Inspect:** `docker inspect` shows only the secret metadata name, never the content.
- **No Disk Footprint:** Secrets are mounted on a `tmpfs` (in-memory filesystem). When the container stops, the RAM is wiped.
- **Granular Access Control:** File permissions can be restricted so only the specific application user (e.g. `mysql`) can read the secret file.

---

## 📊 Comprehensive Comparison Matrix

| Dimension | Environment Variables (`.env`) | Docker Secrets (`/run/secrets/*`) |
|---|---|---|
| **Storage Medium** | Process memory space & container JSON config. | In-memory `tmpfs` virtual filesystem. |
| **Exposure in `docker inspect`** | **LEAKED.** Plaintext printed in container inspect dump. | **PROTECTED.** Only the secret identifier is listed. |
| **Child Process Leakage** | Inherited by every spawned child process. | Only accessible if process opens and reads the file. |
| **Crash Log Dumping** | Frequently printed during stack traces / error dumps. | Never automatically dumped into logs. |
| **Git Safety** | Can easily be accidentally committed if inside Dockerfile/compose. | Managed via dedicated secret files ignored in `.gitignore`. |
| **Ideal Use Case** | Non-sensitive configurations (domain name, DB name, port). | High-value credentials (DB passwords, root passwords, SSL keys). |

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: How does a shell script safely read a password from a Docker Secret?
> <details>
> <summary>Click to reveal answer</summary>
> Using file read redirection or cat from the mounted tmpfs:
> <pre><code>DB_PASS=$(cat /run/secrets/db_password)</code></pre>
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
