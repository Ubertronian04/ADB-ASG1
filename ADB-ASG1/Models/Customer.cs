using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ADB_ASG1.Models
{
    public class Customer
    {
        public string Id { get; set; }
        [StringLength(9, MinimumLength = 9, ErrorMessage = "NRIC must be 9 characters long")]
        [RegularExpression(@"(?i)^[STFG]\d{1-7}[A-Z]$", ErrorMessage = "NRIC must begin and end with a Letter")]
        public string NRIC { get; set; }
        public string Name { get; set; }
        [Display(Name = "Date of Birth")]
        [DataType(DataType.Date)]
        public DateTime DOB { get; set; }
        public string Address { get; set; }
        [StringLength(9, ErrorMessage = "Contact Number cannot be more than 15 characters long")]
        public string Contact { get; set; }
        public string Email { get; set; }
        [Display(Name="Annual Income")]
        [DataType(DataType.Currency, ErrorMessage = "Annual Income is formatted for currency")]
        [DisplayFormat(DataFormatString = "{0:C2}")]
        public decimal AnnualIncome { get; set; }
        [Display(Name = "Date Joined")]
        [DataType(DataType.Date)]
        public DateTime JoinDate { get; set; }
        [RegularExpression(@"Pending|Active|Suspended", ErrorMessage = "Customer Status can only be 'Pending', 'Active' or 'Suspended'")]
        public string Status { get; set; }
    }
}
