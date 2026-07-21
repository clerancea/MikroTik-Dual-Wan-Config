# PCC Load Balancing

Distributes new LAN connections across WAN1 and WAN2 using RouterOS's Per Connection Classifier (PCC), so each connection sticks to a single WAN for its lifetime — preventing the packet reordering that per-packet load balancing causes.

> **Interface naming used below:** `bridge-lan` (LAN), `WAN1`, `WAN2` — adjust to match your actual interface names.

## How it works

```
New connection from LAN
        |
        v
  PCC classifier (src-address, mod 2)
        |
   -----------------
   |               |
 remainder 0     remainder 1
   |               |
   v               v
WAN1_conn       WAN2_conn
   |               |
   v               v
to_WAN1         to_WAN2
   |               |
   v               v
 WAN1            WAN2
```

## Step 1 — Mark connections by WAN

```
/ip firewall mangle add chain=prerouting in-interface=bridge-lan \
    connection-mark=no-mark connection-state=new \
    dst-address-type=!local per-connection-classifier=src-address:2/0 \
    action=mark-connection new-connection-mark=WAN1_conn passthrough=yes \
    comment="PCC: assign new LAN connections to WAN1"

/ip firewall mangle add chain=prerouting in-interface=bridge-lan \
    connection-mark=no-mark connection-state=new \
    dst-address-type=!local per-connection-classifier=src-address:2/1 \
    action=mark-connection new-connection-mark=WAN2_conn passthrough=yes \
    comment="PCC: assign new LAN connections to WAN2"
```

`connection-state=new` limits these rules to the first packet of each connection — without it, every packet of every existing connection is re-evaluated against the classifier, which costs CPU for no benefit once a connection is already marked.

## Step 2 — Mark routing based on the connection mark

```
/ip firewall mangle add chain=prerouting in-interface=bridge-lan \
    connection-mark=WAN1_conn action=mark-routing \
    new-routing-mark=to_WAN1 passthrough=yes \
    comment="Route WAN1-marked connections via to_WAN1 table"

/ip firewall mangle add chain=prerouting in-interface=bridge-lan \
    connection-mark=WAN2_conn action=mark-routing \
    new-routing-mark=to_WAN2 passthrough=yes \
    comment="Route WAN2-marked connections via to_WAN2 table"
```

## Step 3 — Routes for each routing mark

The mangle rules above only tag traffic — they don't do anything without matching routes in each routing table:

```
/ip route add dst-address=0.0.0.0/0 gateway=<WAN1_GATEWAY> routing-mark=to_WAN1 distance=1
/ip route add dst-address=0.0.0.0/0 gateway=<WAN2_GATEWAY> routing-mark=to_WAN2 distance=1
```

## FastTrack warning

If FastTrack is enabled on this router (RouterOS default), fast-tracked packets bypass mangle prerouting after the first few packets of a connection — which silently breaks PCC marking for long-lived connections. Either disable FastTrack, or explicitly exclude PCC-marked traffic from it before relying on this setup in production.

## Verifying the split

```
/ip firewall connection print where connection-mark=WAN1_conn
/ip firewall connection print where connection-mark=WAN2_conn
```

Open several unrelated connections from a LAN client (e.g., different websites) and confirm they distribute roughly evenly between the two connection marks — expect close to a 50/50 split with `src-address:2/x` classification, not an exact split on small sample sizes.
