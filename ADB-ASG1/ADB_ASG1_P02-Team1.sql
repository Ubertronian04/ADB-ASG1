/**-----------------------------------------------**/
/**              ADB ASSIGNMENT 1                 **/
/**             Credit Card System                **/
/**						                          **/
/**  		      BY P02-Team 1                   **/
/**   Chiam Wei, Nathaniel Tong & Daniel Chan     **/
/**  		                                      **/
/**-----------------------------------------------**/

USE CreditCardSys
GO

-- +++++++++++++++ Error Codes Stored Procedure +++++++++++++++

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetErrorCodes' AND  Type='P')
	DROP PROC uspGetErrorCodes
GO

-- ** Actions/Error messages for error codes returned by stored procedures **
-- Create custom messages or actions for each custom type of error code
-- CreditCard -> -1**, Transactions -> -2**, CreditCardStatement -> -3**, Reward -> -4**
CREATE PROC uspGetErrorCodes(@Status SMALLINT = 0)
AS
	IF SUBSTRING(CAST(@Status AS VARCHAR(50)),1,2) = '-1'
	BEGIN
		IF @Status = -100
			-- New customer applicant is not eligible
			THROW 50100, 'This applicant is not eligible for an account with ADBeBank', 1
	END
	ELSE IF SUBSTRING(CAST(@Status AS VARCHAR(50)),1,2) = '-2'
	BEGIN
		IF @Status = -200
			-- Customer not found
			THROW 50200, 'This customer does not exist', 1
		ELSE IF @Status = -201
			-- No transactions for that month
			THROW 50201, 'This customer does not have any transactions for the month', 1
	END
	ELSE IF SUBSTRING(CAST(@Status AS VARCHAR(50)),1,2) = '-3'
	BEGIN
		IF @Status = -300
			-- Monthly statement already exists
			THROW 50300, 'The monthly statement for the most recent month has already been created for this customer.', 1
		ELSE IF @Status = -301
			-- No transactions for the month
			THROW 50301, 'The selected credit card does not have any transactions for the month', 1
		ELSE IF @Status = -302
			-- Insertion error for CreditCardStatement
			THROW 50302, 'Could not insert a new record into the CreditCardStatement table', 1
		ELSE IF @Status = -303
			-- No transactions to be updates to "Billed" status
			THROW 50303, 'No pending transactions to be added to the monthly credit card statement', 1
	END

RETURN
GO

-- =================================
-- || ~ Credit Card Application ~ || --
-- =================================
/* ------TEST DATA------
DECLARE @money SMALLMONEY
SET @money = 38475
EXEC uspCreateCustomer 'T8672938E', 'casdasd', '1998-06-03 00:00:00', 'asfasdaewf3q222523earfas', 'faadasfas', 'asfasdwfdadsfs', @money
GO

EXECUTE uspCreateCustomer 'T03100300K', 'erh', '2000/02/01', 'dfh', '9111111', 'eragb@gmail.com', 35000
SELECT * FROM Customer
SELECT * FROM CreditCard
UPDATE Customer SET CustStatus = 'Active' WHERE CustId = 'C000005'
UPDATE Customer SET CustStatus = 'Suspended' WHERE CustId = 'C000005'

DELETE FROM CreditCard WHERE CCCustId = 'C000005'
DELETE FROM Customer WHERE CustId = 'C000005'
*/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='CustomerView' AND  Type='V')
	DROP VIEW CustomerView
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspCreateCustomer' AND  Type='P')
	DROP PROC uspCreateCustomer
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspCreateCreditCard' AND  Type='P')
	DROP PROC uspCreateCreditCard
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigCustomerStatusUpdate')
	DROP TRIGGER trigCustomerStatusUpdate
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigDeletedCreditCard')
	DROP TRIGGER trigDeletedCreditCard
GO


-- ========== VIEWS ========== --

