/**-----------------------------------------------**/
/**  ADB ASSIGNMENT 15 OCT 2022, SEMESTER 2 & 4   **/
/**             Credit Card System                **/
/**						                          **/
/**   Database Script for creating simplified	  **/
/**  		database tables and data.             **/
/**		                                          **/
/** IMPORTANT: Do not modify the table defintions.**/
/**  But you may add new tables and sample data.  **/
/**-----------------------------------------------**/

/**=========== Create Database =================**/

CREATE DATABASE CreditCardSys
--GO

USE CreditCardSys
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Reward' AND TYPE='U')
DROP TABLE Reward
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CardTransaction' AND TYPE='U')
DROP TABLE CardTransaction
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CreditCardStatement' AND TYPE='U')
DROP TABLE CreditCardStatement
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CreditCard' AND TYPE='U')
DROP TABLE CreditCard
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Customer' AND TYPE='U')
DROP TABLE Customer
GO

/**=========== Create Tables =================**/

/**====== Table: Customer ======**/ 
CREATE TABLE Customer (
	CustId CHAR(7) NOT NULL,
	CustNRIC CHAR(9) NOT NULL,
	CustName VARCHAR(50) NOT NULL,
	CustDOB  SMALLDATETIME NOT NULL,
	CustAddress VARCHAR(100) NOT NULL,
	CustContact VARCHAR(15) NOT NULL,
	CustEmail VARCHAR(50) NOT NULL,
	CustAnnualIncome SMALLMONEY NOT NULL,
	CustJoinDate SMALLDATETIME NOT NULL,
	CustStatus VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Customer PRIMARY KEY NONCLUSTERED (CustId),
	CONSTRAINT CHK_Customer_CustStatus CHECK (CustStatus IN ('Pending', 'Active', 'Suspended'))
) 
GO

/**====== Table: CreditCard ======**/ 
CREATE TABLE CreditCard  (
	CCNo CHAR(16) NOT NULL,
	CCCVV CHAR(3) NOT NULL,
	CCValidThru CHAR(7) NOT NULL,
	CCCreditLimit SMALLMONEY NOT NULL,
	CCCurrentBal SMALLMONEY NOT NULL,
	CCStatus VARCHAR(10) NOT NULL,
	CCCustId CHAR(7) NOT NULL,
	CONSTRAINT PK_CreditCard PRIMARY KEY NONCLUSTERED (CCNo),
	CONSTRAINT CHK_CreditCard_CCStatus CHECK (CCStatus IN ('Active', 'Expired', 'Cancelled', 'Suspended')),
	CONSTRAINT FK_CreditCard_CCCustId FOREIGN KEY (CCCustId) REFERENCES Customer (CustId)
) 
GO

/**====== Table: Reward  ======**/ 
CREATE TABLE Reward (
	RewID INT IDENTITY(1,1) NOT NULL,
	RewDesc VARCHAR(100) NOT NULL,
	RewAmount SMALLMONEY NOT NULL,
	RewValidTill SMALLDATETIME NOT NULL,
	RewRedeemDate SMALLDATETIME NULL,
	RewStatus VARCHAR(10) NOT NULL,
	RewCCNo CHAR(16) NOT NULL,
	CONSTRAINT PK_Reward PRIMARY KEY NONCLUSTERED (RewID),
	CONSTRAINT FK_Reward_RewCCNo FOREIGN KEY (RewCCNo) REFERENCES CreditCard (CCNo)
) 
GO

/**====== Table: CreditCardStatement  ======**/ 
CREATE TABLE CreditCardStatement (
	CCSNo CHAR(10) NOT NULL,
	CCSDate SMALLDATETIME NOT NULL,
	CCSPayDueDate SMALLDATETIME NOT NULL,
	CCSCashback SMALLMONEY NOT NULL,
	CCSTotalAmountDue SMALLMONEY NOT NULL,
	CONSTRAINT PK_CreditCardBill PRIMARY KEY NONCLUSTERED (CCSNo)
) 
GO

/**====== Table: CardTransaction  ======**/ 
CREATE TABLE CardTransaction (
	CTNo CHAR(10) NOT NULL,
	CTMerchant VARCHAR(100) NOT NULL,
	CTAmount SMALLMONEY NOT NULL,
	CTDate SMALLDATETIME NOT NULL,
	CTStatus VARCHAR(10) NOT NULL,
	CTCCNo CHAR(16) NOT NULL,
	CTCCSNo CHAR(10) NULL,
	CONSTRAINT PK_CardTransaction PRIMARY KEY NONCLUSTERED (CTNo),
	CONSTRAINT FK_CardTransaction_CTCCNo FOREIGN KEY (CTCCNo) REFERENCES CreditCard (CCNo),
	CONSTRAINT FK_CardTransaction_CTCCSNo FOREIGN KEY (CTCCSNo) REFERENCES CreditCardStatement (CCSNo)
) 
GO

