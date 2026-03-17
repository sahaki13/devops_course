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

YQ_BIN="yq_${KERNEL_NAME,,}_${ARCH}"
YQ="https://github.com/mikefarah/yq/releases/latest/download/$YQ_BIN"
KUSTOMIZE="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_${KERNEL_NAME,,}_${ARCH}.tar.gz"

if [ ! -f "${HOME}/.local/bin/$YQ_BIN" ]; then
  mkdir -p ~/.local/bin
  echo "Downloading $YQ"
  curl -LO --progress-bar \
    "$YQ" \
    --output-dir "$HOME/.local/bin" \
    && chmod +x "$HOME/.local/bin/$YQ_BIN"
fi

if [ ! -f "${HOME}/.local/bin/kustomize" ]; then
  mkdir -p ~/.local/bin
  echo "Downloading $KUSTOMIZE"
  curl -sL --progress-bar \
    "$KUSTOMIZE" \
    | tar xz -C "$HOME/.local/bin" kustomize \
    && chmod +x "$HOME/.local/bin/kustomize"
fi

echo "Kustomize: $(kustomize version)"
$YQ_BIN --version

