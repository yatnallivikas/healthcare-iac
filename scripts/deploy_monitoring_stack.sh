#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-dev}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
TF_DIR="${TF_DIR:-$(git rev-parse --show-toplevel)/terraform}"
VALUES_DIR="${VALUES_DIR:-$(git rev-parse --show-toplevel)/k8s/monitoring/helm-values}"
KUSTOMIZE_MONITORING_PATH="${KUSTOMIZE_MONITORING_PATH:-$(git rev-parse --show-toplevel)/k8s/monitoring}"
NAMESPACE="${NAMESPACE:-monitoring}"
PROM_STACK_RELEASE="${PROM_STACK_RELEASE:-observability}"
LOKI_RELEASE="${LOKI_RELEASE:-loki-stack}"

for bin in aws kubectl terraform helm; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "$bin not found in PATH" >&2
    exit 1
  fi
done

pushd "$TF_DIR" >/dev/null
if [ ! -d .terraform ]; then
  terraform init -input=false >/dev/null
fi
if ! terraform workspace list | grep -q "${WORKSPACE}"; then
  echo "Terraform workspace ${WORKSPACE} does not exist." >&2
  exit 1
fi
terraform workspace select "${WORKSPACE}" >/dev/null
if ! terraform output >/dev/null 2>&1; then
  echo "Terraform outputs unavailable; run terraform apply first." >&2
  exit 1
fi

CLUSTER_NAME=$(terraform output -raw cluster_name)
KUBECONFIG_CMD=$(terraform output -raw kubeconfig_command)
popd >/dev/null

if [[ -z "$CLUSTER_NAME" ]]; then
  echo "Cluster name output empty" >&2
  exit 1
fi

echo "Ensuring cluster ${CLUSTER_NAME} is reachable"
aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null

if [[ -n "$KUBECONFIG_CMD" ]]; then
  eval "$KUBECONFIG_CMD"
else
  aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
fi

kubectl apply -k "$KUSTOMIZE_MONITORING_PATH"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install "$PROM_STACK_RELEASE" prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  -f "$VALUES_DIR/kube-prometheus-stack.values.yaml" \
  --create-namespace

helm upgrade --install "$LOKI_RELEASE" grafana/loki-stack \
  --namespace "$NAMESPACE" \
  -f "$VALUES_DIR/loki-stack.values.yaml"

echo "Monitoring services"
kubectl get pods -n "$NAMESPACE"
kubectl get svc -n "$NAMESPACE"
