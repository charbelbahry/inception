---
title: "Virtual Machines vs Docker Containers"
tags: [architecture, vm, docker, virtualization, comparison]
aliases: ["VM vs Containers", "Virtualization Comparison"]
created: 2026-11-05
type: concept
---

# ⚔️ Virtual Machines vs. Docker Containers

> [!abstract] Subject Mandatory Requirement
> The Inception subject explicitly mandates a comparative analysis between **Virtual Machines** and **Docker Containers** in your documentation and evaluation defense.

---

## 🏛️ Architectural Comparison

```
┌─────────────────────────────────────────┐      ┌─────────────────────────────────────────┐
│           VIRTUAL MACHINE (VM)          │      │            DOCKER CONTAINER             │
├─────────────────────────────────────────┤      ├─────────────────────────────────────────┤
│    App A      │    App B      │  App C  │      │    App A      │    App B      │  App C  │
├───────────────┼───────────────┼─────────┤      ├───────────────┼───────────────┼─────────┤
│  Libs & Bins  │  Libs & Bins  │Libs/Bins│      │  Libs & Bins  │  Libs & Bins  │Libs/Bins│
├───────────────┼───────────────┼─────────┤      ├─────────────────────────────────────────┤
│   Guest OS    │   Guest OS    │Guest OS │      │              Container Engine           │
│ (Full Kernel) │ (Full Kernel) │ (Kernel)│      │            (Docker / containerd)        │
├───────────────┴───────────────┴─────────┤      ├─────────────────────────────────────────┤
│          Hypervisor (Type 1/2)          │      │            Host OS Kernel               │
│          (KVM, VirtualBox, ESXi)        │      │          (Namespaces + cgroups)         │
├─────────────────────────────────────────┤      ├─────────────────────────────────────────┤
│            Physical Hardware            │      │            Physical Hardware            │
└─────────────────────────────────────────┘      └─────────────────────────────────────────┘
```

---

## 📊 Comprehensive Comparison Matrix

| Dimension | Virtual Machine (VM) | Docker Container |
|---|---|---|
| **Virtualization Level** | **Hardware virtualization**. Emulates virtual hardware (CPU, RAM, NIC, BIOS/UEFI) via a hypervisor. | **Operating System virtualization**. Shares the host kernel; isolates processes using namespaces and cgroups. |
| **Operating System** | Each VM runs a complete, independent **Guest OS** with its own kernel, system services, and drivers. | Containers do **not** have their own kernel. They contain only userspace binaries and libraries. |
| **Startup Latency** | **Slow** (tens of seconds to minutes). Must boot BIOS, load kernel, initialize init system (`systemd`). | **Instantaneous** (sub-second / milliseconds). Just starting a new host process. |
| **Resource Overhead** | **Heavy**. Requires gigabytes of pre-allocated RAM and storage per VM just to maintain the guest OS. | **Negligible**. Consumes only the exact memory and CPU required by the application process. |
| **Filesystem / Storage** | Monolithic virtual disk images (`.vdi`, `.qcow2`, `.vmdk`), typically 10–50 GB each. | Layered storage via **OverlayFS**. Read-only layers are shared across containers; copy-on-write upper layer. |
| **Isolation & Security** | **Hardware-grade isolation**. Breaking out of a VM requires exploiting the hypervisor itself. | **Process-grade isolation**. A kernel exploit in a container compromises the entire shared host kernel. |
| **Portability** | Bulky image transfers (gigabytes) tied to hypervisor formats. | Highly portable standard Open Container Initiative (OCI) images. |

---

## ⚡ Active Recall & Defense Drill

> [!question] Q: If a container runs Debian Bullseye on top of an Arch Linux host, which kernel is actually running?
> <details>
> <summary>Click to reveal answer</summary>
> The <b>Arch Linux host kernel</b>! The Debian container only provides Debian's userspace rootfs (binaries like <code>/bin/bash</code>, glibc libraries, configuration files). When any binary in the container makes a system call, it is handled directly by the host Arch Linux kernel.
> </details>

---
*Back to: [[00 - Inception Master MOC]]*
