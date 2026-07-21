# DNS Configuration

## Overview

DNS is handled centrally by the router rather than by individual LAN clients querying external resolvers directly. This keeps DNS behavior consistent across both WAN links and means a WAN failover doesn't require any client-side reconfiguration.

## Upstream Resolvers

```
/ip dns set servers=1.1.1.1,8.8.8.8,9.9.9.9
```

The router queries these in order, falling over to the next if one doesn't respond — giving DNS-level redundancy independent of the WAN failover mechanism itself. Three independent providers (Cloudflare, Google, Quad9) means a single resolver outage doesn't cause resolution failures on its own.

## LAN Client DNS

```
/ip dhcp-server network set [find] dns-server=192.168.1.1
```

DHCP hands out the router's own LAN address as the DNS server. LAN clients query the router, and the router recursively resolves using the upstream list above. This is the reason WAN failover doesn't require touching client DNS settings — clients only ever talk to the router.

## DNS Traffic and WAN Failover

Because DNS queries originate from the router itself (not from a PCC-classified LAN connection), they are **not** subject to the PCC connection marking described in [`pcc-load-balancing.md`](pcc-load-balancing.md) — router-originated traffic uses the main routing table by default, not the `to_WAN1`/`to_WAN2` tables.

This has one important consequence worth documenting explicitly: if the main routing table's active default route is tied to whichever WAN is currently primary, a failure on that WAN needs to be reflected in the main table too, not just in the PCC routing tables — otherwise the router's own DNS queries could keep failing even after LAN traffic has correctly failed over. Confirm this behavior against the actual recursive-route setup in [`failover-design.md`](failover-design.md) rather than assuming it's automatic.

## Verification

```
/ip dns print
/ip dns cache print
/resolve cloudflare.com
```

Run `/resolve` against a hostname during a simulated WAN1 failure (see `failover-testing.md`, Scenario 1) to confirm resolution keeps working through the failover window, not just after it completes.
