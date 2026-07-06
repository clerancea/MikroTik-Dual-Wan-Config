**Troubleshooting Guide**

## No Internet Connectivity

- Verify Interface Status

   /interface print


- Verify IP Assignment

   /ip address print

- Verify Gateway Reachability

   /ping 8.8.8.8

## NAT Issues

- Check NAT Rules

   /ip firewall nat print

Expected Rules:

   /ip firewall nat add chain=srcnat action=masquerade out-interface=WAN1 comment="NAT for WAN1"
   
   /ip firewall nat add chain=srcnat action=masquerade out-interface=WAN2 comment="NAT for WAN2"


## Load Balancing Issues

- Verify Mangle Rule

   /ip firewall mangle print

Check for:

- Connection marks

- Routing marks

- PCC classifiers

## Failover Issues

- Verify Routes

    /ip route print detail

- Route active status

- Gateway reachability

- Routing marks
