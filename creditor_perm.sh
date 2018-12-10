#!/bin/bash

ACCOUNT=$1
API=${2:-http://localhost:8888}

cleos -u $API set account permission $ACCOUNT creditorperm '{"threshold": 1,"keys": [],"accounts": [{"permission":{"actor":"bankofstaked","permission":"eosio.code"},"weight":1}]}'  "active" -p $ACCOUNT@active
cleos -u $API set action permission $ACCOUNT $ACCOUNT delegatebw creditorperm -p $ACCOUNT@active
cleos -u $API set action permission $ACCOUNT eosio undelegatebw creditorperm -p $ACCOUNT@active
