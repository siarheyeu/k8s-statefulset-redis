# Kubernetes StatefulSet with Redis

A hands-on demo of running **Redis as a StatefulSet** in Kubernetes with persistent storage, stable network identity, and replication.

## 🎯 Purpose

This project demonstrates:

- **StatefulSet** vs Deployment: stable pod names, ordered scaling, persistent volumes
- **Headless Service** for stable DNS names (`redis-0.redis`, `redis-1.redis`, etc.)
- **PersistentVolumeClaims** with dynamically provisioned storage
- **Redis replication** with master/slave topology
- **Failover testing** — what happens when the master pod dies
- **Data persistence** across pod restarts

## 📚 Why StatefulSet?

| Feature | Deployment | StatefulSet |
|---------|-----------|-------------|
| Pod names | Random (`app-7d8f9-abc`) | Stable (`redis-0`, `redis-1`) |
| Network identity | Load-balanced | Stable DNS per pod |
| Storage | Shared or ephemeral | Dedicated PVC per pod |
| Scaling order | Parallel | Sequential (0 → 1 → 2) |
| Use case | Stateless apps | Databases, queues, caches |

Redis needs **stable identity** and **persistent storage** — that's why StatefulSet.

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud)
- `kubectl` configured
- StorageClass that supports dynamic provisioning (default in minikube/kind)

### Deploy

bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/headless-service.yaml
kubectl apply -f k8s/statefulset.yaml
kubectl apply -f k8s/service.yaml
Or use the script:

bash
./scripts/deploy.sh
Verify
bash
kubectl get pods -n redis-demo -w
kubectl get pvc -n redis-demo
kubectl get svc -n redis-demo
You should see 3 pods: redis-0, redis-1, redis-2, each with its own PVC.

🧪 Experiments
1. Check Replication
Connect to the master and check replication status:

bash
kubectl exec -it redis-0 -n redis-demo -- redis-cli info replication
2. Write Data, Kill Pod, Read Data
bash
# Write to master
kubectl exec -it redis-0 -n redis-demo -- redis-cli set mykey "hello"

# Kill the pod
kubectl delete pod redis-0 -n redis-demo

# Wait for it to come back
kubectl wait --for=condition=Ready pod/redis-0 -n redis-demo --timeout=120s

# Read the data — it should persist
kubectl exec -it redis-0 -n redis-demo -- redis-cli get mykey
3. Failover Test
Run the failover script:

bash
./scripts/test-failover.sh
It will:

Identify the current master

Kill the master pod

Wait for a new master to be elected

Verify the new master

4. Scale Up/Down
bash
kubectl scale statefulset redis -n redis-demo --replicas=5
kubectl get pods -n redis-demo -w
📁 Project Structure
text
.
├── k8s/              # Kubernetes manifests
├── scripts/          # Deploy, test, cleanup
└── docs/             # Architecture notes
🧹 Cleanup
bash
./scripts/cleanup.sh
Or manually:

bash
kubectl delete namespace redis-demo
