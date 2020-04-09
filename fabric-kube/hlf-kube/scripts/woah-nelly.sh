#!/bin/bash

## Runs a few invokes against a channel to show transactions moving through.

CHANNEL_NAME="haunt"
CC_NAME="splunk_cc"
OP="+"

echo "================= Welcome to Haunt, mate!!!! ================="
cat << "EOF"
       (\-"""-/)
        |     |
        \ ^ ^ /  .-.
         \_o_/  / /
        /`   `\/  |
       /       \  |
       \ (   ) /  |
      / \_) (_/ \ /
     |   (\-/)   |
     \  --^o^--  /
      \ '.___.' /
     .'  \-=-/  '.
    /   /`   `\   \
   (//./       \.\\)
    `"`         `"`
EOF

peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["update","buttercup","0","+"]}' 2> /dev/null

peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["update","seabiscuit","0","+"]}' 2> /dev/null

for (( i = 0; i < 150; ++i ))
do
	if [ $((RANDOM % 2)) == 1 ]; then
		VAR="buttercup"
	else
		VAR="seabiscuit"
	fi

	VAL=$((RANDOM % 10))

	echo "$VAR moves forward $VAL paces!"
	peer chaincode invoke -o orderer.example.com:7050  \
						  --tls $CORE_PEER_TLS_ENABLED \
						  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
						  -C $CHANNEL_NAME -n $CC_NAME \
						  -c '{"Args":["update","'$VAR'","'$VAL'","'$OP'"]}' 2> /dev/null &
done


peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["get","buttercup"]}' 2>&1 >/dev/null \
					  | python -c 'import sys, json, re; print "Buttercup has a score of: " + re.search(".*payload:\"(\d+)\"", json.load(sys.stdin)["msg"]).group(1)'



peer chaincode invoke -o orderer.example.com:7050  \
					  --tls $CORE_PEER_TLS_ENABLED \
					  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
					  -C $CHANNEL_NAME -n $CC_NAME \
					  -c '{"Args":["get","seabiscuit"]}' 2>&1 >/dev/null \
					  | python -c 'import sys, json, re; print "Seabiscuit has a score of: " + re.search(".*payload:\"(\d+)\"", json.load(sys.stdin)["msg"]).group(1)'
