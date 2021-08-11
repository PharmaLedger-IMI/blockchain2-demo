aws eks --region eu-central-1 update-kubeconfig --name pl-cluster4


kubectl apply -f ./cluster2/step0
kubectl get services


kubectl apply -f ./cluster1/step0
kubectl get services
