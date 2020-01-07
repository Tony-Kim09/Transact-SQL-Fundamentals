---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 07 - Beyond the Fundamentals of Querying
---------------------------------------------------------------------

--Question 1: Write a query against the dbo.Orders table that computes for 
--			  each customer order, both a rank and a dense rank, 
--			  partitioned by custid, ordered by qty

SELECT custid, orderid, qty, 
	RANK() OVER(PARTITION BY custid ORDER BY qty) AS Rnk,
	DENSE_RANK() OVER(PARTITION BY custid ORDER BY qty) AS denseRnk
FROM dbo.Orders;

--Question 2: The following query against the Sales.OrderValues view returns
--			  distinct values and their associated row numbers

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

--Question 3: Write a query against the dbo.Orders table that computes
--			  for each customer order:
--				* the difference between the current order quantity
--				  and the customer's previous order quantity
--				* the difference between the current order quantity
--				  and the customer's next order quantity.

SELECT custid, orderid, qty,
  qty - LAG(qty) OVER(PARTITION BY custid
                      ORDER BY orderdate, orderid) AS diffprv,
  qty - LEAD(qty) OVER(PARTITION BY custid
                       ORDER BY orderdate, orderid) AS diffnxt
FROM dbo.Orders;

--Question 4: Write a query against the dbo.Orders table that returns a row for each employee,
--			  a column for each order year, and the count of orders for each employee and
--			  order year

SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
FROM (SELECT empid, YEAR(orderdate) AS orderyear
      FROM dbo.Orders) AS O
  PIVOT(COUNT(orderyear)
        FOR orderyear IN([2014], [2015], [2016])) AS P;

--Question 5: Run the following code to create and populate the EmpYearOrders table:
USE TSQLV4;

DROP TABLE IF EXISTS dbo.EmpYearOrders;

CREATE TABLE dbo.EmpYearOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
  cnt2014 INT NULL,
  cnt2015 INT NULL,
  cnt2016 INT NULL
);

INSERT INTO dbo.EmpYearOrders(empid, cnt2014, cnt2015, cnt2016)
  SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
  FROM (SELECT empid, YEAR(orderdate) AS orderyear
        FROM dbo.Orders) AS D
    PIVOT(COUNT(orderyear)
          FOR orderyear IN([2014], [2015], [2016])) AS P;

SELECT * FROM dbo.EmpYearOrders;

-- Output:
empid       cnt2014     cnt2015     cnt2016
----------- ----------- ----------- -----------
1           1           1           1
2           1           2           1
3           2           0           2

-- Write a query against the EmpYearOrders table that unpivots
-- the data, returning a row for each employee and order year
-- with the number of orders
-- Exclude rows where the number of orders is 0
-- (in our example, employee 3 in year 2016)

SELECT empid, 
		CAST(RIGHT(orderyear, 4) AS INT) AS orderyear,
			numorders
FROM dbo.EmpYearOrders
  UNPIVOT(numorders FOR orderyear IN(cnt2014, cnt2015, cnt2016)) AS U
WHERE numorders <> 0;

--Question 6: Write a query against the dbo.Orders table that returns the 
--			  total quantities for each:
--			  employee, customer, and order year
--			  employee and order year
--			  customer and order year.
--				Include a result column in the output that uniquely identifies 
--				the grouping set with which the current row is associated
--				Tables involved: TSQLV4 database, dbo.Orders table

SELECT
  GROUPING_ID(empid, custid, YEAR(Orderdate)) AS groupingset,
  empid, custid, 
  YEAR(Orderdate) AS orderyear, 
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    (empid, custid, YEAR(orderdate)),
    (empid, YEAR(orderdate)),
    (custid, YEAR(orderdate))
  );