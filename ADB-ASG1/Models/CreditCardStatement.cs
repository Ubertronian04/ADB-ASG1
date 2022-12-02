using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ADB_ASG1.Models
{
    public class CreditCardStatement
    {
        [Display(Name ="Statement No")]
        public string ccsNo { get; set; }
        [Display(Name = "Date Issued")]
        [DataType(DataType.Date)]
        public DateTime ccsBillDate { get; set; }
        [Display(Name = "Payment Due Date")]
        [DataType(DataType.Date)]
        public DateTime ccsPayDueDate { get; set; }
        [Display(Name = "Cashback")]
        [DataType(DataType.Currency)]
        [DisplayFormat(DataFormatString = "{0:C2}")]
        public decimal ccsCashback { get; set; }
        [Display(Name = "Total")]
        [DataType(DataType.Currency)]
        [DisplayFormat(DataFormatString = "{0:C2}")]
        public decimal ccsTotalAmountDue { get; set; }
    }
}
