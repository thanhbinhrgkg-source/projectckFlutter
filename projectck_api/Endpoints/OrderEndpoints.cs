namespace ProjectckApi;

public static class OrderEndpoints
{
    private const string OrderColumns = """
        o.id, o.memberId, m.email AS memberEmail, o.statusId, st.name AS statusName, o.fullName, o.phone,
        o.address, ISNULL(o.note, N'') AS note, o.paymentMethod, o.total,
        CONVERT(varchar(19), o.createdDate, 120) AS createdDate,
        (SELECT SUM(d.quantity) FROM orderDetail d WHERE d.orderId = o.id) AS itemCount
        FROM orders o
        JOIN orderStatus st ON st.id = o.statusId
        JOIN member m ON m.id = o.memberId
        """;

    public static void MapOrder(this RouteGroupBuilder api, Db db, IConfiguration config)
    {
        api.MapGet("/order-status", () => db.Query("SELECT id, name FROM orderStatus ORDER BY id"));

        api.MapPost("/orders", (OrderDto dto) =>
        {
            var items = dto.Items.Where(p => p.Quantity > 0).ToList();
            if (items.Count == 0) return AuthEndpoints.Fail("Giỏ hàng đang trống");
            if (string.IsNullOrWhiteSpace(dto.FullName) || string.IsNullOrWhiteSpace(dto.Phone)
                || string.IsNullOrWhiteSpace(dto.Address))
                return AuthEndpoints.Fail("Vui lòng nhập đầy đủ họ tên, số điện thoại và địa chỉ");
            using var connection = db.Open();
            using var tx = connection.BeginTransaction();
            decimal total = 0;
            var prices = new Dictionary<int, decimal>();
            foreach (var item in items)
            {
                if (Db.Command(connection, "SELECT price FROM product WHERE id = @ProductId", item, tx)
                        .ExecuteScalar() is not decimal price)
                {
                    tx.Rollback();
                    return AuthEndpoints.Fail("Có sản phẩm không còn tồn tại, vui lòng kiểm tra lại giỏ hàng");
                }
                prices[item.ProductId] = price;
                total += price * item.Quantity;
            }
            var orderId = (int)Db.Command(connection, """
                INSERT INTO orders (memberId, statusId, fullName, phone, address, note, paymentMethod, total)
                OUTPUT INSERTED.id
                VALUES (@MemberId, 1, @FullName, @Phone, @Address, @Note, @PaymentMethod, @Total)
                """, new
            {
                dto.MemberId,
                FullName = dto.FullName.Trim(),
                Phone = dto.Phone.Trim(),
                Address = dto.Address.Trim(),
                Note = dto.Note?.Trim(),
                dto.PaymentMethod,
                Total = total,
            }, tx).ExecuteScalar()!;
            foreach (var item in items)
            {
                Db.Command(connection, """
                    INSERT INTO orderDetail (orderId, productId, quantity, price)
                    VALUES (@orderId, @productId, @quantity, @price)
                    """, new { orderId, productId = item.ProductId, quantity = item.Quantity, price = prices[item.ProductId] },
                    tx).ExecuteNonQuery();
            }
            tx.Commit();
            return Results.Ok(new { success = true, message = "Đặt hàng thành công", id = orderId });
        });

        api.MapGet("/orders", (string? memberId, string? keyword, string? fromDate, string? toDate, int? statusId) =>
        {
            var where = new List<string>();
            if (memberId != null) where.Add("o.memberId = @memberId");
            if (statusId != null) where.Add("o.statusId = @statusId");
            if (DateTime.TryParse(fromDate, out _)) where.Add("CAST(o.createdDate AS DATE) >= @fromDate");
            if (DateTime.TryParse(toDate, out _)) where.Add("CAST(o.createdDate AS DATE) <= @toDate");
            if (!string.IsNullOrWhiteSpace(keyword))
                where.Add("""
                    (CAST(o.id AS VARCHAR(20)) = @code OR o.fullName LIKE @keyword OR o.phone LIKE @keyword
                    OR m.email LIKE @keyword OR EXISTS (SELECT 1 FROM orderDetail d JOIN product p ON p.id = d.productId
                        WHERE d.orderId = o.id AND p.name LIKE @keyword))
                    """);
            var sql = $"SELECT {OrderColumns}"
                + (where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "")
                + " ORDER BY o.createdDate DESC";
            var code = keyword?.Trim().TrimStart('#').ToUpper().Replace("DH", "");
            return db.Query(sql, new
            {
                memberId,
                statusId,
                fromDate = DateTime.TryParse(fromDate, out var f) ? f.Date : (DateTime?)null,
                toDate = DateTime.TryParse(toDate, out var t) ? t.Date : (DateTime?)null,
                code,
                keyword = $"%{keyword?.Trim()}%",
            });
        });

        api.MapGet("/orders/{id:int}", (int id) =>
        {
            var order = db.QueryOne($"SELECT {OrderColumns} WHERE o.id = @id", new { id });
            if (order == null) return Results.NotFound();
            order["items"] = db.Query("""
                SELECT d.id, d.orderId, d.productId, p.name AS productName, p.imageUrl, d.quantity, d.price
                FROM orderDetail d JOIN product p ON p.id = d.productId
                WHERE d.orderId = @id
                """, new { id });
            return Results.Ok(order);
        });

        api.MapPut("/orders/{id:int}/status", (int id, OrderStatusDto dto) =>
            db.Execute("UPDATE orders SET statusId = @statusId WHERE id = @id", new { id, statusId = dto.StatusId }) > 0
                ? AuthEndpoints.Ok("Cập nhật trạng thái thành công")
                : AuthEndpoints.Fail("Không tìm thấy đơn hàng"));

        api.MapPut("/orders/{id:int}/cancel", (int id, CancelOrderDto dto) =>
            db.Execute("UPDATE orders SET statusId = 0 WHERE id = @id AND memberId = @memberId AND statusId = 1",
                new { id, memberId = dto.MemberId }) > 0
                ? AuthEndpoints.Ok("Đã hủy đơn hàng")
                : AuthEndpoints.Fail("Chỉ hủy được đơn hàng đang chờ xác nhận"));

        api.MapGet("/orders/{id:int}/vietqr", (int id) =>
        {
            if (db.Scalar("SELECT total FROM orders WHERE id = @id", new { id }) is not decimal total)
                return Results.NotFound();
            var bank = config["VietQR:BankId"];
            var account = config["VietQR:AccountNo"];
            var name = Uri.EscapeDataString(config["VietQR:AccountName"] ?? "");
            var url = $"https://img.vietqr.io/image/{bank}-{account}-compact2.png"
                + $"?amount={total:0}&addInfo=DH{id}&accountName={name}";
            return Results.Ok(new { url, bank, account, accountName = config["VietQR:AccountName"], content = $"DH{id}", amount = total });
        });
    }
}
