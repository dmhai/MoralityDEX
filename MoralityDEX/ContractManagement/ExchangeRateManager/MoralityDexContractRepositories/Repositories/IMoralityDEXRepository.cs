using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace MoralityDexContractRepositories.Repositories
{
    public interface IMoralityDEXRepository
    {
        Task<string> UpdateToken(string address, string pk, string symbol, string tokenAddress, BigInteger newRate);
        Task<string> GetToken(string symbol);
    }
}
