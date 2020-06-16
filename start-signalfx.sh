#!/bin/bash
helm repo add signalfx https://dl.signalfx.com/helm-repo
helm repo update
helm upgrade --install signalfx-agent -f signalfx/values.yaml  signalfx/signalfx-agent