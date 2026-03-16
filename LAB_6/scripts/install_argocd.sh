#!/usr/bin/env bash

set -e

version="v3.3.2"
argoproj="https://raw.githubusercontent.com/argoproj/argo-cd/${version}/manifests/install.yaml"

# kubectl create namespace argocd
curl -LO $argoproj --output-dir ./scripts/
# kubectl apply -n argocd --server-side --force-conflicts -f
