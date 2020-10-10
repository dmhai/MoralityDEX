using MoralityDexContractRepositories.Repositories;
using MoralityDexRepositories;
using System;
using System.Threading.Tasks;
using System.Linq;
using Newtonsoft.Json;
using LiveModels = MoralityDexContractRepositories.Models;
using MoralityDexModel.Models;
using MoralityDexServices.Models;
using MoralityDexRepositories.Interfaces;
using System.Numerics;

namespace MoralityDexServices
{
    public class TokenService
    {
        private readonly ITokenIndexRepository _tokenIndexRepository;
        private readonly ITransactionRepository _transactionRepository;
        private readonly IMoralityDEXRepository _dexRepository;

        private readonly Monitor _monitor;
        private readonly LiveRateService _liveRateService;

        public TokenService(ITokenIndexRepository tokenIndexRepository, ITransactionRepository transactionRepository, IMoralityDEXRepository dexRepository,
            LiveRateService liveRateService)
        {
            _tokenIndexRepository = tokenIndexRepository;
            _dexRepository = dexRepository;
            _transactionRepository = transactionRepository;
            _liveRateService = liveRateService;
        }

        public async Task UpdateTokenRates(EthereumUser user)
        {
            var tokensListed = _tokenIndexRepository.GetTokens().ToList();
            foreach (var tokenListed in tokensListed)
            {
                try
                {
                    var liveToken = await GetLiveToken(tokenListed.Symbol);
                    if (liveToken != null)
                    {
                        var liveRate = _liveRateService.GetLiveRate(tokenListed.Symbol);
                        if (liveToken.Rate != liveRate && liveRate > 0)
                            await UpdateToken(user, liveToken, tokenListed, liveRate);
                    }
                }
                catch (Exception ex)
                {
                    _monitor.Log($"Transaction with requesters address:{user?.Address}, symbol: {tokenListed?.Symbol} failed", ex.ToString());
                }
            }

        }

        private async Task<bool> UpdateToken(EthereumUser user, LiveModels.Token liveToken, Token tokenListed, BigInteger newRate)
        {
            if (liveToken != null)
            {
                var updatedTx = await _dexRepository.UpdateToken(user.Address, user.PrivateKey, tokenListed.Symbol, liveToken.Address, newRate);
                if (!string.IsNullOrEmpty(updatedTx))
                {
                    _transactionRepository.AddTransaction(new Transaction()
                    {
                        Symbol = tokenListed.Symbol,
                        RequestAddress = user.Address,
                        TokenAddress = liveToken.Address,
                        Rate = newRate,
                        Tx = updatedTx,
                        DateCompleted = DateTime.UtcNow
                    });
                    return Convert.ToBoolean(_transactionRepository.Save());
                }
                else
                    _monitor.Log($"Transaction with requesters address:{user?.Address}, symbol: {tokenListed?.Symbol}, token address: {liveToken?.Address} and rate: {newRate} failed");
            }
            return false;
        }

        public async Task<LiveModels.Token> GetLiveToken(string symbol)
        {
            if (!string.IsNullOrEmpty(symbol))
            {
                var tokenStr = await _dexRepository.GetToken(symbol);
                if (!string.IsNullOrEmpty(tokenStr))
                    return JsonConvert.DeserializeObject<LiveModels.Token>(tokenStr);
            }
            return null;
        }
    }
}
