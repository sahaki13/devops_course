#!/usr/bin/env bash

set -e

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
  echo -e "Error: This script must be run as root (privileged mode)."
  exit 1
fi

TARGET_USER=$(getent passwd 1000 | cut -d: -f1)
if [[ -z "$TARGET_USER" ]]; then
  echo "Error: No user with UID 1000 found."
  exit 1
fi

# Install packages
apt update && apt install -y --no-install-recommends python3 python3-pip make

# Switch to the user with UID 1000 and run commands
su - "$TARGET_USER" -c "
  mkdir -p ~/.local/bin

  if ! grep -q 'export PATH=\"\$PATH:\$HOME/.local/bin\"' ~/.bashrc; then
    echo 'export PATH=\"\$PATH:\$HOME/.local/bin\"' >> ~/.bashrc
  fi

  python3 -m pip install --break-system-packages --user ansible ansible-core ansible-lint argcomplete passlib

  # Install Ansible and check the version
  ~/.local/bin/activate-global-python-argcomplete --user
  ~/.local/bin/ansible --version
"

echo "INSTALLATION DONE"
