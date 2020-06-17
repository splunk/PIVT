#!/bin/bash
# Install prometheus-operator
helm upgrade --install prometheus-operator --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false stable/prometheus-operator

kubectl apply -f signalfx-prometheus-operator/serviceMonitor-hlf.yml

helm repo add signalfx https://dl.signalfx.com/helm-repo
helm repo update
helm upgrade --install signalfx-agent -f signalfx-prometheus-operator/signalfx-values.yaml  signalfx/signalfx-agent