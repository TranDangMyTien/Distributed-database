--BTH4

--Câu 1 
create database Northwind1
go


--Câu 2 
--KH1--
CREATE TABLE KH1(
[CustomerID] [nchar](5) NOT NULL,
[CompanyName] [nvarchar](40) NOT NULL,
[ContactName] [nvarchar](30) NULL,
[ContactTitle] [nvarchar](30) NULL,
[Address] [nvarchar](60) NULL,
[City] [nvarchar](15) NULL,
[Region] [nvarchar](15) NULL,
[PostalCode] [nvarchar](10) NULL,
[Country] [nvarchar](15) NULL,
[Phone] [nvarchar](24) NULL,
[Fax] [nvarchar](24) NULL)
go
--KH2--
CREATE TABLE KH2(
[CustomerID] [nchar](5) NOT NULL,
[CompanyName] [nvarchar](40) NOT NULL,
[ContactName] [nvarchar](30) NULL,
[ContactTitle] [nvarchar](30) NULL,
[Address] [nvarchar](60) NULL,
[City] [nvarchar](15) NULL,
[Region] [nvarchar](15) NULL,
[PostalCode] [nvarchar](10) NULL,
[Country] [nvarchar](15) NULL,
[Phone] [nvarchar](24) NULL,
[Fax] [nvarchar](24) NULL)
go

-- lấy data cho 2 phân mảnh KH1 và KH2
INSERT INTO Northwind1.dbo.KH1
SELECT *
FROM   Northwind.dbo.Customers KH
WHERE (KH.Country = N'USA') OR(KH.Country =N'UK')
GO

INSERT INTO Northwind1.dbo.KH2
SELECT *
FROM   Northwind.dbo.Customers KH
WHERE (KH.Country <> N'USA') AND (KH.Country <> N'UK') -- <> là khác với
GO

-- Câu 3 : Xem dữ liệu từ phân mảnh KH1 ( khách hàng Anh, Mỹ)
SELECT * FROM   Northwind1.dbo.KH1
ORDER BY Country
go

-- Câu 4: Xem dữ liệu từ phân mảnh KH2 (khách hàng các nước còn lại)
SELECT * FROM   Northwind1.dbo.KH2
ORDER BY Country
go

-- Câu 5: Lấy danh sách tất cả khách hàng: Truy vấn trong suốt mức 1 
--(hay mức toàn cục, mức Global, mức không thấy các phân mảnh, hay mức trong suốt phân mảnh, fragmentation transparency)

use Northwind
go
create proc dsallKHMUC1
as
select * from Northwind.dbo.Customers
go
exec dsallKHMUC1
go

drop proc dsallKHMUC1
go

-- Câu 6: Lấy danh sách tất cả khách hàng: Truy vấn trong suốt mức 2
--Cách 1: không có ORDER BY Country
use Northwind1
go
create proc dsallKHMUC2
as
begin
  select * from Northwind1.dbo.KH1
  union
  select * from Northwind1.dbo.KH2
end
go

exec dsallKHMUC2
go

drop proc dsallKHMUC2
go

-- cách 2 dùng bảng tạm, có thể sắp xếp ORDER BY Country
create proc dsallKHMUC2C2
as
begin
     if exists ( -- nếu đã có bảng Northwind1.dbo.TAM thì xóa 
	    select *
		from sys.tables
		join sys.schemas
		on sys.tables.schema_id = sys.schemas.schema_id
		where sys.schemas.name = 'dbo' and sys.tables.name = 'TAM')

	drop table Northwind1.dbo.TAM

	-- Vừa tạo vừa lấy dữ liệu cho bảng Northwind1.dbo.TAM từ phân mảnh KH1
	select * into Northwind1.dbo.TAM from Northwind1.dbo.KH1
	-- lấy thêm data từ phân mảnh KH2
	insert into Northwind1.dbo.TAM select * from Northwind1.dbo.KH2
	-- XUẤT KQ từ bảng Northwind1.dbo.TAM dc sắp xếp tăng dần theo quốc gia
	select * from Northwind1.dbo.TAM order by Country
