namespace ProjectckApi;

public static class ShopEndpoints
{
    private const string ProductColumns = """
        p.id, p.categoryId, c.name AS categoryName, p.name, p.description, p.price, p.quota, p.imageUrl,
        CONVERT(varchar(19), p.createdDate, 120) AS createdDate
        FROM product p JOIN category c ON c.id = p.categoryId
        """;

    public static void MapShop(this RouteGroupBuilder api, Db db, FileStore files)
    {
        api.MapGet("/categories", () => db.Query("""
            SELECT c.id, c.name, c.description, c.imageUrl,
                (SELECT COUNT(*) FROM product p WHERE p.categoryId = c.id) AS productCount
            FROM category c ORDER BY c.id
            """));

        api.MapPost("/categories", async (HttpRequest request) =>
        {
            var form = await request.ReadFormAsync();
            var name = form["name"].ToString().Trim();
            if (name.Length == 0) return AuthEndpoints.Fail("Vui lòng nhập tên danh mục");
            if (AuthEndpoints.Exists(db, "SELECT COUNT(*) FROM category WHERE name = @name", new { name }))
                return AuthEndpoints.Fail("Danh mục đã tồn tại");
            var imageUrl = await files.Save(form.Files["image"], "categories");
            db.Execute("INSERT INTO category (name, description, imageUrl) VALUES (@name, @description, @imageUrl)",
                new { name, description = form["description"].ToString().Trim(), imageUrl });
            return AuthEndpoints.Ok("Thêm danh mục thành công");
        });

        api.MapPut("/categories/{id:int}", async (int id, HttpRequest request) =>
        {
            var old = db.QueryOne("SELECT imageUrl FROM category WHERE id = @id", new { id });
            if (old == null) return AuthEndpoints.Fail("Không tìm thấy danh mục");
            var form = await request.ReadFormAsync();
            var name = form["name"].ToString().Trim();
            if (name.Length == 0) return AuthEndpoints.Fail("Vui lòng nhập tên danh mục");
            if (AuthEndpoints.Exists(db, "SELECT COUNT(*) FROM category WHERE name = @name AND id <> @id", new { name, id }))
                return AuthEndpoints.Fail("Danh mục đã tồn tại");
            var oldImage = old["imageUrl"] as string;
            var imageUrl = oldImage;
            var newImage = await files.Save(form.Files["image"], "categories");
            if (newImage != null)
            {
                files.Delete(oldImage);
                imageUrl = newImage;
            }
            else if (form["removeImage"] == "1")
            {
                files.Delete(oldImage);
                imageUrl = null;
            }
            db.Execute("UPDATE category SET name = @name, description = @description, imageUrl = @imageUrl WHERE id = @id",
                new { id, name, description = form["description"].ToString().Trim(), imageUrl });
            return AuthEndpoints.Ok("Cập nhật danh mục thành công");
        });

        api.MapDelete("/categories/{id:int}", (int id) =>
        {
            var old = db.QueryOne("SELECT imageUrl FROM category WHERE id = @id", new { id });
            if (old == null) return AuthEndpoints.Fail("Không tìm thấy danh mục");
            var count = db.Scalar("SELECT COUNT(*) FROM product WHERE categoryId = @id", new { id }) as int? ?? 0;
            if (count > 0) return AuthEndpoints.Fail($"Danh mục đang có {count} sản phẩm, không thể xóa");
            db.Execute("DELETE FROM category WHERE id = @id", new { id });
            files.Delete(old["imageUrl"] as string);
            return AuthEndpoints.Ok("Xóa danh mục thành công");
        });

        api.MapGet("/products", (int? categoryId, string? keyword, int? page, int? pageSize) =>
        {
            var where = new List<string>();
            if (categoryId != null) where.Add("p.categoryId = @categoryId");
            if (!string.IsNullOrWhiteSpace(keyword)) where.Add("(p.name LIKE @keyword OR p.description LIKE @keyword)");
            var filter = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";
            return Paging(db, filter, new { categoryId, keyword = $"%{keyword?.Trim()}%" }, page, pageSize);
        });

        api.MapGet("/products/{id:int}", (int id) =>
            db.QueryOne($"SELECT {ProductColumns} WHERE p.id = @id", new { id }) is { } product
                ? Results.Ok(product)
                : Results.NotFound());

        api.MapGet("/products/{id:int}/related", (int id, int? page, int? pageSize) =>
            Paging(db, " WHERE p.id <> @id AND p.categoryId = (SELECT categoryId FROM product WHERE id = @id)",
                new { id }, page, pageSize));

        api.MapPost("/products", async (HttpRequest request) =>
        {
            var form = await request.ReadFormAsync();
            var error = Validate(form);
            if (error != null) return AuthEndpoints.Fail(error);
            var imageUrl = await files.Save(form.Files["image"], "products");
            if (imageUrl == null) return AuthEndpoints.Fail("Vui lòng chọn hình ảnh sản phẩm");
            db.Execute("""
                INSERT INTO product (categoryId, name, description, price, quota, imageUrl)
                VALUES (@categoryId, @name, @description, @price, @quota, @imageUrl)
                """, ProductArgs(form, imageUrl));
            return AuthEndpoints.Ok("Thêm sản phẩm thành công");
        });

        api.MapPut("/products/{id:int}", async (int id, HttpRequest request) =>
        {
            var oldImage = db.Scalar("SELECT imageUrl FROM product WHERE id = @id", new { id }) as string;
            if (oldImage == null) return AuthEndpoints.Fail("Không tìm thấy sản phẩm");
            var form = await request.ReadFormAsync();
            var error = Validate(form);
            if (error != null) return AuthEndpoints.Fail(error);
            var newImage = await files.Save(form.Files["image"], "products");
            if (newImage != null) files.Delete(oldImage);
            db.Execute("""
                UPDATE product SET categoryId = @categoryId, name = @name, description = @description,
                    price = @price, quota = @quota, imageUrl = @imageUrl
                WHERE id = @id
                """, ProductArgs(form, newImage ?? oldImage, id));
            return AuthEndpoints.Ok("Cập nhật sản phẩm thành công");
        });

        api.MapDelete("/products/{id:int}", (int id) =>
        {
            var oldImage = db.Scalar("SELECT imageUrl FROM product WHERE id = @id", new { id }) as string;
            if (oldImage == null) return AuthEndpoints.Fail("Không tìm thấy sản phẩm");
            if (AuthEndpoints.Exists(db, "SELECT COUNT(*) FROM orderDetail WHERE productId = @id", new { id }))
                return AuthEndpoints.Fail("Sản phẩm đã có trong đơn hàng, không thể xóa");
            db.Execute("DELETE FROM product WHERE id = @id", new { id });
            files.Delete(oldImage);
            return AuthEndpoints.Ok("Xóa sản phẩm thành công");
        });
    }

