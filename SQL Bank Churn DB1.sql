--DDL & DML

--1) Create Database:

Create DATABASE BankChurnDB;

Use BankChurnDB;

--2) Create Tables

-- Costomer_Info Table

CREATE TABLE Customer_Info (

Customer_ID INT PRIMARY KEY,
Churn_Status VARCHAR(50),
Age INT,
Gender VARCHAR(10),
Num_Dependents INT,
Education_Level VARCHAR(50),
Marital_Status VARCHAR(20),
Income_Range VARCHAR(50),
Card_type VARCHAR(30)
);


-- Account_Activity Table

CREATE TABLE Account_Activity (

Account_ID INT IDENTITY(1,1) PRIMARY KEY,
Customer_ID INT,
Tenure_Months INT,
Num_Bank_Products INT,
Inactive_Months_Last_year INT,
Customer_Service_Calls INT,

FOREIGN KEY (Customer_ID) REFERENCES Customer_Info(Customer_ID)
);

--Transaction_Credit Table

CREATE TABLE Transaction_Credit (

Transaction_ID INT IDENTITY(1,1) PRIMARY KEY,
Customer_ID INT,
Credit_Limit FLOAT,
Revolving_Balance FLOAT,
Available_Credit FLOAT,
Total_Transaction_Amount FLOAT,
Total_Transaction_Count INT,
Credit_Utilization_Ratio FLOAT,
Spending_Change_Q4_Q1 FLOAT,
Transaction_Count_Change_Q4_Q1 FLOAT,

FOREIGN KEY (Customer_ID) REFERENCES Customer_Info(Customer_ID)
);


--3) Staging Table before Bulk Insert

CREATE TABLE Staging_Table (

Customer_ID INT,
Churn_Status VARCHAR(100),
Age INT,
Gender VARCHAR(50),
Num_Dependents INT,
Education_Level VARCHAR(100),
Marital_Status VARCHAR(60),
Income_Range VARCHAR(100),
Card_Type VARCHAR(70),
Tenure_Months INT,
Num_Bank_Products INT,
Inactive_Months_Last_Year INT,
Customer_Service_Calls INT,
Credit_Limit FLOAT,
Revolving_Balance FLOAT,
Available_Credit FLOAT,
Total_Transaction_Amount FLOAT,
Total_Transaction_Count INT,
Credit_Utilization_Ratio FLOAT,
Spending_Change_Q4_Q1 FLOAT,
Transaction_Count_Change_Q4_Q1 FLOAT
);



CREATE TABLE Staging_Table (

Customer_ID INT,
Churn_Status VARCHAR(100),
Age INT,
Gender VARCHAR(50),
Num_Dependents INT,
Education_Level VARCHAR(100),
Marital_Status VARCHAR(60),
Income_Range VARCHAR(100),
Card_Type VARCHAR(70),
Tenure_Months INT,
Num_Bank_Products INT,
Inactive_Months_Last_Year INT,
Customer_Service_Calls INT,
Credit_Limit FLOAT,
Revolving_Balance FLOAT,
Available_Credit FLOAT,
Total_Transaction_Amount FLOAT,
Total_Transaction_Count INT,
Credit_Utilization_Ratio FLOAT,
Spending_Change_Q4_Q1 FLOAT,
Transaction_Count_Change_Q4_Q1 FLOAT
);


--4) Bulk Insert

BULK INSERT Staging_Table
FROM 'C:\Users\HP\Downloads\cleaned_merged_data.csv'
WITH (
     FORMAT = 'CSV',
     FIRSTROW = 2
);


-- Have an Issue in bulk insert so dropped staging_table and save CSV file as CSV (Comma Delimited), then make Bulk Insert again 
DROP TABLE Staging_Table;

-- Testing
SELECT TOP 10 * FROM Staging_Table;


-- Insert Data Into 3 Tables From Staging_Table after BULK_INSERT

--1) Customer_Info Table

INSERT INTO Customer_Info
SELECT DISTINCT 
      Customer_ID,
      Churn_Status,
      Age,
      Gender,
      Num_Dependents,
      Education_Level,
      Marital_Status,
      Income_Range,
      Card_Type
FROM Staging_Table;

-- TEST
SELECT TOP 10 * FROM Customer_Info;


-- 2) Account_Activity

INSERT INTO Account_Activity
(Customer_ID, Tenure_Months, Num_Bank_Products, Inactive_Months_Last_year, Customer_Service_Calls)
SELECT
  Customer_ID,
  Tenure_Months,
  Num_Bank_Products,
  Inactive_Months_Last_Year,
  Customer_Service_Calls
FROM Staging_Table;

--TEST
SELECT TOP 10 * FROM Account_Activity;


--3) Transaction_Credit 

INSERT INTO Transaction_Credit
(Customer_ID, Credit_Limit, Revolving_Balance, Available_Credit, Total_Transaction_Amount, Total_Transaction_Count, Credit_Utilization_Ratio, Spending_Change_Q4_Q1, Transaction_Count_Change_Q4_Q1)
SELECT
    Customer_ID,
    Credit_Limit,
    Revolving_Balance,
    Available_Credit,
    Total_Transaction_Amount,
    Total_Transaction_Count,
    Credit_Utilization_Ratio,
    Spending_Change_Q4_Q1,
    Transaction_Count_Change_Q4_Q1
