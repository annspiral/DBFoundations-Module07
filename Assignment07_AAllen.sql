--*************************************************************************--
-- Title: Assignment07
-- Author: AAllen
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-11-28,AAllen,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AAllen')
	 Begin 
	  Alter Database [Assignment07DB_AAllen] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AAllen;
	 End
	Create Database Assignment07DB_AAllen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AAllen;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

/*
-- Show a list of Product Names and Unit Price

go
Select
	p.ProductName 
	, p.UnitPrice
From dbo.vProducts As p

-- Format the Price
go
Select
	p.ProductName 
	, Format(p.UnitPrice, 'C', 'en-US')
From dbo.vProducts As p

*/
-- Order results
go
Select
	p.ProductName 
	, Format(p.UnitPrice, 'C', 'en-US') As UnitPrice
From dbo.vProducts As p
Order by ProductName

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- Start with Select statement from Assignment 05, Question #1, format price

Select 
	c.CategoryName
	, p.ProductName 
	, Format(p.UnitPrice, 'C', 'en-US') As UnitPrice
From vCategories as c
	Full Join vProducts As p
		On c.CategoryID= p.CategoryID
Order By CategoryName, ProductName

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Start with the Select Statement from Assignment 5, Question 2, 
/*
go
Select 
	p.ProductName 
	, i.InventoryDate
	, SUM([Count]) As [Count]
From dbo.vProducts as p
	Left Join dbo.vInventories as i 
		On p.ProductID=i.ProductID
Group By ProductName, InventoryDate
Order By ProductName, InventoryDate, [Count]

*/
-- Format Date, Update Count Column name

Select 
	p.ProductName 
	, [InventoryDate] = DateName(mm,i.InventoryDate) + ', ' + DateName(yy, i.InventoryDate)
	, SUM([Count]) As [InventoryCount]
From dbo.vProducts as p
	Left Join dbo.vInventories as i 
		On p.ProductID=i.ProductID
Group By ProductName, InventoryDate
Order By ProductName, i.InventoryDate, InventoryCount
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Start with result from #3 and add to view - must use TOP with Group By
-- Updated InventoryDate formatting using new Format type

go
Create --Drop
View vProductInventories
As
	Select TOP 1000000 
				p.ProductName 
				, [InventoryDate] = Format(i.InventoryDate,'MMMM, yyyy')
				, SUM([Count]) As [InventoryCount]
			From dbo.vProducts as p
				Left Join dbo.vInventories as i 
					On p.ProductID=i.ProductID
			Group By ProductName, InventoryDate
			Order By ProductName, i.InventoryDate, InventoryCount


-- Check that it works: Select * From vProductInventories;
go
Select * From vProductInventories

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Start with view from Assignment 6, Remove Product Names
/*
go
Create -- Drop
View vCategoryInventories
As
	Select TOP 100000000
		c.CategoryName 
		, i.InventoryDate 
		, i.Count
	From dbo.vProducts As p
		Left Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Left Join dbo.vInventories as i
			On i.ProductID = p.ProductID
	Order By CategoryName, ProductName, InventoryDate, Count
go
-- Rename Count column, Remove ProductName from Order by

Create -- Drop
View vCategoryInventories
As
	Select TOP 10000000000
		c.CategoryName 
		, i.InventoryDate 
		, i.Count as InventoryCountByCategory
	From dbo.vProducts As p
		Left Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Left Join dbo.vInventories as i
			On i.ProductID = p.ProductID
	Order By CategoryName, InventoryDate, Count

-- Check that it works: Select * From vCategoryInventories;
go
Select * From vCategoryInventories

-- Aggregate Count and Group by Category

Create -- Drop
View vCategoryInventories
As
	Select TOP 10000000000
		c.CategoryName 
		, i.InventoryDate 
		, [InventoryCountByCategory] = SUM(i.Count)
	From dbo.vProducts As p
		Left Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Left Join dbo.vInventories as i
			On i.ProductID = p.ProductID
	Group by CategoryName, InventoryDate
	Order By CategoryName, InventoryDate, InventoryCountByCategory
*/
-- Format Date, update Order by to use underlying date
go

Create -- Drop
View vCategoryInventories
As
	Select TOP 10000000000
		c.CategoryName 
		, [InventoryDate] = Format(i.InventoryDate,'MMMM, yyyy')
		, [InventoryCountByCategory] = SUM(i.Count)
	From dbo.vProducts As p
		Left Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Left Join dbo.vInventories as i
			On i.ProductID = p.ProductID
	Group by CategoryName, InventoryDate
	Order By CategoryName, i.InventoryDate, InventoryCountByCategory

-- Check that it works: Select * From vCategoryInventories;
go
Select * From vCategoryInventories



-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- Create vProductInventoriesWithPreviousMonthCounts to show vProductInventories
/*
go
Create View vProductInventoriesWithPreviousMonthCounts
As
	Select * From vProductInventories

-- Add Previous Month Count
go
Create -- Drop
View vProductInventoriesWithPreviousMonthCounts
As
	Select TOP 100000
		vPI.ProductName
		, vPI.InventoryDate
		, vPI.InventoryCount
		, [PreviousMonthCount] = Lag(InventoryCount) Over(Partition By ProductName Order By Convert(date, InventoryDate))
	From vProductInventories As vPI

*/
-- Replace Null values, Add Order By
go
Create -- Drop
View vProductInventoriesWithPreviousMonthCounts
As
	Select TOP 100000
		vPI.ProductName
		, vPI.InventoryDate
		, vPI.InventoryCount
		, [PreviousMonthCount] = Case
								When Left(InventoryDate, 3) =  'Jan' Then 0
								Else Lag(InventoryCount) Over(Partition By ProductName Order By Convert(date, InventoryDate))
								End
	From vProductInventories As vPI
	Order By ProductName, Cast(InventoryDate As date)
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCounts

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- Start with code from #6, Add KPI column
go
Create -- Drop
View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select TOP 100000
		vPI.ProductName
		, vPI.InventoryDate
		, vPI.InventoryCount
		, [PreviousMonthCount] = Case
								When Left(InventoryDate, 3) =  'Jan' Then 0
								Else Lag(InventoryCount) Over(Partition By ProductName Order By Convert(date, InventoryDate))
								End
		, [CountVsPreviousCountKPI] = Case
										When InventoryCount > PreviousMonthCount Then 1
										When InventoryCount < PreviousMonthCount Then -1
										When InventoryCount = PreviousMonthCount Then 0
										End
	From vProductInventoriesWithPreviousMonthCounts As vPI
	Order By ProductName, Cast(InventoryDate As date)


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- Start with basic function calling view from #7
/*
go
Create -- Drop
Function fProductInventoriesWithPreviousMonthCountsWithKPIs()
Returns Table
As
	Return
	Select * From vProductInventoriesWithPreviousMonthCounts

go
*/
-- Add function parameter and Where clause, Order by Product and Date
go
Create -- Drop
Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
As
	Return
	Select Top 1000000
		vPI.ProductName
		, vPI.InventoryDate
		, vPI.InventoryCount
		, vPI.PreviousMonthCount 
		, vPI.CountVsPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs As vPI
	Where CountVsPreviousCountKPI = @KPI
	Order By ProductName, Cast(InventoryDate As date)

go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
/***************************************************************************************/