CREATE VIEW CustomerView
AS
	SELECT CustNRIC, CustName, CustDOB, CustAddress, CustContact, CustEmail, CustAnnualIncome, CustJoinDate, CustStatus, 
			CCNo, CCCVV, CCValidThru, CCCreditLimit, CCCurrentBal, CCStatus
	FROM Customer c
	INNER JOIN CreditCard cc on C.CustId = CC.CCCustId
GO

-- ========== STORED PROCEDURES ==========

CREATE PROC uspCreateCustomer (@NRIC CHAR(9), @Name VARCHAR(50), @DOB SMALLDATETIME, 
									@Address VARCHAR(100), @ContactNo CHAR(15), @Email VARCHAR(50),
									@Income SMALLMONEY)
AS
	DECLARE @CusID CHAR(7)
    SELECT TOP 1 @CusID = 'C' +  SUBSTRING(CAST('1'+SUBSTRING(CustId, 2, 7)+1 AS CHAR(7)), 2, 7)
    FROM Customer
    ORDER BY CustId DESC

	IF DATEDIFF(YEAR, @DOB, GETDATE()) > 70
	BEGIN
		EXEC uspGetErrorCodes -100 -- Not eligible
		Return
	END
	IF DATEDIFF(YEAR, @DOB, GETDATE()) < 21
	BEGIN	
		EXEC uspGetErrorCodes -100 -- Not eligible
		Return
	END
	IF @Income < 30000
	BEGIN	
		EXEC uspGetErrorCodes -100 -- Not eligible
		Return
	END
	ELSE
		INSERT INTO Customer(CustId,CustNRIC, CustName, CustDOB, CustAddress, CustContact, CustEmail, CustAnnualIncome, CustJoinDate, CustStatus)
		VALUES (@CusID, @NRIC, @Name, @DOB, @Address, @ContactNo, @Email, @Income, GETDATE(), 'Pending')
		SET @CusID = @@IDENTITY
RETURN 
GO

CREATE PROC uspCreateCreditCard (@Income SMALLMONEY, @CustID CHAR(7))
AS
	DECLARE @CCNo CHAR(16)
	SET @CCNo = '5' + CAST(CAST(RAND() * 1000000000000000 AS BIGINT) AS CHAR(15))
	WHILE EXISTS (SELECT CCNo FROM CreditCard WHERE CCNo = @CCNo)
		SET @CCNo = '5' + CAST(CAST(RAND() * 1000000000000000 AS BIGINT) AS CHAR(15))
		
	DECLARE @CVV CHAR(3)
	SET @CVV = CAST(RAND() * 999 AS SMALLINT)
	DECLARE @ValidThru CHAR(7)
	SET @ValidThru = CAST(FORMAT(DATEADD(year,3,GETDATE()), 'MM/yyyy') AS CHAR(7))
	INSERT INTO CreditCard(CCno, CCCVV, CCValidThru, CCCreditLimit, CCCurrentBal, CCStatus, CCCustId) 
	VALUES (@CCNo, @CVV, @ValidThru, @Income/2, @Income/2, 'Active', @CustID)
	SET  @CCNo = @@IDENTITY
RETURN
GO

-- ========== TRIGGERS ==========

CREATE TRIGGER trigCustomerStatusUpdate
ON Customer
AFTER UPDATE
AS
	IF UPDATE(CustStatus)
	DECLARE @Status VARCHAR(10), @Income SMALLMONEY, @Id CHAR(7)
	SELECT @Status = (SELECT i.CustStatus FROM inserted i),
			@Income = (SELECT i.CustAnnualIncome FROM inserted i),
			@Id = (SELECT i.CustId FROM inserted i)
	IF @Status = 'Active'
		EXECUTE uspCreateCreditCard @Income, @Id
	IF @Status = 'Suspended'
		UPDATE CreditCard SET CCStatus = 'Suspended'
		WHERE CCCustId = @Id
GO

