---
title: "Docker Bridge Network and DNS"
tags: [networking, docker, dns, bridge, comparison]
aliases: ["Docker Network", "Bridge Network", "Docker Network vs Host Network"]
created: 2026-11-05
type: concept
---

# 🌐 Docker Bridge Network and DNS

> [!abstract] Subject Mandatory Requirement
> The subject strictly mandates a comparative analysis between **Docker Network** and **Host Network**, and explicitly forbids using `network: host` or `--link`.

---

## 🔬 Under the Hood: Virtual Ethernet (`veth`) Pairs & Bridge

When you define a custom network in `docker-compose.yml`:
```yaml
networks:
  inception:
    driver: bridge
```
Docker performs the following Linux kernel actions:
1. **Linux Bridge Creation:** Allocates a software bridge switch (e.g. `br-xxxxxx`) on the host.
2. **`veth` Pair Generation:** For every attached container, creates a pair of linked virtual ethernet cables. One peer is placed inside the container's network namespace as `eth0`; the other end (`vethYYYY`) is plugged into the bridge switch on the host.
3. **Internal Subnet & Gateway:** Assigns a private CIDR block (e.g. `172.19.0.0/16`) and sets the host bridge interface as default gateway (`172.19.0.1`).

---

## 🔎 Embedded Docker DNS Server (`127.0.0.11`)

In default bridge networks, containers can only reach each other by IP. But in **user-defined bridge networks**:
- Docker automatically runs an embedded DNS server inside each container at **`127.0.0.11`**.
- When NGINX looks up `wordpress:9000`, the resolver asks `127.0.0.11`.
- Docker DNS dynamically returns the current internal container IP (e.g. `172.19.0.3`).
- **Result:** You never need to hardcode or maintain volatile container IP addresses.

---

## ⚔️ Docker Network vs. Host Network

| Feature | Docker Bridge Network | Host Network (`network: host`) |
|---|---|---|
| **Network Namespace** | Dedicated isolated `net` namespace per container. Has its own IP, loopback, routing table. | Shares host's network namespace directly. No isolation whatsoever. |
| **Port Exposure** | Strict firewall. Ports are reachable externally **only** if explicitly published (`ports: 443:443`). | Every port opened by the process is open directly on the host interface. |
| **Port Conflicts** | Multiple containers can bind to port 80 internally without conflict. | Two containers cannot listen on the same port simultaneously. |
| **Service Discovery** | Built-in DNS resolver (`127.0.0.11`) resolves container names automatically. | No DNS resolution; containers must address each other via `localhost` or host IPs. |
| **Security Surface** | Minimum attack surface. Database and PHP-FPM are completely unreachable from outside. | High risk. A compromised container can sniff host interfaces and bypass host firewalls. |
| **Subject Rule** | **MANDATORY.** | **STRICTLY FORBIDDEN.** |

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: Why is `--link` forbidden by modern Docker standards and the 42 subject?
> <details>
> <summary>Click to reveal answer</summary>
> <code>--link</code> is a legacy Docker feature that statically injected environment variables and hardcoded <code>/etc/hosts</code> entries at boot time. It does not handle IP updates if containers restart. User-defined bridge networks replace this with dynamic, non-blocking internal DNS (<code>127.0.0.11</code>).
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
