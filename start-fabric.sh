#!/bin/bash
set +ex
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s -- 1.4.1
export PATH=$PATH:$PWD/fabric-samples/bin

cd fabric-kube
./init.sh samples/splunk-fabric samples/chaincode
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm dependency update ./hlf-kube/
helm install hlf-kube hlf-kube -f samples/splunk-fabric/network.yaml -f samples/splunk-fabric/crypto-config.yaml -f samples/splunk-fabric/persistence.yaml --set peer.launchPods=false --set orderer.launchPods=false
./collect_host_aliases.sh samples/splunk-fabric/
helm upgrade hlf-kube ./hlf-kube -f samples/splunk-fabric/network.yaml -f samples/splunk-fabric/crypto-config.yaml -f samples/splunk-fabric/persistence.yaml -f samples/splunk-fabric/hostAliases.yaml
cd ../
helm install -n fabric-logger -f fabric-logger-values.yaml -f fabric-kube/samples/splunk-fabric/hostAliases.yaml ./fabric-logger
until ! kubectl get pods | grep hlf | grep -E 'ContainerCreating|Pending|Error'
do
  echo 'Waiting for fabric to start'
  sleep 5
done

kubectl exec hlf-cli -- bash hlf-scripts/channel-setup.sh
