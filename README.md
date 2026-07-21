# MikroTik Dual-WAN Load Balancing & Failover

A documented, reusable configuration framework for deploying dual-ISP redundancy on MikroTik RouterOS — covering PCC-based load balancing, automatic failover, source NAT, and route health monitoring.

![RouterOS](https://img.shields.io/badge/RouterOS-7.x-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-active-brightgreen)

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Results](#results)
- [Roadmap](#roadmap)
- [License](#license)

## Overview

This repository documents a dual-WAN deployment built to provide internet redundancy, automatic failover, and load balancing for a multi-site setup. The design uses two independent ISP connections:

| Link | Type | Role |
|------|------|------|
| WAN1 | Dedicated public IP | Primary |
| WAN2 | DHCP internet connection | Secondary / load-shared |

'''

New Connection
      |
      V
PCC Classifier
      |
 -------------
 |           |
WAN1_conn  WAN2_conn
 |           |
 V           V
to_WAN1   to_WAN2
 |           |
WAN1      WAN2


It combines **Per Connection Classifier (PCC)** load balancing with **policy-based routing** and **recursive route health checks**, so the network keeps working through single-ISP outages without manual intervention.

## Architecture

```
                ┌────────────────────┐
   ISP 1 ───────┤   WAN1 (dedicated) │
                │                    │
   LAN Clients ─┤   MikroTik Router  │
                │                    │
   ISP 2 ───────┤   WAN2 (DHCP)      │
                └────────────────────┘

  Prerouting → Mangle (PCC mark) → Routing table (per WAN) →
  Postrouting (masquerade) → Route health check → Failover
```

See [`docs/network-architecture.md`](docs/network-architecture.md) for the full breakdown.

## Key Features

**Connectivity**
- Dual ISP support with independent failure domains
- Dynamic failover on link or upstream-reachability loss
- Multi-target route health monitoring (avoids single-probe false positives)

**Performance**
- PCC-based per-connection traffic distribution across both WANs
- Reduced congestion on either single ISP link
- Improved aggregate bandwidth utilization

**Resilience**
- Automatic route failover with recursive gateway checks
- Rapid recovery once a failed ISP link is restored
- Backup and recovery procedure for router configuration

## Repository Structure

```
MikroTik-Dual-Wan-Config/
├── README.md
├── docs/
│   ├── network-architecture.md   — topology, interfaces, addressing
│   ├── pcc-load-balancing.md     — PCC mangle rules and hashing method
│   ├── failover-design.md        — recursive routing and health checks
│   ├── dns-configuration.md      — DNS handling across both WANs
│   ├── troubleshooting.md        — common issues and diagnostic steps
│   └── backup-recovery.md        — config backup and restore procedure
└── Config/
    └── mikrotik-dual-wan.rsc     — reference RouterOS script
```

## Prerequisites

- MikroTik router running **RouterOS 7.x** (interface/routing-mark syntax differs on v6 — not covered here)
- Two independent internet connections
- Winbox or SSH access to the router
- A local or out-of-band management connection — **do not apply `mikrotik-dual-wan.rsc` over a remote WAN/VPN session**, since it resets interfaces and routing

## Getting Started

1. Review [`docs/network-architecture.md`](docs/network-architecture.md) and adjust interface names/addressing to match your hardware.
2. Back up your existing configuration first — see [`docs/backup-recovery.md`](docs/backup-recovery.md).
3. Transfer `configs/mikrotik-dual-wan.rsc` to the router via Winbox (drag-and-drop into Files) or SCP/SFTP.
4. Apply the script from a local console session, not remotely.
5. Validate load balancing and failover using the checks in [`docs/troubleshooting.md`](docs/troubleshooting.md).

## Documentation

| Doc | Covers |
|---|---|
| [network-architecture.md](docs/network-architecture.md) | Topology, interface roles, addressing scheme |
| [pcc-load-balancing.md](docs/pcc-load-balancing.md) | Mangle rules, PCC hashing, per-connection distribution |
| [failover-design.md](docs/failover-design.md) | Recursive routes, gateway health checks, failover/recovery behavior |
| [dns-configuration.md](docs/dns-configuration.md) | DNS resolution across both WAN paths |
| [troubleshooting.md](docs/troubleshooting.md) | Diagnostic commands and common failure modes |
| [backup-recovery.md](docs/backup-recovery.md) | Configuration backup and restore procedure |



## License

Released under the [MIT License](LICENSE).
