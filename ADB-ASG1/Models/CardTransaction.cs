using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ADB_ASG1.Models
{
    public class CardTransaction
    {
        [Display(Name ="CT Number")]
        public string CTNo { get; set; }
        [Display(Name ="Name of Merchant")]
        public string Merchant { get; set; }
        [Display(Name ="Amount")]
        [DataType(DataType.Currency)]
        public decimal Amount { get; set; }
        [Display(Name ="Date of Purchase")]
        public DateTime Date { get; set; }
        [Display(Name ="Status")]
        public string Status { get; set; }
        public string CCNo { get; set; }
        public string CCSNo { get; set; }
    }
}
