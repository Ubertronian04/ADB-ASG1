using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Threading;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using ADB_ASG1.Models;

namespace ADB_ASG1.DAL
{
    public class CustomerDAL
    {
        private IConfiguration Configuration { get; }
        private SqlConnection conn;

        public CustomerDAL()
        {
            //Read ConnectionString from appsettings.json file
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json");

            Configuration = builder.Build();
            string strConn = Configuration.GetConnectionString("ADBCreditCardConnectionString");

            conn = new SqlConnection(strConn);
        }

        public string getCustCreditCard(string custId)
        {
            //Create a SqlCommand object and specify the SQL statement
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM CreditCard WHERE CCCustId=@selectedId";
            cmd.Parameters.AddWithValue("@selectedId", custId);

            //Open a database connection and execute the SQL statement
            conn.Open();

            string ccNo = "";
            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                ccNo = reader.GetString(0);
            }

            return ccNo;
        }

        public Customer IsCustExists(string nric, string email)
        {
            //Create a SqlCommand object and specify the SQL statement
            //to get a customer record with the nric to be validated
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM Customer WHERE CustNRIC=@selectedNRIC AND CustEmail=@selectedEmail";
            cmd.Parameters.AddWithValue("@selectedNRIC", nric);
            cmd.Parameters.AddWithValue("@selectedEmail", email);

            //Open a database connection and execute the SQL statement
            conn.Open();
            Customer c = new Customer();
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.HasRows)
            { //Records found
                while (reader.Read())
                {
                    c.Id = reader.GetString(0);
                    c.NRIC = reader.GetString(1);
                    c.Name = reader.GetString(2);
                    c.DOB = reader.GetDateTime(3);
                    c.Address = reader.GetString(4);
                    c.Contact = reader.GetString(5);
                    c.Email = reader.GetString(6);
                    c.AnnualIncome = reader.GetDecimal(7);
                    c.JoinDate = reader.GetDateTime(8);
                    c.Status = reader.GetString(9);
                }
            }
            reader.Close();
            conn.Close();

            return c;
        }

        public CreditCard GetCreditCardDetails(string custId)
        {
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM CreditCard WHERE CCCustId=@selectedId";
            cmd.Parameters.AddWithValue("@selectedId", custId);

            //Open a database connection and execute the SQL statement
            conn.Open();
            CreditCard cc = new CreditCard();
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.HasRows)
            { //Records found
                while (reader.Read())
                {
                    cc.CCNo = reader.GetString(0);
                    cc.CVV = reader.GetString(1);
                    cc.ValidThru = reader.GetString(2);
                    cc.CreditLimit = reader.GetDecimal(3);
                    cc.CurrentBal = reader.GetDecimal(4);
                    cc.Status = reader.GetString(5);
                    cc.CustId = reader.GetString(6);
                }
            }

            reader.Close();

            conn.Close();

            return cc;
        }

        public void CreateCustomer(Customer c)
        {
            //Get stored procedure from database
            // TODO add stored procedure
            SqlCommand cmd = new SqlCommand("uspCreateCustomer", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@C", c.NRIC);
            cmd.Parameters.AddWithValue("@CurrentDate", c.Name);
            cmd.Parameters.AddWithValue("@CurrentDate", c.DOB);
            cmd.Parameters.AddWithValue("@CurrentDate", c.Address);
            cmd.Parameters.AddWithValue("@CurrentDate", c.Contact);
            cmd.Parameters.AddWithValue("@CurrentDate", c.Email);
            cmd.Parameters.AddWithValue("@CurrentDate", c.AnnualIncome);

            //open database connection
            conn.Open();
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch (SqlException sqlEx)
            {
                Debug.WriteLine(sqlEx.Message);
            }

            //close connection
            conn.Close();
        }
    }
}
