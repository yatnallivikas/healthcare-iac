# Monitoring Stack

This folder supplies Helm values and supporting assets for deploying a full monitoring stack (Prometheus Operator, Grafana, Alertmanager, Loki, and Promtail) into the `monitoring` namespace of the healthcare EKS cluster.

## Components

- `helm-values/kube-prometheus-stack.values.yaml` – overrides for `prometheus-community/kube-prometheus-stack` enabling Grafana with a LoadBalancer service, extra Loki datasource, and tuned retention/resources.
- `helm-values/loki-stack.values.yaml` – persistence-enabled Loki plus Promtail daemonset scraping pod logs with filtered labels.
- `dashboards/` – drop-in Grafana dashboards packaged by the Prometheus Operator sidecar.
- `namespace.yaml` & `kustomization.yaml` – optional manifests for GitOps-based namespace creation and dashboard ConfigMap generation.

## Deploy

```
export WORKSPACE=dev        # or staging/prod Terraform workspace
export AWS_REGION=ap-south-1
./scripts/deploy_monitoring_stack.sh
```

The script:
1. Reads the Terraform outputs for the selected workspace to discover the EKS cluster name and recommended `aws eks update-kubeconfig` command.
2. Verifies the cluster exists, updates kubeconfig, and ensures the `monitoring` namespace.
3. Installs/updates the Prometheus stack and Loki stack with the provided values.

## Access Grafana

```
kubectl -n monitoring get svc kube-prom-stack-grafana
kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80
```

Browse to `http://localhost:3000`, login with the credentials defined in the values file (`admin` / `CHANGEME-...` – override before production). Grafana already knows about Prometheus and Loki, so you can build dashboards that correlate metrics (`prometheus`) and logs (`loki`).

## Inspect Metrics & Logs

- Cluster health: `kubectl -n monitoring get pods`, `kubectl top nodes`, Grafana dashboards prefixed with `Kubernetes /`.
- Application metrics: add `ServiceMonitor` objects or expose Prometheus-format metrics from services; by default you still get CPU/memory/pod health from kube-state-metrics.
- Logs: query `loki` datasource in Grafana (`{namespace="healthcare-apps"}`) or run `kubectl logs -n healthcare-apps <pod>`.
