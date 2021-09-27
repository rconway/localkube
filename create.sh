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
k3d cluster create "${CLUSTER_NAME}" \
  -p "9080:80@loadbalancer" \
  -p "9443:443@loadbalancer" \
  --k3s-server-arg --disable=traefik \
  --agents 1 --agents-memory 8G \
  --kubeconfig-update-default=false \
  --wait

# Config
mkdir -p kubernetes
k3d kubeconfig get "${CLUSTER_NAME}" >kubernetes/kube_config_cluster.yml
chmod 600 kubernetes/kube_config_cluster.yml
kubemerge
export KUBECONFIG="${PWD}/kubernetes/kube_config_cluster.yml"

# Nginx Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
