# Failover Testing

## Objective

Validate that internet access continues uninterrupted when either WAN link fails, and that normal PCC load balancing resumes cleanly once the failed link recovers.

## Test Scenario 1 — WAN1 Failure

**Procedure**
1. Disconnect WAN1 (unplug the cable, or disable the interface — test both ways separately, since they exercise different failure detection paths).
2. Monitor LAN client internet access continuously during the disconnect.
3. Check active routes: `/ip route print` — the `to_WAN1` routing-mark route should show as inactive.
4. Confirm existing and new LAN connections are using WAN2.

**Pass criteria**
- No more than one dropped request/ping during the transition.
- Failover completes within `[ X seconds — set your target ]` of the link going down.
- All new connections route via WAN2 for the remainder of the outage.

## Test Scenario 2 — WAN1 Recovery

**Procedure**
1. Reconnect WAN1.
2. Confirm the WAN1 gateway responds: `/ping <WAN1_GATEWAY>`.
3. Confirm the `to_WAN1` route becomes active again in `/ip route print`.
4. Confirm new connections begin distributing across both WAN1 and WAN2 again per PCC.

**Pass criteria**
- WAN1 route reactivates within `[ X seconds ]` of connectivity returning.
- Sessions that failed over to WAN2 during the outage are **not** forcibly reset — only new connections should redistribute.
- PCC 50/50 split resumes (verify with the connection-mark check below).

## Test Scenario 3 — Combined failover + rebalancing

This scenario is often skipped but is the one most likely to fail in production: it checks that failover and load balancing don't fight each other.

**Procedure**
1. Start a long-lived connection (e.g., a large file download) and confirm via `/ip firewall connection print` which WAN it's using.
2. Fail that connection's WAN mid-transfer.
3. Confirm the download either resumes over the other WAN or fails cleanly (depending on whether the app supports reconnection) — connections aren't silently re-marked to a different WAN mid-flight, which would break stateful sessions.
4. Restore the failed WAN and confirm the connection does not get disrupted a second time by the recovery.

## Verification commands

```
/ip route print
/interface print
/ip firewall connection print where connection-mark=WAN1_conn
/ip firewall connection print where connection-mark=WAN2_conn
/ping <WAN1_MONITOR_IP>
/ping <WAN2_MONITOR_IP>
```

## Notes

- Test both failure modes separately: physical link-down (cable unplugged) and upstream-only failure (link stays up, but the ISP itself is unreachable). Route health checks that only monitor link state will miss the second case — see `failover-design.md` for the recursive/multi-target probing that catches it.
- Re-run all three scenarios after any change to mangle rule order, routing tables, or firewall rules — failover behavior is easy to silently break with an unrelated rule change.
