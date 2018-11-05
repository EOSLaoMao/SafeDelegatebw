[点击这里查看中文介绍](./README-CN.md)


## Intro

In order to lower the risk of creditor account granting delegatebw permission to Bank of Staked, we have built a smart contract called SafeDelegatebw.

As we know it, there is a 5th parameter in system contract's `delegatebw` action called `transfer`, which can be specified as `true` meaning transfer the ownership of the EOS you staked to the beneficiary account, which is pretty risky. Bank of Staked set `transfer` to `false` while it calls creditors `delegatebw` action, but still, there is a single point failure risk here. Thats why we built SafeDelegatebw.

## Design of SafeDelegatebw 

SafeDelegatebw wraps up a new customized interface also named `delegatebw` with only 3 parameters(without `from` and `transfer` as in system contract) and hardcodes `transfer` to `false` while it calls system contract. creditor account deployed `SafeDelegatebw` can just grant this customized `delegatebw` action to Bank of Staked instead of the one from system contract.

Code is open source: https://github.com/EOSLaoMao/safedelegatebw

The only cost we see here is an additional 60K RAM. We will have detailed guide for creditors to set it up later.

## setup safe creditor for Bank of Staked using SafeDelegatebw

### First, deploy SafeDelegatebw contract to creditor account

1. deploy:

```
cleos -u https://api.eoslaomao.com set contract CREDITOR safedelegatebw/
```

2. grant system contract's `delegatebw` action permission to a new permission `delegateperm`, which will be used only for SafeDelegatebw:

```
./delegate_perm.sh CREDITOR PUBKEY https://api.eoslaomao.com
```

now the permission structure of creditor account would be like:

```
cleos -u https://api.eoslaomao.com get account CREDITOR

permissions:
     owner     1:    1 OWNER_KEY
        active     1:    1 ACTIVE_KEY
           delegateperm     1:    1 PUBKEY    1 CREDITOR@eosio.code
```

### Grant creditor delegate/undelegate permission to Bank of Staked

1. Create `creditorperm` permission and grant it to `bankofstaked@eosio`

```
cleos -u https://api.eoslaomao.com set account permission CREDITOR creditorperm '{"threshold": 1,"keys": [],"accounts": [{"permission":{"actor":"bankofstaked","permission":"eosio.code"},"weight":1}]}'  "active" -p CREDITOR@active
```

2. Grant these two actions permission to `creditorperm`:

    `delegatebw action from CREDITOR(SafeDelegatebw)`

    `undelegatebw action from eosio (System Contract)`


```
cleos -u https://api.eoslaomao.com set action permission CREDITOR CREDITOR delegatebw creditorperm -p CREDITOR@active
cleos -u https://api.eoslaomao.com set action permission CREDITOR eosio undelegatebw creditorperm -p CREDITOR@active
```

Finally the permission structure of creditor account would like:

```
cleos -u https://api.eoslaomao.com get account CREDITOR

permissions:
     owner     1:    1 OWNER_KEY
        active     1:    1 ACTIVE_KEY
           delegateperm     1:    1 PUBKEY    1 CREDITOR@eosio.code
           creditorperm     1:    1 bankofstaked@eosio.code
```

Now it's all set, contact Bank of Staked to add it to creditor table to start leasing your EOS(which is only aval to BPs for now)
