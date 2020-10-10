using MoralityDexModel.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexRepositories.Interfaces
{
    public interface ITransactionRepository
    {
        void AddTransaction(Transaction transaction);
        int Save();
    }
}
