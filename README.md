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

## Intro

In order to lower the risk of creditor account granting delegatebw permission to Bank of Staked, we have built a smart contract called SafeDelegatebw.

As we know it, there is a 5th parameter in system contract's `delegatebw` action called `transfer`, which can be specified as `true` meaning transfer the ownership of the EOS you staked to the beneficiary account, which is pretty risky. Bank of Staked set `transfer` to `false` while it calls creditors `delegatebw` action, but still, there is a single point failure risk here. Thats why we built SafeDelegatebw.

## Design of SafeDelegatebw 

SafeDelegatebw wraps up a new customized interface also named `delegatebw` with only 3 parameters(without `from` and `transfer` as in system contract) and hardcodes `transfer` to `false` while it calls system contract. creditor account deployed `SafeDelegatebw` can just grant this customized `delegatebw` action to Bank of Staked instead of the one from system contract.

Code is open source: https://github.com/EOSLaoMao/safedelegatebw

The only cost we see here is an additional 60K RAM. We will have detailed guide for creditors to set it up later.
