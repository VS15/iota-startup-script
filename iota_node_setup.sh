#!/bin/bash

echo "Setting up your IOTA node.... (ETA around 20 min)"

###Docker setup - Ubuntu 16.04###

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo apt-get install -y jq

###IRI SETUP###

mkdir -p /iri/conf
mkdir /iri/data

###NEIGHBOORS CREATE###

touch /iri/conf/neighbors 
echo "udp://54.236.24.175:14600" > /iri/conf/neighbors
echo "udp://85.214.192.129:14600" >> /iri/conf/neighbors
echo "udp://159.203.66.78:14600" >> /iri/conf/neighbors

###INITIAL LAUNCH###

docker run -d --net=host --name iota-node-1 -e MIN_MEMORY=2G -e MAX_MEMORY=4G -e API_PORT=14265 -e UDP_PORT=14600 -e TCP_PORT=15600 -v /iri/data:/iri/data -v /iri/conf/neighbors:/iri/conf/neighbors bluedigits/iota-node:latest

###INTIAL STOP###

sudo docker stop iota-node-1 && sudo docker rm iota-node-1
sudo service docker restart

###UPDATE TANGLE DB###

wget https://iota.lukaseder.de/downloads/db.tar.bz2
tar xvf db.tar.bz2 &&

rm -vf /iri/data/mainnetdb/*

mv db/* /iri/data/mainnetdb/  

###Final Launch###
docker run -d --net=host --name iota-node-1 -e MIN_MEMORY=2G -e MAX_MEMORY=4G -e API_PORT=14265 -e UDP_PORT=14600 -e TCP_PORT=15600 -v /iri/data:/iri/data -v /iri/conf/neighbors:/iri/conf/neighbors bluedigits/iota-node:latest

###DISPLAY STATS###
echo "Your nodes and Neighbors Stats"

curl http://localhost:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1.4' -d '{"command":"getNeighbors"}'|jq

curl http://localhost:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1.4' -d '{"command":"getNodeInfo"}'|jq

echo "Your IOTA NODE IP and PORT Bitch....."

ifconfig eth0|grep inet\ addr|awk '{print $2,14265}'