CREATE Trigger trigDeletedCreditCard
on CreditCard
INSTEAD OF DELETE
AS
	DECLARE @Status VARCHAR(10), @Id CHAR(7)
	SET @Id = (SELECT d.CCCustId FROM deleted d)
	UPDATE CreditCard SET CCStatus = 'Cancelled'
	WHERE CCCustId = @Id
GO



-- ======================
-- || ~ Transactions ~ || --
-- ======================
/* ------TEST DATA------
EXECUTE uspTransactions 'sefea', '80', '5443835770559378'
SELECT * FROM CardTransaction
*/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspTransactions' AND  Type='P')
	DROP PROC uspTransactions
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspCustomerMonthlyDetail' AND  Type='P')
	DROP PROC uspCustomerMonthlyDetail
GO

-- ========== STORED PROCEDURES ==========

CREATE PROC uspTransactions (@Merchant VARCHAR(100), @Amount SMALLMONEY, @CCno CHAR(16), @CreditCardStatement CHAR(10) = NULL)
AS
	DECLARE @TransactionNo CHAR(10)
	SELECT TOP 1 @TransactionNo = 'T' +  SUBSTRING(CAST('1'+SUBSTRING(CTNo, 2, 10)+1 AS CHAR(10)), 2, 10)
	FROM CardTransaction
	ORDER BY CTNo DESC
	DECLARE @Status VARCHAR(10)
	DECLARE @CCStatus VARCHAR(10)
	DECLARE @Balance SMALLMONEY
	SET @CCStatus = (SELECT CCStatus FROM CreditCard WHERE CCNo = @CCno)
	SET @Balance = (SELECT CCCurrentBal FROM CreditCard WHERE CCNo = @CCno)
	IF @CCStatus = 'Active' AND @Balance >= @Amount
		SET @Status = 'Pending'
	ELSE
		SET @Status = 'Failed'
	INSERT INTO CardTransaction(CTNo, CTMerchant, CTAmount, CTDate, CTStatus, CTCCNo, CTCCSNo)
	VALUES(@TransactionNo, @Merchant, @Amount, GETDATE(), @Status, @CCno, @CreditCardStatement)
	SET @TransactionNo = @@IDENTITY
RETURN
GO

-- ========== MAIN QUERIES ==========

/* ------TEST DATA------
EXECUTE uspCustomerMonthlyDetail 'S1111111A', '2022-09-01'
GO
*/

-- 4. Details of the transactions for a given customer for a given month.

CREATE PROC uspCustomerMonthlyDetail (@NRIC CHAR(9), @Date SMALLDATETIME)
AS
	
	IF NOT EXISTS(SELECT CTNo FROM CardTransaction ct
					INNER JOIN CreditCard cc on ct.CTCCNo = cc.CCNo
					INNER JOIN Customer c on cc.CCCustId = c.CustId
					WHERE @NRIC = CustNRIC)
		BEGIN
		EXEC uspGetErrorCodes -200 -- No Such Customer
		RETURN 
		END
	IF NOT EXISTS(SELECT CTNo FROM CardTransaction WHERE Month(@Date) = Month(CTDate) AND YEAR(@DATE) = YEAR(CTDate))
		BEGIN
		EXEC uspGetErrorCodes -201 -- No transaction during given month
		RETURN 
		END
	ELSE
		SELECT CTNo, CTMerchant, CTAmount, CTDate, CTStatus, CTCCNo, CTCCSNo FROM CardTransaction ct
					INNER JOIN CreditCard cc on ct.CTCCNo = cc.CCNo
					INNER JOIN Customer c on cc.CCCustId = c.CustId
					WHERE @NRIC = CustNRIC AND Month(@Date) = Month(CTDate) AND YEAR(@DATE) = YEAR(CTDate)
		
	RETURN
GO



-- ==============================================
-- || ~ Monthly Credit Card Statement (Bill) & Cashback ~ || --
-- ==============================================