end
go

exec dsallKHMUC2C2
go

drop table Northwind1.dbo.Tam
GO
drop proc dsallKHMUC2C2
go

--Câu 7 DS Khách hàng biết tên quốc gia , mức 1
-- tạo proc 
-- chạy proc với quốc gia là Canada

--mức 1
use Northwind
go
create proc dsCusBietQGMuc1 ( @QG nvarchar(15)	)
as
begin
  select  * from Northwind.dbo.Customers where Country = @QG
end
go

exec dsCusBietQGMuc1 N'Canada'
go
exec dsCusBietQGMuc1 N'USA'
go

--mức 2
use Northwind1
go
create proc dsCusBietQGMuc2 ( @QG nvarchar(15)	)
as
begin 
	if(@QG = 'USA' or @QG ='UK')
    select  * from Northwind1.dbo.KH1 where Country = @QG
	else
	 select  * from Northwind1.dbo.KH2 where Country = @QG

end
go

exec Northwind1.dbo.dsCusBietQGMuc2 N'Canada'
go
exec Northwind1.dbo.dsCusBietQGMuc2 N'UK'
go
drop proc dbo.dsCusBietQGMuc2
go

--câu 9: Phân mảnh ngang dẫn xuất 
---Tạo phân mảnh DH1 (đơn hàng 1) chứa các đơn hàng do các KH Mỹ, và Anh mua
---Tạo phân mảnh DH2 (đơn hàng 2) chứa các đơn hàng do các KH còn lại
use Northwind1
go

-- tạo và lấy data cho PM DH1 ( đơn hàng 1)
select * into dbo.DH1
from Northwind.dbo.Orders DH
where DH.CustomerID in 
						(select CustomerID from Northwind.dbo.Customers 
						 where Country = N'USA' OR Country = N'UK')
						 go

-- tạo và lấy data cho PM DH2 ( đơn hàng 2)
select * into dbo.DH2
from Northwind.dbo.Orders DH
where DH.CustomerID in 
						(select CustomerID from Northwind.dbo.Customers 
						 where Country <> N'USA' OR Country <> N'UK')
						 go


-- câu 10 DS ALL ĐƠN HÀNG MỨC 1
SELECT * FROM Northwind.dbo.Orders
GO
-- CÂU 11 ds all đơn hàng mức 2

SELECT * FROM Northwind1.dbo.DH1
UNION
SELECT * FROM Northwind1.dbo.DH2
GO

-- câu 12 ds đơn hàng biết QG khách hàng mua, mức 1
use Northwind
go

CREATE PROC dbo.DSDHBietQGMUC1(@QG nvarchar(15)) AS
BEGIN
SELECT * FROM Northwind.dbo.Orders DH
WHEREDH.CustomerID IN
  (SELECT CustomerID FROM Northwind.dbo.Customers WHERE Country= @QG)
END
go
EXEC DSDHBietQGMUC1 N'Canada'
go
EXEC DSDHBietQGMUC1 N'USA'
go
DROP PROC DSDHBietQGMUC1
GO

-- câu 13 ds đơn hàng biết quốc gia khách hàng mua mức 2
use Northwind1
go
CREATE PROC dbo.DSDHBietQGMUC2(@QG nvarchar(15)) 
AS
BEGIN
	IF (@QG=N'USA' OR @QG=N'UK')
   		SELECT * FROM   Northwind1.dbo.DH1 TB1   
   		WHERE TB1.CustomerID IN
   		(SELECT TB2.CustomerID FROM Northwind1.dbo.KH1 TB2
			WHERE TB2.Country=@QG)
	ELSE
   		SELECT * FROM   Northwind1.dbo.DH2 TB1   
   		WHERE TB1.CustomerID IN
   		(SELECT TB2.CustomerID FROM Northwind1.dbo.KH2 TB2
			WHERE TB2.Country=@QG)    
