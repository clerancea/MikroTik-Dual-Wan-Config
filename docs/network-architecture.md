**Network Overview
Objective**
Provide stable internet connectivity using two separate ISP circuits with load sharing and failover.

**text
                     Internet
                        |
          -----------------------------
          |                           |
       WAN1                       WAN2
  102.208.20.206/30         192.168.100.8/24
          |                           |
          +----- MikroTik Router -----+
                      |
               Bridge/LAN
             192.168.1.0/24
                      |
                User Devices

**WAN Configuration
WAN1**
| Parameter | Value       |
| --------- | ----------- |
| Type      | Static      |
| Role      | Primary ISP |

WAN1 uses a dedicated public IP with a dedicated gateway.

**WAN2**
| Parameter | Value         |
| --------- | ------------- |
| Type      | DHCP          |
| Role      | Secondary ISP |

WAN2 automatically receives addressing information from the ISP.

**LAN Segment**

| Interface      | Purpose       |  
| -------------- | ------------- | 
| Local_Network | Corporate LAN | 

**Design Goals**
Availability

- Continuous internet access
- ISP failure tolerance

Performance

- Traffic distribution
- Reduced bottlenecks

Scalability

- Additional WAN links can be incorporated(if hardware has the capability and capacity)
- VLAN segmentation can be added later
