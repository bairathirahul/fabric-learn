#!/bin/bash

peer channel fetch config ./channel-artifacts/config_block.pb -o $CORE_ORDERER_ADDRESS --tls --cafile $CORE_ORDERER_CA -c $CHANNEL_NAME
configtxlator proto_decode --input ./channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./channel-artifacts/config.json
configtxlator proto_decode --input ./channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./channel-artifacts/modified_config.json

read -p "Make changes in the modified_config.json file and press enter to continue"

configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb
configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/update.pb
configtxlator proto_decode --input ./channel-artifacts/update.pb --type common.ConfigUpdate
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(configtxlator proto_decode --input ./channel-artifacts/update.pb --type common.ConfigUpdate)'}}}' | jq . > ./channel-artifacts/update_in_envelope.json
configtxlator proto_encode --input ./channel-artifacts/update_in_envelope.json --type common.Envelope --output ./channel-artifacts/update_in_envelope.pb
