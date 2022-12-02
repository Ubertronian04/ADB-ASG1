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
            string ccNo = HttpContext.Session.GetString("CCNo");
            //Stop access if action is not logged in
            if (ccNo == null)
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

        // GET: MonthlyStatementController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: MonthlyStatementController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: MonthlyStatementController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: MonthlyStatementController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: MonthlyStatementController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: MonthlyStatementController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
