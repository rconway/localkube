#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# Nginx Ingress Controller
echo -e "\nDeploy the nginx ingress controller (will wait for readiness)..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx --wait >/dev/null

# The first time the ingress controller starts, two Jobs create the SSL Certificate used by the admission webhook.
# For this reason, there is an initial delay of up to two minutes until it is possible to create and validate Ingress definitions.
echo "[INFO]  Wait for ingress-nginx ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s 2>/dev/null
echo "[INFO]  ...ingress-nginx READY."
#
# Also the ingress-nginx admission controller seems to take a while to be ready...
function ingress_admission_ready_check() {
  interval=$((1))
  msgInterval=$((5))
  step=$((msgInterval / interval))
  count=$((0))
  status=$((1))
  while [ $status -ne 0 ]; do
    kubectl apply -f - <<EOF 2>/dev/null
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: readycheck
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: readycheck
          servicePort: 80
EOF
    status=$(($?))
    if [ $status -eq 0 ]; then break; fi
    test $((count % step)) -eq 0 && echo "[INFO]  Waiting for service/ingress-nginx-controller-admission"
    sleep $interval
    count=$((count + interval))
  done
  kubectl delete ingress/readycheck
}
echo "[INFO]  Wait for ingress-nginx admission ready..."
ingress_admission_ready_check
echo "[INFO]  ...ingress-nginx admission READY."
