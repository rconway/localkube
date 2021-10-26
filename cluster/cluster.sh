#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-mykube}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# k3d
./install-k3d.sh

# kubernetes cluster
echo -e "\nCreate cluster with k3d..."
k3d cluster create "${CLUSTER_NAME}" \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --agents 1 \
  --wait
export KUBECONFIG=$(k3d kubeconfig write "${CLUSTER_NAME}")

# Ingress controller
./nginx-ingress-controller.sh

# Certificate manager
./certificate-manager.sh

# Cluster Issuer
./letsencrypt/letsencrypt.sh