/* ------TEST DATA------
SELECT * FROM CreditCard
SELECT * FROM Customer
SELECT * FROM CreditCardStatement
SELECT * FROM CardTransaction
SELECT * FROM Reward
SELECT * FROM CreditCardStatementView
GO

EXEC uspGenerateMonthlyCardStatement '5395164704886973'
GO
EXEC uspGenerateMonthlyCardStatement '5181075091396053'
GO
EXEC uspGenerateMonthlyCardStatement '5443835770559378'
GO
*/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='CreditCardStatementView' AND  Type='V')
	DROP VIEW CreditCardStatementView
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGenerateMonthlyCardStatement' AND  Type='P')
	DROP PROC uspGenerateMonthlyCardStatement
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetMonthlyStatement' AND  Type='P')
	DROP PROC uspGetMonthlyStatement
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetCashback' AND  Type='P')
	DROP PROC uspGetCashback
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspAddTransactionToStatement' AND  Type='P')
	DROP PROC uspAddTransactionToStatement
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigUpdateCardTransactionStatus')
	DROP TRIGGER trigUpdateCardTransactionStatus
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigInsertMonthlyStatement')
	DROP TRIGGER trigInsertMonthlyStatement
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetCustomerRewards' AND  Type='P')
	DROP PROC uspGetCustomerRewards
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetMerchantWithMostTransactions' AND  Type='P')
	DROP PROC uspGetMerchantWithMostTransactions
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspGetSuspendedCustomers' AND  Type='P')
	DROP PROC uspGetSuspendedCustomers
GO

-- ========== VIEWS ========== --

-- **Credit Card Statement View** --

CREATE VIEW CreditCardStatementView
AS
	SELECT DISTINCT ccs.CCSNo, ccs.CCSDate, ccs.CCSPayDueDate, ccs.CCSCashback, ccs.CCSTotalAmountDue, 
					cc.CCNo, cc.CCCreditLimit, cc.CCCurrentBal
	FROM CreditCardStatement ccs
	INNER JOIN CardTransaction ct ON ccs.CCSNo = ct.CTCCSNo
	INNER JOIN CreditCard cc ON cc.CCNo = ct.CTCCNo
GO

-- ========== STORED PROCEDURES ========== --

-- ** Cashback on monthly credit card bills **
-- 1% of TotalAmtDue, provided TotalAmountDue >= $800
-- If 1% of TotalAmtDue > 50, cap at $50 cashback

CREATE PROC uspGetCashback(@CCSNo CHAR(10), @CCSTotal SMALLMONEY, @CCCashback SMALLMONEY OUTPUT)
AS
	-- Check if transactions total is at least $800
	IF (@CCSTotal >= 800)
		SET @CCCashback = @CCSTotal / 100
	ELSE
		-- Return no cashback
		SET @CCCashback = 0
		RETURN

	-- Check if cashback value has exceeded $50
	IF (@CCCashback > 50)
		SET @CCCashback = 50
RETURN
GO

-- ** Add Pending Transactions to Credit Card Statement **
-- Add transaction amount to Card Statement
-- Update transaction status from "Pending" to "Billed"
-- Ignore transactions with status "Failed"

CREATE PROC uspAddTransactionToStatement(@CCSNo CHAR(10)) -- using credit card statement id
AS
	DECLARE @CCSTotal SMALLMONEY, @CCCashback SMALLMONEY
	SELECT @CCSTotal = SUM(CTAmount)
	FROM CardTransaction
	WHERE CTCCSNo = @CCSNo AND CTStatus = 'Pending'

	--if no transactions to add
	IF (@CCSTotal IS NULL)
	BEGIN
		EXEC uspGetErrorCodes -303
		RETURN
	END

	EXEC uspGetCashback @CCSNo = @CCSNo, @CCSTotal = @CCSTotal, @CCCashback = @CCCashback OUTPUT

	UPDATE CreditCardStatement
	SET CCSTotalAmountDue = @CCSTotal - @CCCashback, CCSCashback = @CCCashback
	WHERE CCSNo = @CCSNo

	PRINT 'A new monthly credit card statement has been created'
