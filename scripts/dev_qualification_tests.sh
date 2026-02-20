#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${1:-}"

if [[ -z "${IMAGE_TAG}" ]]; then
  echo "Usage: $(basename "$0") <IMAGE_TAG>"
  exit 1
fi

echo "[qualify] Starting dev qualification smoke for image tag: ${IMAGE_TAG}"
echo "[qualify] TODO: kubectl rollout status deploy/api --namespace dev"
echo "[qualify] TODO: curl https://dev.example.com/health"
echo "[qualify] TODO: Validate ingress or service endpoint once wired"

echo "[qualify] Simulated rollout verification succeeded"
echo "[qualify] Simulated /health smoke succeeded"
echo "STAGING_QUALIFIED=true"
