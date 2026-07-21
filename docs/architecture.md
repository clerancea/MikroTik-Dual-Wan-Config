# Network Architecture

## Purpose

This document describes the physical and logical layout of the dual-WAN network: interface roles, addressing, and how traffic flows through the router under normal conditions. For how traffic is split across the two WANs, see [`pcc-load-balancing.md`](pcc-load-balancing.md). For what happens when a link fails, see [`failover-design.md`](failover-design.md).

The design provides:
- Internet redundancy across two independent ISPs
- Load balancing of outbound traffic across both links
- Automatic failover with no manual intervention required

## Topology

```
                ┌────────────────────┐
   ISP 1 ───────┤ ether1 / WAN1      │
  (dedicated IP)│                    │
                │   MikroTik Router  │
   ISP 2 ───────┤ ether2 / WAN2      │
  (DHCP)        │                    │
                │ ether3 / Local_Network
                └──────────┬─────────┘
                           │
                       LAN Clients
```

> **Open question to resolve before publishing:** confirm whether `Local_Network` is a single interface (`ether3` only) or a bridge spanning multiple LAN ports (e.g. `ether3`–`ether5`). If it's a bridge, document the bridge name and member ports here explicitly — right now a reader can't tell which is the case.

## Components

### ISP Connections

| ISP | Role | Addressing |
|-----|------|------------|
| WAN1 | Primary | Dedicated public IP (static) |
| WAN2 | Secondary | DHCP-assigned |

### Interface Design

| Router Interface | Name | Function |
|---|---|---|
| ether1 | WAN1 | Primary internet uplink |
| ether2 | WAN2 | Secondary internet uplink |
| ether3 | Local_Network | Internal LAN |

## Addressing Scheme

*(Fill in your actual values — this section is the reason an architecture document exists, and it's currently missing.)*

| Segment | Subnet | Gateway | Notes |
|---|---|---|---|
| WAN1 | `[ e.g. 203.0.113.0/30 ]` | `[ WAN1 gateway ]` | Static, assigned by ISP1 |
| WAN2 | `[ DHCP-assigned ]` | `[ WAN2 gateway ]` | Dynamic, assigned by ISP2 |
| LAN | `[ e.g. 192.168.100.0/24 ]` | `[ router LAN IP ]` | Local_Network segment |
| DNS | `[ resolver IPs used ]` | — | Confirm whether the router forwards to ISP resolvers or public resolvers (1.1.1.1, 9.9.9.9, etc.) — see `dns-configuration.md` |

## Traffic Flow

### Outbound (LAN → Internet)

1. A LAN client initiates a new connection.
2. The connection is classified by PCC and assigned to WAN1 or WAN2 (see `pcc-load-balancing.md`).
3. A routing mark sends the connection's traffic into the matching WAN's routing table.
4. Traffic exits the assigned WAN interface.
5. Source NAT (masquerade) rewrites the LAN source address to the WAN's public address before the packet leaves the router.

### Inbound (return traffic)

Return traffic for an established connection is tracked by RouterOS's connection tracking and sent back out the same WAN it arrived on, regardless of current PCC state — this avoids asymmetric routing issues for long-lived sessions.

## High Availability

If a WAN's upstream connectivity fails, the router's route health checks detect the failure and traffic reroutes to the surviving WAN automatically; service is restored on the original WAN once it recovers. The detection mechanism, probe targets, and recovery behavior are documented in detail in [`failover-design.md`](failover-design.md) rather than repeated here.
