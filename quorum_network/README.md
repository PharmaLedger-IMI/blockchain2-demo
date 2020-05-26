# N Node Quorum Network On Kubernetes

We followed [quorum official guideline](https://github.com/jpmorganchase/qubernetes#generating-quorum-and-k8s-resources-from-custom-configs) and generated k8s template to deploy a **4 Nodes Quorum Network**

Deploy resources to kubernetes cluster

```
kubectl apply -f k8s
```

Deploy nodes to kubernetes cluster


```
kubectl apply -f k8s/deployments
```

Deleting the nodes
```
kubectl delete -f k8s/deployments
```

Deleting the resources
```
kubectl delete -f k8s
```