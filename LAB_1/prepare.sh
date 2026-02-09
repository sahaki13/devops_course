#!/usr/bin/env bash

# https://releases.hashicorp.com/terraform/1.14.4/terraform_1.14.4_linux_amd64.zip
# git clone --depth=1 https://github.com/dmacvicar/terraform-provider-libvirt
# cd terraform-provider-libvirt
# make build
# make install

# _version="0.8.3"
_version="0.9.2"
_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_plugin_dir="$HOME/.terraform.d/plugins/registry.terraform.io/dmacvicar/libvirt/$_version/linux_amd64"

# tf
unzip $_script_dir/terraform_1.14.4_linux_amd64.zip -d ~/.local/bin
if ! grep -q "export PATH=\"\$PATH:~/.local/bin/\"" ~/.bashrc; then
    echo "export PATH=\"\$PATH:~/.local/bin/\"" >> ~/.bashrc
    . ~/.bashrc
fi

# libvirt provider
mkdir -pv ~/.terraform.d/plugins/registry.terraform.io/dmacvicar/libvirt/$_version/linux_amd64
curl -L -o /tmp/terraform-provider-libvirt_${_version}_linux_amd64.zip https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v$_version/terraform-provider-libvirt_${_version}_linux_amd64.zip
unzip /tmp/terraform-provider-libvirt_${_version}_linux_amd64.zip -d $_plugin_dir && rm /tmp/terraform-provider-libvirt_${_version}_linux_amd64.zip
cp -v $_script_dir/.terraformrc ~/