RETURN
GO


-- ========== TRIGGERS ========== --

-- **Change status of Card Transaction table after amounts are added to monthly CCS

CREATE TRIGGER trigUpdateCardTransactionStatus
ON CreditCardStatement AFTER UPDATE
AS
	DECLARE @CCSTotal SMALLMONEY, @CCSId CHAR(10)
	SET @CCSTotal = (SELECT i.CCSTotalAmountDue FROM INSERTED i)
	SET @CCSId = (SELECT i.CCSNo FROM INSERTED i)

	IF (@CCSTotal = 0) --if no transactions to add
		EXEC uspGetErrorCodes -303
	ELSE
		UPDATE CardTransaction
		SET CTStatus = 'Billed'
		WHERE CTCCSNo = @CCSId AND CTStatus = 'Pending'
GO

-- **Insert and fill new monthly statement**

CREATE TRIGGER trigInsertMonthlyStatement
ON CreditCardStatementView INSTEAD OF INSERT
AS
	DECLARE @CCSId CHAR(10), @CCSDate SMALLDATETIME, @CCSPayDueDate SMALLDATETIME, 
	@CCNo CHAR(16), @IsCCSExists SMALLINT, @HasPendingTransactions SMALLINT

	SET @CCSId = (SELECT i.CCSNo FROM INSERTED i)
	SET @CCSDate = (SELECT i.CCSDate FROM INSERTED i)
	SET @CCSPayDueDate = (SELECT i.CCSPayDueDate FROM INSERTED i)
	SET @CCNo = (SELECT i.CCNo FROM INSERTED i)

	-- Checks if there is already an existing CCS for the credit card, does not generate a CCS if there is
	IF EXISTS (SELECT CCSDate
		FROM CreditCardStatementView
		WHERE CCNo = @CCNo AND MONTH(CCSDate) = MONTH(@CCSDate) AND YEAR(CCSDate) = YEAR(@CCSDate))
	BEGIN
		EXEC uspGetErrorCodes -300
		RETURN
	END

	-- Checks if there are any transaction records, does not generate a CCS if there are none
	IF NOT EXISTS (SELECT * FROM CardTransaction WHERE CTCCNo = @CCNo AND CTStatus = 'Pending')
	BEGIN
		EXEC uspGetErrorCodes -301
		RETURN
	END

	INSERT INTO CreditCardStatement
	VALUES (@CCSId, @CCSDate, @CCSPayDueDate, 0, 0)
	-- error handling
	IF @@ERROR <> 0
	BEGIN
		EXEC uspGetErrorCodes -302
		RETURN
	END
	
	-- Update customer's transactions with credit card statement Id for those that are pending or failed transactions from the current month
	UPDATE CardTransaction
	SET CTCCSNo = @CCSId
	WHERE CTCCNo = @CCNo AND (CTStatus = 'Pending' OR (CTStatus = 'Failed' AND MONTH(CTDate) = MONTH(@CCSDate) AND YEAR(CTDate) = YEAR(@CCSDate)))

	-- Adds transaction amounts to newly created statement
	EXEC uspAddTransactionToStatement @CCSNo=@CCSId
GO

-- *This procedure is created here due to multi-table view conflict that has to be resolved by the trigger above first

-- ** Generate a new Credit Card Statement **
-- Default payment due date is three weeks from statement date
-- Statement date is date when statement is generated (i.e. last day of the month)


