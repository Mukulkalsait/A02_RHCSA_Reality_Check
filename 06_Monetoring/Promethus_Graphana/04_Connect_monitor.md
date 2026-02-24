
# 🔌 STEP 6 — Connect Grafana to Prometheus

Inside Grafana:

1. Settings → Data Sources
2. Add Prometheus
3. URL:

```
http://host.containers.internal:9090
```

Save & Test → should be green

---

# 📈 STEP 7 — Test Metrics

In Grafana Explore:

Query:

```
blobpool_add_gapped
```

If graph shows → SUCCESS.

---

# 🛡️ STEP 8 — Production Move (Important)

Right now containers restart only if you manually start them.

We need:

```
Auto-start after reboot
```

You have 2 good options:

### Option A (Better SRE signal):

Generate systemd units from podman:

```bash
podman generate systemd --name prometheus --files --new
podman generate systemd --name grafana --files --new
```

Move files:

```bash
sudo mv container-prometheus.service /etc/systemd/system/
sudo mv container-grafana.service /etc/systemd/system/
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable container-prometheus
sudo systemctl enable container-grafana
```

---
