---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 08 - Data Modification
---------------------------------------------------------------------

--Question 1.1: Insert into the dbo.Customers table a row with:
--	custid: 100
--	companyname: Coho Winery
--	country: USA
--	region: WA
--	city: Redmond

INSERT INTO dbo.Customers VALUES(100, N'Coho Winery', N'USA', N'WA', N'Redmond');

--Question 1.2: Insert into the dbo.Customers table all customers 
--				from Sales.Customers who placed orders

INSERT INTO dbo.Customers(custid, companyname, country, region, city)
	SELECT C.custid, C.companyname, C.country, C.region, C.city 
		FROM Sales.Customers AS C
			WHERE EXISTS
				(SELECT 1 FROM Sales.Orders AS O
				 WHERE O.custid = C.custid);
--Question 1.3: Use a SELECT INTO statement to create and populate the dbo.Orders
--				table with orders from the Sales.Orders that were placed in 
--			    the years 2014 through 2016

SELECT * INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate >= '20140101'
	AND orderdate < '20170101';

--Question 2: Delete from the dbo.Orders table orders that were placed
--			  before August 2014. Use the OUTPUT clause to return the orderid
--			  and orderdate of the deleted orders

DELETE FROM dbo.Orders
	OUTPUT deleted.orderid, deleted.orderdate
WHERE orderdate < '20140801';

--Question 3: Delete from the dbo.Orders table orders placed by customers from Brazil

DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE country = N'Brazil';

--OR

MERGE INTO dbo.Orders AS O
USING (SELECT * FROM dbo.Customers WHERE country = N'Brazil') AS C
  ON O.custid = C.custid
WHEN MATCHED THEN DELETE;

--Question4: Run the following query against dbo.Customers,
--			 and notice that some rows have a NULL in the region column

SELECT * FROM dbo.Customers;

-- Output:
custid      companyname    country         region     city
----------- -------------- --------------- ---------- --------------- 
1           Customer NRZBB Germany         NULL       Berlin
2           Customer MLTDN Mexico          NULL       México D.F.
3           Customer KBUDE Mexico          NULL       México D.F.
4           Customer HFBZG UK              NULL       London
5           Customer HGVLZ Sweden          NULL       Luleå
6           Customer XHXJV Germany         NULL       Mannheim
7           Customer QXVLA France          NULL       Strasbourg
8           Customer QUHWH Spain           NULL       Madrid
9           Customer RTXGC France          NULL       Marseille
10          Customer EEALV Canada          BC         Tsawassen

-- Update the dbo.Customers table and change all NULL region values to '<None>'
-- Use the OUTPUT clause to show the custid, old region and new region

UPDATE dbo.Customers
SET region = '<None>'
OUTPUT deleted.custid,
		deleted.region AS oldregion,
		inserted.region AS newregion
WHERE region IS NULL;

--Question 5: Update in the dbo.Orders table all orders placed by UK customers
--			  and set their shipcountry, shipregion, shipcity values
--			  to the country, region, city values of the corresponding customers
--			  from dbo.Customers

MERGE INTO dbo.Orders AS O
USING (SELECT * FROM dbo.Customers WHERE country = N'UK') AS C
		ON O.custid = C.custid
WHEN MATCHED THEN
	UPDATE SET
		O.shipcountry = C.country,
		O.shipregion = C.region,
		O.shipcity = C.city;

--Question 6: Run the following code to create the tables Orders and OrderDetails and populate them with data

USE TSQLV4;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- Write and test the T-SQL code that is required to truncate both tables,
-- and make sure that your code runs successfully

--Answer 
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders;

TRUNCATE TABLE dbo.OrderDetails;
TRUNCATE TABLE dbo.Orders;

ALTER TABLE dbo.OrderDetails ADD CONSTRAINT FK_OrderDetails_Orders
	FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid);