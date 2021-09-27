#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-eoepca}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

echo -e "\nInstall k3d..."
./install-k3d.sh

echo -e "\nCreate the cluster..."
./create-cluster.sh "${CLUSTER_NAME}"
export KUBECONFIG=$(k3d kubeconfig write "${CLUSTER_NAME}")

echo -e "\nCluster post-installation steps..."
./cluster-post-install.sh

echo -e "\nCreate letsencrypt cluster issuer..."
kubectl apply -f cert-manager

echo -e "\neoepca helm repo..."
helm repo add eoepca https://eoepca.github.io/helm-charts/

echo -e "\nLogin service pre-requisites..."
kubectl apply -f login-service/yaml

echo -e "\nDeploy login-service..."
./login-service/login-service.sh upgrade -i
