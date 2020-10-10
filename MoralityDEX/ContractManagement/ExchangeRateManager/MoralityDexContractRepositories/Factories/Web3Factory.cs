using MoralityDexContractRepositories.Repositories;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexContractRepositories.Factories
{
    public class Web3Factory
    {
        public static Web3 GetWeb3(string endpointAddress, string adminPass)
        {
            var pk = new Account(adminPass);
            var web3 = new Web3(pk, endpointAddress);
            return web3;
        }

        public static Web3 GetWeb3(string endpointAddress)
        {
            var web3 = new Web3(endpointAddress);
            return web3;
        }

        public static TokenRepository GetStandardTokenServiceWeb3(string endpointAddress, string adminPass, string contrtactAddress)
        {
            var web3 = GetWeb3(endpointAddress, adminPass);
            return new TokenRepository(web3, contrtactAddress);
        }

        public static TokenRepository GetStandardTokenServiceWeb3(string endpointAddress, string contrtactAddress)
        {
            var web3 = GetWeb3(endpointAddress);
            return new TokenRepository(web3, contrtactAddress);
        }
    }
}
