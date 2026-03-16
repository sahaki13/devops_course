#!/usr/bin/env bash

set -e

PRIVATE_KEY_PATH="${HOME}/.ssh/id_ed25519"

yq_linux_amd64 -i \
  '.stringData.sshPrivateKey = load_str("'"$PRIVATE_KEY_PATH"'") | .stringData.sshPrivateKey style="literal"' \
  ./argocd/argocd-custom-secret.yaml

