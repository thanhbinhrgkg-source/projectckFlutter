IF DB_ID(N'KhaoSatDoanhNghiep') IS NULL CREATE DATABASE KhaoSatDoanhNghiep;
GO
USE KhaoSatDoanhNghiep;
GO

IF OBJECT_ID(N'orderDetail') IS NOT NULL DROP TABLE orderDetail;
IF OBJECT_ID(N'orders') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID(N'orderStatus') IS NOT NULL DROP TABLE orderStatus;
IF OBJECT_ID(N'product') IS NOT NULL DROP TABLE product;
IF OBJECT_ID(N'category') IS NOT NULL DROP TABLE category;
IF OBJECT_ID(N'answer') IS NOT NULL DROP TABLE answer;
IF OBJECT_ID(N'response') IS NOT NULL DROP TABLE response;
IF OBJECT_ID(N'choice') IS NOT NULL DROP TABLE choice;
IF OBJECT_ID(N'question') IS NOT NULL DROP TABLE question;
IF OBJECT_ID(N'survey') IS NOT NULL DROP TABLE survey;
IF OBJECT_ID(N'topic') IS NOT NULL DROP TABLE topic;
IF OBJECT_ID(N'member') IS NOT NULL DROP TABLE member;
IF OBJECT_ID(N'role') IS NOT NULL DROP TABLE role;
GO

