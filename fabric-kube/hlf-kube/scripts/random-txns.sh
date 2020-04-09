#!/bin/bash
set -e

## Runs a few invokes against a channel to show transactions moving through.
declare -a CHANNELS=('buttercup-go' 'haunt' 'crisis-uprising' 'containment-apocalyse' 'rage-trilogy' 'chaos-oath');
declare -a USERNAMES=('jeff' 'nate' 'stephen' 'ryan');
CC_NAME="splunk_cc"

if [ -z $1 ]; then
	echo "No transactions per second arg passed, setting to 1 by default"
	TRANSACTIONS_PER_SECOND=1
else
	TRANSACTIONS_PER_SECOND=$1
fi

echo "================= Buttercup Go!!!! ================="
cat << "EOF"
                            _(\_/) 
                          ,((((^`\
                         ((((  (6 \ 
                       ,((((( ,    \
   ,,,_              ,(((((  /"._  ,`,
  ((((\\ ,...       ,((((   /    `-.-'
  )))  ;'    `"'"'""((((   (      
 (((  /            (((      \
  )) |                      |
 ((  |        .       '     |
 ))  \     _ '      `t   ,.')
 (   |   y;- -,-""'"-.\   \/  
 )   / ./  ) /         `\  \
    |./   ( (           / /'
    ||     \\          //'|
    ||      \\       _//'||
    ||       ))     |_/  ||
    \_\     |_/          ||
    `'"                  \_\
EOF

echo "Press [CTRL+C] to stop.."
while :
do
	for (( i = 0; i < $TRANSACTIONS_PER_SECOND; ++i ))
	do	
		if [ $((RANDOM % 2)) == 1 ]; then
			ORG_NAME="buttercup.example.com"
			PEER_NAME=peer0.buttercup.example.com
			CORE_PEER_ADDRESS=peer0.buttercup.example.com:7051
			MSP_ID=ButtercupMSP
			export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
			export CORE_PEER_ADDRESS=$PEER_NAME:7051
			export CORE_PEER_LOCALMSPID="$MSP_ID"
			export CORE_PEER_TLS_ROOTCERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/ca.crt
			export CORE_PEER_TLS_KEY_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.key
			export CORE_PEER_TLS_CERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.crt
		else
			ORG_NAME="popstar.example.com"
			MSP_ID=PopstarMSP
			PEER_NAME=peer0.popstar.example.com
			CORE_PEER_ADDRESS=peer0.popstar.example.com:7051
			export CORE_PEER_MSPCONFIGPATH=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
			export CORE_PEER_ADDRESS=$PEER_NAME:7051
			export CORE_PEER_LOCALMSPID="$MSP_ID"
			export CORE_PEER_TLS_ROOTCERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/ca.crt
			export CORE_PEER_TLS_KEY_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.key
			export CORE_PEER_TLS_CERT_FILE=/hlf_config/crypto-config/peerOrganizations/$ORG_NAME/peers/$PEER_NAME/tls/server.crt
		fi

		export ORDERER_CA=/hlf_config/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/tlscacerts/cert.pem
		user=${USERNAMES[$((RANDOM % 4))]}
		CHANNEL_NAME=${CHANNELS[$((RANDOM % 6))]}
		score=$((RANDOM % 100))
		peer chaincode invoke -o orderer.example.com:7050  \
							  --tls $CORE_PEER_TLS_ENABLED \
							  --cafile $ORDERER_CA  \
							  -C $CHANNEL_NAME -n $CC_NAME \
							  -c '{"Args":["update","'$user'","'$score'","+"]}'

	done

	echo $i" transactions posted."
	sleep 1
done
