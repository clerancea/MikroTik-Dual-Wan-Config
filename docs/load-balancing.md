**PCC Configuration**

WAN1 Connection Mark

/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN1_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/0


WAN2 Connection Mark

/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN2_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/1


**Routing Marks**
WAN1

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN1 passthrough=yes connection-mark=WAN1_conn in-interface=Local_Network

WAN2

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN2 passthrough=yes connection-mark=WAN2_conn in-interface=Local_Network



## Result

Traffic distribution:

- WAN1 ≈ 50%
- WAN2 ≈ 50%

---

# docs/failover-testing.md

# Failover Testing

## Objective

Validate uninterrupted internet access during ISP failures.

---

## Test Scenario 1 - WAN1 Failure

### Procedure

1. Disconnect WAN1.
2. Monitor internet access.
3. Verify active routes.
4. Confirm traffic uses WAN2.

### Expected Result

- Internet remains available.
- WAN2 becomes active path.

---

## Test Scenario 2 - WAN1 Recovery

### Procedure

1. Reconnect WAN1.
2. Verify gateway availability.
3. Confirm route recovery.
4. Confirm PCC balancing resumes.

### Expected Result

- Dual WAN functionality restored.

---

## Verification Commands

### View Routes

/ip route print


###View Interfaces

/interface print
