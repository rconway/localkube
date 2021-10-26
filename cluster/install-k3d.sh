#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

echo "Installing k3d..."
if ! hash k3d >/dev/null 2>&1; then
  echo "Installing k3d..."
  curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
else
  echo "  [skip] already installed"
fi
