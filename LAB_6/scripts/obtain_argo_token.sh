#!/usr/bin/env bash

kubectl get secrets -n argocd argocd-initial-admin-secret -o json \
    | jq -r '.data.password' \
    | base64 -d
echo -e "\n"

