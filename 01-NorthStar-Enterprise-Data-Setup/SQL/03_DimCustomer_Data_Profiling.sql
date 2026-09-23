/* ============================================================
   NorthStarBI - DimCustomer Data Profiling

   Purpose:
   Assess the completeness, uniqueness, validity, consistency,
   and referential integrity of customer dimension data.
   ============================================================ */

-- Review DimCustomer structure and constraints
EXEC sp_help 'dbo.DimCustomer';


-- Check total number of customer records
SELECT COUNT(*) AS TotalRecords
FROM dbo.DimCustomer;


-- Check for NULL values in the primary key
SELECT *
FROM dbo.DimCustomer
WHERE CustomerKey IS NULL;

-- Check for duplicate CustomerKeys
SELECT CustomerKey, COUNT(*) AS Duplicate
FROM dbo.DimCustomer
GROUP BY CustomerKey
HAVING COUNT(*) > 1;

-- Review customer distribution by gender
SELECT Gender, COUNT(*) AS Num_Customer
FROM dbo.DimCustomer
GROUP BY Gender;

-- Review customer distribution by segment
SELECT Segment, COUNT(*) AS Num_Customer
FROM dbo.DimCustomer
GROUP BY Segment;

-- Review customer distribution by active status
SELECT IsActive, COUNT(*) AS Num_Customer
FROM dbo.DimCustomer
GROUP BY IsActive;

-- Review customer distribution by loyalty tier
SELECT LoyaltyTier, COUNT(*) AS Num_Customer
FROM dbo.DimCustomer
GROUP BY LoyaltyTier;

-- Check for customers whose signup date is before their birth date
SELECT
    CustomerKey,
    FirstName,
    LastName,
    BirthDate,
    SignupDate
FROM dbo.DimCustomer
WHERE BirthDate > SignupDate;

-- Check for non-NULL GeographyKeys without a matching DimGeography record
SELECT *
FROM dbo.DimCustomer c
WHERE c.GeographyKey IS NOT NULL
  AND NOT EXISTS
(
    SELECT 1
    FROM dbo.DimGeography g
    WHERE c.GeographyKey = g.GeographyKey
);

-- Check for blank FirstName or LastName values
SELECT *
FROM dbo.DimCustomer
WHERE LTRIM(RTRIM(FirstName)) = ''
   OR LTRIM(RTRIM(LastName)) = '';


-- Count missing values in important customer attributes

SELECT COUNT(*) AS NullCustomerID
FROM dbo.DimCustomer
WHERE CustomerID IS NULL;

SELECT COUNT(*) AS NullIsActive
FROM dbo.DimCustomer
WHERE IsActive IS NULL;

SELECT COUNT(*) AS NullSignupDate
FROM dbo.DimCustomer
WHERE SignupDate IS NULL;

SELECT COUNT(*) AS NullLoyaltyTier
FROM dbo.DimCustomer
WHERE LoyaltyTier IS NULL;

SELECT COUNT(*) AS NullDataQualityFlag
FROM dbo.DimCustomer
WHERE DataQualityFlag IS NULL;

-- Check for duplicate CustomerIDs
SELECT CustomerID, COUNT(*) AS Duplicate
FROM dbo.DimCustomer
GROUP BY CustomerID
HAVING COUNT(*) > 1;


-- Check customer age range
SELECT
    MIN(DATEDIFF(YEAR, BirthDate, GETDATE())) AS MinimumAge,
    MAX(DATEDIFF(YEAR, BirthDate, GETDATE())) AS MaximumAge
FROM dbo.DimCustomer;


-- Check BirthDate range
SELECT
    MIN(BirthDate) AS EarliestBirthDate,
    MAX(BirthDate) AS LatestBirthDate
FROM dbo.DimCustomer;


-- Check SignupDate range
SELECT
    MIN(SignupDate) AS EarliestSignupDate,
    MAX(SignupDate) AS LatestSignupDate
FROM dbo.DimCustomer;
