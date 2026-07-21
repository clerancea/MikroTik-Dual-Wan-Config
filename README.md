# MikroTik Dual WAN Load Balancing & Failover

## Overview

Overview
This repository documents the MikroTik dual-WAN deployment used to provide internet redundancy, failover, and load balancing. The solution utilizes two ISP connections:

WAN1 – Dedicated Public IP

WAN2 – DHCP Internet Connection

PCC Load Balancing

Automatic WAN Failover

Source NAT

Route Health Monitoring


The design ensures continuous internet connectivity and efficient utilization of available bandwidth.


## 📂 Repository Structure

```text
mikrotik-dual-wan-config/
│
├── README.md
│
├── docs/
│   ├── network-architecture.md
│   ├── pcc-load-balancing.md
│   ├── failover-design.md
│   ├── dns-configuration.md
│   ├── troubleshooting.md
│   └── backup-recovery.md
│
├── configs/
   └── mikrotik-dual-wan.rsc


**Key Features**
Connectivity

- Dual ISP support
- Dynamic failover
- Route monitoring
- High availability internet access

Performance

- PCC-based traffic distribution
- Reduced ISP congestion
- Improved bandwidth utilization

Resilience

- Automatic route failover
- Gateway health checks
- Rapid recovery after ISP restoration
