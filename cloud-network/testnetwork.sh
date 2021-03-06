#!/bin/bash
export FABRIC_CFG_PATH=${PWD}
# GIVE A CHANNEL NAME OF YOUR OWN CHOICE
export CHANNEL_NAME=mychannel 

# Generating crytographic material :- Certs
echo "=========================================="
echo "        Generating Certificates           "
echo "=========================================="
./cryptogen generate --config=./crypto-config.yaml

# Generating Orderer and Genesis block
echo "=========================================="
echo "     Creating Orderer Genesis Block       "
echo "=========================================="
mkdir channel-artifacts
chmod 777 *
./configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

# Creating a Channel Config Transaction
echo "=========================================="
echo "         Creating Channel Config          "
echo "=========================================="
./configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

# Defining Anchor peers from all organisations

echo "=========================================="
echo "          Defining Anchor Peers           "
echo "=========================================="
echo ""
echo ""
echo "Org1......."
./configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
echo "Org2......."
./configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
echo "Org3......."
./configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP

# Setting up the network using docker compose
echo "=========================================="
echo "           Setting up Network             "
echo "=========================================="
export IMAGE_TAG=latest
docker-compose -f docker-compose-cli.yaml up -d
docker exec cli scripts/functions.sh