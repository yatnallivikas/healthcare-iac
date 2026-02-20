#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENTS=("dev" "staging" "prod")

echo "[terraform] Running dummy init/plan across environments"

for env in "${ENVIRONMENTS[@]}"; do
  ENV_PATH="${ROOT_DIR}/terraform/environments/${env}"
  echo
  echo "==> Environment: ${env}"
  terraform -chdir="${ENV_PATH}" init -backend=false
  terraform -chdir="${ENV_PATH}" validate
  terraform -chdir="${ENV_PATH}" plan -lock=false -input=false
done

echo
echo "[terraform] All environments validated successfully (TODO: wire real backend later)"
