/* ============================================================================
   DATA ANALYST INTERNSHIP - TASK 3
   SQL ANALYSIS: Chinook Database (SQLite)
   Author: Intern
   ----------------------------------------------------------------------------
   Notes on schema used:
     Invoice(InvoiceId, CustomerId, InvoiceDate, BillingCountry, Total, ...)
     InvoiceLine(InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity)
     Track(TrackId, Name, AlbumId, GenreId, UnitPrice, ...)
     Album(AlbumId, Title, ArtistId)
     Artist(ArtistId, Name)
     Genre(GenreId, Name)
     Customer(CustomerId, FirstName, LastName, Country, ...)

   "Revenue" is taken from Invoice.Total (order-level) unless a query needs to
   be broken down by Track/Genre/Artist, in which case it is computed from
   InvoiceLine.UnitPrice * InvoiceLine.Quantity (line-level), which reconciles
   to the same total.
   ============================================================================ */


/* ---------------------------------------------------------------------------
   1. TOTAL REVENUE
   --------------------------------------------------------------------------- */
SELECT ROUND(SUM(Total), 2) AS TotalRevenue
FROM Invoice;


/* ---------------------------------------------------------------------------
   2. TOTAL CUSTOMERS
   --------------------------------------------------------------------------- */
SELECT COUNT(*) AS TotalCustomers
FROM Customer;


/* ---------------------------------------------------------------------------
   3. TOTAL ORDERS
   --------------------------------------------------------------------------- */
SELECT COUNT(*) AS TotalOrders
FROM Invoice;


/* ---------------------------------------------------------------------------
   4. AVERAGE ORDER VALUE
   --------------------------------------------------------------------------- */
SELECT ROUND(AVG(Total), 2) AS AverageOrderValue
FROM Invoice;


/* ---------------------------------------------------------------------------
   5. AVERAGE SPENDING PER CUSTOMER
   --------------------------------------------------------------------------- */
SELECT ROUND(SUM(Total) * 1.0 / COUNT(DISTINCT CustomerId), 2) AS AvgSpendPerCustomer
FROM Invoice;


/* ---------------------------------------------------------------------------
   6. TOP 10 CUSTOMERS BY SPENDING
   --------------------------------------------------------------------------- */
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    c.Country,
    ROUND(SUM(i.Total), 2) AS TotalSpent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, CustomerName, c.Country
ORDER BY TotalSpent DESC
LIMIT 10;


/* ---------------------------------------------------------------------------
   7. REVENUE BY COUNTRY
   --------------------------------------------------------------------------- */
SELECT
    BillingCountry AS Country,
    ROUND(SUM(Total), 2) AS Revenue,
    COUNT(*) AS Orders
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC;


/* ---------------------------------------------------------------------------
   8. CUSTOMER COUNT BY COUNTRY
   --------------------------------------------------------------------------- */
SELECT
    Country,
    COUNT(*) AS CustomerCount
FROM Customer
GROUP BY Country
ORDER BY CustomerCount DESC;


/* ---------------------------------------------------------------------------
   9. TOP-SELLING GENRES (by revenue)
   --------------------------------------------------------------------------- */
SELECT
    g.Name AS Genre,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue,
    SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON t.TrackId = il.TrackId
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.Name
ORDER BY Revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------------
   10. TOP-SELLING ARTISTS (by revenue)
   --------------------------------------------------------------------------- */
SELECT
    ar.Name AS Artist,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue,
    SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t   ON t.TrackId = il.TrackId
JOIN Album al  ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.Name
ORDER BY Revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------------
   11. TOP-SELLING TRACKS (by revenue)
   --------------------------------------------------------------------------- */
SELECT
    t.Name AS Track,
    ar.Name AS Artist,
    SUM(il.Quantity) AS UnitsSold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t   ON t.TrackId = il.TrackId
JOIN Album al  ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY t.TrackId, t.Name, ar.Name
ORDER BY Revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------------
   12. REVENUE BY YEAR
   --------------------------------------------------------------------------- */
SELECT
    STRFTIME('%Y', InvoiceDate) AS Year,
    ROUND(SUM(Total), 2) AS Revenue,
    COUNT(*) AS Orders
FROM Invoice
GROUP BY Year
ORDER BY Year;


/* ---------------------------------------------------------------------------
   13. REVENUE BY MONTH (year-month series)
   --------------------------------------------------------------------------- */
SELECT
    STRFTIME('%Y-%m', InvoiceDate) AS YearMonth,
    ROUND(SUM(Total), 2) AS Revenue,
    COUNT(*) AS Orders
FROM Invoice
GROUP BY YearMonth
ORDER BY YearMonth;


/* ---------------------------------------------------------------------------
   14. MONTHLY / YEARLY SALES GROWTH (% change vs prior period)
       Uses a CTE + window function (LAG) to compute period-over-period growth.
   --------------------------------------------------------------------------- */
-- Yearly growth
WITH yearly AS (
    SELECT
        STRFTIME('%Y', InvoiceDate) AS Year,
        SUM(Total) AS Revenue
    FROM Invoice
    GROUP BY Year
)
SELECT
    Year,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(Revenue - LAG(Revenue) OVER (ORDER BY Year), 2) AS AbsoluteChange,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year)) * 100.0
        / LAG(Revenue) OVER (ORDER BY Year), 2
    ) AS GrowthPct