/**  Create Sample Data  **/

/** Creating Records for Table Customer **/
INSERT INTO Customer VALUES ('C000001','S1111111A','Peter Chew','2000/02/01','Blk 111, Toa Payoh Ave 4, #01-111','9111111','peter@mymail.com.sg',50000,'2022/01/02','Active')
INSERT INTO Customer VALUES ('C000002','S2222222B','Betty Phua','1995/02/02','Blk 222, Queenstown Estate, #02-222','92222222','betty@yourmail.com.sg',45000, '2022/05/06','Active')
INSERT INTO Customer VALUES ('C000003','S3333333C','Charlie David','1998/03/03','Blk 333, Ang Mo Kio Ave 2, #03-333','93333333','charlie@hismail.com.sg',90000,'2022/11/01','Suspended')
INSERT INTO Customer VALUES ('C000004','S4444444D','Anil Kumar','2000/03/03','Blk 444, Jurong West Ave 10, #04-444','94444444','anil@hismail.com.sg',60000,'2022/11/03','Pending')
--GO

/** Creating Records for Table CreditCard **/
INSERT INTO CreditCard VALUES ('5443835770559378','123','08/2026', 25000, 25000, 'Active', 'C000001')
INSERT INTO CreditCard VALUES ('5395164704886973','456','10/2022', 22500, 21300, 'Expired', 'C000002')
INSERT INTO CreditCard VALUES ('5181075091396053','789','01/2025', 45000, 45000, 'Suspended', 'C000003')
--GO

/** Creating Records for Table CreditCardStatement **/
INSERT INTO CreditCardStatement VALUES ('S000000001','2022/09/30','2022-10-21', 8.80, 871.20)
INSERT INTO CreditCardStatement VALUES ('S000000002','2022/10/31','2022-11-21', 12, 1188)
INSERT INTO CreditCardStatement VALUES ('S000000003','2022/10/31','2022-11-21', 0, 460)
INSERT INTO CreditCardStatement VALUES ('S000000004','2022/10/31','2022-11-21', 0, 735)
--GO

/** Creating Records for Table CardTransaction **/
INSERT INTO CardTransaction VALUES ('T000000001', 'ADB Jewelry','750','2022-09-05','Billed', '5443835770559378', 'S000000001')
INSERT INTO CardTransaction VALUES ('T000000002', 'ADB Grocery','50','2022-09-10','Billed', '5443835770559378', 'S000000001')
INSERT INTO CardTransaction VALUES ('T000000003', 'ADB Petrol','80','2022-09-20','Billed', '5443835770559378', 'S000000001')
INSERT INTO CardTransaction VALUES ('T000000004', 'ADB Furniture','1200','2022-10-20','Billed', '5395164704886973', 'S000000002')
INSERT INTO CardTransaction VALUES ('T000000005', 'ADB Travel','400','2022-10-20','Failed', '5395164704886973', NULL)
INSERT INTO CardTransaction VALUES ('T000000006', 'ADB Supermarket','500','2022-10-29','Pending', '5395164704886973', NULL)
INSERT INTO CardTransaction VALUES ('T000000007', 'ADB Games','640','2022-10-31','Pending', '5395164704886973', NULL)
INSERT INTO CardTransaction VALUES ('T000000008', 'ADB Electronics','640','2022-9-30','Pending', '5181075091396053', NULL)
INSERT INTO CardTransaction VALUES ('T000000009', 'ADB Grocery','340','2022-10-10','Billed', '5443835770559378', 'S000000003')
INSERT INTO CardTransaction VALUES ('T000000010', 'ADB Petrol','120','2022-10-20','Billed', '5443835770559378', 'S000000003')
INSERT INTO CardTransaction VALUES ('T000000011', 'ADB Games','735','2022-10-15','Billed', '5395164704886973', 'S000000004')
INSERT INTO CardTransaction VALUES ('T000000012', 'ADB Travel','500','2022-12-1','Failed', '5395164704886973', NULL)
--GO

/** Creating Records for Table Reward **/
INSERT INTO Reward VALUES ('ADB Jewelry Voucher', 5, '2023-09-05', 2022-10-05, 'Claimed', '5443835770559378')
INSERT INTO Reward VALUES ('ADB Furniture Voucher', 10, '2023-10-20', NULL, 'Available', '5395164704886973')
--GO
