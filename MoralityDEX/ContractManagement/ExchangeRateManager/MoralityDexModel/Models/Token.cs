using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexModel.Models
{
    public class Token
    {
        public int Id { get; set; }
        public string Symbol { get; set; }
        public string Description { get; set; }
        public int PointPrecision { get; set; }
        public bool Active { get; set; }
    }
}
