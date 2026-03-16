#!/usr/bin/env bash

set -e

TMP_FILE="/tmp/ssh_known_hosts"

ssh-keyscan -p 2222 192.168.99.100 | grep '\[' > "$TMP_FILE"

yq_linux_amd64 -i \
  '.data.ssh_known_hosts = load_str("'"$TMP_FILE"'") | .data.ssh_known_hosts style="literal"' \
  ./argocd/argocd-cm-ssh-patch.yaml \
  && rm -fv /tmp/ssh_known_hosts

