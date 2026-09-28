/* ============================================================
   NorthStarBI - FactSales Data Profiling

   Purpose:
   Assess the completeness, uniqueness, validity, consistency,
   referential integrity, and business-rule accuracy of the
   FactSales table.
   ============================================================ */

/*Structure: What columns are in FactSales? What is the primary key? 
Which columns permit NULLs?*/

EXEC sp_help 'dbo.factsales';

----Volume: How many rows are in FactSales?

SELECT COUNT(saleskey)
FROM
dbo.FactSales;

/*Primary-key quality: Are there NULL SalesKey values? Are there 
duplicate SalesKey values?*/

SELECT  *
FROM
dbo.factsales
WHERE SalesKey IS NULL


SELECT  saleskey, COUNT(saleskey) AS Duplicate
FROM
dbo.factsales
GROUP BY SalesKey
HAVING COUNT(SalesKey) > 1;

/*Missing data: Which important columns contain NULLs? Count the NULLs 
for each relevant column.*/

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE SalesKey IS NULL;

SELECT COUNT(*) AS Total_NUll
FROM
dbo.FactSales
WHERE SalesDateKey IS NULL;

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE OrderKey IS NULL;

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE CustomerKey IS NULL;

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE ProductKey IS NULL;

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE StoreKey IS NULL;

SELECT COUNT(*) AS Total_Null
FROM
dbo.FactSales
WHERE EmployeeKey IS NULL;


/*Referential integrity: Check whether the relevant non-NULL keys in 
FactSales have matching records in their dimension tables. For example, 
if you find CustomerKey, ProductKey, SalesDateKey, or other dimension 
keys, use NOT EXISTS against the appropriate dimension.*/

SELECT *
FROM
dbo.FactSales f
WHERE CustomerKey IS NOT NULL AND NOT EXISTS( SELECT 1 FROM dbo.DimCustomer c
WHERE f.CustomerKey = c.CustomerKey);

SELECT *
FROM
dbo.FactSales f
WHERE ProductKey IS NOT NULL AND NOT EXISTS( SELECT 1 FROM dbo.DimProduct p
WHERE f.ProductKey = p.productkey);

SELECT *
FROM
dbo.FactSales f
WHERE SalesDateKey IS NOT NULL AND NOT EXISTS( SELECT 1 FROM dbo.DimDate d
WHERE f.SalesDateKey = d.DateKey);

/*Numeric validity: Examine the minimum and maximum values of important 
numeric measures such as quantity, unit price, discount, cost, or sales 
amount—using the actual columns in your table. Then identify values that 
appear impossible, such as negative quantities or amounts where the 
business logic says they shouldn't be negative.*/

SELECT min(quantity) AS min_qty, max(quantity) AS max_qty
FROM
dbo.factsales;

SELECT min(netsales) AS min_sales, max(netsales) AS max_sales
FROM
dbo.factsales;

SELECT min(discountamount) AS min_disamt, max(discountamount) AS max_disamt
FROM
dbo.factsales;

SELECT min(grosssales) AS min_sales, max(grosssales) AS max_sales
FROM
dbo.factsales;

SELECT min(costamount) AS min_amt, max(costamount) AS max_amt
FROM
dbo.factsales;

SELECT min(profitamount) AS min_amt, max(profitamount) AS max_amt
FROM
dbo.factsales;

/*Date quality: Find the earliest and latest sales dates/keys. Then 
check whether every non-NULL sales date key exists in DimDate.*/

SELECT min(SalesDateKey) AS esrliestdate, max(SalesDateKey) AS latestdate
FROM
dbo.FactSales;

SELECT *
FROM
dbo.FactSales f WHERE SalesDateKey IS NOT NULL AND NOT EXISTS(
SELECT 1 FROM dbo.DimDate d WHERE f.SalesDateKey = d.DateKey
);

/*Customer/product integrity: Determine whether any sales reference
customers or products that don't exist in their respective dimensions.*/

SELECT *
FROM
dbo.FactSales f
WHERE NOT EXISTS(
SELECT 1 FROM dbo.DimCustomer c WHERE f.CustomerKey = c.CustomerKey);

SELECT *
FROM
dbo.FactSales f
WHERE NOT EXISTS(
SELECT 1 FROM dbo.DimProduct c WHERE f.ProductKey = c.ProductKey);


/*Business calculation: If FactSales contains the necessary columns, test 
whether the stored sales amount is consistent with the components used to 
calculate it. Don't assume the formula yet—inspect the columns and 
determine what relationship makes sense.*/

USE NorthStarBI;

SELECT SalesKey, SalesDateKey, Quantity, CostAmount,DiscountAmount, 
NetSales, GrossSales, (GrossSales - DiscountAmount) AS Net_sales,
(NetSales - ProfitAmount) AS cost_Amount,
CASE
WHEN NetSales = (GrossSales - DiscountAmount) THEN 1
ELSE 0 
END AS Nets,
CASE
WHEN CostAmount = (NetSales - ProfitAmount) THEN 1
ELSE 0
END AS Cost,
CASE
    WHEN ABS(NetSales - (GrossSales - DiscountAmount)) <= 0.01 THEN 1
    ELSE 0
END AS NetSalesValid,
CASE
    WHEN ABS(CostAmount - (NetSales - ProfitAmount)) <= 0.01 THEN 1
    ELSE 0
END AS CostAmountValid
FROM
dbo.FactSales


/*Business patterns: Choose two useful analytical questions of your own 
about the sales data and write SQL to answer them. For example, 
you might investigate sales by year, product, customer, channel, 
region, or another attribute—but choose based on the columns you 
actually have.*/

-----Sales Volume By Product

SELECT ProductName, SUM(Quantity)AS Total_Qty
FROM
dbo.FactSales f
INNER JOIN
dbo.DimProduct p
ON f.ProductKey = p.ProductKey
GROUP BY ProductName
ORDER BY SUM(Quantity)


----Total Revenue By Employee

SELECT EmployeeID, FirstName, LastName, Department, 
ROUND(SUM(NetSales),2) AS Revenue
FROM
dbo.FactSales f
INNER JOIN
dbo.DimEmployee e
ON f.EmployeeKey = e.EmployeeKey
GROUP BY EmployeeID, FirstName, LastName, Department
ORDER BY ROUND(SUM(NetSales),2);
