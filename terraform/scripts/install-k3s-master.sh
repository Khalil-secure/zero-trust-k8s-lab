#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y
apt-get install -y curl wget git unzip

# Install k3s master
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --disable servicelb \
  --write-kubeconfig-mode 644 \
  --token ${node_token} \
  --tls-san $(curl -s ifconfig.me)" sh -

# Wait for k3s to be ready
sleep 30

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
export PATH=$PATH:/root/istio-1.20.0/bin
istioctl install --set profile=minimal -y

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install OPA Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.14.0/deploy/gatekeeper.yaml

# Save kubeconfig
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/kubeconfig
chown ubuntu:ubuntu /home/ubuntu/kubeconfig

echo "✅ k3s master setup complete"
