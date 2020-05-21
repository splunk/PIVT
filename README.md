# Hyperledger Fabric meets Kubernetes
![Fabric Meets K8S](https://raft-fabric-kube.s3-eu-west-1.amazonaws.com/images/fabric_meets_k8s.png)

* [What is this?](#what-is-this)
* [Requirements](#requirements)
* [Network Architecture](#network-architecture)
* [Launching the network](#launching-the-network)
* [View in Splunk](#view-in-splunk)
* [Generate Transactions](#generate-transactions)



## [What is this?](#what-is-this)
This repository contains a couple of Helm charts to:
* Launch splunk and monitor kubernetes with splunk connect for kubernetes.
* Configure and launch the whole HL Fabric network:
  * A scaled up one, multiple peers per organization and Raft orderers
  * Monitor fabric transactions and events with splunk connect for hyperledger fabric

## [Requirements](#requirements)
* A running Kubernetes cluster, Microk8s should also work
* [HL Fabric binaries](https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html)
* [Helm](https://github.com/helm/helm/releases/tag/v3.2.1), developed with 3.2.1, newer 3.xx versions should also work
* [jq](https://stedolan.github.io/jq/download/) 1.5+
> `brew install jq`
* [yq](https://pypi.org/project/yq/) 2.6+
> `brew install python-yq`

## [Network Architecture](#network-architecture)

### Scaled Up Raft Network Architecture

![Scaled Up Raft Network](https://raft-fabric-kube.s3-eu-west-1.amazonaws.com/images/HL_in_Kube_raft.png)
**Note:** For transparent load balancing TLS should be disabled. This is only possible for Raft orderers since Fabric 1.4.5. See the [Scaled-up Raft network without TLS](#scaled-up-raft-network-without-tls) sample for details.


## [Launching The Network](#launching-the-network)
First install install splunk chart:
```
./start-splunk.sh
```
Wait for splunk-splunk-kube to start up and go to running.
```
kubectl get pods -w
```
Install the SignalFx agent:
```
./start-signalfx.sh
```

Now, we are ready to launch the network:
```
./start-fabric.sh
```
This chart creates all the above mentioned secrets, pods, services, etc. cross configures them 
and launches the network.

There will be 6 channels created and "splunk_cc" chaincode instantiated.

Congratulations you have a running HL Fabric network in Kubernetes!


## [Generate Transactions](#generate-transactions)

```
kubectl exec hlf-cli -- bash hlf-scripts/random-txns.sh
```

## [View in Splunk](#view-in-splunk)
Get the ip to access your splunk instance.
```
kubectl get services splunk-splunk-kube
```
Navigate to http://{{splunk ip}}:8080/en-US/app/splunk-hyperledger-fabric/introduction

Login with user admin password changeme


## [Limitations](#limitations)

### TLS

Transparent load balancing is not possible when TLS is globally enabled. So, instead of `Peer-Org`, `Orderer-Org` or `Orderer-LB` services, you need to connect to individual `Peer` and `Orderer` services.

Running Raft orderers without globally enabling TLS is possible since Fabric 1.4.5. See [Scaled-up Raft network without TLS](#scaled-up-raft-network-without-tls) sample for details.


## [Conclusion](#conclusion)

So happy BlockChaining in Kubernetes :)

And don't forget the first rule of BlockChain club:

**"Do not use BlockChain unless absolutely necessary!"**

*Hakan Eryargi (r a f t)*
