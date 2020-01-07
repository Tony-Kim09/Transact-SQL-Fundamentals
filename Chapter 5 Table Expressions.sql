---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 05 - Table Expressions
---------------------------------------------------------------------

--Question 1: The following query attempts to filter orders placed on the last day of the year
USE TSQLV4;
GO

SELECT orderid, orderdate, custid, empid, 
	DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> endofyear;

-- When you try to run this query you get the following error.
/*
Msg 207, Level 16, State 1, Line 233
Invalid column name 'endofyear'.
*/
-- Explain what the problem is and suggest a valid solution.

/* Answer: SQL Server processes a query in this order: FROM, WHERE, GROUP BY, HAVING, SELECT, and ORDER BY.
   Since WHERE clause is processed before the SELECT clause, SQL Server will not know any aliases 
   created in the SELECT clause. Therefore if we reference a column based on the alias, SQL Server
   will not know what it is referring to. */

WITH CTE AS
(
  SELECT orderid, orderdate, custid, empid, 
    DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
  FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid, endofyear
FROM CTE
WHERE orderdate <> endofyear;

-- Question 2.1: Write a query that returns the maximum order date for each employee

SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid;

--Question 2.2: Encapsulate the query from exercise 2.1 in a derived table
--		Write a join query between the derived table and the Sales.Orders
--		table to return the Sales.Orders with the maximum order date for each employee

SELECT T.empid, T.maxorderdate, O.orderid, O.custid
FROM Sales.Orders AS O
INNER JOIN 
	(SELECT empid, MAX(orderdate) AS maxorderdate
	 FROM Sales.Orders
	 GROUP BY empid) AS T
		ON O.empid = T.empid
		AND O.orderdate = T.maxorderdate;

--Question 3.1: Write a query that calculates a row number for each order
--		based on orderdate, orderid ordering

SELECT orderid, orderdate, custid, empid,
		ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders;

--Question 3.2: Write a query that returns rows with row numbers 11 through 20
--		based on the row number definition in exercise 3.1
--		Use a CTE to encapsulate the code from exercise 3.1

WITH CTE AS 
	(SELECT orderid, orderdate, custid, empid,
		ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
	 FROM Sales.Orders)

SELECT orderid, orderdate, custid, empid, rownum
FROM CTE
WHERE rownum BETWEEN 11 and 20;

--Question 4: Write a solution using a recursive CTE that returns the management
--	      chain leading to Patricia Doyle (employee ID 9)

WITH mghier AS
	(SELECT empid, mgrid, firstname, lastname
	 FROM HR.Employees
	 WHERE empid = 9
  
	 UNION ALL
  
	 SELECT D.empid, D.mgrid, D.firstname, D.lastname
	 FROM mghier AS H
	 INNER JOIN HR.Employees AS D
		 ON H.mgrid = D.empid
)
SELECT empid, mgrid, firstname, lastname
FROM mghier;

--Question 5.1: Create a view that returns the total qty for each employee and year

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW vEmpOrd AS
	SELECT O.empid, YEAR(O.orderdate) AS orderyear, SUM(OD.qty) AS ttlQty
	FROM Sales.Orders AS O
	INNER JOIN Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid
	GROUP BY empid, YEAR(orderdate);
GO

--Question 5.2 (Advanced): Write a query against Sales.vEmpOrders that returns
--			   the running qty for each employee and year

SELECT v.empid, v.orderyear, v.ttlqty, 
				(SELECT SUM(ttlqty)
				 FROM Sales.vEmpOrd AS v2
				 WHERE v.empid = v2.empid
				 AND v.orderyear >= v2.orderyear) AS runqty
FROM Sales.vEmpOrd AS v
ORDER BY v.empid, v.orderyear;

--Question 6.1: Create an inline function that accepts as inputs a supplier id
--		(@supid AS INT), and a requested number of products (@n AS INT)
--		The function should return @n products with the highest unit prices
--		that are supplied by the given supplier id

DROP FUNCTION IF EXISTS Production.TopProducts;
GO

CREATE FUNCTION Production.TopProducts
	(@supid AS INT, @n AS INT)
	RETURNS TABLE
AS
RETURN
	SELECT TOP (@n) productid, productname, unitprice
	FROM Production.Products
	WHERE supplierid = @supid
	ORDER BY unitprice DESC;
GO
--Question 6.2: Using the CROSS APPLY operator and the function you created
--		in exercise 6.1, return, for each supplier, the two most
--		expensive products

SELECT S.supplierid, S.companyname, T.productid, T.productname, T.unitprice
FROM Production.Suppliers AS S
  CROSS APPLY Production.TopProducts(S.supplierid, 2) AS T;
