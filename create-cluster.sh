#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-mykube}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# Cluster
echo -e "\nCreate cluster with k3d..."
k3d cluster create "${CLUSTER_NAME}" \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --agents 1 \
  --wait

# Merge config to default location
KUBECONFIG= k3d kubeconfig merge eoepca -d -s
