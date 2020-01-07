---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 02 - Single-Table Queries
-- Exercises
---------------------------------------------------------------------

--Question 1: Return orders placed in June 2015

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20150601'
	AND orderdate < '20150701';

/* The reason this method is preferred over using YEAR(orderdate) and MONTH(orderdate)
   is because filtered columns are not sargable (search argument). 
   Hence, this solution is more efficient. */

--Question 2: Return orders placed on the last day of the month

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

--Question 3: Return employees with last name containing the letter 'e' twice or more

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%'
	OR lastname LIKE '%ee%';

--Question 4: Return orders with total value(qty*unitprice) greater than 10000
--			  sorted by total value. 

SELECT orderid, SUM(qty*unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000
ORDER BY totalvalue DESC;

--Question 5: Write a query against the HR.Employeestable that returns employees
--			  with a last name that starts with a lower case letter. Remember that
--			  the collation of the sample database is case insensitive
--			  (Latin1_General_CI_AS). 

SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

--Question 6: Explain the difference between the following two queries

-- Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

-- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

/* The fundamental difference between the WHERE clause and the HAVING clause 
is that WHERE is a row filter and HAVING is a group filter. Therefore the first 
query finds the total number of orders per employee before the date 2016 05 01. 
Whereas, the second query shows who ever did not send any orders past the date 2016 05 01. */

--Question 7: Return the three ship countries with the highest average freight for orders placed in 2015

SELECT TOP (3) shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' 
	AND orderdate < '20160101'
GROUP BY shipcountry
ORDER BY avgfreight DESC;

--Question 8: Calculate row numbers for orders based on orderdate ordering 
--			 (using orderid as tiebreaker) for each customer separately

SELECT custid, orderdate, orderid,
  ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS rownumber
FROM Sales.Orders
ORDER BY custid, rownumber;

--Question 9: Figure out and return for each employee the gender based on the title of courtesy
--			  Ms., Mrs. - Female, Mr. -Male, Dr. -Unknown

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
    WHEN 'Mr.'  THEN 'Male'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Ms.'  THEN 'Female'
    ELSE 'Unknown'
  END AS gender
FROM HR.Employees;

--Question 10: Return for each customer the customer ID and region, sort the rows in the
--			   output by region having NULLs sort last (after non-NULL values). 

SELECT custid, region
FROM Sales.Customers
ORDER BY
	CASE
		WHEN region IS NULL THEN 1
		ELSE 0 END, region;

/* The case in this query gives all rows where region is NULL a value of 1 and all other rows
   a value of 0 and orders the result based on those values. Meaning all the rows with 0 will be placed
   before the NULL rows with a value of 1. Then SQL Server orders region in ASC order. */