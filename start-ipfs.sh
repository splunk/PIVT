#!/bin/bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm install ipfs stable/ipfs