FROM yearly
ORDER BY Year;

-- Monthly growth
WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', InvoiceDate) AS YearMonth,
        SUM(Total) AS Revenue
    FROM Invoice
    GROUP BY YearMonth
)
SELECT
    YearMonth,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY YearMonth)) * 100.0
        / LAG(Revenue) OVER (ORDER BY YearMonth), 2
    ) AS GrowthPct
FROM monthly
ORDER BY YearMonth;


/* ---------------------------------------------------------------------------
   15. HIGHEST-PERFORMING COUNTRY (single best answer)
   --------------------------------------------------------------------------- */
SELECT
    BillingCountry AS Country,
    ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC
LIMIT 1;


/* ---------------------------------------------------------------------------
   16. HIGHEST-PERFORMING MONTH (calendar month, aggregated across all years)
   --------------------------------------------------------------------------- */
SELECT
    STRFTIME('%m', InvoiceDate) AS MonthNum,
    CASE STRFTIME('%m', InvoiceDate)
        WHEN '01' THEN 'January'  WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'    WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'      WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'     WHEN '08' THEN 'August'
        WHEN '09' THEN 'September' WHEN '10' THEN 'October'
        WHEN '11' THEN 'November' WHEN '12' THEN 'December'
    END AS MonthName,
    ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY MonthNum
ORDER BY Revenue DESC
LIMIT 1;


/* ---------------------------------------------------------------------------
   17. HIGHEST-PERFORMING ARTIST
   --------------------------------------------------------------------------- */
SELECT
    ar.Name AS Artist,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t   ON t.TrackId = il.TrackId
JOIN Album al  ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.Name
ORDER BY Revenue DESC
LIMIT 1;


/* ---------------------------------------------------------------------------
   18. CUSTOMERS WITH HIGHEST PURCHASE FREQUENCY (order count)
   --------------------------------------------------------------------------- */
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    COUNT(i.InvoiceId) AS OrderCount,
    ROUND(SUM(i.Total), 2) AS TotalSpent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, CustomerName
HAVING COUNT(i.InvoiceId) >= 7   -- customers with 7+ orders (frequent buyers)
ORDER BY OrderCount DESC, TotalSpent DESC;


/* ---------------------------------------------------------------------------
   19. REVENUE CONTRIBUTION OF TOP CUSTOMERS (Top 10 vs rest, % of total)
       Uses a CTE + subquery for the grand-total denominator.
   --------------------------------------------------------------------------- */
WITH customer_spend AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS CustomerName,
        SUM(i.Total) AS TotalSpent
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, CustomerName
),
ranked AS (
    SELECT
        CustomerName,
        TotalSpent,
        RANK() OVER (ORDER BY TotalSpent DESC) AS SpendRank
    FROM customer_spend
)
SELECT
    CustomerName,
    ROUND(TotalSpent, 2) AS TotalSpent,
    ROUND(
        TotalSpent * 100.0 / (SELECT SUM(Total) FROM Invoice), 2
    ) AS PctOfTotalRevenue
FROM ranked
WHERE SpendRank <= 10
ORDER BY TotalSpent DESC;


/* ---------------------------------------------------------------------------
   20. HIGH / MEDIUM / LOW-VALUE CUSTOMER SEGMENTS
       Chinook's per-customer spend range is narrow ($36.64-$49.62), so fixed
       dollar cut-offs would misclassify almost everyone into one bucket.
       Instead we rank customers into value terciles with NTILE(3), a
       data-driven percentile split, then label the tiers with CASE.
   --------------------------------------------------------------------------- */
WITH customer_spend AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS CustomerName,
        c.Country,
        SUM(i.Total) AS TotalSpent
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, CustomerName, c.Country
),
tiered AS (
    SELECT
        *,
        NTILE(3) OVER (ORDER BY TotalSpent DESC) AS Tier
    FROM customer_spend
)
SELECT
    CASE Tier
        WHEN 1 THEN 'High-Value'
        WHEN 2 THEN 'Medium-Value'
        ELSE 'Low-Value'
    END AS CustomerSegment,
    COUNT(*) AS NumCustomers,
    ROUND(SUM(TotalSpent), 2) AS SegmentRevenue,
    ROUND(AVG(TotalSpent), 2) AS AvgSpendInSegment
FROM tiered
GROUP BY Tier
ORDER BY Tier;


/* ---------------------------------------------------------------------------
   BONUS: Per-customer segment detail (used to feed Power BI / Python)
   --------------------------------------------------------------------------- */
WITH customer_spend AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS CustomerName,
        c.Country,
        SUM(i.Total) AS TotalSpent
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, CustomerName, c.Country
),
tiered AS (
    SELECT
        *,
        NTILE(3) OVER (ORDER BY TotalSpent DESC) AS Tier
    FROM customer_spend
)
SELECT
    CustomerId,
    CustomerName,
    Country,
    ROUND(TotalSpent, 2) AS TotalSpent,
    CASE Tier
        WHEN 1 THEN 'High-Value'
        WHEN 2 THEN 'Medium-Value'
        ELSE 'Low-Value'
    END AS CustomerSegment
FROM tiered
ORDER BY TotalSpent DESC;
