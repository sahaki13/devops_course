#!/usr/bin/env bash

set -e

SOURCE_MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.3/deploy/static/provider/baremetal/deploy.yaml"
SCRIPT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

kubectl kustomize "$SCRIPT_DIR" > "$SCRIPT_DIR/new.yaml"
curl -s -LO \
  "$SOURCE_MANIFEST" \
  --output-dir "$SCRIPT_DIR"
diff -u "$SCRIPT_DIR/deploy.yaml" "$SCRIPT_DIR/new.yaml" || true

rm -fv "$SCRIPT_DIR/new.yaml" "$SCRIPT_DIR/deploy.yaml"
