# Architecture

## Components

- **StatefulSet `redis`** — 3 replicas, each with a stable name (`redis-0`, `redis-1`, `redis-2`)
- **Headless Service `redis-headless`** — provides stable DNS names for each pod
- **Service `redis`** — ClusterIP for client access
- **ConfigMap `redis-config`** — Redis configuration
- **Secret `redis-secret`** — Redis password
- **PVC per pod** — 1Gi per replica, dynamically provisioned

## Network Identity

Each pod gets a stable DNS name:

redis-0.redis-headless.redis-demo.svc.cluster.local
redis-1.redis-headless.redis-demo.svc.cluster.local
redis-2.redis-headless.redis-demo.svc.cluster.local

This is critical for replication: slaves connect to the master by its stable DNS name.

## Storage

Each pod has its own PVC (`data-redis-0`, `data-redis-1`, `data-redis-2`). When a pod is rescheduled, it reattaches to the same PVC — data persists.

## Replication

- `redis-0` is the initial master.
- `redis-1` and `redis-2` are replicas.
- On failover, a new master is elected (manually or via Sentinel in production).

## Scaling

- Scale up: `kubectl scale statefulset redis -n redis-demo --replicas=5`
- Pods are created sequentially: `redis-3`, then `redis-4`.
- Scale down: pods are deleted in reverse order (`redis-4`, then `redis-3`).
