-- Câu 1: Phân mảnh ngang chính và dẫn xuất 
-- TaoPM_Ngang_PB của PhongBan : chính 
-- TaoPM_Ngang_NhanVien của NhanVien : dẫn xuất theo PhongBan


--Tạo TaoPM_Ngang_PB
create proc TaoPM_Ngang_PB
as 
begin 
select * into PhongBanHN 
from PhongBan
where ChiNhanh = N'Hà Nội'

select * into PhongBanSG 
from PhongBan
where ChiNhanh = N'Sài Gòn'
end 
go 

--Test cho phần TaoPM_Ngang_PB : phân mảnh ngang chính 
exec dbo.TaoPM_Ngang_PB

--TaoPM_Ngang_NhanVien
create proc TaoPM_Ngang_NhanVien
as 
begin
select * into NhanVienHN 
from NhanVien
where MaPB in (select MaPB from PhongBanHN) 

select * into NhanVienSG 
from NhanVien
where MaPB in (select MaPB from PhongBanSG) 
end 
go 

--Test cho phần TaoPM_Ngang_NhanVien: phân mảnh ngang dựa theo PhongBan 
exec dbo.TaoPM_Ngang_NhanVien


-- Câu 2: Thêm dữ liệu vào phân mảnh ngang của bảng PhongBan -> stored ThemPB 
-- Các tham số vào là : @MaPB, @TenPB, @ChiNhanh 
-- Thông báo khi thêm thành công hoặc có lỗi 
-- Không thêm dữ liệu khi gặp trường hợp ngoại lệ 
-- * Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
-- * @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”
-- * @MaPB đã có (nếu thêm sẽ bị trùng @MaLop)
-- Tạo đủ các trường hợp để kiểm thử => Chứng minh nó là đúng 
create proc ThemPB 
@MaPB nvarchar(10), 
@TenPB nvarchar(50),
@ChiNhanh nvarchar(50)
as 
begin 
if (@MaPB is null) 
print N'Không thêm vì không có giá trị mã PB'
else if (@TenPB is null)
print N'Không thêm vì không có giá trị tên PB'
else if (@ChiNhanh is null)
print N'Không thêm vì không có giá trị chi nhánh'
else if @ChiNhanh not in (N'Sài gòn', N'Hà nội')
print N'Không thêm vì không có giá trị chi nhánh hợp lệ'
else if exists (select * from PhongBanHN where MaPB=@MaPB) or exists (select * from PhongBanSG where MaPB=@MaPB)
print N'Không thêm vì trùng mã phòng ban'
else if @ChiNhanh = N'Hà nội'
begin 
insert into PhongBanHN values (@MaPB, @TenPB, @ChiNhanh) 
print N'Thêm dữ liệu thành công phân mảnh PhongBanHN'
end 
else if @ChiNhanh = N'Sài gòn'
begin
insert into PhongBanSG values (@MaPB, @TenPB, @ChiNhanh) 
print N'Thêm dữ liệu thành công phân mảnh PhongBanSG'
end

end 
go 

-- Test 
exec dbo.ThemPB null, null, null 
exec dbo.ThemPB null, N'aa', N'Sài gòn'
exec dbo.ThemPB N'a1', N'aa', null
exec dbo.ThemPB N'a1', null, N'Sài gòn'
exec dbo.ThemPB N'a1', N'aa', N'Sài gòn'
exec dbo.ThemPB N'a1', N'ab', N'Sài gòn'
exec dbo.ThemPB N'a2', N'ab', N'Hà nội'

--Câu 3: Sửa dữ liệu phân mảnh ngang bảng PhongBan => SuaPB
-- (update) tại 2 cột TenPB và ChiNhanh (không sửa cột MaPB)
-- Tham số vào là @MaPB, @TenPB, và @ChiNhanh, trong đó @MaPB để xác định hàng dữ liệu cần sửa
-- Không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau
-- * Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
-- * Không tìm thấy @MaPB để sửa dữ liệu
-- * @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”

create proc SuaPB
@MaPB nvarchar(10), 
@TenPB nvarchar(50),
@ChiNhanh nvarchar(50)
as 
begin 
if (@MaPB is null) 
print N'Không sửa vì không có giá trị mã PB'
else if (@TenPB is null)
print N'Không sửa vì không có giá trị tên PB'
else if (@ChiNhanh is null)
print N'Không sửa vì không có giá trị chi nhánh'
else if @ChiNhanh not in (N'Sài gòn', N'Hà nội')
print N'Không sửa vì không có giá trị chi nhánh hợp lệ'

else if exists (select * from PhongBanHN where MaPB=@MaPB)
begin 
update PhongBanHN
set TenPB = @TenPB, ChiNhanh = @ChiNhanh
where MaPB = @MaPB
if (@ChiNhanh = N'Sài gòn')
begin 
insert into PhongBanSG 
select *from PhongBanHN where MaPB = @MaPB
delete PhongBanHN where MaPB = @MaPB
insert into NhanVienSG 
select *from NhanVienHN where MaPB = @MaPB
delete NhanVienHN where MaPB = @MaPB
print N'DL được cập nhật. PhongBanHN -> NhanVienSG và NhanVienHN -> NhanVienSG'
end 
else 
print N'DL được cập nhật tại PhongBanHN'
end

