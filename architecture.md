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

| Router Interface | Name           | Function           |                                                                                              |
| ---------------- | -------------- | ------------------ | -------------------------------------------------------------------------------------------- |
| ether1           | WAN1           | Primary Internet   |                                                                                              |
| ether2           | WAN2           | Secondary Internet |                                                                                              |
| ether3           | Local\_Network | Internal LAN       |  [\[MikroTik CONFIG \| OneNote\]](https://phope-my.sharepoint.com/personal/cadatuu_projecthope_org/_layouts/15/Doc.aspx?action=edit&mobileredirect=true&wdorigin=Sharepoint&sourcedoc=%7baa14171f-10dc-40f9-b87d-b865d892d50f%7d&wdsectionfileid=%7ba17b1058-15a9-4a30-8626-765ebce45f7a%7d&wdpartId=%7BE7521A4A-4A02-4EDC-89F0-2B3C669C3768%7D%7B1%7D), [\[Project Hope IT Main \| OneNote\]](https://phope-my.sharepoint.com/personal/cadatuu_projecthope_org/_layouts/15/Doc.aspx?action=edit&mobileredirect=true&wdorigin=Sharepoint&DefaultItemOpen=1&sourcedoc={aa14171f-10dc-40f9-b87d-b865d892d50f}&wd=target(/Project Hope IT Main.one/)) |

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










ISPRoleWAN1Primary ISPWAN2Secondary ISP
WAN1 uses a dedicated public IP while WAN2 obtains connectivity through DHCP.
