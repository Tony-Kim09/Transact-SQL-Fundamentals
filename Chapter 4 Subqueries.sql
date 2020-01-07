---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries
---------------------------------------------------------------------

--Question 1: Write a query that returns all orders placed on the last
--	      day of activity that can be found in the Orders table

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = 
	(SELECT MAX(O.orderdate) FROM Sales.Orders AS O);

--Question 2(Advanced): Write a query that returns all orders placed by
--		        the customer(s) who placed the highest number of orders.
--			Note: There may be more than one customer with same highest

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
  (SELECT TOP (1) WITH TIES O.custid
   FROM Sales.Orders AS O
   GROUP BY O.custid
   ORDER BY COUNT(O.orderid) DESC);

--Question 3: Write a query that returns employees who did not
--	      place orders on or after May 1st, 2016

SELECT empid, FirstName, lastname
FROM HR.Employees
WHERE empid NOT IN (SELECT O.empid
		    FROM Sales.Orders AS O
		    WHERE O.orderdate >= '20160501');
--Question 4: Write a query that returns countries where there are customers but not employees

SELECT DISTINCT C.country
FROM Sales.Customers AS C
WHERE C.country NOT IN (SELECT E.country
			FROM HR.Employees AS E);

--Question 5: Write a query that returns for each customer all orders placed on
--	      the customer's last day of activity

SELECT O.custid, O.orderid, O.orderdate, O.empid
FROM Sales.Orders AS O
WHERE O.orderdate = (SELECT MAX(O2.orderdate)
			FROM Sales.Orders O2
			WHERE O2.custid = O.custid)
ORDER BY O.custid;

--Question 6: Write a query that returns customers who placed orders in 2015 but not 2016

SELECT C.custid, C.companyname
FROM Sales.Customers AS C
WHERE EXISTS (SELECT 1
		FROM Sales.Orders AS O
		WHERE O.custid = C.custid
		AND O.orderdate < '20160101'
		AND O.orderdate >= '20150101')
AND NOT EXISTS (SELECT 1
		FROM Sales.Orders AS O2
		WHERE O2.custid = C.custid
		AND O2.orderdate < '20170101'
		AND O2.orderdate >= '20160101');

--Question 7 (Advanced): Write a query that returns customers who ordered product 12

SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (SELECT O.custid
		 FROM Sales.Orders AS O
		 INNER JOIN Sales.OrderDetails AS OD
		 	ON O.orderid = OD.orderid
		 WHERE OD.productid = 12);

--Question 8 (Advanced): Write a query that calculates a running total qty
--			 for each customer and month using subqueries

SELECT C.custid, C.ordermonth, C.qty, (SELECT SUM(C2.qty)
					FROM Sales.CustOrders AS C2
					WHERE C2.custid = C.custid
					AND C2.ordermonth <= C.ordermonth) AS runQty
FROM Sales.CustOrders AS C
ORDER BY C.custid, C.ordermonth;

--Question 9: Explain the difference between IN and EXISTS

/* The biggest difference between IN and EXIST has to do with the way SQL Server 
   handles NULL variables. Since NULL is neither TRUE or FALSE as it is UNKNOWN, it 
   will never evaluate to either. IN always uses three-valued logic: TRUE, FALSE, UNKNOWN. 
   EXISTS uses two-valued logic: TRUE and FALSE. The biggest difference is when using
   NOT IN or NOT EXIST. When NULL values exist, NOT IN will always result in an empty set
   since any value compared with a NULL will always be UNKNOWN. NOT EXIST however, will
   result in FALSE even when comparing rows that contain NULL since it uses two-valued logic */
 
--Question 10 (Advanced): Write a query that returns for each order the number
--			  of days that past since the same customer's previous order.
--			  To determine recency among orders, use orderdate as the primary
--			  sort element and orderid as the tiebreaker

SELECT O.custid, O.orderdate, O.orderid,
	DATEDIFF(day,
		    (SELECT TOP (1) O2.orderdate
			FROM Sales.Orders AS O2
			WHERE O2.custid = O.custid
				AND (O2.orderdate = O.orderdate AND O2.orderid < O.orderid
				OR O2.orderdate < O.orderdate)
			ORDER BY O2.orderdate DESC, O2.orderid DESC),
		O.orderdate) AS diff
FROM Sales.Orders AS O
ORDER BY O.custid, O.orderdate, O.orderid;
