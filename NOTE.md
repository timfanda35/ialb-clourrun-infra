
Install Docker

```bash
curl -fsSL https://get.docker.com | sudo bash
```

Run Grafana

```bash
docker run -d -p 3000:3000 --name=grafana grafana/grafana-oss
```

Datasource 1:
- Prometheus server URL: `my-prometheus.com/prometheus-1`

Datasource 2:
- Prometheus server URL: `my-prometheus.com/prometheus-2`
