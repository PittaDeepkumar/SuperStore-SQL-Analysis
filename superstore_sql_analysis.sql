
-- Data Validation :
-- Purpose :
-- Checking Total number of records
-- Ensuring Row_id and Order_id have no null values
-- Verifying Row_id is unique per row

-- Total number of rows
SELECT count(*) as total_rows 
FROM SuperStore ;

-- Check for nulls in key identifier columns
SELECT 
	count(*) AS total_rows ,
	count(row_id) as count_of_row_id ,
	count(order_id) as count_of_order_id
FROM SuperStore ;

-- Verify Row_id uniqueness ( candidate primary key )
SELECT count(DISTINCT row_id ) as Count_of_unique_rowID
FROM SuperStore ;

-- Result: Row_ID count matches total rows  , confirming uniqueness.


-- Checking for zero or negative quantities
SELECT *
FROM SuperStore
WHERE Quantity <= 0; 

-- Checking for negative sales
SELECT *
FROM SuperStore
WHERE Sales < 0;

-- Result: No invalid values found


/* 
=======================
Data Cleaning
=======================
*/

-- Checking Nulls 
SELECT 
	count(*) As total_rows ,
	count(Sales) as SalesCount ,
	count(Profit) as ProfitCount ,
	count(Quantity) as QuantityCount ,
	count(Order_date) as OrderDateCount
FROM SuperStore ;

-- Result : No Null values are found in any column

-- Checking for duplicates

SELECT 
	Order_ID ,
	Product_ID ,
	Count(*) as duplicates
FROM superstore
Group by Order_ID , Product_ID 
Having count(*) > 1

-- There are multiple Order_ID, Product_ID combinations appearing more than once 
-- but before we remove, check if it is actually a duplicate or not

SELECT
	Order_ID ,
	Product_ID ,
	Sales ,
	Quantity ,
	Profit ,
	Ship_Date
FROM SuperStore
WHERE Order_ID = 'CA-2016-137043' And 
	  Product_ID = 'FUR-FU-10003664' ;

-- We have two types of duplicates one where all the columns have same values
-- and the other one which have Order_ID , Product_ID are same but sales, quantity, profits etc are different
-- So In order to define True duplicates rows

SELECT
	Order_ID, 
	Product_ID , 
	Sales ,
	Quantity ,
	Profit ,
	Ship_Date ,
	count(*) As Duplicate_Count
FROM SuperStore
Group By 
	Order_ID, 
	Product_ID , 
	Sales ,
	Quantity ,
	Profit ,
	Ship_Date
Having Count(*) > 1 ;

-- We identified One True Duplicate rows 
-- In order to delete it

WITH cte_duplicate As ( 
	SELECT
		* ,
		ROW_NUMBER() Over( Partition By Order_ID, Product_ID, Sales, Quantity, Profit, Ship_Date  Order by Row_ID ) As rn
	FROM SuperStore
)
DELETE FROM cte_duplicate
WHERE rn > 1

-- After checking once again for duplicates, I found no duplicates.


/* 
========================
Exploratory Analysis
========================
*/
-- Get an overall snapshot of total sales , profit and quantity
SELECT
	SUM(Sales) As total_sales ,
	SUM(Profit) As total_profit ,
	SUM(Quantity) AS total_quantity
FROM SuperStore ;

-- Overall profit is positive

SELECT 
	SUM(profit)/SUM(sales) * 100 As profit_margin_percent
FROM SuperStore ;

-- Overall profit margin is approx 12.5% indicating a moderately positive margin

 
-- Checking for profit over sales by category
SELECT
	Category ,
	SUM(Sales) As Total_Sales ,
	SUM(profit) As Total_Profit
FROM SuperStore
Group By Category ;

-- we can see Technology has the most profit compared to other categories even when sales are lesser.
-- but we have to see profit margin percentage to get exact answer

SELECT 
	Category ,
	(Sum(Profit) / Sum(Sales)) * 100 As Profit_Margin_Percent
FROM SuperStore 
Group by Category ;

-- Insight: Technology and office supplies have the most profit percent around 17%
--			while furniture shows very low profitability of only 2.5% despite high Sales


-- Investigating discount impact on profitability

SELECT
	Category ,
	Avg(Discount) As Avg_discount
FROM SuperStore 
Group by Category ;

-- Insight : Furniture has the highest average discount , which likely contributes
-- to its low profit margin compared to Technology and Office Supplies.


SELECT 
	Discount ,
	Sum(Sales) As TotalSales , 
	Sum(Profit) As TotalProfit
FROM SuperStore 
Group By Discount
Order By Discount ;

-- Insight: Orders with discounts of 30% or higher consistently generate losses ,
-- indicating that heavy discounting is a primary driver of negative profitability.


/*
======================
Business Recommendations
======================
*/

-- Recommendations 1: Reduce deep discounting(above 30%) , especially in the furniture
-- as high discounts are consistently associated with negative profitability.

-- Recommendation 2 : Prioritize growth in Technology and Office Supplies, 
-- which demonstrate strong and stable profit margins(17%).

-- Recommendation 3 : Review pricing and cost structure for Furniture products ,
-- as high sales volumes are not translating into proportional profits.

