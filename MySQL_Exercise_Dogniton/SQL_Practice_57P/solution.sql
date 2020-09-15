-- 0
use Northwind_SPP

-- Introductory
--1 
SELECT * FROM Shippers

--2
SELECT CategoryName, Descriptipon FROM Categories

--3 
SELECT FirstName, LastName, HireDate
FROM Employees
WHERE Title = 'Sales representative'

--4
SELECT FirstName, LastName, HireDate
FROM Employees
WHERE Title = 'Sales representative'
AND Country = 'USA'

--5
SELECT ORDerID, OrderDate FROM dbo.Orders WHERE EmployeeID = 5

--6
SELECT SupplierID, ContactName, ContactTitle 
from dbo.Suppliers WHERE ContactTitle != 'Marketing Manager'

--7  
-- % - The percent sign represents zero, one, or multiple characters
-- _ - The underscore represents a single character
SELECT ProductName, ProductID from dbo.Products
WHERE ProductName like '%queso%'


--8 use OR
SELECT OrderID, CustomerID, ShipCountry from Orders 
WHERE ShipCountry = 'France' OR ShipCountry = 'Belgium'

--9 use multiple selection
SELECT OrderID, CustomerID, ShipCountry from Orders 
WHERE ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela')

--10
SELECT FirstName, LastName,Title, BirthDate FROM Employees
ORDER BY BirthDate 

--11 Convert()
SELECT FirstName, LastName,Title, CONVERT(date, BirthDate) FROM Employees
ORDER BY BirthDate 

--12 
SELECT FirstName, LastName, CONCAT(FirstName, ' ', LastName) as Fullname FROM Employees

--13
SELECT OrderID, ProductID, UnitPrice, Quantity, UnitPrice*Quantity AS TotalPrice 
FROM OrderDetails
ORDER BY OrderID, ProductID

--14
SELECT COUNT(CustomerID) 
FROM Customers 

--15
SELECT Min(OrderDate) FROM Orders
-- OR
SELECT TOP 1 OrderDate FROM Orders
ORDER BY OrderDate

--16
SELECT DISTINCT Country FROM Customers
-- OR
SELECT Country FROM Customers
GROUP BY Country

--17
SELECT ContactTitle, COUNT(ContactTitle) FROM Customers
GROUP BY ContactTitle

--18
SELECT ProductID, ProductName, CompanyName
FROM Products
LEFT JOIN Suppliers
ON Products.SupplierID = Suppliers.SupplierID
ORDER BY ProductID

--19
SELECT OrderID, OrderDate = CONVERT(date, OrderDate), Shippers.CompanyName AS Shipper
FROM Orders
LEFT JOIN Shippers
ON Orders.ShipVia = Shippers.ShipperID
WHERE OrderId < 10300
ORDER BY OrderID

-- Intermediate
--20
SELECT CategoryName, COUNT(ProductID) AS Count
FROM Products
LEFT JOIN Categories
ON Products.CategoryID = Categories.CategoryID
GROUP BY Categories.CategoryName
ORDER BY Count DESC

--21
SELECT Country, City, COUNT(CustomerID) AS TotalCustomer
FROM Customers
GROUP BY Country, City
ORDER BY TotalCustomer DESC

--22
SELECT ProductID, ProductName, UnitsInStock, ReorderLevel
FROM Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID

--23
SELECT ProductID, ProductName, UnitsInStock, ReorderLevel
FROM Products
WHERE UnitsInStock + UnitsOnOrder <= ReorderLevel AND Discontinued = 0
ORDER BY ProductID

--24
SELECT CustomerID, CompanyName, Region
FROM Customers
ORDER BY (CASE WHEN Region is null THEN 1 ELSE 0 END), Region, CustomerID
-- 使用 CASE 语句来生成临时列，根据临时列将Region中的Null放到后面去

--25
SELECT TOP 3 ShipCountry, AVG(Freight) AS AverageFreight
FROM Orders
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

--26
SELECT TOP 3 ShipCountry, AVG(Freight) AS AverageFreight
FROM Orders
WHERE YEAR(OrderDate) = 2015
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

--27
SELECT OrderDate
FROM Orders
WHERE OrderDate BETWEEN '1/1/2015' AND '1/1/2016'
ORDER BY OrderDate
--注意日期是选择到该日子的开头，而不是结束

--28
SELECT TOP 3 ShipCountry, AVG(Freight) AS AverageFreight
FROM Orders
WHERE DATEDIFF(month, OrderDate, 
	(SELECT Top 1 OrderDate
	FROM Orders
	ORDER BY OrderDate DESC)
	) <= 12
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

--29
SELECT Employees.EmployeeID, Employees.LastName, Orders.OrderID, Products.ProductName, OrderDetails.Quantity
FROM Orders
LEFT JOIN Employees
ON Orders.EmployeeID = Employees.EmployeeID
LEFT JOIN OrderDetails
ON Orders.OrderID = OrderDetails.OrderID
LEFT JOIN Products
ON Products.ProductID = OrderDetails.ProductID
ORDER BY Orders.OrderID, Products.ProductID

--30
SELECT Customers.CustomerID, Orders.CustomerID
FROM Customers
LEFT JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.CustomerID is null

--31  需要检查
SELECT Customers.CustomerID
FROM Customers
LEFT JOIN
	(SELECT DISTINCT Customers.CustomerID
	FROM Customers
	LEFT JOIN Orders
	ON Customers.CustomerID = Orders.CustomerID
	WHERE Orders.EmployeeID =4) AS Temp
ON Customers.CustomerID = Temp.CustomerID
WHERE Temp.CustomerID is Null

--advanced

--32 注意复杂语句的缩进
SELECT 
	Customers.CustomerID, 
	Customers.CompanyName, Orders.OrderID, 
	TotalOrderAmount = SUM(OrderDetails.Quantity * OrderDetails.UnitPrice)
FROM OrderDetails
	LEFT JOIN Orders
		ON OrderDetails.OrderID = Orders.OrderID
	LEFT JOIN Customers
		ON Orders.CustomerID = Customers.CustomerID
WHERE YEAR(Orders.OrderDate) = 2016 
GROUP BY --先用Group by，后用Having
	Customers.CustomerID,
	Customers.CompanyName,
	Orders.OrderID
HAVING SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) >= 10000
ORDER BY TotalOrderAmount DESC

--33
