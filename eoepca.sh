#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

CLUSTER_NAME="${1:-mykube}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

echo "Install k3d..."
./install-k3d.sh

echo "Create the cluster..."
./create-cluster.sh eoepca

echo "Create letsencrypt cluster issuer..."
kubectl apply -f cert-manager

echo "Login service pre-requisites..."
kubectl apply -f login-service/yaml

echo "Deploy login-service..."
./login-service/login-service.sh upgrade -i
