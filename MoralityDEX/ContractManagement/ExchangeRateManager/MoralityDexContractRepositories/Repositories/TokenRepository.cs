using Nethereum.StandardTokenEIP20;
using Nethereum.Web3;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexContractRepositories.Repositories
{
    public class TokenRepository : StandardTokenService
    {
        public TokenRepository(Web3 web3, string contractAddress) : base(web3, contractAddress) { }

        public Web3 GetWeb3()
        {
            return this.Web3;
        }
    }
}
