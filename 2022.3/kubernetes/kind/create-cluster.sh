#!/bin/bash

set -xv
set -euo pipefail

KIND_NODE_IMAGE=${KIND_NODE_IMAGE:-"kindest/node:v1.22.5"}
REGISTRY_IMAGE=${REGISTRY_IMAGE:-"docker.io/library/registry:2"}
REGISTRY_NAME=${REGISTRY_NAME:-'kind-registry'}
REGISTRY_PORT=${REGISTRY_PORT:-'5000'}
CNC_NGINX_NS=${CNC_NGINX_NS:-"ingress-nginx"}

running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${REGISTRY_PORT}:5000" --name "${REGISTRY_NAME}" \
    "$REGISTRY_IMAGE"
fi

kind create cluster --config=config.yaml --image "$KIND_NODE_IMAGE"

docker network connect "kind" "${REGISTRY_NAME}" || true

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<-EOF  | kubectl apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: local-registry-hosting
      namespace: kube-public
    data:
      localRegistryHosting.v1: |
        host: "localhost:${REGISTRY_PORT}"
        help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

kubectl get nodes
kubectl wait --for=condition="Ready" nodes --all --timeout="15m"

kubectl apply -f ./metrics-server.yaml

kubectl create ns "$CNC_NGINX_NS" || true

helm install --namespace "$CNC_NGINX_NS" my-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --debug \
  --version 4.0.17 \
  --set controller.hostPort.enabled=true \
  --set controller.service.type=NodePort \
  --set controller.metrics.enabled=true \
  -f nginx-values.yaml

kubectl get pods -A
kubectl wait --namespace "$CNC_NGINX_NS" \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=10m
