<p align="center">
  <img width="180" height="160" src="https://i.postimg.cc/J0mKhXCD/mo.png">
</p>

# MoralityDEX :money_with_wings:
Decentralized exchange for ERC20 tokens on the Ethereum blockchain (ERC20 -> ETH && ERC20 <- ETH)

The project contains:

1. The Morality DEX contract
2. The rate updater application (C#)

The DEX Contract Workflow:

1. Seller -> Approves payment to DEX contract (ERC20.approve(DEX_CONTRACT_ADDRESS, AMOUNT))
2. Seller -> Adds trade to contract 
3. DEX Contract -> Makes payment of behalf of "Seller" to itself (the ERC20 tokens for trade)
4. Buyer -> Purchases ERC20 token (some or all) - sends Ether (AMOUNT)
5. DEX Contract -> Sends Ether to "Seller"
6. DEX Contract -> Sends ERC20 tokens to "Buyer"

The Rate Updater Workflow (Cron Job - Hourly/Daily):

1. Checks hosted database for listed symbols
2. Gets rates for all symbols
3. Updates each symbol on the DEX contract
