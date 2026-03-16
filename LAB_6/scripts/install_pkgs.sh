#!/usr/bin/env bash

set -e

PRIVATE_KEY_PATH="${HOME}/.ssh/id_ed25519"
ARCH="$(uname -m)"
KERNEL_NAME="$(uname -s)"
KUSTOMIZE_VERSION="v5.8.1"

case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
esac

YQ="https://github.com/mikefarah/yq/releases/latest/download/yq_${KERNEL_NAME,,}_${ARCH}"
KUSTOMIZE="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_${KERNEL_NAME,,}_${ARCH}.tar.gz"

if [ ! -f "${HOME}/.local/bin/yq_linux_amd64" ]; then
  mkdir -p ~/.local/bin
  echo "Downloading $YQ"
  curl -LO --progress-bar \
    "$YQ" \
    --output-dir ~/.local/bin \
    && chmod +x ~/.local/bin/yq_linux_amd64
fi

if [ ! -f "${HOME}/.local/bin/kustomize" ]; then
  mkdir -p ~/.local/bin
  echo "Downloading $KUSTOMIZE"
  curl -sL --progress-bar \
    "$KUSTOMIZE" \
    | tar xz -C ~/.local/bin kustomize \
    && chmod +x ~/.local/bin/kustomize
fi

echo "Kustomize: $(kustomize version)"
yq_linux_amd64 --version

