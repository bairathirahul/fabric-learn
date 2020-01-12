peer channel fetch config ./channel-artifacts/config_block.pb -o $CORE_ORDERER_ADDRESS --tls --cafile $CORE_ORDERER_CA -c $CHANNEL_NAME
configtxlator proto_decode --input ./channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./channel-artifacts/config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ./channel-artifacts/config.json ./channel-artifacts/org3.json > ./channel-artifacts/modified_config.json 
configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb
configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/org3_update.pb
configtxlator proto_decode --input ./channel-artifacts/org3_update.pb --type common.ConfigUpdate | jq . > ./channel-artifacts/org3_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat ./channel-artifacts/org3_update.json)'}}}' | jq . > ./channel-artifacts/org3_update_in_envelope.json
configtxlator proto_encode --input ./channel-artifacts/org3_update_in_envelope.json --type common.Envelope --output ./channel-artifacts/org3_update_in_envelope.pb
peer channel signconfigtx -f ./channel-artifacts/org3_update_in_envelope.pb
