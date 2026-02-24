

# 🎯 Goal

Run:

* ✅ Prometheus (scraping Geth metrics)
* ✅ Grafana (visualizing metrics)
* ✅ Using Podman containers
* ✅ Clean directory structure
* ✅ Persistent storage
* ✅ Systemd-managed containers (SRE signal)

---

# 🧠 Architecture

```
Geth (host)
   |
   | 127.0.0.1:6060/debug/metrics/prometheus
   ↓
Prometheus (container)
   ↓
Grafana (container)
   ↓
Browser → http://your-server-ip:3000
```

---
