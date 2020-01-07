---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operators
---------------------------------------------------------------------

--Question 1: Explain the difference between the UNION ALL and UNION operators.

--Answer
/* The biggest difference between UNION and UNION ALL is that, UNION removed duplicates while
   UNION ALL keeps them. */

--Question 2: Write a query that generates a virtual auxiliary table of 10 numbers
--			  in the range 1 through 10

SELECT n
FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Num(n);

--Question 3: Write a query that returns customer and employee pairs
--			  that had order activity in January 2016 but not in February 2016

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160101' AND orderdate <'20160201'

EXCEPT 

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160201' AND orderdate < '20160301';

--Question 4: Write a query that returns customer and employee pairs
--			  that had order activity in both January 2016 and February 2016

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160101' AND orderdate <'20160201'

INTERSECT 

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160201' AND orderdate < '20160301';

--Question 5: Write a query that returns customer and employee pairs
--			  that had order activity in both January 2016 and February 2016
--			  but not in 2015

(SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160101' AND orderdate <'20160201'

INTERSECT 

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20160201' AND orderdate < '20160301')

EXCEPT 

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101';

--Question 6(Advanced): 
--You are given the following query:
SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Production.Suppliers;

-- You are asked to add logic to the query 
-- such that it would guarantee that the rows from Employees
-- would be returned in the output before the rows from Suppliers,
-- and within each segment, the rows should be sorted
-- by country, region, city

SELECT country, region, city
FROM (SELECT 1 AS sorted, country, region, city
		FROM HR.Employees

		UNION ALL
	
	  SELECT 2, country, region, city
	    FROM Production.Suppliers) AS sortedNew
ORDER BY sorted, country, region, city;