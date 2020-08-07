#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
set -e

mkdir -p channel-artifacts
export MSYS_NO_PATHCONV=1
export FABRIC_CFG_PATH=/hlf_config
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/hlf_config/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/tlscacerts/cert.pem
export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/buttercup.example.com/users/Admin\@buttercup.example.com/msp
function createChannel() {
	CHANNEL_NAME=$1

	# Generate channel configuration transaction
	echo "========== Creating channel transaction for: "$CHANNEL_NAME" =========="
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ../channel-artifacts/$CHANNEL_NAME-channel.tx -channelID $CHANNEL_NAME
	res=$?
	if [ $res -ne 0 ]; then
	    echo "Failed to generate channel configuration transaction..."
	    exit 1
	fi	


	# Channel creation
	echo "========== Creating channel: "$CHANNEL_NAME" =========="
	peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ../channel-artifacts/$CHANNEL_NAME-channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

function joinChannel() {
	PEER_NAME=$1
	CHANNEL_NAME=$2
	MSP_ID=$3
	IS_ANCHOR=$4

	ORG_NAME=$( echo $PEER_NAME | cut -d. -f1 --complement)

	echo "========== Joining "$PEER_NAME" to channel "$CHANNEL_NAME" =========="
	export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
	export CORE_PEER_ADDRESS=$PEER_NAME:7051
	export CORE_PEER_LOCALMSPID="$MSP_ID"
	export CORE_PEER_TLS_ROOTCERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/ca.crt
	export CORE_PEER_TLS_KEY_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.key
	export CORE_PEER_TLS_CERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.crt
	peer channel join -b ${CHANNEL_NAME}.block

	if [ ${IS_ANCHOR} -ne 0 ]; then
		echo "========== Generating anchor peer definition for: "$CHANNEL_NAME" =========="
	    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ../channel-artifacts/$CHANNEL_NAME-${CORE_PEER_LOCALMSPID}anchors.tx -channelID $CHANNEL_NAME -asOrg $MSP_ID

		res=$?
		if [ $res -ne 0 ]; then
		    echo "Failed to generate channel configuration transaction..."
		    exit 1
		fi	
		# if anchor then update this.
		peer channel update -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ../channel-artifacts/${CHANNEL_NAME}-${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
	fi
}

function installChaincode() {
	PEER_NAME=$1
	CHAINCODE_NAME=$2
	MSP_ID=$3
	VERSION=$4
	ORG_NAME=$( echo $PEER_NAME | cut -d. -f1 --complement)

	mkdir -p $GOPATH/src/chaincode
    tar -xf /chaincode/high-throughput/high-throughput.tar -C $GOPATH/src/chaincode

	echo "========== Installing chaincode [${CHAINCODE_NAME}] on ${PEER_NAME} =========="
	export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
	export CORE_PEER_ADDRESS=$PEER_NAME:7051
	export CORE_PEER_LOCALMSPID="$MSP_ID"
	export CORE_PEER_TLS_ROOTCERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/ca.crt
	export CORE_PEER_TLS_KEY_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.key
	export CORE_PEER_TLS_CERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.crt
	peer chaincode install -n $CHAINCODE_NAME -v $VERSION -p chaincode/high-throughput
}

function instantiateChaincode() {
	PEER_NAME=$1
	CHANNEL_NAME=$2
	CHAINCODE_NAME=$3
	MSP_ID=$4
	VERSION=$5

	ORG_NAME=$( echo $PEER_NAME | cut -d. -f1 --complement)

	echo "========== Instantiating chaincode [${CHAINCODE_NAME}] on ${PEER_NAME} in ${CHANNEL_NAME} =========="
	export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
	export CORE_PEER_ADDRESS=$PEER_NAME:7051
	export CORE_PEER_LOCALMSPID="$MSP_ID"
	export CORE_PEER_TLS_ROOTCERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/ca.crt
	export CORE_PEER_TLS_KEY_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.key
	export CORE_PEER_TLS_CERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.crt
	peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED \
		--cafile $ORDERER_CA \
		-C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args": []}' \
		-v $VERSION -P "OR ('ButtercupMSP.member','PopstarMSP.member')"
}


# Create any number of channels here with new names.
createChannel "buttercup-go"
createChannel "haunt"
createChannel "crisis-uprising"
createChannel "containment-apocalyse"
createChannel "rage-trilogy"
createChannel "chaos-oath"

# Have any number of peers to join here. Third argument is ButtercupMSP or PopstarMSP, last arg is 1 or 0 for anchor peer or not. Can only have 1 anchor peer per org per channel.
joinChannel "peer0.buttercup.example.com" "buttercup-go" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "buttercup-go" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "buttercup-go" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "buttercup-go" "PopstarMSP" 0

joinChannel "peer0.buttercup.example.com" "haunt" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "haunt" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "haunt" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "haunt" "PopstarMSP" 0

joinChannel "peer0.buttercup.example.com" "crisis-uprising" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "crisis-uprising" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "crisis-uprising" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "crisis-uprising" "PopstarMSP" 0

joinChannel "peer0.buttercup.example.com" "containment-apocalyse" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "containment-apocalyse" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "containment-apocalyse" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "containment-apocalyse" "PopstarMSP" 0

joinChannel "peer0.buttercup.example.com" "rage-trilogy" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "rage-trilogy" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "rage-trilogy" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "rage-trilogy" "PopstarMSP" 0

joinChannel "peer0.buttercup.example.com" "chaos-oath" "ButtercupMSP" 1
joinChannel "peer1.buttercup.example.com" "chaos-oath" "ButtercupMSP" 0
joinChannel "peer0.popstar.example.com" "chaos-oath" "PopstarMSP" 1
joinChannel "peer1.popstar.example.com" "chaos-oath" "PopstarMSP" 0

# Install chaincode onto peers. Do not worry about channels here.
installChaincode "peer0.buttercup.example.com" "splunk_cc" "ButtercupMSP" 1.0
installChaincode "peer1.buttercup.example.com" "splunk_cc" "ButtercupMSP" 1.0
installChaincode "peer0.popstar.example.com" "splunk_cc" "PopstarMSP" 1.0
installChaincode "peer1.popstar.example.com" "splunk_cc" "PopstarMSP" 1.0

# Instantiate chaincode on each channel.
instantiateChaincode "peer0.popstar.example.com" "buttercup-go" "splunk_cc" "PopstarMSP" 1.0
instantiateChaincode "peer0.popstar.example.com" "haunt" "splunk_cc" "PopstarMSP" 1.0
instantiateChaincode "peer0.popstar.example.com" "crisis-uprising" "splunk_cc" "PopstarMSP" 1.0
instantiateChaincode "peer0.popstar.example.com" "containment-apocalyse" "splunk_cc" "PopstarMSP" 1.0
instantiateChaincode "peer0.popstar.example.com" "rage-trilogy" "splunk_cc" "PopstarMSP" 1.0
instantiateChaincode "peer0.popstar.example.com" "chaos-oath" "splunk_cc" "PopstarMSP" 1.0
