# Monitoring Stack

This package installs a turnkey observability stack for the healthcare platform:

- **Prometheus Operator / kube-prometheus-stack** for metrics, default alerts, and Grafana.
- **Grafana** with preloaded dashboards sourced from `k8s/monitoring/dashboards`. The dashboards focus on `healthcare-apps` via kube-state-metrics and a Loki-powered log overview.
- **Loki + Promtail** for application and cluster log aggregation and querying directly from Grafana.

## Deploy

```bash
export WORKSPACE=dev            # or staging/prod Terraform workspace
=======
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

The script will:
1. Read Terraform outputs to discover the target EKS cluster and update kubeconfig.
2. Apply the `k8s/monitoring` kustomize bundle (namespace + ConfigMaps holding dashboards).
3. Install/upgrade kube-prometheus-stack and Loki using the Helm values checked into this repo.
4. Print the status of monitoring pods and services.

## Grafana Access & Dashboards

```bash
kubectl -n monitoring port-forward svc/observability-grafana 3000:80
```

Then visit `http://localhost:3000` and login with `admin / CHANGEME-CHANGE` (update the password in `kube-prometheus-stack.values.yaml` before production). The dashboards sidecar automatically detects ConfigMaps labeled `grafana_dashboard=1`, so the following dashboards appear immediately:

- **Kube State Metrics - Healthcare Apps** (`uid: kube-state-overview`) – shows deployment availability, failed pods, and restart rates scoped to the `healthcare-apps` namespace.
- **Healthcare App Logs** (`uid: app-logs-overview`) – visualizes log throughput per workload and provides a Loki log explorer filtered to the application namespace.

## Logs

Promtail is configured with relabeling rules that capture `app.kubernetes.io/name` (or fallback to `app`) plus namespace, node, and container labels. Grafana automatically registers a Loki datasource, so queries like `{namespace="healthcare-apps"}` immediately surface application logs.

## Metrics Extensions

- Add `ServiceMonitor` or `PodMonitor` resources per microservice whenever they expose Prometheus metrics endpoints. kube-prometheus-stack already watches the entire cluster by default.
- To create additional dashboards, add JSON exports under `k8s/monitoring/dashboards` and re-run the deployment script or `kubectl apply -k k8s/monitoring`.
=======
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
