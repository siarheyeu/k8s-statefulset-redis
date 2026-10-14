#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="redis-demo"

echo "Deploying Redis StatefulSet to namespace ${NAMESPACE}..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/headless-service.yaml
kubectl apply -f k8s/statefulset.yaml
kubectl apply -f k8s/service.yaml

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod -l app=redis -n "${NAMESPACE}" --timeout=300s

echo "Done. Pods:"
kubectl get pods -n "${NAMESPACE}"
echo "PVCs:"
kubectl get pvc -n "${NAMESPACE}"
