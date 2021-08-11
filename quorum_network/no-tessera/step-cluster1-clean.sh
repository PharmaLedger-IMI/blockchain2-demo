aws eks --region eu-central-1 update-kubeconfig --name pl-cluster4
kubectl delete -f ./cluster1/step3-deployments
kubectl delete -f ./cluster1/step2
kubectl delete -f ./common-step1




