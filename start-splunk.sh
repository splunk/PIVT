#!/bin/bash
set -xe

kubectl create ns splunk
helm install splunk ./splunk-kube  -f ./splunk-kube/splunk.yaml
helm install splunk-connect-k8s -f ./splunk-kube/splunk-connect.yaml https://github.com/splunk/splunk-connect-for-kubernetes/releases/download/1.4.0/splunk-connect-for-kubernetes-1.4.0.tgz
