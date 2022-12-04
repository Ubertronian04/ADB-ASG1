using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Diagnostics;
using ADB_ASG1.Models;
using ADB_ASG1.DAL;

namespace ADB_ASG1.Controllers
{
    public class MonthlyStatementController : Controller
    {
        private CCStatementDAL ccsContext = new CCStatementDAL();

        // GET: MonthlyStatementController
        public ActionResult Index()
        {
            string custId = HttpContext.Session.GetString("CustId");
            string ccNo = HttpContext.Session.GetString("CCNo");
            //Stop access if action is not logged in
            if (custId == null)
                return RedirectToAction("Index", "Home");
            DateTime dateNow = Convert.ToDateTime(HttpContext.Session.GetString("CurrentDate"));
            //Get monthly statement for customer
            MonthlyStatementViewModel monthlyCCS = new MonthlyStatementViewModel();
            if (dateNow.Day == DateTime.DaysInMonth(dateNow.Year, dateNow.Month))
                monthlyCCS = ccsContext.GetMonthlyStatement(ccNo, dateNow.Month, dateNow.Year);
            else
                monthlyCCS = ccsContext.GetMonthlyStatement(ccNo, dateNow.Month - 1, dateNow.Year);

/*            string hasObj = monthlyCCS?.CCStatement?.ccsNo ?? "null";
            Debug.WriteLine(hasObj);
            if (hasObj == "null")
                monthlyCCS = ccsContext.GetMonthlyStatement(ccNo, dateNow.Month - 1, dateNow.Year);*/

            return View(monthlyCCS);
        }

        // GET: MonthlyStatementController/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        public ActionResult ViewAllMonthlyStatements()
        {
            string custId = HttpContext.Session.GetString("CustId");
            string ccNo = HttpContext.Session.GetString("CCNo");
            //Stop access if action is not logged in
            if (custId == null)
                return RedirectToAction("Index", "Home");
            List<MonthlyStatementViewModel> msViewModelList = ccsContext.GetAllCreditCardStatements(ccNo);

            return View(msViewModelList);
        }

        public ActionResult ViewMonthlyTransactions()
        {
            string custId = HttpContext.Session.GetString("CustId");
            //Stop access if action is not logged in
            if (custId == null)
                return RedirectToAction("Index", "Home");

            string nric = HttpContext.Session.GetString("CustNRIC");
            List<CardTransaction> ctList = new List<CardTransaction>();
            DateTime dateNow = Convert.ToDateTime(HttpContext.Session.GetString("CurrentDate"));
            if (dateNow.Day == DateTime.DaysInMonth(dateNow.Year, dateNow.Month))
                ctList = ccsContext.GetMonthlyCardTransactions(nric, dateNow);
            else
                ctList = ccsContext.GetMonthlyCardTransactions(nric, dateNow.AddMonths(-1));

            return View(ctList);
        }
    }
}