CREATE TABLE role (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE member (
    id VARCHAR(32) NOT NULL PRIMARY KEY,
    roleId INT NOT NULL REFERENCES role(id),
    email NVARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    givenName NVARCHAR(50) NOT NULL,
    surname NVARCHAR(50) NULL,
    isVerified INT NOT NULL DEFAULT 0,
    verifyCode VARCHAR(6) NULL,
    codeExpired DATETIME NULL
);

CREATE TABLE topic (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL,
    description NVARCHAR(200) NOT NULL
);

CREATE TABLE survey (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    topicId INT NOT NULL REFERENCES topic(id),
    memberId VARCHAR(32) NOT NULL REFERENCES member(id),
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(1000) NOT NULL,
    isOpen INT NOT NULL DEFAULT 1,
    createdDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE question (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    surveyId INT NOT NULL REFERENCES survey(id),
    content NVARCHAR(500) NOT NULL,
    type VARCHAR(20) NOT NULL
);

CREATE TABLE choice (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    questionId INT NOT NULL REFERENCES question(id),
    content NVARCHAR(200) NOT NULL
);

CREATE TABLE response (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    surveyId INT NOT NULL REFERENCES survey(id),
    memberId VARCHAR(32) NOT NULL REFERENCES member(id),
    date DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE answer (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    responseId INT NOT NULL REFERENCES response(id),
    questionId INT NOT NULL REFERENCES question(id),
    choiceId INT NULL REFERENCES choice(id),
    content NVARCHAR(2000) NULL
);

CREATE TABLE category (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NOT NULL,
    imageUrl NVARCHAR(300) NULL
);

CREATE TABLE product (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    categoryId INT NOT NULL REFERENCES category(id),
    name NVARCHAR(200) NOT NULL,
    description NVARCHAR(2000) NOT NULL,
    price DECIMAL(18, 0) NOT NULL,
    quota INT NOT NULL DEFAULT 0,
    imageUrl NVARCHAR(300) NOT NULL,
    createdDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE orderStatus (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    memberId VARCHAR(32) NOT NULL REFERENCES member(id),
    statusId INT NOT NULL REFERENCES orderStatus(id),
    fullName NVARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address NVARCHAR(300) NOT NULL,
    note NVARCHAR(500) NULL,
    paymentMethod VARCHAR(20) NOT NULL,
    total DECIMAL(18, 0) NOT NULL,
    createdDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE orderDetail (
    id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    orderId INT NOT NULL REFERENCES orders(id),
    productId INT NOT NULL REFERENCES product(id),
    quantity INT NOT NULL,
    price DECIMAL(18, 0) NOT NULL
);
GO

INSERT INTO role (id, name) VALUES
    (110547623, N'member'),
    (105548727, N'manager'),
    (357981523, N'admin');

INSERT INTO member (id, roleId, email, password, givenName, surname, isVerified) VALUES
    ('k8s2m4q9x1v7c3n6b5z0p2r8t4y6w1e3', 357981523, N'admin@gmail.com',
     '$2a$10$OfLqTQ1au0HIA6B./6qG9egP/jf0MNvQkGfJ4DRLbhXfXgkZJj7v.', N'Quản trị', N'Hệ Thống', 1),
    ('m3n7b1v5c9x2z6l4k8j0h3g7f1d5s9a2', 110547623, N'member@gmail.com',
     '$2a$10$Euk34tj/WWAIjzaJDNCQDufWj0puqHD.yskhSBLiW4NKkW4Lx2byi', N'An', N'Nguyễn Văn', 1);

INSERT INTO topic (name, description) VALUES
    (N'Khách hàng', N'Khảo sát mức độ hài lòng và chất lượng dịch vụ'),
    (N'Nhân sự', N'Khảo sát nội bộ về môi trường làm việc và phúc lợi'),
    (N'Sản phẩm', N'Ý kiến về sản phẩm trước và sau khi ra mắt'),
    (N'Thị trường', N'Nghiên cứu thị trường và hành vi người tiêu dùng');

INSERT INTO survey (topicId, memberId, title, description, isOpen) VALUES
    (1, 'k8s2m4q9x1v7c3n6b5z0p2r8t4y6w1e3', N'Khảo sát mức độ hài lòng của khách hàng', N'Giúp chúng tôi hiểu mức độ hài lòng của bạn về sản phẩm và dịch vụ.', 1),
    (2, 'k8s2m4q9x1v7c3n6b5z0p2r8t4y6w1e3', N'Khảo sát mức độ gắn kết của nhân viên', N'Chia sẻ trải nghiệm của bạn về môi trường làm việc, quản lý và phúc lợi.', 1),
    (3, 'k8s2m4q9x1v7c3n6b5z0p2r8t4y6w1e3', N'Ý kiến về sản phẩm mới', N'Cho chúng tôi biết suy nghĩ của bạn về dòng sản phẩm mới trước khi ra mắt chính thức.', 1);

INSERT INTO question (surveyId, content, type) VALUES
    (1, N'Bạn đánh giá chung về dịch vụ của chúng tôi thế nào?', 'rating'),
    (1, N'Bạn biết đến chúng tôi qua kênh nào?', 'single'),
    (1, N'Bạn đã sử dụng những dịch vụ nào của chúng tôi?', 'multiple'),
    (1, N'Chúng tôi cần cải thiện điều gì?', 'text'),
    (2, N'Bạn đánh giá sự cân bằng giữa công việc và cuộc sống thế nào?', 'rating'),
    (2, N'Bạn có cảm thấy được ghi nhận trong công việc không?', 'single'),
    (2, N'Phúc lợi nào quan trọng nhất với bạn?', 'multiple'),
    (2, N'Bạn có góp ý gì cho ban quản lý?', 'text'),
    (3, N'Khả năng bạn mua sản phẩm mới là bao nhiêu?', 'single'),
    (3, N'Bạn mong muốn mức giá nào?', 'single'),
    (3, N'Bạn quan tâm nhất đến tính năng nào?', 'multiple'),
    (3, N'Ý kiến khác', 'text');

INSERT INTO choice (questionId, content) VALUES
    (2, N'Mạng xã hội'),
    (2, N'Bạn bè, người thân'),
    (2, N'Quảng cáo'),
    (2, N'Công cụ tìm kiếm'),
    (3, N'Tư vấn'),
    (3, N'Giao hàng'),
    (3, N'Hỗ trợ sau bán hàng'),
    (3, N'Thanh toán trực tuyến'),
    (6, N'Luôn luôn'),
    (6, N'Thỉnh thoảng'),
    (6, N'Hiếm khi'),
    (6, N'Không bao giờ'),
    (7, N'Bảo hiểm sức khỏe'),
    (7, N'Thưởng'),
    (7, N'Đào tạo'),
    (7, N'Giờ làm việc linh hoạt'),
    (7, N'Du lịch, team building'),
    (9, N'Chắc chắn mua'),
    (9, N'Có thể mua'),
    (9, N'Chưa chắc chắn'),
    (9, N'Không mua'),
    (10, N'Dưới 500.000 VNĐ'),
    (10, N'500.000 - 1.000.000 VNĐ'),
    (10, N'Trên 1.000.000 VNĐ'),
    (11, N'Thiết kế'),
    (11, N'Thời lượng pin'),
    (11, N'Giá cả'),
    (11, N'Bảo hành');

INSERT INTO category (name, description, imageUrl) VALUES
    (N'Khảo sát khách hàng', N'Đo lường mức độ hài lòng, chỉ số NPS và trải nghiệm khách hàng', N'/uploads/seed/category_1.png'),
    (N'Khảo sát nhân sự', N'Mức độ gắn kết, hài lòng của nhân viên và đánh giá năng lực', N'/uploads/seed/category_2.png'),
    (N'Nghiên cứu sản phẩm', N'Thử nghiệm sản phẩm mới, định giá, bao bì và thiết kế', N'/uploads/seed/category_3.png'),
    (N'Nghiên cứu thị trường', N'Phân tích đối thủ, hành vi người tiêu dùng và xu hướng thị trường', N'/uploads/seed/category_4.png');

INSERT INTO product (categoryId, name, description, price, quota, imageUrl, createdDate) VALUES
    (1, N'Gói CSAT Cơ bản', N'Khảo sát mức độ hài lòng khách hàng với 300 phiếu, mẫu câu hỏi có sẵn, báo cáo biểu đồ trực tuyến.', 1500000, 300, N'/uploads/seed/product_1.png', DATEADD(HOUR, -240, GETDATE())),
    (1, N'Gói NPS Chuyên sâu', N'Đo chỉ số NPS với 1.000 phiếu, phân nhóm khách hàng trung thành và tư vấn thiết kế câu hỏi.', 4200000, 1000, N'/uploads/seed/product_2.png', DATEADD(HOUR, -220, GETDATE())),
    (1, N'Gói Hậu mãi', N'Đánh giá chất lượng dịch vụ sau bán hàng, cảnh báo khi có đánh giá thấp.', 2500000, 500, N'/uploads/seed/product_3.png', DATEADD(HOUR, -200, GETDATE())),
    (2, N'Gói Gắn kết nhân viên', N'Khảo sát mức độ gắn kết của nhân viên, ẩn danh người trả lời, báo cáo theo phòng ban.', 1800000, 200, N'/uploads/seed/product_4.png', DATEADD(HOUR, -180, GETDATE())),
    (2, N'Gói Đánh giá 360°', N'Đánh giá năng lực đa chiều từ cấp trên, đồng nghiệp và cấp dưới.', 3500000, 100, N'/uploads/seed/product_5.png', DATEADD(HOUR, -160, GETDATE())),
    (2, N'Gói Khảo sát nghỉ việc', N'Tìm hiểu lý do nhân viên nghỉ việc để cải thiện chính sách nhân sự.', 1200000, 150, N'/uploads/seed/product_6.png', DATEADD(HOUR, -140, GETDATE())),
    (3, N'Gói Thử nghiệm sản phẩm', N'Thu thập ý kiến người dùng về sản phẩm mới trước khi ra mắt.', 3900000, 500, N'/uploads/seed/product_7.png', DATEADD(HOUR, -120, GETDATE())),
    (3, N'Gói Định giá sản phẩm', N'Khảo sát mức giá mong muốn và độ nhạy về giá của khách hàng.', 2900000, 400, N'/uploads/seed/product_8.png', DATEADD(HOUR, -100, GETDATE())),
    (3, N'Gói Bao bì & thiết kế', N'So sánh các phương án bao bì, logo và thiết kế sản phẩm.', 2200000, 300, N'/uploads/seed/product_9.png', DATEADD(HOUR, -80, GETDATE())),
    (4, N'Gói Phân tích đối thủ', N'Khảo sát nhận diện thương hiệu và so sánh với đối thủ cạnh tranh.', 5500000, 600, N'/uploads/seed/product_10.png', DATEADD(HOUR, -60, GETDATE())),
    (4, N'Gói Hành vi tiêu dùng', N'Nghiên cứu thói quen mua sắm và kênh thông tin của người tiêu dùng.', 4800000, 800, N'/uploads/seed/product_11.png', DATEADD(HOUR, -40, GETDATE())),
    (4, N'Gói Doanh nghiệp', N'Trọn gói 3.000 phiếu cho nhiều khảo sát, kèm tư vấn và báo cáo chuyên sâu hằng tháng.', 12000000, 3000, N'/uploads/seed/product_12.png', DATEADD(HOUR, -20, GETDATE()));

INSERT INTO orderStatus (id, name) VALUES
    (0, N'Đã hủy'),
    (1, N'Chờ xác nhận'),
    (2, N'Đã xác nhận'),
    (3, N'Đang triển khai'),
    (4, N'Hoàn thành');

INSERT INTO orders (memberId, statusId, fullName, phone, address, note, paymentMethod, total, createdDate) VALUES
    ('m3n7b1v5c9x2z6l4k8j0h3g7f1d5s9a2', 4, N'Nguyễn Văn An', '0901234567', N'12 Nguyễn Huệ, Quận 1, TP.HCM', NULL, 'COD', 5700000, DATEADD(DAY, -5, GETDATE())),
    ('m3n7b1v5c9x2z6l4k8j0h3g7f1d5s9a2', 1, N'Nguyễn Văn An', '0901234567', N'12 Nguyễn Huệ, Quận 1, TP.HCM', N'Liên hệ trước khi triển khai', 'VIETQR', 3500000, DATEADD(DAY, -1, GETDATE()));

INSERT INTO orderDetail (orderId, productId, quantity, price) VALUES
    (1, 1, 1, 1500000),
    (1, 2, 1, 4200000),
    (2, 5, 1, 3500000);
GO