else if exists (select * from PhongBanSG where MaPB=@MaPB)
begin
update PhongBanSG
set TenPB = @TenPB, ChiNhanh = @ChiNhanh
where MaPB = @MaPB
if (@ChiNhanh = N'Hà nội')
begin
insert into PhongBanHN 
select *from PhongBanSG where MaPB = @MaPB
delete PhongBanSG where MaPB = @MaPB
insert into NhanVienHN 
select *from NhanVienSG where MaPB = @MaPB
delete NhanVienSG where MaPB = @MaPB
print N'DL được cập nhật. PhongBanHN <- NhanVienSG và NhanVienHN <- NhanVienSG'
end
else 
print N'DL được cập nhật tại PhongBanSG'
end

else 
print N'Không sửa vì không tìm thấy giá trị mã PB'
end
go 

--Kiểm thử 
exec dbo.SuaPB null, null, null 
exec dbo.SuaPB null, N'aa', N'Sài gòn'
exec dbo.SuaPB N'a1', N'aa', null
exec dbo.SuaPB N'a1', null, N'Sài gòn'
exec dbo.SuaPB N'a', N'aa', N'Sài gòn'
exec dbo.SuaPB N'a1', N'ab', N'Hà nội'
exec dbo.SuaPB N'a2', N'ab', N'Sài gòn'
exec dbo.SuaPB N'a2', N'aa', N'Sài gòn'


-- Câu 4: Phân mảnh dọc PhongBan -> TaoPM_Doc_PB
-- PhongBan_Doc1(MaPB, TenPB)
-- PhongBan_Doc2(MaPB, ChiNhanh)
create proc TaoPM_Doc_PB
as 
begin 
select MaPB, PhongBan.TenPB into PhongBan_Doc1
from PhongBan
select MaPB, PhongBan.ChiNhanh into PhongBan_Doc2
from PhongBan
end
go 
--Kiểm thử 
exec dbo.TaoPM_Doc_PB

-- Câu 5: Lập danh sách từ phân mảnh dọc bảng PhongBan -> XemPB_Doc
-- Danh sách lớp gồm 3 cột: MaPB, TenPB, ChiNhanh
create proc XemPB_Doc
as 
select PhongBan_Doc1.*, PhongBan_Doc2.ChiNhanh 
from PhongBan_Doc1, PhongBan_Doc2
where PhongBan_Doc1.MaPB = PhongBan_Doc2.MaPB
go 

-- Kiểm tra 
exec dbo.XemPB_Doc

-- Câu 6: Cập nhật phân mảnh dọc -> SuaPB_Doc
-- (update) tại 2 cột TenPB và ChiNhanh (không sửa cột MaPB)
-- Các tham số vào là @MaPB, @TenPB, và @ChiNhanh, trong đó @MaPB để xác định hàng dữ liệu cần sửa
-- Không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- * Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
-- * Không tìm thấy @ MaPB để sửa dữ liệu
-- * Có @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”

create proc SuaPB_Doc
@MaPB nvarchar(10), 
@TenPB nvarchar(50),
@ChiNhanh nvarchar(50)
as 
begin
if (@MaPB is null) 
print N'Không sửa vì không có giá trị mã PB'
else if (@TenPB is null)
print N'Không sửa vì không có giá trị tên PB'
else if (@ChiNhanh is null)
print N'Không sửa vì không có giá trị chi nhánh'
else if @ChiNhanh not in (N'Sài gòn', N'Hà nội')
print N'Không sửa vì không có giá trị chi nhánh hợp lệ'
else if not exists (select * from PhongBan_Doc1 where MaPB=@MaPB)
print N'Không sửa vì không tìm thấy giá trị mã PB'
else
begin
update PhongBan_Doc1
set TenPB = @TenPB
where MaPB = @MaPB
print N'Sửa thành công PhongBan_Doc1'
update PhongBan_Doc2
set ChiNhanh = @ChiNhanh
where MaPB = @MaPB
print N'Sửa thành công PhongBan_Doc2'
end
end
go 

-- Test 
EXEC dbo.SuaPB_Doc null, N'AA', N'Sài Gòn'
EXEC dbo.SuaPB_Doc N'AA', null, N'Sài Gòn'
EXEC dbo.SuaPB_Doc N'AA', N'AA', null
EXEC dbo.SuaPB_Doc N'PB06', N'AA', N'Tây Ninh'
EXEC dbo.SuaPB_Doc N'AA', N'AA', N'Hà Nội'
EXEC dbo.SuaPB_Doc N'PB01', N'AA', N'Hà Nội'
EXEC dbo.SuaPB_Doc N'PB02', N'bb', N'Sài Gòn'