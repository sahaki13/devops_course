#!/bin/sh

set -e

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>> UPDATE_AUTH >>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)
CLUSTER_DOMAIN="cluster.dev"
POLICIES="read-secret-sandbox,read-secret-dev,read-secret-prod"
NAMESPACES="sandbox,dev,prod"
SERVICE_ACCOUNT="vault-auth"
ROLE="vault-auth"

if vault auth list | grep -q "kubernetes/"; then
  echo "Kubernetes auth method already exists."
else
    vault auth enable kubernetes
    vault auth list
fi

vault write auth/kubernetes/config \
            kubernetes_host="https://kubernetes.default.svc:443" \
            token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
            kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
            issuer="https://kubernetes.default.svc.${CLUSTER_DOMAIN}"
# vault read auth/kubernetes/config

vault write auth/kubernetes/role/${ROLE} \
            bound_service_account_names="${SERVICE_ACCOUNT}" \
            bound_service_account_namespaces="${NAMESPACES}" \
            audience="https://kubernetes.default.svc.${CLUSTER_DOMAIN}" \
            policies="${POLICIES}" \
            ttl=1m
# vault kv list auth/kubernetes/role/
