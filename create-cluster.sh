#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-mykube}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# Default kube config
export KUBECONFIG=

# Cluster
k3d cluster create "${CLUSTER_NAME}" \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --k3s-server-arg --disable=traefik \
  --agents 1 \
  --kubeconfig-update-default=false \
  --wait
  # --agents 1 --agents-memory 8G \

# Config
k3d kubeconfig merge "${CLUSTER_NAME}" -d -s

# Nginx Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

# Cert Manager
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
