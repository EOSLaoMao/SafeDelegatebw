#!/bin/bash

docker ps | grep safedelegatebw-eos-dev
if [ $? -ne 0 ]; then
    echo "Run eos dev env "
    docker run --name safedelegatebw-eos-dev -dit --rm -v  `(pwd)`:/safedelegatebw eoslaomao/eos-dev:1.2.3
fi

docker exec safedelegatebw-eos-dev eosiocpp -g /safedelegatebw/safedelegatebw.abi /safedelegatebw/safedelegatebw.cpp
docker exec safedelegatebw-eos-dev eosiocpp -o /safedelegatebw/safedelegatebw.wast /safedelegatebw/safedelegatebw.cpp 
##docker exec eos-dev cleos -u http://$HOST:8888 --wallet-url http://$HOST:8900 set contract safedelegatebw ../safedelegatebw -p safedelegatebw@active
docker cp ../safedelegatebw nodeosd:/
