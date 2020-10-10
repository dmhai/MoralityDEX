using MoralityDexModel;
using MoralityDexModel.Models;
using System;
using System.Collections.Generic;

namespace MoralityDexRepositories
{
    public class TokenIndexRepository : BaseRepository, ITokenIndexRepository
    {
        public TokenIndexRepository(MoralityDEXEntities entities) : base(entities)
        {
        }

        public IEnumerable<Token> GetTokens()
        {
            return _entities.Tokens;
        }
    }
}
