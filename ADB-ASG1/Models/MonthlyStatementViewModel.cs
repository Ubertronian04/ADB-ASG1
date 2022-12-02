using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ADB_ASG1.Models
{
    public class MonthlyStatementViewModel
    {
        public CreditCardStatement CCStatement { get; set; }
        [DataType(DataType.Currency)]
        public decimal CCLimit { get; set; }
        [DataType(DataType.Currency)]
        public decimal CCCurrentBal { get; set; }
    }
}
