
Excellent. Now we’re entering **real networking fundamentals** — this is exactly what shows up in SRE / Linux Admin JDs.

Let’s slow this down and build it properly.

---

# 1️⃣ What is DHCP?

DHCP = **Dynamic Host Configuration Protocol**

When your laptop connects to WiFi, it needs:

* An IP address (e.g. `192.168.1.42`)
* Subnet mask
* Default gateway (router IP)
* DNS server

Instead of configuring these manually, DHCP asks the router:

```
"Hey, give me network configuration."
```

Router replies with:

```
IP: 192.168.1.42
Gateway: 192.168.1.1
DNS: 192.168.1.1
Lease: 24h
```

Done.

---

# 2️⃣ Who handles DHCP in different setups?

This is where the confusion usually happens.

### When using NetworkManager:

```
NetworkManager → handles DHCP internally
```

### When using systemd-networkd:

```
systemd-networkd → handles DHCP
```

### When using old school:

```
dhcpcd → separate DHCP client
```

---

# 3️⃣ What is `networking.useDHCP = false;` in NixOS?

In NixOS, this option controls the **legacy DHCP mechanism**.

Historically, NixOS could enable DHCP automatically on interfaces.

But when you explicitly enable:

```nix
systemd.network.enable = true;
```

Then:

> systemd-networkd becomes responsible for DHCP.

So we disable the older generic DHCP mechanism to avoid double handling.

---

# 4️⃣ So are we disabling DHCP?

❌ NO.

We are disabling the *default NixOS DHCP handler*
✅ and letting **systemd-networkd handle DHCP instead**

So DHCP still exists — just managed by a different service.

---

# 5️⃣ What does systemd-networkd actually do?

It manages:

* Interfaces (wlan0, eth0, etc.)
* DHCP
* Static IP
* Routing
* VLAN
* Bridges
* Bonds

It is very powerful and very common in servers.

---

# 6️⃣ What does `resolvectl status` show?

This is for DNS.

It shows:

* Current DNS servers
* Which interface they belong to
* Whether DNSSEC is enabled
* Current DNS transaction state

Example output:

```
Link 3 (wlan0)
    Current Scopes: DNS
    DNS Servers: 1.1.1.1 8.8.8.8
    DNS Domain: ~.
```

This tells you:

* DNS is working
* Which servers are active
* Which interface is providing them

---

# 7️⃣ Real Debugging Flow (Very SRE)

If you connect WiFi but no internet:

### Step 1 — Check IP

```bash
ip a
```

If no `inet 192.168.x.x`
→ DHCP failed

---

### Step 2 — Check DHCP service

```bash
systemctl status systemd-networkd
```

If inactive or failed → that’s your problem.

---

### Step 3 — Check DNS

```bash
resolvectl status
```

If DNS servers missing → DNS issue.

---

# 8️⃣ Why conflicts happen

If two services try to manage the same interface:

Example:

```
iwd
+ NetworkManager
+ systemd-networkd
+ dhcpcd
```

You get:

* double DHCP
* overwritten routes
* broken DNS
* random disconnects

So we choose ONE stack.

---

# 9️⃣ Your New Clean Stack (After Switch)

```
WiFi association → iwd
IP + DHCP        → systemd-networkd
DNS              → systemd-resolved
```

No conflicts.
Very clean.
Very “Linux-native”.

---

# 🔟 Why this is good for your career

In job descriptions for:

* Linux Admin
* DevOps
* SRE

You’ll see:

* DHCP troubleshooting
* systemd-networkd
* DNS resolution debugging
* routing issues

This setup forces you to understand layers.

NetworkManager hides those layers.

---

# 1️⃣1️⃣ Final Answer to Your Question

> “oi i got it systemd-networkd is going to do it for us so we will manually disable it no conflicts? right?”

Correct.

We disable the generic DHCP,
and explicitly say:

```
systemd-networkd is responsible.
```

No conflict.
Single authority.
Clean architecture.

---

# 🧠 Mental Model (Lock this in)

```
iwd → connect to WiFi
networkd → get IP (DHCP)
resolved → translate domain names
```

Three separate responsibilities.

---

If you want next, we can go deeper into:

* How DHCP handshake actually works (DORA process)
* How to configure static IP in networkd
* How DNS resolution works internally
* How to sniff DHCP packets with tcpdump

Now you’re entering real SRE territory 🔥
