## Intro

为了降低 creditor 账户直接把系统合约的 delegatebw 暴露给 Bank of Staked 的风险，我们做了个 SafeDelegatebw 合约。

SafeDelegatebw 合约用于部署在 creditor 账户，避免直接暴露系统合约的 delegatebw 接口给 Bank of Staked。

系统合约的 delegatebw 接口第 5 个参数 transfer 可以在给对方抵押的时候，同时指定是否把抵押的这部分 token 的所有权也转移给对方，是非常危险的一个操作。

尽管 Bank of Staked 的合约在调用 creditor 的系统合约 delegatebw 接口的时候已经写死了第 5 个参数是 false，但依然存在 Bank of Staked 合约被黑，全部 creditor 账户的 token 被恶意转走的可能性。

## SafeDelegatebw 实现思路

将系统合约的 delegatebw 封装了一下，第 5 个参数 transfer 写死成 false。creditor 改为授权账户本身合约的 delegatebw 接口权限给 Bank of Staked，而不是直接授权系统合约的 delegatebw 接口。

合约代码：https://github.com/EOSLaoMao/safedelegatebw

优点：大大降低 Bank of Staked 合约的单点风险。
唯一的缺点：部署成本，需要大约 60K 的 RAM。

## 基于 SafeDelegatebw 合约提供 Bank of Staked 的 creditor 账户

### 第一步，部署 SafeDelegatebw 合约到 creditor 账户

1. 验证 wasm 哈希并部署合约：

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) 请确保 wasm 的哈希准确无误：

```
cat safedelegatebw.wasm | shasum -a 256
3da535cdb8e47384e3af6e9583f4ec7a82cc2f9f4a188c2c477130fe21b2cfc3  -

cat safedelegatebw.wasm | md5
0c780517f8e9154423606f9cf8c1f0f4
```

部署合约：

```
cleos -u https://api.eoslaomao.com set contract CREDITOR safedelegatebw/
```

2. 增加 delegateperm 权限并将系统合约的 delegatebw 权限授权给 delegateperm：

```
./delegate_perm.sh CREDITOR https://api.eoslaomao.com
```

完成之后 creditor 账户的权限结构如下：

```
cleos -u https://api.eoslaomao.com get account CREDITOR

permissions:
     owner     1:    1 OWNER_KEY
        active     1:    1 ACTIVE_KEY
           delegateperm     1:    1 CREDITOR@eosio.code
```

### 第二步，授权 creditor 账户的 delegatebw 权限给 BankofStaked

增加 creditorperm 权限，并将 creditor 账户部署的 SafeDelegatebw 的 delegatebw 权限，以及系统合约的 undelegatebw 权限授权给 Bank of Staked

1. 新增 creditorperm 权限，授权给 bankofstaked 账户的 eosio.code：

```
cleos -u https://api.eoslaomao.com set account permission CREDITOR creditorperm '{"threshold": 1,"keys": [],"accounts": [{"permission":{"actor":"bankofstaked","permission":"eosio.code"},"weight":1}]}'  "active" -p CREDITOR@active
```

2. 授权 SafeDelegatebw 的 delegatebw 合约权限给 creditorperm

```
cleos -u https://api.eoslaomao.com set action permission CREDITOR CREDITOR delegatebw creditorperm -p CREDITOR@active
```


2. 授权系统合约的 undelegatebw 合约权限给 creditorperm

```
cleos -u https://api.eoslaomao.com set action permission CREDITOR eosio undelegatebw creditorperm -p CREDITOR@active
```

最终 CREDITOR 账户的权限结构如下所示：

```
cleos -u https://api.eoslaomao.com get account CREDITOR

permissions:
     owner     1:    1 OWNER_KEY
        active     1:    1 ACTIVE_KEY
           delegateperm     1:    1 CREDITOR@eosio.code
           creditorperm     1:    1 bankofstaked@eosio.code
```

至此，基于 SafeDelegatebw 合约的 creditor 账户权限设置完毕。接下来联系 Bank of Staked 官方人员将该账户加入到 creditor 表，即可开始自动出租 CPU/NET 资源。[https://t.me/BOSCreditor](https://t.me/BOSCreditor)
