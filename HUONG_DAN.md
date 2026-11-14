# Đề tài 10 – Ứng dụng hỗ trợ khảo sát cho doanh nghiệp

- `projectck/`: app Flutter (Dart). Dùng **SQLite** trên máy để lưu giỏ hàng và bản sao danh mục.
- `projectck_api/`: **REST API C# .NET 10** kết nối **SQL Server** (database `KhaoSatDoanhNghiep`).

## Cách chạy

1. Tạo database. Chỉ cần chạy lần đầu; chạy lại sẽ xóa hết và tạo lại dữ liệu mẫu:
   ```
   cd projectck_api
   sqlcmd -S localhost\MSSQLSERVER01 -U sa -P 123 -C -f 65001 -i Database\01_schema_seed.sql
   ```
2. Chạy API. Để cửa sổ này mở trong suốt lúc dùng app:
   ```
   dotnet run
   ```
3. Chạy app:
   ```
   cd projectck
   flutter run -d windows
   ```
   Dùng máy ảo Android thì chạy `flutter run`. App tự gọi `10.0.2.2:5100` khi chạy trên Android và `localhost:5100` khi chạy trên Windows.

**Tài khoản mẫu**

| Email | Mật khẩu | Vai trò |
|---|---|---|
| admin@gmail.com | admin123 | Quản trị viên |
| member@gmail.com | 123456 | Thành viên |

**Cấu hình thêm** trong `projectck_api/appsettings.json`:
- `Smtp:User` / `Smtp:Password`: Gmail và App Password để gửi mã xác thực qua email thật. Nếu để trống, app chạy chế độ thử và hiện mã ngay trên màn hình.
- `VietQR:BankId`, `AccountNo`, `AccountName`: tài khoản ngân hàng để tạo mã QR thanh toán.

## Đối chiếu chức năng với bảng điểm

Danh mục / sản phẩm trong đề tài này là **danh mục và gói dịch vụ khảo sát**. Doanh nghiệp mua gói, ví dụ "Gói NPS 1.000 phiếu".

### Xác thực người dùng
| Chức năng | Ở đâu trong app |
|---|---|
| Đăng ký | Menu → Đăng ký (`register_page.dart`, API `POST /register`) |
| Đăng nhập | Menu → Đăng nhập (`login_page.dart`, `POST /login`, kiểm tra BCrypt trên server) |
| Đổi mật khẩu | Menu → Đổi mật khẩu (`change_password_page.dart`) |
| Quản lý member | Admin → Thành viên: xem, đổi vai trò, xóa (`member_page.dart`) |
| Quản lý role | Admin → Vai trò: thêm, sửa, xóa; không xóa được vai trò hệ thống hoặc vai trò đang có người dùng (`role_page.dart`) |
| Đăng xuất | Menu → Đăng xuất |
| Phân quyền | Menu hiện khác nhau cho Khách / Thành viên / Quản lý / Quản trị viên |
| Xác thực email (cộng) | Đăng ký xong phải nhập mã 6 số; chưa xác thực thì chưa đăng nhập được (`verify_page.dart`) |
| Quên mật khẩu (cộng) | Màn hình Đăng nhập → Quên mật khẩu (`forgot_password_page.dart`) |

### Quản lý danh mục (admin)
| Chức năng | Ở đâu trong app |
|---|---|
| Hiển thị, thêm, sửa, xóa | Admin → Quản lý danh mục (`category_page.dart`) |
| Kiểm tra còn sản phẩm trước khi xóa | API trả lỗi "Danh mục đang có N sản phẩm, không thể xóa" |
| Upload ảnh đủ 3 trường hợp (cộng) | Thêm có ảnh; sửa đổi ảnh thì ảnh cũ bị xóa trên server; nút "Xóa ảnh"; xóa danh mục thì xóa luôn ảnh |

### Quản lý sản phẩm (admin)
| Chức năng | Ở đâu trong app |
|---|---|
| Hiển thị có phân trang, lọc theo danh mục | Admin → Quản lý sản phẩm (`product_admin_page.dart`, 8 sản phẩm/trang) |
| Thêm sản phẩm (bắt buộc có ảnh) | `product_form_page.dart`, gửi multipart lên `POST /products` |
| Xóa sản phẩm kèm ảnh | `DELETE /products/{id}` xóa luôn file ảnh |
| Sửa sản phẩm, có ảnh mới thì xóa ảnh cũ | `PUT /products/{id}` |
| Kiểm tra sản phẩm có trong đơn hàng trước khi xóa (cộng) | API trả lỗi "Sản phẩm đã có trong đơn hàng, không thể xóa" |

### Trang chủ (tab Cửa hàng)
| Chức năng | Ở đâu trong app |
|---|---|
| Hiển thị danh mục | Hàng danh mục có ảnh (dữ liệu được lưu lại trong SQLite) |
| Sản phẩm mới nhất có phân trang | 6 sản phẩm/trang, sắp theo ngày tạo mới nhất |
| Sản phẩm theo danh mục có phân trang | Bấm vào một danh mục |
| Tìm kiếm có phân trang | Ô tìm kiếm ở đầu trang |
| Chi tiết sản phẩm | Bấm vào thẻ sản phẩm (`product_detail_page.dart`) |
| Sản phẩm liên quan có phân trang (cộng) | Cuối trang chi tiết, 4 sản phẩm/trang |

### Giỏ hàng (lưu bằng SQLite)
| Chức năng | Ở đâu trong app |
|---|---|
| Nút thêm giỏ hàng, thêm vào giỏ | Trên thẻ sản phẩm và trang chi tiết (có chọn số lượng) |
| Số lượng trên icon giỏ hàng | Badge trên thanh tiêu đề (`CartRepository.count`) |
| Hiển thị, cập nhật số lượng, xóa | `cart_page.dart` |
| Đặt hàng (checkout) | `checkout_page.dart`, gửi lên `POST /orders`; server tự tính lại giá |
| Chi tiết đơn hàng | `order_detail_page.dart` |
| Tìm kiếm đơn hàng (cộng) | Menu → Đơn hàng của tôi: tìm theo mã đơn hoặc tên gói, lọc theo ngày và trạng thái |
| Thanh toán VietQR (cộng) | Chọn VietQR khi đặt hàng, trang chi tiết đơn hiện mã QR có sẵn số tiền và nội dung `DHxx` |

### Quản lý đơn hàng (admin)
| Chức năng | Ở đâu trong app |
|---|---|
| Danh sách đơn hàng | Admin → Quản lý đơn hàng (`order_page.dart` với `isAdmin`) |
| Cập nhật trạng thái | Trang chi tiết đơn: Chờ xác nhận / Đã xác nhận / Đang triển khai / Hoàn thành / Đã hủy |
| Tìm kiếm (cộng) | Tìm theo mã đơn, tên khách, email, SĐT, tên gói |
| Lọc theo ngày (cộng) | Nút "Lọc theo ngày đặt" |

### Chức năng riêng của đề tài (giải trình thêm)
- Tạo khảo sát; thêm câu hỏi 4 loại: chọn một, chọn nhiều, đánh giá 1–5, tự luận.
- Làm khảo sát; mỗi tài khoản chỉ làm 1 lần.
- Thống kê kết quả theo phần trăm, điểm trung bình và danh sách câu trả lời tự luận.
- Mở / đóng khảo sát, xem lịch sử khảo sát đã làm trong Hồ sơ.
