#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-mykube}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# minikube
./install-minikube.sh

# kubernetes cluster
if ! k3d cluster list "${CLUSTER_NAME}" >/dev/null 2>&1; then
  echo -e "\nCreate cluster with k3d..."
  k3d cluster create "${CLUSTER_NAME}" \
    -p "80:80@loadbalancer" \
    -p "443:443@loadbalancer" \
    --k3s-arg "--disable=traefik@server:0" \
    --agents 1 \
    --wait
fi
export KUBECONFIG=$(k3d kubeconfig write "${CLUSTER_NAME}")

# Ingress controller
./nginx-ingress-controller.sh

# Certificate manager
./certificate-manager.sh

# Cluster Issuer
./letsencrypt/letsencrypt.sh

# Sealed Secrets
./sealed-secrets.sh "${CLUSTER_NAME}"

# Minio
./minio/minio.sh
