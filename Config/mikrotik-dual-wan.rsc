# =========================================================
# MikroTik Dual-WAN Configuration
# WAN1: dedicated static IP | WAN2: DHCP
# Replace all <PLACEHOLDER> values before running.
# Apply from a LOCAL console session only — this resets interface roles.
# =========================================================

# --- Interface roles ---
/interface ethernet set [find default-name=ether1] name=WAN1
/interface ethernet set [find default-name=ether2] name=WAN2
/interface ethernet set [find default-name=ether3] name=Local_Network

# --- WAN1: static IP from ISP ---
/ip address add address=<PUBLIC_IP>/30 interface=WAN1
/ip route add dst-address=0.0.0.0/0 gateway=<PRIMARY_GATEWAY> distance=1 comment="main table fallback default route"

# --- WAN2: DHCP ---
/ip dhcp-client add interface=WAN2 disabled=no

# --- NAT (masquerade both WANs) ---
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN1 comment="NAT for WAN1"
/ip firewall nat add chain=srcnat action=masquerade out-interface=WAN2 comment="NAT for WAN2"

# --- PCC: split new LAN connections across both WANs ---
# connection-state=new limits re-evaluation to first packet of each connection.
# NOTE: if FastTrack is enabled, exclude PCC-marked traffic from it or these rules
# will be silently bypassed for established connections.
/ip firewall mangle add chain=prerouting in-interface=Local_Network \
    connection-mark=no-mark connection-state=new dst-address-type=!local \
    per-connection-classifier=src-address:2/0 action=mark-connection \
    new-connection-mark=WAN1_conn passthrough=yes comment="PCC: assign to WAN1"

/ip firewall mangle add chain=prerouting in-interface=Local_Network \
    connection-mark=no-mark connection-state=new dst-address-type=!local \
    per-connection-classifier=src-address:2/1 action=mark-connection \
    new-connection-mark=WAN2_conn passthrough=yes comment="PCC: assign to WAN2"

/ip firewall mangle add chain=prerouting in-interface=Local_Network \
    connection-mark=WAN1_conn action=mark-routing new-routing-mark=to_WAN1 \
    passthrough=yes comment="Route WAN1-marked connections"

/ip firewall mangle add chain=prerouting in-interface=Local_Network \
    connection-mark=WAN2_conn action=mark-routing new-routing-mark=to_WAN2 \
    passthrough=yes comment="Route WAN2-marked connections"

# --- Per-table routes WITH backup routes: this is what makes failover actually work ---
# Each routing-mark table gets its own gateway as primary AND the other
# WAN's gateway as a backup at higher distance. Without the backup line,
# traffic marked for a dead WAN has nowhere to go even if check-gateway
# disables the primary route.
/ip route add dst-address=0.0.0.0/0 gateway=<WAN1_GATEWAY> distance=1 \
    routing-mark=to_WAN1 check-gateway=ping comment="to_WAN1 primary"
/ip route add dst-address=0.0.0.0/0 gateway=<WAN2_GATEWAY> distance=2 \
    routing-mark=to_WAN1 check-gateway=ping comment="to_WAN1 backup via WAN2"

/ip route add dst-address=0.0.0.0/0 gateway=<WAN2_GATEWAY> distance=1 \
    routing-mark=to_WAN2 check-gateway=ping comment="to_WAN2 primary"
/ip route add dst-address=0.0.0.0/0 gateway=<WAN1_GATEWAY> distance=2 \
    routing-mark=to_WAN2 check-gateway=ping comment="to_WAN2 backup via WAN1"

# --- Firewall: input chain (traffic TO the router itself) ---
/ip firewall filter add chain=input connection-state=established,related action=accept comment="allow established/related"
/ip firewall filter add chain=input connection-state=invalid action=drop comment="drop invalid"
/ip firewall filter add chain=input in-interface=Local_Network action=accept comment="allow LAN to reach router (Winbox/SSH/etc.)"
/ip firewall filter add chain=input action=drop comment="default drop — blocks unsolicited WAN access to the router"

# --- Firewall: forward chain (traffic THROUGH the router) ---
/ip firewall filter add chain=forward connection-state=established,related action=accept comment="allow established/related forward"
/ip firewall filter add chain=forward connection-state=invalid action=drop comment="drop invalid forward"
/ip firewall filter add chain=forward in-interface=Local_Network action=accept comment="allow LAN to forward out"
/ip firewall filter add chain=forward action=drop comment="default drop — blocks unsolicited inbound-initiated traffic"

# --- DNS ---
/ip dns set servers=1.1.1.1,8.8.8.8,9.9.9.9
/ip dhcp-server network set [find] dns-server=192.168.1.1
