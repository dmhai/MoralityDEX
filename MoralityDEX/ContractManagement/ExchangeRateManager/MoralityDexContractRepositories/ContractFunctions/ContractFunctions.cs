using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexContractRepositories.ContractFunctions
{
    public class ContractFunctions
    {
        public partial class GetTokenFunction : GetTokenFunctionBase { }
        [Function("getToken", "string")]
        public class GetTokenFunctionBase : FunctionMessage
        {
            [Parameter("string", "symbol")]
            public string Symbol { get; set; }
        }
    }
}
