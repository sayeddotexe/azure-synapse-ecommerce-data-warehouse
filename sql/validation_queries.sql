-- Example checks for your Synapse Serverless SQL analytical views.
-- Review column spelling and view names against your actual published schema.
USE SalesDW;
GO

-- Cart-line grain and totals.
SELECT
    COUNT_BIG(*) AS TotalCartLines,
    COUNT(DISTINCT CartId) AS DistinctCarts,
    SUM(Quantity) AS TotalItems,
    SUM(LineBasketValue) AS TotalEstimatedBasketValue
FROM dbo.vwFactCartLines;
GO

-- Invalid quantities / prices (expected: 0 if filtered out upstream).
SELECT COUNT(*) AS InvalidCartLines
FROM dbo.vwFactCartLines
WHERE Quantity <= 0 OR UnitPrice < 0 OR LineBasketValue < 0;
GO

-- Missing matches to the product dimension.
SELECT COUNT(*) AS UnmatchedProductLines
FROM dbo.vwFactCartLines AS f
LEFT JOIN dbo.vwDimProduct AS p ON f.ProductId = p.ProductId
WHERE p.ProductId IS NULL;
GO

-- Category breakdown used by analytical reporting.
SELECT TOP (10)
    p.Category,
    COUNT(DISTINCT f.CartId) AS DistinctCarts,
    SUM(f.LineBasketValue) AS EstimatedBasketValue
FROM dbo.vwFactCartLines AS f
INNER JOIN dbo.vwDimProduct AS p ON f.ProductId = p.ProductId
GROUP BY p.Category
ORDER BY EstimatedBasketValue DESC;
GO
