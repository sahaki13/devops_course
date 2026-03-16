#!/usr/bin/env bash

set -e

JOB_NAME=$(helm template \
  -n vault \
  vault \
  -s templates/jobs/remove-vault-storage.yaml \
  --set jobs.removeVaultStorage.enabled=true \
  . \
  | kubectl apply -f - \
  | grep -i "job\.batch" \
  | awk '{print $1}'
)
echo "Job created: ${JOB_NAME}"

kubectl wait -n vault --for=condition=complete "${JOB_NAME}" --timeout=120s
kubectl logs -n vault "$JOB_NAME"
