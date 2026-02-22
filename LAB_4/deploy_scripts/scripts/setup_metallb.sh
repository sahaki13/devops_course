#!/usr/bin/env bash

set -e

ns="kube-system"
mlb_ns="metallb-system"
metallb_version="v0.15.3"

# prepare
if kubectl get configmap kube-proxy -n $ns -o yaml | grep -q 'strictARP: false'
then
  echo "Need configure strictARP"
  kubectl get configmap kube-proxy -n $ns -o yaml \
    | sed 's|strictARP: false|strictARP: true|' \
    | kubectl apply -f -
  kubectl rollout restart daemonset kube-proxy -n $ns
else
  echo "strictARP configured already"
fi

# Simple way without helm
if kubectl get deployment controller -n "$mlb_ns" >/dev/null 2>&1; then
  echo "<<< MetalLB is already installed in $mlb_ns >>>"
else
  echo "Installing MetalLB ${metallb_version}..."
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/config/manifests/metallb-native.yaml

  # Waiting CRD, else "unknown resource"
  echo "<<< Waiting for MetalLB CRDs to be ready... >>>"
  kubectl wait --for=condition=established --timeout=60s crd/ipaddresspools.metallb.io
  kubectl wait --for=condition=established --timeout=60s crd/l2advertisements.metallb.io
fi


if kubectl get ipaddresspool libvirt-pool -n "$mlb_ns" >/dev/null 2>&1; then
  echo "<<< IPAddressPool 'libvirt-pool' already exists >>>"
else
  echo "<<< Applying MetalLB L2 configuration... >>>"
  cat <<EOF | kubectl apply -f -
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: libvirt-pool
  namespace: $mlb_ns
spec:
  # Address pool that MetalLB assign to services
  addresses:
    - 192.168.99.200-192.168.99.205
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: $mlb_ns
spec:
  # Assign to address pool
  ipAddressPools:
    - libvirt-pool
EOF

fi
