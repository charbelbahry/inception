---
title: "The PID 1 Law and Foreground Daemons"
tags: [kernel, docker, signals, pid1, daemons]
aliases: ["PID 1", "Foreground Daemons", "Zombie Reaping"]
created: 2026-11-05
type: concept
---

# 🛑 The PID 1 Law and Foreground Daemons

> [!danger] Zero-Tolerance Subject Rule
> *"A Docker container is not a virtual machine. Thus, it is not recommended to use any hacky patches based on 'tail -f' and similar methods when trying to run it... The following are a few prohibited hacky patches: tail -f, bash, sleep infinity, while true."*

---

## 🔬 The Sacred Duties of PID 1 in Linux

In standard POSIX systems, **PID 1** (`init` or `systemd`) has two non-negotiable responsibilities:

1. **Signal Forwarding:** When the OS sends a signal (e.g. `SIGTERM`, `SIGINT`), PID 1 must catch it and dispatch it cleanly to child worker processes.
2. **Zombie Reaping:** When a child process terminates, its entry remains in the kernel process table as a "zombie" (`<defunct>`) until its parent calls `wait()` or `waitpid()`. If the parent dies first, PID 1 adopts the orphan and reaps its exit status.

---

## 💥 The `tail -f` Disaster Explained

```
Scenario: service nginx start && tail -f /dev/null

Host Docker Engine (docker stop)
             │
             │ sends SIGTERM
             ▼
      [ PID 1: tail -f ]  <── Ignored! tail has no SIGTERM handler.
             │
             │ (Nginx worker is NOT notified)
             ▼
      [ NGINX Worker ]     <── Never shuts down gracefully!
             │
             ▼ 10 seconds later...
Host Docker Engine sends SIGKILL (kill -9)
             │
      💀 BRUTAL TERMINATION (Data corruption, socket leaks, 0 on evaluation)
```

---

## 🛡️ The Proper Galactic Implementation

We run all daemons in the **foreground** so they become PID 1 directly and handle signals natively:

| Service | Daemon Command | Foreground Flag |
|---|---|---|
| **NGINX** | `nginx` | `-g "daemon off;"` |
| **PHP-FPM** | `php-fpm7.4` | `-F` (force foreground) |
| **MariaDB** | `mysqld_safe` / `mariadbd` | `--console` (logs to stdout, non-forking) |

### The Shell `exec` Handoff
In your container entrypoint script (`init.sh`), the final line must use `exec`:
```bash
#!/bin/bash
# ... perform one-time setup ...

# Hand off PID 1 from the bash script process to the binary:
exec php-fpm7.4 -F
```
`exec` replaces the running shell process image with the daemon binary, ensuring the daemon inherits PID 1 and receives `SIGTERM` directly from Docker.

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: What happens if an entrypoint ends with `service nginx start` and no foreground process?
> <details>
> <summary>Click to reveal answer</summary>
> The background command spawns Nginx as a daemon and exits. The entrypoint script reaches EOF and terminates. Because PID 1 exits, the entire container stops immediately.
> </details>

> [!question] Q: How do you verify PID 1 inside a running container?
> <details>
> <summary>Click to reveal answer</summary>
> Run <code>docker exec -it &lt;container&gt; ps aux</code>. PID 1 should be the actual server process (e.g., <code>nginx: master process</code> or <code>php-fpm: master process</code>), never <code>tail</code>, <code>bash</code>, or <code>sleep</code>.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
