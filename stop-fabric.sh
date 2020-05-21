helm delete hlf-kube --purge
helm delete fabric-logger --purge
kubectl get pvc | awk '/hlf/{print $1}' | xargs kubectl delete pvc
