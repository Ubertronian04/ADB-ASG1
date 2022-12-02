using ADB_ASG1.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using ADB_ASG1.DAL;

namespace ADB_ASG1.Controllers
{
    public class HomeController : Controller
    {
        private CCStatementDAL ccsContext = new CCStatementDAL();
        private CustomerDAL custContext = new CustomerDAL();
        public IActionResult Index()
        {
            HttpContext.Session.SetString("CurrentDate", /*DateTime.Now.ToString()*/"2022-12-31 00:00:00");

            return View();
        }

        public ActionResult Login()
        {
            return View();
        }

        public ActionResult Logout()
        {
            //Remove login credentials
            HttpContext.Session.Clear();

            return RedirectToAction("Index");
        }

        [HttpPost]
        public ActionResult Login(IFormCollection formData)
        {
            string loginNRIC = formData["username"].ToString();
            string loginEmail = formData["password"].ToString();

            Customer checkCust = custContext.IsCustExists(loginNRIC, loginEmail);

            if (checkCust.Id != null)
            {
                string ccNo = custContext.getCustCreditCard(checkCust.Id);
                HttpContext.Session.SetString("CustId", checkCust.Id);
                HttpContext.Session.SetString("CCNo", ccNo);
                DateTime dt = Convert.ToDateTime(HttpContext.Session.GetString("CurrentDate"));
                if (dt.Day == DateTime.DaysInMonth(dt.Year, dt.Month))
                {
                    ccsContext.GenerateMonthlyCardStatement(ccNo, dt);
                }

                return RedirectToAction("Index");
            }
            else
            {
                TempData["LoginError"] = "Invalid login credentials";
                return View();
            }
        }

        [HttpPost]
        public IActionResult AjaxCallSessionString(string sessionName)
        {
            return Json(HttpContext.Session.GetString(sessionName));
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
