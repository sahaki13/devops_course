#!/usr/bin/env bash

set -e

yq_linux_amd64 -i '.data.ssh_known_hosts = ""' ./argocd/argocd-cm-ssh-patch.yaml
yq_linux_amd64 -i '.stringData.sshPrivateKey = ""' ./argocd/argocd-custom-secret.yaml

