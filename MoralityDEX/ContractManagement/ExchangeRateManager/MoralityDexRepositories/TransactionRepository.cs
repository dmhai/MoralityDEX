using MoralityDexModel;
using MoralityDexModel.Models;
using MoralityDexRepositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexRepositories
{
    public class TransactionRepository : BaseRepository, ITransactionRepository
    {
        public TransactionRepository(MoralityDEXEntities entities) : base(entities)
        {
        }

        public void AddTransaction(Transaction transaction)
        {
            _entities.Transactions.Add(transaction);
        }
    }
}
