**Network Architecture
Purpose**
The network architecture provides:

**Internet redundancy**
Load balancing
High availability
Network resilience


**Components
ISP Connections**

| ISP  | Role          |
| ---- | ------------- |
| WAN1 | Primary ISP   |
| WAN2 | Secondary ISP |


WAN1 uses a dedicated public IP while WAN2 obtains connectivity through DHCP.

**Interface Design**

| Router Interface | Name           | Function           |                                                                   
| ---------------- | -------------- | ------------------ |
| ether1           | WAN1           | Primary Internet   |                                                                                              |
| ether2           | WAN2           | Secondary Internet |                                                                                              |
| ether3           | Local_Network | Internal LAN       | 

**Traffic Flow
Outbound Traffic**

- Client initiates request.
- Connection receives PCC classification.
- Connection receives routing mark.
- Traffic exits assigned WAN.
- NAT translates traffic.

**High Availability**
When the primary gateway becomes unavailable:

Route check fails.

Traffic reroutes automatically.

Internet access continues through surviving link.

Service restores automatically when connectivity returns.