CREATE PROC uspGenerateMonthlyCardStatement(@CCNo CHAR(16), @CurrentDate SMALLDATETIME = NULL)
AS
	-- Sets parameter to current date if none is specified
	IF (@CurrentDate IS NULL)
		SET @CurrentDate = GETDATE()

	-- Generate a new credit card statement id
	DECLARE @CCSId CHAR(10)
	SELECT TOP 1 @CCSId = 'S' +  SUBSTRING(CAST('1'+SUBSTRING(CCSNo, 2, 10)+1 AS CHAR(10)), 2, 10)
	FROM CreditCardStatement
	ORDER BY CCSNo DESC

	-- Initialize new credit card statement using view
	INSERT INTO CreditCardStatementView
	VALUES (@CCSId, @CurrentDate, DATEADD(DAY, 21, @CurrentDate), 0, 0, @CCNo, 0, 0)

RETURN
GO

-- ========== MAIN QUERIES ==========

/* ------TEST DATA------
SELECT * FROM CardTransaction

DECLARE @date DATETIME
SET @date = CONVERT(DATETIME, '2023-03-05 00:00:00')
EXEC uspGetCustomerRewards @date

EXEC uspGetMerchantWithMostTransactions
INSERT INTO CardTransaction VALUES ('T000000013', 'ADB Travel','700','2022-12-1','Failed', '5395164704886973', NULL)
DELETE FROM CardTransaction WHERE CTNo = 'T000000013'

EXEC uspGetSuspendedCustomers

EXEC uspGetMonthlyStatement @CCNo = '5443835770559378', @CCSMonth = 10, @CCSYear = 2022
GO
*/

-- **Display Monthly Statement**
-- Must have all transactions displayed, including failed ones
-- Statement must show total credit limit and available balance (From CreditCard table)

CREATE PROC uspGetMonthlyStatement (@CCNo CHAR(16), @CCSMonth SMALLINT = NULL, @CCSYear SMALLINT = NULL)
AS
	IF (@CCSMonth = NULL OR @CCSYear = NULL)
		SET @CCSMonth = MONTH(GETDATE())
		SET @CCSYear = YEAR(GETDATE())

	SELECT *
	FROM CreditCardStatementView
	WHERE CCNo = @CCNo AND MONTH(CCSDate) = @CCSMonth AND YEAR(CCSDate) = @CCSYear
RETURN
GO

-- ** Details of customers who have earned rewards in the current month. **
CREATE PROC uspGetCustomerRewards(@CurrentDate DATETIME = NULL)
AS
	-- Default value is current date
	IF (@CurrentDate IS NULL)
		SET @CurrentDate = GETDATE()

	PRINT MONTH(@CurrentDate)
	PRINT YEAR(@CurrentDate)

	SELECT c.CustId, c.CustName, r.*
	FROM Customer c
	INNER JOIN CreditCard cc ON cc.CCCustId = c.CustId
	INNER JOIN Reward r ON r.RewCCNo = cc.CCNo
	WHERE MONTH(DATEADD(MONTH, -6, r.RewValidTill)) = MONTH(@CurrentDate) AND YEAR(DATEADD(MONTH, -6, r.RewValidTill)) = YEAR(@CurrentDate)
RETURN

GO
-- ** The name of the merchant that the most number of transactions were made to. **
CREATE PROC uspGetMerchantWithMostTransactions
AS
	SELECT CTMerchant, COUNT(CTNo) AS 'Number of Transactions' -- get all counts of transactions from each merchant that has the most number of transactions
	FROM CardTransaction
	GROUP BY CTMerchant
	HAVING COUNT(CTNo) = 
		(SELECT MAX(mt.[Number of Transactions]) -- get max value of counts of transactions from all merchant
		FROM (SELECT CTMerchant, COUNT(CTNo) as 'Number of Transactions' -- get all counts of transactions from each merchant
			FROM CardTransaction
			GROUP BY CTMerchant) as mt
		)
RETURN
GO

-- ** Details of customers who have not paid their bills last month. **
--	> Assume customers who are currently suspended are automatically suspended if they have not paid their bills
CREATE PROC uspGetSuspendedCustomers
AS
	SELECT c.*, cc.CCNo, cc.CCStatus
	FROM Customer c
	INNER JOIN CreditCard cc ON cc.CCCustId = c.CustId
	WHERE CustStatus = 'Suspended'
