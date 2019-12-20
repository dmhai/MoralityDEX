<p align="center">
  <img width="180" height="160" src="https://i.postimg.cc/J0mKhXCD/mo.png">
</p>

# MoralityDEX :currency_exchange:
Decentralized exchange for ERC20 tokens on the Ethereum blockchain (ERC20 --> ETH && ERC20 <-- ETH)

The project contains:

1. The Morality DEX contract (Solidity)
2. The rate updater application (C#)

 The DEX Contract Workflow:

1. :man_with_turban: Seller --> :+1: Approves token payment to :currency_exchange: DEX contract via token contract (ERC20.approve())
2. :man_with_turban: Seller --> :ticket: Adds trade to :currency_exchange: DEX contract 
3. :currency_exchange: DEX Contract --> :money_with_wings: Makes payment of behalf of :man_with_turban: "Seller" to itself (the ERC20 tokens for trade)
4. :girl: Buyer ---> :money_with_wings: Purchases ERC20 token (some or all) - sends Ether (AMOUNT)
5. :currency_exchange: DEX Contract --> Sends Ether to :man_with_turban: "Seller"
6. :currency_exchange: DEX Contract --> Sends ERC20 tokens to :girl: "Buyer"

The Rate Updater Workflow (Cron Job - Hourly/Daily):

1. Checks hosted database for listed symbols 
2. Gets rates for all symbols
3. Updates each symbol on the DEX contract

Morality Dex 📑

Address: 
Link on Rinkby.Etherscan: https://rinkeby.etherscan.io/address/
