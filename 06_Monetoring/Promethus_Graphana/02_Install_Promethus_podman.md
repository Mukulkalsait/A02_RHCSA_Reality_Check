
# 📁 STEP 2 — Create Monitoring Directory Structure

We do this cleanly (resume-worthy layout):

```bash
sudo mkdir -p /opt/monitoring/prometheus
sudo mkdir -p /opt/monitoring/grafana
sudo chown -R $USER:$USER /opt/monitoring
```

This shows structure thinking. Interviewers like this.

---

# 📝 STEP 3 — Create Prometheus Config

Create:

```bash
nvim /opt/monitoring/prometheus/prometheus.yml
```

Add:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "geth"
    static_configs:
      - targets: ["host.containers.internal:6060"]
```

### Why `host.containers.internal`?

Because:

* Geth runs on host
* Prometheus runs inside container
* This special DNS lets container reach host

This is important SRE knowledge.

---

# 🚀 STEP 4 — Run Prometheus (Podman)

```bash
podman run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /opt/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:Z \
  -v /opt/monitoring/prometheus/data:/prometheus:Z \
  prom/prometheus
```

Now check:

```bash
podman ps
```

Test:

```
http://your-server-ip:9090
```

Then go to:

```
Status → Targets
```

You should see `geth` target UP.

---
