***WAN configs***
/interface ethernet set [find default-name=ether1] name=WAN1
/interface ethernet set [find default-name=ether2] name=WAN2
/interface ethernet set [find default-name=ether3] name=Local_Network

/ip dhcp-client add interface=WAN2 disabled=no

/ip address add address=<PUBLIC_IP>/30 interface=WAN1

/ip route add gateway=<PRIMARY_GATEWAY>

***Firewall NAT rules***
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN1 comment="NAT for WAN1"

/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN2 comment="NAT for WAN2"

***Mangle rules for Load balancing**
/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN1_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/0

/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN2_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/1

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN1 passthrough=yes connection-mark=WAN1_conn in-interface=Local_Network

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN2 passthrough=yes connection-mark=WAN2_conn in-interface=Local_Network

***Add static routes***
/ip route add dst-address=0.0.0.0/0 gateway=<WAN1_GATEWAY> distance=5 routing-mark=to_WAN1 check-gateway=ping

/ip route add dst-address=0.0.0.0/0 gateway=<WAN2_GATEWAY> distance=1 routing-mark=to_WAN2 check-gateway=ping