RETURN
GO



-- ===========================
-- || ~ Rewards Programme ~ || --
-- ===========================

/* ------TEST DATA------
-- Trying out to insert a transaction---- 
INSERT INTO CardTransaction (CTNo, CTMerchant, CTAmount, CTDate, CTStatus, CTCCNo, CTCCSNo)
VALUES ('T000000006','Don Don Donkey', 871.20, GETDATE() ,'Billed', 5443835770559378, 'S000000001')

-- Updating the Reward Status to claimed to trigger trigUpdateRedeemDate --
UPDATE Reward
SET RewStatus = 'Claimed'
Where RewID = 3;

Select * FROM Reward*/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='uspRewards' AND  Type='P')
	DROP PROC uspRewards
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigCreateReward')
	DROP TRIGGER trigCreateReward
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='trigUpdateRedeemDate')
	DROP TRIGGER trigUpdateRedeemDate
GO

-- ========== STORED PROCEDURES ========== --

-- Stored Procedure for Rewards -- 

CREATE PROC uspRewards(@MerchantDescription VARCHAR(100),  
@Amount SMALLMONEY, @CCNo CHAR(16),@RewardDate SMALLDATETIME )
AS
	DECLARE @RewardAmount SMALLMONEY
	SET @RewardDate = DATEADD(MONTH,6,@RewardDate)
	SET @MerchantDescription = @MerchantDescription + ' Voucher'
	
	IF @Amount >= 500 or @Amount <= 999.99
		SET @RewardAmount = 5.00
	
	ELSE IF @Amount >= 1000
		SET @RewardAmount = 10.00
	
	ELSE IF @@ERROR<>0
		print 'Cannot be processed'
	
	ELSE
	BEGIN
		print 'Your Amount is not eligible for the
		Voucher reward'
		RETURN
	END
	INSERT INTO Reward(RewDesc,RewAmount,RewValidTill,RewStatus,RewCCNo)
	VALUES(@MerchantDescription,@RewardAmount,@RewardDate,'Available', @CCNo)
	SET @MerchantDescription = @@IDENTITY
RETURN
GO	

-- ========== TRIGGERS ========== --

-- Trigger reward stored procedure when a transaction is Inserted --

CREATE TRIGGER trigCreateReward
ON CardTransaction  AFTER INSERT
	AS
	
	DECLARE @TransactedAmount SMALLMONEY, @Merchant VARCHAR(100),
	@Amt SMALLMONEY, @CCNo CHAR(16), @RewardDate SMALLDATETIME


	SET @TransactedAmount = (SELECT i.CTAmount FROM INSERTED i)
	SET @Merchant = (SELECT i.CTMerchant FROM INSERTED i)
	SET @Amt = (SELECT i.CTAmount FROM INSERTED i)
	SET @CCNo = (SELECT i.CTCCNo FROM INSERTED i)
	SET @RewardDate = (SELECT i.CTDate FROM INSERTED i)

	IF (@@ROWCOUNT>0)
		BEGIN
			EXEC uspRewards @MerchantDescription = @Merchant,  
@Amount = @Amt, @CCNo = @CCNo , @RewardDate = @RewardDate 
		END
	GO

	
-- Trigger to update the redeem date if reward status is claimed --

CREATE TRIGGER trigUpdateRedeemDate
On Reward AFTER UPDATE
	AS

	DECLARE @RewStatus VARCHAR(10), @RedeemDate SMALLDATETIME

	SET @RewStatus = (SELECT i.RewStatus FROM INSERTED i)
	SET @RedeemDate = (SELECT i.RewRedeemDate FROM INSERTED i)

	if @RewStatus = 'Claimed'
		UPDATE Reward
		SET RewRedeemDate = GETDATE()
	Return
	GO