# 4 Nodes Quorum Network deployed on 2 clusters example

We followed [quorum official guideline](https://github.com/jpmorganchase/qubernetes#generating-quorum-and-k8s-resources-from-custom-configs) and generated k8s template to deploy a **4 Nodes Quorum Network**

Start by applying the k8s files from step0 in each cluster(1 and 2)

```
#select the kubernetes cluster that you want to use as cluster 1
...
#apply in your cluster1 the step0 yaml files from step0
kubectl apply -f cluster1/step0

#list and save the external-ip of the newly deployed services
kubectl get services

#select the kubernetes cluster that you want to use as cluster 2
...
#apply in your cluster2 the step0 yaml files from step0
kubectl apply -f cluster2/step0

#list and save the external-ip of the newly deployed services
kubectl get services

```

Update the quorum-env-config configmap available in common-step1 by updating the external addresses for <b>QUORUM_NODE1_SERVICE_HOST, QUORUM_NODE2_SERVICE_HOST, QUORUM_NODE3_SERVICE_HOST, QUORUM_NODE4_SERVICE_HOST</b>

```
cd common-step1
nano 02-quorum-shared-config.yaml
...
```

Deploy the configmaps on both clusters
```
#select the kubernetes cluster that you want to use as cluster 1
...
#apply in your cluster1 the step1 yaml files from common-step1
kubectl apply -f common-step1

#select the kubernetes cluster that you want to use as cluster 2
...
#apply in your cluster2 the step1 yaml files from common-step1
kubectl apply -f common-step1
```

At this point continue with node deployment on each cluster
```
#select the kubernetes cluster that you want to use as cluster 1
...
#apply in your cluster1 the step2 and step3 yaml files 
kubectl apply -f cluster1/step2
kubectl apply -f cluster1/step3-deployments

#select the kubernetes cluster that you want to use as cluster 2
...
#apply in your cluster2 the step2 and step3 yaml files 
kubectl apply -f cluster2/step2
kubectl apply -f cluster2/step3-deployments
```
