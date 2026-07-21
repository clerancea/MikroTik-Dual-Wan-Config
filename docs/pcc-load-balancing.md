**PCC Configuration**

```text
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
WAN1       WAN2





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

