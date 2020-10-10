using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;

namespace MoralityDexModel.Models
{
    public class Transaction
    {
        public int Id { get; set; }
        public string RequestAddress { get; set; }
        public string Symbol { get; set; }
        public string TokenAddress { get; set; }
        public BigInteger Rate { get; set; }
        public string Tx { get; set; }
        public DateTime DateCompleted { get; set; }
    }
}