END
GO
EXEC DSDHBietQGMUC2 N'Canada'
GO
EXEC DSDHBietQGMUC2 N'USA'
GO
DROP PROC DSDHBietQGMUC2
GO

-- câu 14
--Phân mảnh dọc trên bảng Employee
-- Phân mảnh NV1
--Phân mảnh NV2
USE Northwind1
GO      
--Tạo và lấy dữ liệu cho phân mảnh NV1(NHÂN VIÊN1)
SELECT [EmployeeID],[LastName],[FirstName],[TitleOfCourtesy] 
INTO dbo.NV1  
FROM   Northwind.dbo.Employees
GO
--Tạo và lấy phân mảnh NV2(NHÂN VIÊN2)
USE Northwind1
GO
SELECT [EmployeeID]
      ,[Title]       
	,[BirthDate]
	,[HireDate]
	,[Address]
	,[City]
	,[Region]
	,[PostalCode]
	,[Country]
	,[HomePhone]
	,[Extension]
	,[Photo]
	,[Notes]
	,[ReportsTo]
	,[PhotoPath]   
	INTO dbo.NV2   
	FROM   Northwind.dbo.Employees
GO

-- câu 15
--ds all NV mức 1
SELECT * FROM Northwind.dbo.Employees
GO

--ds all NV mức 2
SELECT TB1.[EmployeeID]
      ,[LastName]
,[FirstName]
,[Title]
,[TitleOfCourtesy]
,[BirthDate]
,[HireDate]
,[Address]
,[City]
,[Region]
,[PostalCode]
,[Country]
,[HomePhone]
,[Extension]
,[Photo]
,[Notes]
,[ReportsTo]
,[PhotoPath]
	FROM Northwind1.dbo.NV1 TB1,Northwind1.dbo.NV2 TB2   
	WHERE TB1.EmployeeID=TB2.EmployeeID
	GO


--BTH5 tiếp theo
--câu 2 Tạo View để thống kê số lượng khách hàng của từng quốc gia
-- ViewThongKeSLKHTheoQGMuc1 trên Northwind gồm cột quốc gia và số lượng khách hàng
-- ViewThongKeSLKHTheoQGMuc2 trên Northwind1

use Northwind
go

CREATE VIEW ViewThongKeSLKHTheoQGMuc1 AS
SELECT 
    c.Country,
    COUNT(DISTINCT c.CustomerID) AS NumberOfCustomers
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.Country;


select * from ViewThongKeSLKHTheoQGMuc1
go


--câu 3 Tạo View để thống kê số lượng đơn hàng của từng quốc gia
use Northwind
go
CREATE VIEW ViewThongKeSLDHTheoQGMuc1 AS
SELECT c.Country, COUNT(o.OrderID) AS N'Số Lượng Đơn Hàng'
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Country;

select * from ViewThongKeSLDHTheoQGMuc1


-- câu 4 Tạo Procedure để in danh sách khách hàng chưa mua đơn hàng nào
--Procedure này không có tham số, đặt tên Proc này ở 2 mức là
-- ProcKHChuaMuaHangMuc1 trên trên Northwind
--ProcKHChuaMuaHangMuc2 trên trên Northwind1 => so sánh 2 proc
use Northwind
go
create proc ProcKHChuaMuaHangMuc1 
as
begin
	SELECT c.CustomerID, c.CompanyName, c.ContactName, c.Country
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    WHERE o.CustomerID IS NULL;
end;

exec ProcKHChuaMuaHangMuc1
go

use Northwind1
go
create proc ProcKHChuaMuaHangMuc2
as
begin
    SELECT c.CustomerID, c.CompanyName, c.ContactName, c.Country
    FROM KH1 c left join DH1 o ON c.CustomerID = o.CustomerID
	where o.CustomerID is null
	union
	SELECT c.CustomerID, c.CompanyName, c.ContactName, c.Country
    FROM KH2 c left join DH2 o ON c.CustomerID = o.CustomerID
	where o.CustomerID is null
end
go

exec ProcKHChuaMuaHangMuc2
go
