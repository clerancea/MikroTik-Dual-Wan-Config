# Troubleshooting Guide

## Start Here — Narrow the Scope

Before diving into a specific section, check logs for anything obvious:

```
/log print where topics~"interface"
/log print where topics~"dhcp"
/log print where topics~"firewall"
```

Then determine the scope of the problem:
- **Total outage** (both WANs down) → check physical/interface status first.
- **Partial** (some sites/services fail, others work) → likely a routing-mark or PCC issue, not a link issue.
- **One WAN down, other working** → confirm this is expected failover behavior, not a bug — see Failover Issues below.

## No Internet Connectivity

```
/interface print          # confirm both WAN interfaces show "R" (running)
/ip address print         # confirm expected addresses are assigned
/ping 8.8.8.8 routing-table=to_WAN1
/ping 8.8.8.8 routing-table=to_WAN2
```

Pinging with `routing-table=` is deliberate — a plain `/ping 8.8.8.8` only tests whatever the main table's current default route is, which won't tell you if one specific WAN is down while the other is fine.

**Common causes:** physical link down, ISP outage, DHCP lease not renewed on WAN2, wrong gateway configured on a static WAN.

## NAT Issues

```
/ip firewall nat print
```

**Expected rules:**
```
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN1 comment="NAT for WAN1"
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN2 comment="NAT for WAN2"
```

**Symptom → cause:**
- LAN clients have no internet but the router itself can ping out → NAT rule missing or disabled for the active WAN.
- One WAN's clients work, the other's don't → NAT rule exists for only one `out-interface`.

## Load Balancing Issues (PCC)

```
/ip firewall mangle print
/ip firewall connection print where connection-mark=WAN1_conn
/ip firewall connection print where connection-mark=WAN2_conn
```

**Symptom → likely cause:**
- No connections show either mark at all → mangle rules aren't matching; check `in-interface` matches your actual LAN interface/bridge name, and check FastTrack isn't bypassing mangle prerouting for established connections (see `pcc-load-balancing.md`).
- All connections show only one mark → PCC classifier misconfigured (check the `2/0` vs `2/1` remainder split), or one WAN's route is down so failover is masking what looks like a load-balancing bug.
- Marks look correct but traffic still goes out the wrong WAN → check that routes exist for both `routing-mark=to_WAN1` and `to_WAN2` (see Step 3 in `pcc-load-balancing.md`) — a connection mark with no matching route silently falls through to the main table.

## Failover Issues

```
/ip route print detail
```

Check for each routing-mark's route:
- **Active status** — is the route currently active, or sitting inactive when it should be up?
- **Gateway reachability** — is the recursive/probe target for this route actually responding?
- **Distance values** — if both WAN default routes have the same distance, you get load balancing (ECMP) instead of failover; failover requires a distance difference or a recursive gateway check, not identical-distance routes.

**Symptom → likely cause:**
- Failover never triggers even when a WAN is down → probe target might itself be down (single point of failure in the health check) — confirm the design uses multiple probe targets per WAN, per `failover-design.md`.
- Failover triggers but doesn't recover when the WAN comes back → check recursive route re-activation, not just the physical interface state.

## DNS Not Resolving

```
/ip dns print
/resolve cloudflare.com
```

If LAN clients can't resolve names but the router itself can (`/resolve` succeeds), the issue is between client and router, not router and internet — check `/ip dhcp-server network print` for the correct `dns-server=` value. Full DNS design is in [`dns-configuration.md`](dns-configuration.md).
