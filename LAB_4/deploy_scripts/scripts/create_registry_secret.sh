#!/usr/bin/env bash
set -e

# Change these vars if needed
DEFAULT_REGISTRY="http://192.168.99.100:5050"
DEFAULT_USERNAME="user" # ignored when using a GitLab PAT
KUBE_NAMESPACES=('dev' 'preprod' 'prod')
KUBE_RES_NAME="gitlab-insecure-registry"

echo -e "Create Docker registry secret for Kubernetes\n"

# Registry server
read -rp "Registry server [$DEFAULT_REGISTRY]: " REGISTRY_SERVER_ADDR
REGISTRY_SERVER_ADDR="${REGISTRY_SERVER_ADDR:-$DEFAULT_REGISTRY}"

# Username
read -rp "Username [$DEFAULT_USERNAME]: " REGISTRY_USERNAME
REGISTRY_USERNAME="${REGISTRY_USERNAME:-$DEFAULT_USERNAME}"

read -rsp "Password/Token (input hidden): " REGISTRY_PASSWORD
echo -e "\n"

if [ -z "$REGISTRY_PASSWORD" ]; then
    echo >&2
    echo "Error: Password/token cannot be empty." >&2
    exit 1
fi

# Create the namespace if it does not exist
for kube_ns in "${KUBE_NAMESPACES[@]}"
do
  kubectl get namespace "$kube_ns" >/dev/null 2>&1 || kubectl create namespace "$kube_ns"

  # Remove the old secret if it already exist
  kubectl delete secret "$KUBE_RES_NAME" -n "$kube_ns" >/dev/null 2>&1 || true

  # Create the new secret
  kubectl create secret docker-registry "$KUBE_RES_NAME" \
    --namespace="$kube_ns" \
    --docker-server="$REGISTRY_SERVER_ADDR" \
    --docker-username="$REGISTRY_USERNAME" \
    --docker-password="$REGISTRY_PASSWORD" \
    --docker-email=""

  echo -e "\nSecret '$KUBE_RES_NAME' created in namespace '$kube_ns'.\n"
done

# Check the secret content:
# k get secrets -n echo-server gitlab-insecure-registry -o json | jq -r '.data[".dockerconfigjson"]' | base64 -d | json_pp
