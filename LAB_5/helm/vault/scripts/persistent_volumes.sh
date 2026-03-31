#!/usr/bin/env bash

# set -e

mode=$1
NS="vault"

echo "Mode: $mode"

if [[ ! $mode =~ ^(createPv|deletePv)$ ]]; then
  echo "Usage: $0 {createPv|deletePv}"
  exit 1
fi

if [[ $mode == "deletePv" ]]; then
  kubectl delete pvc -n $NS data-vault-0 || true
  kubectl delete pv vault-pv-0
fi

JOB_NAME=$(helm template \
  -n vault \
  vault \
  -s templates/jobs/$mode.yaml \
  --set jobs.$mode.enabled=true \
  . \
  | kubectl apply -f - \
  | grep -i "job\.batch" \
  | awk '{print $1}'
)
echo "Job created: ${JOB_NAME}"

kubectl wait -n "$NS" --for=condition=complete "${JOB_NAME}" --timeout=120s
kubectl logs -n "$NS" "$JOB_NAME"

if [[ $mode == "createPv" ]]; then
  kubectl get pv | grep -E "vault"
fi

