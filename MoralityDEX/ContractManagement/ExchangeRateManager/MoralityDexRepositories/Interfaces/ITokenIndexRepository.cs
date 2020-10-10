using MoralityDexModel.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexRepositories
{
    public interface ITokenIndexRepository
    {
        IEnumerable<Token> GetTokens();
    }
}
