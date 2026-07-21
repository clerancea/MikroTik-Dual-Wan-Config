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
