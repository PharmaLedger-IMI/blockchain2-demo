aws eks --region eu-central-1 update-kubeconfig --name pl-cluster4
kubectl apply -f ./common-step1
kubectl apply -f ./cluster1/step2
kubectl apply -f ./cluster1/step3-deployments
