***WAN configs***
/interface ethernet set [find default-name=ether1] name=WAN1
/interface ethernet set [find default-name=ether2] name=WAN2
/interface ethernet set [find default-name=ether3] name=Local_Network

/ip dhcp-client add interface=WAN2 disabled=no

/ip address add address=<PUBLIC_IP>/30 interface=WAN1

/ip route add gateway=<PRIMARY_GATEWAY>

***Firewall NAT rules (scope to LAN)***
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN1 comment="NAT for WAN1"

/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN2 comment="NAT for WAN2"

***Mangle rules for PCC load-balancing***
# PCC example using both-addresses-and-ports:2/x to split connections between 2 WANs.
# Adjust per-connection-classifier to your needs (per-dst-address, both-addresses, ports, etc)

/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN1_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/0

/ip firewall mangle add chain=prerouting action=mark-connection new-connection-mark=WAN2_conn passthrough=yes dst-address-type=!local connection-mark=no-mark in-interface=Local_Network per-connection-classifier=src-address:2/1

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN1 passthrough=yes connection-mark=WAN1_conn in-interface=Local_Network

/ip firewall mangle add chain=prerouting action=mark-routing new-routing-mark=to_WAN2 passthrough=yes connection-mark=WAN2_conn in-interface=Local_Network

***Static routes / routing table entries***
# Replace <WAN1_GATEWAY> and <WAN2_GATEWAY> with the correct next-hop IPs
/ip route add dst-address=0.0.0.0/0 gateway=<WAN1_GATEWAY> distance=5 routing-mark=to_WAN1 check-gateway=ping

/ip route add dst-address=0.0.0.0/0 gateway=<WAN2_GATEWAY> distance=1 routing-mark=to_WAN2 check-gateway=ping

***Basic firewall filters (minimum)***
/ip firewall filter add chain=input connection-state=established,related action=accept comment="allow established/related"
/ip firewall filter add chain=input connection-state=invalid action=drop comment="drop invalid"
/ip firewall filter add chain=forward connection-state=established,related action=accept comment="allow established/related forward"
/ip firewall filter add chain=forward in-interface=Local_Network action=accept comment="allow LAN to forward (adjust as needed)"


***Gateway monitoring and automatic route enable/disable (netwatch)***
# Netwatch will disable/enable routes when a WAN loses reachability to a public IP.
# Choose reliable probe hosts (e.g., provider DNS, 8.8.8.8, 1.1.1.1). Tweak intervals/timeouts.

/tool netwatch add host=8.8.8.8 interval=00:00:15 timeout=2 up-script="/ip route enable [find comment=\"to_WAN1\"]" \ down-script="/ip route disable [find comment=\"to_WAN1\"]" comment="Monitor WAN1"

/tool netwatch add host=1.1.1.1 interval=00:00:15 timeout=2 up-script="/ip route enable [find comment=\"to_WAN2\"]" \ down-script="/ip route disable [find comment=\"to_WAN2\"]" comment="Monitor WAN2"
