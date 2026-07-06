# MikroTik Dual WAN Load Balancing & Failover

## Overview

Overview
This repository documents the MikroTik dual-WAN deployment used to provide internet redundancy, failover, and load balancing for the Project HOPE Ghana office network. The solution utilizes two ISP connections:

WAN1 – Dedicated Public IP

WAN2 – DHCP Internet Connection

PCC Load Balancing

Automatic WAN Failover

Source NAT

Route Health Monitoring


The design ensures continuous internet connectivity and efficient utilization of available bandwidth.


**Repository Structure**

<img width="177" height="181" alt="image" src="https://github.com/user-attachments/assets/ba0f16e8-97eb-478d-bed6-df8305a59b66" />



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
