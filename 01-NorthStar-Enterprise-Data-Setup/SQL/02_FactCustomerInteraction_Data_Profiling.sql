/* ============================================================
   NorthStarBI - FactCustomerInteraction Data Profiling
   Purpose:
   Assess data quality, validity, uniqueness, and referential
   integrity of the FactCustomerInteraction table.
   ============================================================ */

-- 1. Check for missing Satisfaction Scores
SELECT COUNT(*) AS Null_Value
FROM dbo.FactCustomerInteraction
WHERE SatisfactionScore IS NULL;

-- 2. Check for Satisfaction Scores outside the valid range of 1–5
SELECT *
FROM dbo.FactCustomerInteraction
WHERE SatisfactionScore < 1
   OR SatisfactionScore > 5;


-- 3. Review the distribution of Resolved status
SELECT 
    Resolved,
    COUNT(*) AS InteractionCount
FROM dbo.FactCustomerInteraction
GROUP BY Resolved;


-- 4. Check for CustomerKeys that do not exist in DimCustomer
SELECT *
FROM dbo.FactCustomerInteraction f
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.DimCustomer c
    WHERE c.CustomerKey = f.CustomerKey
);


-- 5. Check for non-NULL AgentEmployeeKeys that do not exist in DimEmployee
SELECT *
FROM dbo.FactCustomerInteraction f
WHERE f.AgentEmployeeKey IS NOT NULL
  AND NOT EXISTS
(
    SELECT 1
    FROM dbo.DimEmployee e
    WHERE f.AgentEmployeeKey = e.EmployeeKey
);


-- 6. Check minimum and maximum ResolutionMinutes
SELECT
    MIN(ResolutionMinutes) AS MinResolutionMinutes,
    MAX(ResolutionMinutes) AS MaxResolutionMinutes
FROM dbo.FactCustomerInteraction;


-- 7. Check for duplicate InteractionKeys
SELECT
    InteractionKey,
    COUNT(*) AS Num_InteractionKey
FROM dbo.FactCustomerInteraction
GROUP BY InteractionKey
HAVING COUNT(*) > 1;


-- 8. Check earliest and latest InteractionDateKey
SELECT
    MIN(InteractionDateKey) AS EarliestDate,
    MAX(InteractionDateKey) AS LatestDate
FROM dbo.FactCustomerInteraction;


-- 9. Check for InteractionDateKeys that do not exist in DimDate
SELECT *
FROM dbo.FactCustomerInteraction f
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.DimDate d
    WHERE d.DateKey = f.InteractionDateKey
);
