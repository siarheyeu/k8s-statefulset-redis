#!/usr/bin/env bash
set -euo pipefail

echo "Deleting namespace redis-demo..."
kubectl delete namespace redis-demo --ignore-not-found=true

echo "Done."