    private static object Paging(Db db, string filter, object args, int? page, int? pageSize)
    {
        var size = Math.Clamp(pageSize ?? 6, 1, 50);
        var current = Math.Max(page ?? 1, 1);
        var total = db.Scalar($"SELECT COUNT(*) FROM product p {filter}", args) as int? ?? 0;
        var items = db.Query($"""
            SELECT {ProductColumns} {filter}
            ORDER BY p.createdDate DESC, p.id DESC
            OFFSET {(current - 1) * size} ROWS FETCH NEXT {size} ROWS ONLY
            """, args);
        return new { items, total, page = current, pageSize = size };
    }

    private static string? Validate(IFormCollection form)
    {
        if (!int.TryParse(form["categoryId"], out _)) return "Vui lòng chọn danh mục";
        if (form["name"].ToString().Trim().Length == 0) return "Vui lòng nhập tên sản phẩm";
        if (!decimal.TryParse(form["price"], out var price) || price < 0) return "Giá không hợp lệ";
        if (!int.TryParse(form["quota"], out var quota) || quota < 0) return "Số phiếu không hợp lệ";
        return null;
    }

    private static object ProductArgs(IFormCollection form, string imageUrl, int id = 0) => new
    {
        id,
        categoryId = int.Parse(form["categoryId"]!),
        name = form["name"].ToString().Trim(),
        description = form["description"].ToString().Trim(),
        price = decimal.Parse(form["price"]!),
        quota = int.Parse(form["quota"]!),
        imageUrl,
    };
}
