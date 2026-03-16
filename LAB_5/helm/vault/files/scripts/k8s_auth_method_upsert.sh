#!/bin/sh

set -e

. /vault/scripts/vars.sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>> UPDATE_AUTH >>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)
CLUSTER_DOMAIN="cluster.dev"

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

for app in $APPLICATIONS; do
  for env in $ENVIRONMENTS; do
    ROLE_NAME="vault-auth-${env}-${app}"
    POLICY_NAME="read-secret-${env}-${app}"
    NAMESPACE="${env}"  # many services within NS
    # NAMESPACE="${app}"  # one service one ns
    # NAMESPACE="${app},${env}"  # combined

    echo "Creating role: ${ROLE_NAME}"

    vault write auth/kubernetes/role/${ROLE_NAME} \
      bound_service_account_names="${app}" \
      bound_service_account_namespaces="${NAMESPACE}" \
      audience="https://kubernetes.default.svc.${CLUSTER_DOMAIN}" \
      policies="${POLICY_NAME}" \
      ttl=1h
  done
done

### combined
# for app in $APPLICATIONS; do
#   # 1. ................ ............: read-secret-<env>-<app>
#   POLICIES=""
#   for env in $ENVIRONMENTS; do
#     policy="read-secret-${env}-${app}"
#     if [ -z "$POLICIES" ]; then
#       POLICIES="$policy"
#     else
#       POLICIES="${POLICIES},${policy}"
#     fi
#   done

#   NAMESPACES=""
#   for env in $ENVIRONMENTS; do
#     ns="${app}-${env}"
#     if [ -z "$NAMESPACES" ]; then
#       NAMESPACES="$ns"
#     else
#       NAMESPACES="${NAMESPACES},${ns}"
#     fi
#   done

#   vault write auth/kubernetes/role/vault-auth-${app} \
#               bound_service_account_names="${app}" \
#               bound_service_account_namespaces="${NAMESPACES}" \
#               audience="https://kubernetes.default.svc.${CLUSTER_DOMAIN}" \
#               policies="${POLICIES}" \
#               ttl=5m
#   # vault kv list auth/kubernetes/role/
# done

### simple case. one SA to NS list
# NAMESPACES="dev,preprod,prod"
# POLICIES="read-secret-dev,read-secret-preprod,read-secret-prod"
# vault write auth/kubernetes/role/vault-auth \
#             bound_service_account_names=vault-auth \
#             bound_service_account_namespaces="${NAMESPACES}" \
#             audience="https://kubernetes.default.svc.${CLUSTER_DOMAIN}" \
#             policies="${POLICIES}" \
#             ttl=1m
