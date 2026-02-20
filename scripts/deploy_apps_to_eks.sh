#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-dev}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
TF_DIR="${TF_DIR:-$(git rev-parse --show-toplevel)/terraform}"
KUSTOMIZE_PATH="${KUSTOMIZE_PATH:-$(git rev-parse --show-toplevel)/k8s/apps}"
APP_NAMESPACE="${APP_NAMESPACE:-healthcare-apps}"
ECR_PULL_SECRET_NAME="${ECR_PULL_SECRET_NAME:-aws-ecr}"
CREATE_ECR_PULL_SECRET="${CREATE_ECR_PULL_SECRET:-true}"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI not found" >&2
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found" >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform not found" >&2
  exit 1
fi

if ! command -v kustomize >/dev/null 2>&1; then
  echo "kustomize binary is required for image overrides. Install it first (https://kubectl.docs.kubernetes.io/installation/kustomize/)" >&2
  exit 1
fi

pushd "$TF_DIR" >/dev/null
if [ ! -d .terraform ]; then
  terraform init -input=false >/dev/null
fi
if ! terraform workspace list | grep -q "${WORKSPACE}"; then
  echo "Terraform workspace ${WORKSPACE} does not exist. Create it before deploying." >&2
  exit 1
fi
terraform workspace select "$WORKSPACE" >/dev/null

if ! terraform output >/dev/null 2>&1; then
  echo "Terraform state is unavailable. Run terraform init/plan/apply first." >&2
  exit 1
fi

CLUSTER_NAME=$(terraform output -raw cluster_name)
KUBECONFIG_CMD=$(terraform output -raw kubeconfig_command)
popd >/dev/null

if [[ -z "$CLUSTER_NAME" ]]; then
  echo "Cluster name not found in Terraform outputs. Ensure the EKS module has been applied." >&2
  exit 1
fi

echo "Checking EKS cluster ${CLUSTER_NAME} in ${AWS_REGION}..."
if ! aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "Cluster ${CLUSTER_NAME} not found. Apply Terraform for workspace ${WORKSPACE} first." >&2
  exit 1
fi

echo "Updating kubeconfig via Terraform output command..."
if [[ -n "$KUBECONFIG_CMD" ]]; then
  eval "$KUBECONFIG_CMD"
else
  aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
fi

echo "Verifying cluster connectivity..."
kubectl get nodes || true

kubectl create namespace "$APP_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
KUSTOMIZE_PARENT="$(cd "$(dirname "$KUSTOMIZE_PATH")" && pwd)"
KUSTOMIZE_BASENAME="$(basename "$KUSTOMIZE_PATH")"
TMP_PARENT="${TMP_DIR}/kustomize-root"
mkdir -p "$TMP_PARENT"
cp -R "${KUSTOMIZE_PARENT}/." "$TMP_PARENT/"
TMP_KUSTOMIZE_PATH="${TMP_PARENT}/${KUSTOMIZE_BASENAME}"

ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query 'Account' --output text)}"
ECR_REGISTRY="${ECR_REGISTRY:-${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
APPOINTMENT_IMAGE="${APPOINTMENT_IMAGE:-${ECR_REGISTRY}/appointment-service:${IMAGE_TAG}}"
PATIENT_IMAGE="${PATIENT_IMAGE:-${ECR_REGISTRY}/patient-service:${IMAGE_TAG}}"

if [[ "${CREATE_ECR_PULL_SECRET}" == "true" ]]; then
  echo "Ensuring image pull secret ${ECR_PULL_SECRET_NAME} exists in namespace ${APP_NAMESPACE}"
  ECR_PASSWORD=$(aws ecr get-login-password --region "$AWS_REGION")
  kubectl -n "$APP_NAMESPACE" create secret docker-registry "$ECR_PULL_SECRET_NAME" \
    --docker-server="${ECR_REGISTRY}" \
    --docker-username=AWS \
    --docker-password="${ECR_PASSWORD}" \
    --dry-run=client -o yaml | kubectl apply -f -
  unset ECR_PASSWORD
fi

pushd "$TMP_KUSTOMIZE_PATH" >/dev/null
kustomize edit set image appointment-service="${APPOINTMENT_IMAGE}"
kustomize edit set image patient-service="${PATIENT_IMAGE}"
popd >/dev/null

echo "Deploying application manifests via kustomize build"
kustomize build --load-restrictor=LoadRestrictionsNone "$TMP_KUSTOMIZE_PATH" | kubectl apply -f -

echo "Deployment completed. Namespaces and workloads:"
kubectl get ns "$APP_NAMESPACE" || true
kubectl get all -n "$APP_NAMESPACE"
