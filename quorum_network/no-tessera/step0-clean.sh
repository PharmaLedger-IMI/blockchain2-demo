aws eks --region eu-central-1 update-kubeconfig --name pl-cluster4
kubectl delete -f ./cluster2/step0

aws eks --region eu-central-1 update-kubeconfig --name pl-cluster4
kubectl delete -f ./cluster1/step0
