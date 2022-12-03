using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ADB_ASG1.Models
{
    public class CreditCard
    {
        [Display(Name="Credit Card Number")]
        public string CCNo { get; set; }
        [Display(Name = "CVV")]
        public string CVV { get; set; }
        [Display(Name = "Expiration Date")]
        public string ValidThru { get; set; }
        [Display(Name = "Credit Limit")]
        [DataType(DataType.Currency)]
        public decimal CreditLimit { get; set; }
        [Display(Name = "Current Balance")]
        [DataType(DataType.Currency)]
        public decimal CurrentBal { get; set; }
        [Display(Name = "Status")]
        public string Status { get; set; }
        [Display(Name = "Customer ID")]
        public string CustId { get; set; }
    }
}
