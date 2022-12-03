﻿using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ADB_ASG1.Models;
using ADB_ASG1.DAL;

namespace ADB_ASG1.Controllers
{
    public class CustomerController : Controller
    {
        private CustomerDAL custContext = new CustomerDAL();
        // GET: CustomerController
        public ActionResult Index()
        {
            if (HttpContext.Session.GetString("CustId") == null)
                return RedirectToAction("Index", "Home");
            return View();
        }

        // GET: CustomerController/Create
        public ActionResult Create()
        {
            if (HttpContext.Session.GetString("CustId") != null)
                return RedirectToAction("Index");
            return View();
        }

        // POST: CustomerController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(Customer cust)
        {
            if (ModelState.IsValid)
                // TODO: insert customer into database
                return RedirectToAction("Index", "Home");
            else
                return View(cust);
        }

        // GET: CustomerController/Edit/5
        public ActionResult Edit(int id)
        {
            if (HttpContext.Session.GetString("CustId") == null)
                return RedirectToAction("Index", "Home");
            return View();
        }

        // POST: CustomerController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(Customer c)
        {
            if (ModelState.IsValid)
                return RedirectToAction(nameof(Index));
            else
                return View(c);
        }

        // GET: CustomerController/Delete/5
        public ActionResult ViewCreditCard()
        {
            string custId = HttpContext.Session.GetString("CustId");
            if (custId == null)
                return RedirectToAction("Index", "Home");

            CreditCard cc = custContext.GetCreditCardDetails(custId);
            return View(cc);
        }
    }
}
