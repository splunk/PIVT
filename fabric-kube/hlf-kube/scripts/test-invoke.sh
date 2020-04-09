#!/bin/bash

if [ -z "$1" ]; then
	echo "Set the channel name as the first argument."
	exit 1
fi

CHANNEL_NAME=$1
CC_NAME="splunk_cc"
OP="+"

peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["update","test_data","100","+"]}'

echo "Wait 2 seconds for validation..."
sleep 2

peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["get","test_data"]}'

