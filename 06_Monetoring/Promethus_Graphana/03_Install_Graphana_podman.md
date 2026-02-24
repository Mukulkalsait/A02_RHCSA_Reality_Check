
# 📊 STEP 5 — Run Grafana

```bash
podman run -d \
  --name grafana \
  -p 3000:3000 \
  -v /opt/monitoring/grafana:/var/lib/grafana:Z \
  grafana/grafana-oss
```

Check:

```bash
podman ps
```

Open:

```
http://your-server-ip:3000
```

Default login:

```
admin / admin
```

---
