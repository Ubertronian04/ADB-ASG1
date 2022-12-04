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
    public class CCStatementDAL
    {
        private IConfiguration Configuration { get; }
        private SqlConnection conn;
        //Constructor
        public CCStatementDAL()
        {
            //Read ConnectionString from appsettings.json file
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json");

            Configuration = builder.Build();
            string strConn = Configuration.GetConnectionString("ADBCreditCardConnectionString");

            conn = new SqlConnection(strConn);
        }

        public void GenerateMonthlyCardStatement(string ccNo, DateTime? currentDT = null)
        {
            //Get stored procedure from database
            SqlCommand cmd = new SqlCommand("uspGenerateMonthlyCardStatement", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CCNo", ccNo);
            cmd.Parameters.AddWithValue("@CurrentDate", currentDT);
            
            //open database connection
            conn.Open();
            try
            {
                cmd.ExecuteNonQuery();
            } catch (SqlException sqlEx)
            {
                Debug.WriteLine(sqlEx.Message);
            }
            
            //close connection
            conn.Close();
        }

        public MonthlyStatementViewModel GetMonthlyStatement(string ccNo, int? month, int? year)
        {
            //Get stored procedure from database
            SqlCommand cmd = new SqlCommand("uspGetMonthlyStatement", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CCNo", ccNo);
            cmd.Parameters.AddWithValue("@CCSMonth", month);
            cmd.Parameters.AddWithValue("@CCSYear", year);

            //open database connection
            conn.Open();
            //Execute reader
            SqlDataReader reader = cmd.ExecuteReader();

            //Get monthly statement
            MonthlyStatementViewModel ccsViewModel = new MonthlyStatementViewModel();
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    ccsViewModel.CCStatement = new CreditCardStatement
                    {
                        ccsNo = reader.GetString(0),
                        ccsBillDate = reader.GetDateTime(1),
                        ccsPayDueDate = reader.GetDateTime(2),
                        ccsCashback = reader.GetDecimal(3),
                        ccsTotalAmountDue = reader.GetDecimal(4)
                    };
                    ccsViewModel.CCLimit = reader.GetDecimal(6);
                    ccsViewModel.CCCurrentBal = reader.GetDecimal(7);
                    
                }
            }

            //close reader
            reader.Close();
            //close connection
            conn.Close();

            return ccsViewModel;
        }

        public List<MonthlyStatementViewModel> GetAllCreditCardStatements(string ccNo)
        {
            //Create a SqlCommand object from connection object
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM CreditCardStatementView WHERE CCNo=@CCNo ORDER BY CCSNo DESC";
            cmd.Parameters.AddWithValue("@CCNo", ccNo);

            //open database connection
            conn.Open();
            //Execute reader
            SqlDataReader reader = cmd.ExecuteReader();

            List<MonthlyStatementViewModel> msViewModelList = new List<MonthlyStatementViewModel>();
            while (reader.Read())
            {
                msViewModelList.Add(
                    new MonthlyStatementViewModel
                    {
                        CCStatement = new CreditCardStatement
                        {
                            ccsNo = reader.GetString(0),
                            ccsBillDate = reader.GetDateTime(1),
                            ccsPayDueDate = reader.GetDateTime(2),
                            ccsCashback = reader.GetDecimal(3),
                            ccsTotalAmountDue = reader.GetDecimal(4)
                        },
                        CCLimit = reader.GetDecimal(6),
                        CCCurrentBal = reader.GetDecimal(7)
                    });
            }

            //Close DataReader
            reader.Close();
            //Close database connection
            conn.Close();

            return msViewModelList;
        }
        public List<CardTransaction> GetMonthlyCardTransactions(string nric, DateTime dt)
        {
            //Get stored procedure from database
            SqlCommand cmd = new SqlCommand("uspCustomerMonthlyDetail", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@NRIC", nric);
            cmd.Parameters.AddWithValue("@Date", dt);

            List<CardTransaction> ctList = new List<CardTransaction>();

            //open database connection
            conn.Open();
            try
            {
                //Execute reader
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ctList.Add(
                            new CardTransaction
                            {
                                CTNo = reader.GetString(0),
                                Merchant = reader.GetString(1),
                                Amount = reader.GetDecimal(2),
                                Date = reader.GetDateTime(3),
                                Status = reader.GetString(4),
                                CCNo = reader.GetString(5),
                                CCSNo = reader.GetString(6)
                            });
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                Debug.WriteLine(sqlEx.Message);
            }

            return ctList;
        }
    }
}
