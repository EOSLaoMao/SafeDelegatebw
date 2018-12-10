#!/bin/bash

ACCOUNT=$1
API=${2:-http://localhost:8888}

cleos -u $API set account permission $ACCOUNT delegateperm '{"threshold": 1,"keys": [],"accounts": [{"permission":{"actor":"'$ACCOUNT'","permission":"eosio.code"},"weight":1}]}'  "active" -p $ACCOUNT@active
cleos -u $API set action permission $ACCOUNT eosio delegatebw delegateperm -p $ACCOUNT@active
cleos -u $API set action permission $ACCOUNT $ACCOUNT delegatebw delegateperm -p $ACCOUNT@active
