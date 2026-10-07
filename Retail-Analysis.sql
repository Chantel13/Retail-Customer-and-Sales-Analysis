RETAIL SALES ANALYSIS
SQL PORTFOLIO PROJECT

Objective: 
Analyse retail sales to understand revenue, profitability, customer behaviour, product performance, regional performance, sales channels, and returns.

Tools:
SQL Server / SSMS

Author: MS MNYONI, CHANTEL

1. DATA OVERVIEW

-- Check number of Customers
SELECT COUNT(*) AS TotalCustomers
FROM Customers;

-- Check number of Products
SELECT COUNT(*) AS TotalProducts
FROM Products;

-- Check number of Orders
SELECT COUNT(*) AS TotalOrders
FROM Orders;

-- Check number of Returns
SELECT COUNT(*) AS TotalReturns
FROM Returns;

2. DATA QUALITY CHECKS

-- Check for orders with no matching customer
SELECT 
    OrderID, 
    CustomerName 
FROM Orders as o 
LEFT JOIN Customers as c 
    ON c.customerid = o.customerid 
WHERE CustomerNAME IS NULL;

-- Check for orders with no matching product
SELECT 
    OrderID, 
    ProductName 
FROM Orders AS o 
LEFT JOIN Products AS p 
    ON p.ProductID = o.ProductID 
WHERE ProductName IS NULL; 
 
-- Check for orders with invalid quantities
SELECT 
    Quantity 
FROM Orders 
WHERE Quantity <= 0; 
 
 -- Check for invaild discounts
SELECT 
    Orderid, 
    Discount 
FROM Orders 
WHERE Discount < 0 OR Discount > 0.20;

-- Check whether returned quantity exceeds ordered quantity 
SELECT 
    Quantity, 
    QuantityReturned 
FROM Orders as o 
JOIN Returns as r 
    ON o.orderid = r.orderid 
WHERE Quantity < QuantityReturned; 
 
-- Check for duplicate orders
SELECT 
    OrderID, 
    COUNT(OrderID) AS NumberOfOrders
FROM Orders 
GROUP BY OrderID
HAVING COUNT(OrderID) > 1; 

3. OVERALL SALES PERFORMANCE

-- Total Revenue
SELECT 
    SUM(p.UnitPrice * o.Quantity) AS [Total Revenue] 
FROM Products AS P 
JOIN Orders AS O 
    ON p.productid = o.productid; 

-- Revenue after Discount
SELECT
    SUM(
        p.UnitPrice * o.Quantity * (1 - o.Discount)
    ) AS [Discounted Revenue]
FROM Products AS p
JOIN Orders AS o
    ON p.ProductID = o.ProductID;

-- Profit after discount
SELECT
    SUM(
        (p.UnitPrice * o.Quantity * (1 - o.Discount))
        -
        (p.CostPrice * o.Quantity)
    ) AS [Total Profit]
FROM Products AS p
JOIN Orders AS o
    ON p.ProductID = o.ProductID;

4. PRODUCT PERFORMANCE

-- Revenue by Products
SELECT 
    p.ProductName AS [Product Name], 
    SUM(p.UnitPrice * o.Quantity) AS [Total Revenue] 
FROM Products AS P 
JOIN Orders AS O 
    ON p.productid = o.productid 
GROUP BY p.ProductName 
ORDER BY [Total Revenue] DESC;

-- Rank top performing products within each category
WITH ProductRevenue AS
(
SELECT
    P.ProductName,
    P.Category,
    SUM(P.UnitPrice * O.Quantity) AS TotalRevenue
FROM Products AS P
JOIN Orders AS O
    ON p.productid = o.productid
GROUP BY 
    P.ProductName,
    P.Category
),
RankedProducts AS
(
SELECT
    ProductName,
    Category,
    TotalRevenue,
    RANK () OVER (
        PARTITION BY Category
        ORDER BY TotalRevenue DESC
        ) AS RevenueRank
FROM ProductRevenue
)
SELECT
    ProductName,
    Category,
    TotalRevenue
FROM RankedProducts
WHERE RevenueRank = 1;

-- AVERAGE ORDER VALUE
SELECT
    AVG(p.UnitPrice * o.Quantity) AS [Average Order Value]
FROM Products AS p
JOIN Orders AS o
    ON p.ProductID = o.ProductID;

5. Revenue generated in each month 
 
-- MONTHLY REVENUE
SELECT
    DATENAME(MONTH, o.OrderDate) AS MonthName,
    SUM(p.UnitPrice * o.Quantity) AS TotalRevenue
FROM Products AS p
JOIN Orders AS o
    ON p.ProductID = o.ProductID
GROUP BY
    DATENAME(MONTH, o.OrderDate),
    MONTH(o.OrderDate)
ORDER BY
    MONTH(o.OrderDate);

6. Percentage of orders returned

-- RETURNS RATE
SELECT
(
    COUNT(DISTINCT OrderID) * 1.0 
    /
    (SELECT COUNT(*) FROM Orders) 
) * 100 AS ReturnRate
FROM Returns;

7. Sales channels that generate the most revenue

-- SALES CHANNELS
SELECT
    o.SalesChannel,
    SUM(p.UnitPrice * o.Quantity) AS TotalRevenue
FROM Products AS p
JOIN Orders AS o
    ON p.ProductID = o.ProductID
GROUP BY o.SalesChannel
ORDER BY TotalRevenue DESC;

8. Top 10 customers whose revenue is above the average customer revenue

-- CUSTOMER BEHAVIOUR
WITH CustomerRevenue AS
(
SELECT
    C.CustomerName,
    SUM(p.UnitPrice * o.Quantity) AS TotalRevenue
FROM Customers AS C
JOIN Orders AS O
    ON c.customerid = o.customerid
JOIN Products AS P
    ON p.productid = o.productid
GROUP BY C.CustomerName
)
SELECT TOP 10
    CustomerName,
    TotalRevenue
FROM CustomerRevenue
WHERE TotalRevenue > 
( 
    SELECT 
        AVG(TotalRevenue)
    FROM CustomerRevenue
)
ORDER BY TotalRevenue DESC;