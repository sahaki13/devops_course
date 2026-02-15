#!/usr/bin/env bash

set -e

# Update PATH in .bashrc if not already present
if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found. Install kubectl before."
  exit 1
fi

if ! grep -q "alias k=kubectl" ~/.bashrc; then
  cat <<EOF >> ~/.bashrc

alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k
EOF
  echo "The alias and completion have been added to ~/.bashrc"
else
  echo "Already exists in ~/.bashrc"
fi
