-- Câu 6: Tạo view từ 4 phân mảnh hỗn hợp 
CREATE VIEW DanhSachTatCaPB_HH
AS
SELECT hh1.MaPB, hh1.TenPB, hh2.ChiNhanh
FROM PhongBan_HH1 hh1
INNER JOIN PhongBan_HH2 hh2 ON hh1.MaPB = hh2.MaPB

UNION ALL

SELECT hh3.MaPB, hh3.TenPB, hh4.ChiNhanh
FROM PhongBan_HH3 hh3
INNER JOIN PhongBan_HH4 hh4 ON hh3.MaPB = hh4.MaPB;
GO


-- CÂU 7 CÁCH 1 
CREATE PROCEDURE ThemPB_HH
    @MaPB NVARCHAR(20), 
    @TenPB NVARCHAR(80), 
    @ChiNhanh NVARCHAR(80)
AS
BEGIN
    -- Kiểm tra nếu @MaPB, @TenPB, hoặc @ChiNhanh là NULL
    IF @MaPB IS NULL
    BEGIN
        PRINT N'Không thể sửa do không có giá trị mã phòng ban!';
        RETURN;
    END

    IF @TenPB IS NULL
    BEGIN
        PRINT N'Không thể sửa do không có giá trị tên phòng ban!';
        RETURN;
    END

    IF @ChiNhanh IS NULL
    BEGIN
        PRINT N'Không thể sửa do không có giá trị chi nhánh!';
        RETURN;
    END

    -- Kiểm tra nếu @ChiNhanh không phải là "Sài Gòn" hoặc "Hà Nội"
    IF @ChiNhanh NOT IN (N'Sài Gòn', N'Hà Nội')
    BEGIN
        PRINT N'Không thể sửa do giá trị cơ sở không hợp lệ! (Chỉ có thể là "Sài Gòn" và "Hà Nội")';
        RETURN;
    END

    -- Kiểm tra nếu @MaPB đã tồn tại trong các phân mảnh
    IF EXISTS (SELECT * FROM dbo.PhongBan_HH1 WHERE MaPB = @MaPB)
       OR EXISTS (SELECT * FROM dbo.PhongBan_HH3 WHERE MaPB = @MaPB)
    BEGIN
        PRINT N'Không thể thêm do bị trùng mã phòng ban';
        RETURN;
    END

    -- Thêm vào các phân mảnh thích hợp
    IF @ChiNhanh = N'Sài Gòn'
    BEGIN
        INSERT INTO dbo.PhongBan_HH1 (MaPB, TenPB) VALUES (@MaPB, @TenPB);
        INSERT INTO dbo.PhongBan_HH2 (MaPB, ChiNhanh) VALUES (@MaPB, @ChiNhanh);
    END
    ELSE IF @ChiNhanh = N'Hà Nội'
    BEGIN
        INSERT INTO dbo.PhongBan_HH3 (MaPB, TenPB) VALUES (@MaPB, @TenPB);
        INSERT INTO dbo.PhongBan_HH4 (MaPB, ChiNhanh) VALUES (@MaPB, @ChiNhanh);
    END

    PRINT N'Thêm dữ liệu thành công';
END
GO

-- Test
exec ThemPB_HH null,'Quản trị','Sài gòn' -- null mã
exec ThemPB_HH 'PB07', 'Kỹ sư', 'Cần thơ' -- khác chi nhánh ko phải là sg hoặc là hn
exec ThemPB_HH 'PB01','IT','Sài gòn' -- trùng phòng ban đã tồn tại
exec ThemPB_HH 'PB07', 'IT',N'Sài gòn'-- thêm được
exec ThemPB_HH 'PB08', N'Sáng tạo',N'Hà nội'-- thêm dc

