curl -sSL https://bit.ly/2ysbOFE | bash -s -- 1.4.3
export PATH=$PATH:$PWD/../fabric-samples/bin
cd fabric-kube
./init.sh samples/splunk-fabric samples/chaincode
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm dependency update ./hlf-kube/
helm install hlf-kube --name hlf-kube -f samples/splunk-fabric/network.yaml -f samples/splunk-fabric/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false
./collect_host_aliases.sh samples/splunk-fabric/
helm upgrade hlf-kube ./hlf-kube -f samples/splunk-fabric/network.yaml -f samples/splunk-fabric/crypto-config.yaml -f samples/splunk-fabric/hostAliases.yaml
cd ../
helm install -n fabric-logger -f fabric-logger-values.yaml -f fabric-kube/samples/splunk-fabric/hostAliases.yaml ./fabric-logger 
sleep 15
kubectl exec hlf-cli -- bash hlf-scripts/channel-setup.sh
