  #!/bin/bash
set -e

apt-get update -y
apt-get upgrade -y
apt-get install -y curl

# Join k3s cluster
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${master_ip}:6443" \
  K3S_TOKEN="${node_token}" \
  sh -

echo "✅ k3s worker joined cluster"
