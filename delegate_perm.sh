#!/bin/bash

ACCOUNT=$1
PKEY=$2
API=${3:-http://localhost:8888}

cleos set account permission $ACCOUNT delegateperm '{"threshold": 1,"keys": [{"key": "'$PKEY'","weight": 1}],"accounts": [{"permission":{"actor":"'$ACCOUNT'","permission":"eosio.code"},"weight":1}]}'  "active" -p $ACCOUNT@active
cleos set action permission $ACCOUNT eosio delegatebw delegateperm -p $ACCOUNT@active
cleos set action permission $ACCOUNT $ACCOUNT delegatebw delegateperm -p $ACCOUNT@active
