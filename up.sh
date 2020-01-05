export CHANNEL_NAME=cert
rm -rf crypto-config/*
rm -rf channel-artifacts/*
../fabric-samples/bin/cryptogen  generate --config=./crypto-config.yaml
../fabric-samples/bin/configtxgen -profile CertGenesis -channelID cert-sys-channel -outputBlock ./channel-artifacts/genesis.block
../fabric-samples/bin/configtxgen -profile CertChannel -channelID $CHANNEL_NAME -outputCreateChannelTx ./channel-artifacts/channel.tx
../fabric-samples/bin/configtxgen -profile CertChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
../fabric-samples/bin/configtxgen -profile CertChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

docker-compose -f org0/docker-compose.yaml -f org1/docker-compose.yaml -f org2/docker-compose.yaml up -d

docker exec -it cli.org1.com bash