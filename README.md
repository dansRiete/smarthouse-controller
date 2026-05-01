# Smarthouse Controller

Spring Boot IoT home automation backend running on a home server (i7-4770k, 192.168.0.201).

## Infrastructure

All services run in Kubernetes (k3s) in the `smarthouse` namespace.

| Service | Description | External port |
|---|---|---|
| `smarthouse-controller` | Spring Boot app | 24867 |
| `smarthouse-db` | PostgreSQL 14.5 | 24870 |
| `smarthouse-influxdb` | InfluxDB 2.0 | 8086 |
| `smarthouse-mqtt-broker` | Eclipse Mosquitto | 1883 |

## Monitoring & GitOps

| Tool | URL | Credentials |
|---|---|---|
| ArgoCD | http://192.168.0.201:30080 | admin / see k8s secret |
| Grafana | http://192.168.0.201:30300 | admin / see k8s secret |
| Prometheus | http://192.168.0.201:30090 | — |

## Kubernetes — common commands

> SSH into the server first: `ssh alexkzk@192.168.0.201`
> 
> `KUBECONFIG` is set in `~/.bashrc` — no prefix needed after login.

### Check status

```bash
# All pods across the cluster
kubectl get pods -A

# Smarthouse namespace
kubectl get pods -n smarthouse
kubectl get all -n smarthouse

# Recent events (errors, restarts)
kubectl get events -n smarthouse --sort-by='.lastTimestamp'
```

### Logs

```bash
# App logs (last 100 lines)
kubectl logs -n smarthouse -l app=smarthouse-controller --tail=100

# Follow logs live
kubectl logs -n smarthouse -l app=smarthouse-controller -f

# Logs for a specific pod
kubectl logs -n smarthouse <pod-name>
```

### Restart a service

```bash
kubectl rollout restart deployment/smarthouse-controller -n smarthouse
kubectl rollout restart deployment/smarthouse-db -n smarthouse
kubectl rollout restart deployment/smarthouse-influxdb -n smarthouse
kubectl rollout restart deployment/smarthouse-mqtt-broker -n smarthouse
```

### Describe a pod (useful for crash diagnosis)

```bash
kubectl describe pod -n smarthouse <pod-name>
```

### Scale down / up

```bash
# Stop a service (scale to 0)
kubectl scale deployment/smarthouse-controller -n smarthouse --replicas=0

# Start it back
kubectl scale deployment/smarthouse-controller -n smarthouse --replicas=1
```

## Deploying changes

Push to `master` — GitHub Actions builds a new Docker image and deploys it automatically.

ArgoCD watches the `k8s/` folder and applies any manifest changes within ~3 minutes of a push.

To force an immediate ArgoCD sync:
```bash
kubectl annotate application smarthouse-controller -n argocd argocd.argoproj.io/refresh=normal --overwrite
```

## k8s manifests

All manifests live in `k8s/`. ArgoCD syncs this folder to the `smarthouse` namespace automatically.

| File | Description |
|---|---|
| `deployment.yaml` | smarthouse-controller app |
| `postgres.yaml` | PostgreSQL + ClusterIP service |
| `influxdb.yaml` | InfluxDB + ClusterIP service |
| `mosquitto.yaml` | Mosquitto + ConfigMap + ClusterIP service |
| `configmap.yaml` | App environment variables |
| `secret.yaml` | DB password |
| `service.yaml` | smarthouse-controller ClusterIP service |
| `namespace.yaml` | smarthouse namespace |
| `argocd-app.yaml` | ArgoCD Application definition |
