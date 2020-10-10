using MoralityDexContractRepositories.Factories;
using Nethereum.Hex.HexTypes;
using Nethereum.Web3;
using System;
using System.Collections.Generic;
using System.Net;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using static MoralityDexContractRepositories.ContractFunctions.ContractFunctions;

namespace MoralityDexContractRepositories.Repositories
{
    public class MoralityDEXRepository : IMoralityDEXRepository
    {
        private string _endPointAddress;
        private string _contractAddress;
        private string _abi;

        public MoralityDEXRepository(string endPointAddress, string contractAddress, string abi)
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            _endPointAddress = endPointAddress;
            _contractAddress = contractAddress;
            _abi = abi;
        }

        private TokenRepository GetStandardTokenService(string adminPk = null)
        {
            if (string.IsNullOrEmpty(adminPk))
                return Web3Factory.GetStandardTokenServiceWeb3(_endPointAddress, _contractAddress);
            else return Web3Factory.GetStandardTokenServiceWeb3(_endPointAddress, adminPk, _contractAddress);
        }

        public async Task<string> GetToken(string symbol)
        {
            var getTokenFunction = new GetTokenFunction() { Symbol = symbol };
            var token = await GetStandardTokenService().ContractHandler
                .QueryAsync<GetTokenFunction, string>(getTokenFunction, null);
            return token;
        }

        public async Task<string> UpdateToken(string address, string pk, string symbol, string tokenAddress, BigInteger newRate)
        {
            var tokenService = GetStandardTokenService(pk);
            var contract = tokenService.GetWeb3().Eth.GetContract(_abi, _contractAddress);
            var updateToken = contract.GetFunction("updateToken");
            var gas = await updateToken.EstimateGasAsync(address, null, null, new object[] { symbol, newRate, tokenAddress});
            var call = await updateToken.SendTransactionAsync(address, gas, (HexBigInteger)null, new object[] { symbol, newRate, tokenAddress});
            return call;
        }
    }
}
