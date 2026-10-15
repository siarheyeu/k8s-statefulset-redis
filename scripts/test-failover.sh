#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="redis-demo"
PASSWORD="super-secret-password"

echo "=== Checking current master ==="
MASTER=$(kubectl exec -it redis-0 -n "${NAMESPACE}" -- redis-cli -a "${PASSWORD}" info replication | grep role:master || true)

if [ -z "$MASTER" ]; then
  echo "redis-0 is not the master. Checking redis-1..."
  MASTER_POD="redis-1"
else
  MASTER_POD="redis-0"
fi

echo "Current master: ${MASTER_POD}"

echo "=== Killing master pod ${MASTER_POD} ==="
kubectl delete pod "${MASTER_POD}" -n "${NAMESPACE}"

echo "=== Waiting for new master to be elected ==="
sleep 30

for pod in redis-0 redis-1 redis-2; do
  ROLE=$(kubectl exec -it "${pod}" -n "${NAMESPACE}" -- redis-cli -a "${PASSWORD}" info replication | grep role || true)
  echo "${pod}: ${ROLE}"
done

echo "=== Failover test complete ==="
