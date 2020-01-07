---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 03 - Joins
---------------------------------------------------------------------

--Question 1.1: Write a query that generates 5 copies out of each employee row

SELECT E.empid, E.firstname, E.lastname, N.n
FROM HR.Employees AS E
CROSS JOIN (SELECT TOP (5) * FROM dbo.Nums) AS N
ORDER BY N.n;

-- OR

SELECT E.empid, E.firstname, E.lastname, N.n
FROM HR.Employees AS E
CROSS JOIN dbo.Nums AS N
WHERE N.n <= 5
ORDER BY N.n;

--Question 1.2 (Advanced): Write a query that returns a row for each employee and day
--			   in the range June 12, 2016 - June 16 2016.

SELECT E.empid,
  DATEADD(day, N.n, CAST('20160611' AS DATE)) AS dt
FROM HR.Employees AS E
  CROSS JOIN Nums AS N
WHERE N.n <= DATEDIFF(day, '20160612', '20160616') + 1
ORDER BY empid, dt;

--Question 2: Explain what's wrong in the following query and provide a correct alternative

SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON Customers.custid = Orders.custid;

/* The reason the query fails is because in the FROM clause, the Sales.Customers and Sales.Orders 
   are given aliases C and O respectively. Because the tables are given an alias name, the SQL Server 
   could no longer find columns using the tables original name. An easy fix is to simply use the Alias 
   name to refer to specific table column as follows */

-- Correct Query

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
	INNER JOIN Sales.Orders AS O
		ON C.custid = O.custid;

--Question 3: Return US customers, and for each customer the total number of orders and quantities

SELECT C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(D.qty) AS totalqty
FROM Sales.Customers AS C
	INNER JOIN Sales.Orders AS O
		ON C.custid = O.custid
	INNER JOIN Sales.OrderDetails AS D
		ON D.orderid = O.orderid
WHERE C.country = N'USA'
GROUP BY C.custid;

--Question 4: Return customers and their orders including customers who placed no orders

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT JOIN Sales.Orders AS O
	ON C.custid = O.custid;

--Question 5: Return customers who placed no orders

SELECT C.custid, C.companyname
FROM Sales.Customers AS C
LEFT JOIN Sales.Orders AS O
	ON C.custid = O.custid
WHERE O.orderid IS NULL;

--Question 6: Return customers with orders placed on Feb 12, 2016 along with their orders

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212';

--Question 7 (Advanced): Write a query that returns all customers in the output, but 
--			 matches them with their respective orders only if they were placed
--			 on February 12, 2016

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT JOIN (SELECT custid, orderid, orderdate
		FROM Sales.Orders
		WHERE orderdate = '20160212') AS O
	ON C.custid = O.custid;

-- OR 

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
    AND O.orderdate = '20160212';

--Question 8 (Advanced): Explain why the following query isn't a correct solution
--			 for exercise 7

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;

/* The LEFT JOIN will create NULL values for the Sales.Orders table that are not matched by O.custid.
   However, the WHERE clause for O.orderdate = '20160212' will filter out all results that are not true.
   Since comparing NULL value with any value results in UNKNOWN, they will all be filtered out along with
   results that are false. */

--Question 9 (Advanced): Return all customers, and for each return a Yes/No value depending
--			 on whether the customer placed an order on Feb 12, 2016

SELECT DISTINCT C.custid, C.companyname,
	CASE
	     WHEN O.orderdate = '20160212' THEN 'Yes'
	     ELSE 'No'
	     END AS OrderedOn20160212
FROM Sales.Customers AS C
	LEFT JOIN Sales.Orders AS O
	ON O.custid = C.custid
	AND O.orderdate = '20160212';
