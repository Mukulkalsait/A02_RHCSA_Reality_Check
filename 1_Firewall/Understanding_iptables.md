```bash 

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
 458K 2265M nixos-fw   all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain nixos-fw (1 references)
 pkts bytes target     prot opt in     out     source               destination         
  452 33336 nixos-fw-accept  all  --  lo     *       0.0.0.0/0            0.0.0.0/0           
 456K 2265M nixos-fw-accept  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    0     0 nixos-fw-accept  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:4000
    0     0 nixos-fw-accept  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:5173
    0     0 nixos-fw-accept  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:27015
    0     0 nixos-fw-accept  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:27036
    0     0 nixos-fw-accept  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:27037
    0     0 nixos-fw-accept  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:10400
    0     0 nixos-fw-accept  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:10401
    0     0 nixos-fw-accept  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:27015
    0     0 nixos-fw-accept  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:27036
    0     0 nixos-fw-accept  udp  --  podman0 *       0.0.0.0/0            0.0.0.0/0            udp dpt:53
    0     0 nixos-fw-accept  udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpts:27031:27035
    0     0 nixos-fw-accept  icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 8
 1794  314K nixos-fw-log-refuse  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain nixos-fw-accept (14 references)
 pkts bytes target     prot opt in     out     source               destination         
 456K 2265M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain nixos-fw-log-refuse (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 LOG        tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp flags:0x17/0x02 LOG flags 0 level 6 prefix "refused connection: "
 1426  301K nixos-fw-refuse  all  --  *      *       0.0.0.0/0            0.0.0.0/0            PKTTYPE != unicast
  368 13248 nixos-fw-refuse  all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain nixos-fw-refuse (2 references)
 pkts bytes target     prot opt in     out     source               destination         
 1794  314K DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0           
```

# Explanations: 

## Annotated `iptables -L -n -v` (NixOS firewall)

---

### 🔹 FILTER TABLE — TOP-LEVEL CHAINS

```text
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 455K 2264M nixos-fw   all  --  *      *       0.0.0.0/0            0.0.0.0/0
```

**What this means**

* Kernel receives packets destined **to this machine**
* Instead of defining rules directly in `INPUT`, NixOS:

  * Redirects *all* traffic to a custom chain → `nixos-fw`
* This is **clean architecture**:

  * `INPUT` stays minimal
  * All policy lives in `nixos-fw`

> 🔑 Mental model:
> INPUT = traffic router
> nixos-fw = firewall logic

---

```text
Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
```

**Meaning**

* No forwarding rules
* Your machine is **not acting as a router**
* Containers / NAT would populate this

✔ Safe for workstation / server

---

```text
Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
```

**Meaning**

* Outbound traffic is unrestricted
* This is normal unless:

  * You’re building a zero-trust egress firewall
  * Or a locked-down enterprise host

✔ Default and expected

---

## 🔹 CORE FIREWALL LOGIC — `nixos-fw`

```text
Chain nixos-fw (1 references)
```

This chain is the **real firewall**.

---

### 1️⃣ Loopback traffic

```text
410 packets → nixos-fw-accept  all  --  lo  *
```

**Why this exists**

* Local services talk to each other via `127.0.0.1`
* Blocking loopback breaks:

  * systemd
  * DBs
  * package managers

✔ Mandatory rule in every firewall on Earth

---

### 2️⃣ Stateful connection tracking

```text
453K packets → nixos-fw-accept  ctstate RELATED,ESTABLISHED
```

**This is CRITICAL**

* Allows return traffic
* Example:

  * You open HTTPS → response comes back
* Without this:

  * Firewall behaves like a brick wall

> 🔥 Interview gold:
> “Stateful firewall allows replies without opening ephemeral ports.”

---

### 3️⃣ Explicitly allowed TCP ports

```text
tcp dpt:4000
tcp dpt:5173
```

**Source**

From your `firewall.nix`:

```nix
allowTCPPorts = [ 4000 5173 ];
```

**Meaning**

* New inbound TCP connections are allowed
* Only on these ports
* Everything else → denied later

✔ Declarative → kernel reality confirmed

---

### 4️⃣ Additional allowed ports (merged modules)

```text
tcp dpt:27015
tcp dpt:27036
tcp dpt:27037
udp dpt:10400
udp dpt:10401
udp dpt:27015
udp dpt:27036
udp dpts:27031:27035
```

**Where these come from**

* Steam / Proton
* Gaming services
* Other NixOS modules

**Important concept**

> NixOS firewall rules are **composed**, not overwritten.

Multiple modules → one final ruleset.

✔ This is NOT accidental
✔ This is reproducible infra

---

### 5️⃣ Interface-specific rule

```text
udp dpt:53 in:podman0
```

**Meaning**

* DNS allowed on container bridge
* Needed for:

  * Podman containers
  * Internal name resolution

✔ Container-aware firewall

---

### 6️⃣ ICMP (ping)

```text
icmp type 8
```

**Meaning**

* ICMP echo request allowed
* Useful for:

  * Monitoring
  * Debugging
  * Network diagnostics

Disabling ping:

* Makes ops harder
* Doesn’t add real security

✔ Sensible default

---

### 7️⃣ Default path → LOG + DROP

```text
1567 packets → nixos-fw-log-refuse
```

**Meaning**

* Packet didn’t match any allow rule
* Sent to refusal pipeline

---

## 🔹 ACCEPT CHAIN

```text
Chain nixos-fw-accept
  ACCEPT all
```

**Why this exists**

* All “allowed” traffic jumps here
* Single ACCEPT point
* Clean separation of:

  * decision logic
  * final action

✔ Very clean design

---

## 🔹 LOGGING + REFUSAL

```text
Chain nixos-fw-log-refuse
```

### Logging (rate-limited)

```text
LOG tcp flags SYN prefix "refused connection:"
```

**Purpose**

* Logs blocked connection attempts
* Useful for:

  * Intrusion detection
  * Debugging misconfigurations

✔ Logs intent, not noise

---

### Non-unicast filter

```text
PKTTYPE != unicast → nixos-fw-refuse
```

**Why this exists**

* Drops:

  * Broadcast
  * Multicast junk
* Reduces attack surface

✔ Quietly defensive

---

### Final refusal

```text
nixos-fw-refuse
```

---

## 🔹 FINAL DROP

```text
Chain nixos-fw-refuse
 DROP all
```

**This is the most important rule**

* Anything not explicitly allowed
* Is dropped
* No exceptions

> 🔐 **Default deny firewall**
> This is enterprise-grade security

---

## 🧠 Final mental model (memorize this)

```
INPUT
  ↓
nixos-fw
  ├─ allow loopback
  ├─ allow ESTABLISHED
  ├─ allow declared ports
  ├─ allow container needs
  ├─ allow ping
  ↓
LOG
  ↓
DROP
```

---

## Why this matters for YOU

* You now understand:

  * Declarative → kernel translation
  * Stateful firewalling
  * Rule composition
  * Container-aware security
* This knowledge transfers to:

  * firewalld
  * nftables
  * cloud security groups
  * Kubernetes NetworkPolicies

---

If you want next:

* Convert this into **firewalld zones**
* Explain **nftables equivalent**
* Break an RHCSA-style firewall question
* Simulate “I locked myself out” recovery

You’re doing this *the right way*.