FROM Staging_Table
);

--TEST
SELECT TOP 10 * FROM Transaction_Credit;

----------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:-

--1) Overall Churn Rate

CREATE VIEW Overall_Churn_Rate_View AS
SELECT
COUNT(CASE WHEN Churn_Status = 'Attrited Customer' THEN 1 END) * 1.0 / COUNT(*) AS Overall_Churn_Rate
FROM Customer_Info;
Go

SELECT * FROM Overall_Churn_Rate_View;




--2) Average Age of Customers

CREATE VIEW Avg_Age_Of_Customers_View AS
SELECT AVG(Age) AS Avg_Age
FROM Customer_Info;
GO

SELECT * FROM Avg_Age_Of_Customers_View;


--3) Avg Credit Utilization

CREATE VIEW Credit_Card_Utilization_Ratio_View AS
SELECT
AVG(Credit_Utilization_Ratio) AS Avg_Credit_Card_Utilization_Ratio
FROM Transaction_Credit;
GO

SELECT * FROM Credit_Card_Utilization_Ratio_View;


--4) Churn rate per Income range

CREATE VIEW Churn_Per_Income_View AS
SELECT
Income_Range, COUNT(*) AS Churn_Customers
FROM Customer_Info
GROUP BY Income_Range;
GO

SELECT * FROM Churn_Per_Income_View;

--5) Card Distribution

CREATE VIEW Distribution_by_Card_Type_View AS
SELECT
Card_Type, COUNT(*) AS Distribution_by_Card_Type
FROM Customer_Info
GROUP BY Card_type;
GO

SELECT * FROM Distribution_by_Card_Type_View;


--6) Transactions by Tenure

CREATE VIEW Tenure_Spending_View AS
SELECT
Tenure_Months, SUM(Total_Transaction_Amount) AS Total_Spending
FROM Account_Activity a
JOIN Transaction_Credit t
ON a.Customer_ID = t.Customer_ID
GROUP BY Tenure_Months;
GO

SELECT * FROM Tenure_Spending_View;

--7) Credit VS Balance

CREATE VIEW Credit_Balance_View AS
SELECT
Credit_Limit, Revolving_Balance
FROM Transaction_Credit;
GO

SELECT * FROM Credit_Balance_View;


--8) Avg Calls (Churned)

CREATE VIEW Avg_Churn_Calls_View AS
SELECT
AVG(Customer_Service_Calls) AS Avg_Churn_Calls
FROM Account_Activity a
JOIN Customer_Info c
ON a.Customer_ID = c.Customer_ID
WHERE Churn_Status = 'Attrited Customer';
GO

SELECT * FROM Avg_Churn_Calls_View;


--9) Avg Inactive Months

CREATE VIEW Avg_Inactive_Months_View AS
SELECT
AVG(Inactive_Months_Last_year) AS Avg_Inactive_Months
FROM Account_Activity;
GO

SELECT * FROM Avg_Inactive_Months_View;

--10) Education VS Churn

CREATE VIEW Education_Churned_Customers_View AS
SELECT
Education_Level, COUNT(*) AS Churned_Customers
FROM Customer_Info
WHERE Churn_Status = 'Attrited Customer'
GROUP BY Education_Level;
GO 

SELECT * FROM Education_Churned_Customers_View;


--11) Credit VS Available

CREATE VIEW Credit_Available_View AS
SELECT
Credit_Limit, Available_Credit
FROM Transaction_Credit;
GO

SELECT * FROM Credit_Available_View;

--12) Spending by Card

CREATE VIEW Card_With_Highest_Spending_View AS
SELECT
Card_Type, Sum(Total_Transaction_Amount) AS Highest_Spending
FROM Customer_Info c
JOIN Transaction_Credit t
ON c.Customer_ID = t.Customer_ID
GROUP BY Card_type
ORDER BY SUM(Total_Transaction_Amount) DESC ;
GO

SELECT * FROM Card_With_Highest_Spending_View;                              

--13) Top 5 Customers

CREATE VIEW Top_Customers_View AS
SELECT
TOP 5 Customer_ID, SUM(Total_Transaction_Amount) AS Top_5_Customers
FROM Transaction_Credit
GROUP BY Customer_ID
ORDER BY SUM(Total_Transaction_Amount) DESC;
GO

SELECT * FROM Top_Customers_View;


--14) Churn Rate Per Marital_Status

CREATE VIEW Marital_Status_View AS
SELECT
Marital_Status, COUNT(*) AS Churned_Customers
FROM Customer_Info
GROUP BY Marital_Status;
GO

SELECT * FROM Marital_Status_View;

--15) Q4 VS Q1

CREATE VIEW Q4_q1_View AS
SELECT
Spending_Change_Q4_Q1, Transaction_Count_Change_Q4_Q1
FROM Transaction_Credit;
GO

SELECT * FROM Q4_q1_View;


CREATE VIEW AVG_Revolving_Balance AS
SELECT 
Revolving_Balance AS AVG_Revolving_Balance
FROM Transaction_Credit;

CREATE VIEW AVG_Transaction_Count_Change_Q4_Q1 AS
SELECT
Transaction_Count_Change_Q4_Q1 AS AVG_Transaction_Count_Change_Q4_Q1
FROM Transaction_Credit;