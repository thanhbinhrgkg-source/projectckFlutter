namespace ProjectckApi;

public static class AuthEndpoints
{
    private const string MemberColumns = """
        m.id, m.roleId, r.name AS roleName, m.email, '' AS password, m.givenName,
        ISNULL(m.surname, N'') AS surname, m.isVerified
        FROM member m JOIN role r ON r.id = m.roleId
        """;

    private const string DeleteMember = """
        SET XACT_ABORT ON;
        BEGIN TRAN;
        DELETE FROM orderDetail WHERE orderId IN (SELECT id FROM orders WHERE memberId = @id);
        DELETE FROM orders WHERE memberId = @id;
        DELETE FROM answer WHERE responseId IN (
            SELECT id FROM response WHERE memberId = @id OR surveyId IN (SELECT id FROM survey WHERE memberId = @id));
        DELETE FROM response WHERE memberId = @id OR surveyId IN (SELECT id FROM survey WHERE memberId = @id);
        DELETE FROM answer WHERE questionId IN (
            SELECT q.id FROM question q JOIN survey s ON s.id = q.surveyId WHERE s.memberId = @id);
        DELETE FROM choice WHERE questionId IN (
            SELECT q.id FROM question q JOIN survey s ON s.id = q.surveyId WHERE s.memberId = @id);
        DELETE FROM question WHERE surveyId IN (SELECT id FROM survey WHERE memberId = @id);
        DELETE FROM survey WHERE memberId = @id;
        DELETE FROM member WHERE id = @id;
        COMMIT;
        """;

    private static readonly string[] SystemRoles = ["member", "manager", "admin"];

    public static void MapAuth(this RouteGroupBuilder api, Db db, Mailer mailer)
    {
        api.MapGet("/roles", () => db.Query("""
            SELECT r.id, r.name, (SELECT COUNT(*) FROM member m WHERE m.roleId = r.id) AS memberCount
            FROM role r ORDER BY r.name
            """));

        api.MapGet("/roles/{name}", (string name) =>
            db.QueryOne("SELECT id, name FROM role WHERE name = @name", new { name }) is { } role
                ? Results.Ok(role)
                : Results.NotFound());

        api.MapPost("/roles", (RoleNameDto dto) =>
        {
            var name = dto.Name.Trim().ToLower();
            if (name.Length == 0) return Fail("Vui lòng nhập tên vai trò");
            if (Exists(db, "SELECT COUNT(*) FROM role WHERE name = @name", new { name }))
                return Fail("Vai trò đã tồn tại");
            db.Execute("INSERT INTO role (id, name) SELECT ISNULL(MAX(id), 0) + 1, @name FROM role", new { name });
            return Ok("Thêm vai trò thành công");
        });

        api.MapPut("/roles/{id:int}", (int id, RoleNameDto dto) =>
        {
            var name = dto.Name.Trim().ToLower();
            var old = db.Scalar("SELECT name FROM role WHERE id = @id", new { id }) as string;
            if (old == null) return Fail("Không tìm thấy vai trò");
            if (SystemRoles.Contains(old)) return Fail("Không thể đổi tên vai trò hệ thống");
            if (name.Length == 0) return Fail("Vui lòng nhập tên vai trò");
            if (Exists(db, "SELECT COUNT(*) FROM role WHERE name = @name AND id <> @id", new { name, id }))
                return Fail("Vai trò đã tồn tại");
            db.Execute("UPDATE role SET name = @name WHERE id = @id", new { id, name });
            return Ok("Cập nhật vai trò thành công");
        });

        api.MapDelete("/roles/{id:int}", (int id) =>
        {
            var old = db.Scalar("SELECT name FROM role WHERE id = @id", new { id }) as string;
            if (old == null) return Fail("Không tìm thấy vai trò");
            if (SystemRoles.Contains(old)) return Fail("Không thể xóa vai trò hệ thống");
            if (Exists(db, "SELECT COUNT(*) FROM member WHERE roleId = @id", new { id }))
                return Fail("Vai trò đang có thành viên, không thể xóa");
            db.Execute("DELETE FROM role WHERE id = @id", new { id });
            return Ok("Xóa vai trò thành công");
        });

        api.MapPost("/register", (RegisterDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            if (email.Length == 0 || !email.Contains('@')) return Fail("Email không hợp lệ");
            if (dto.Password.Length < 6) return Fail("Mật khẩu phải có ít nhất 6 ký tự");
            if (string.IsNullOrWhiteSpace(dto.GivenName)) return Fail("Vui lòng nhập tên");
            if (Exists(db, "SELECT COUNT(*) FROM member WHERE email = @email", new { email }))
                return Fail("Email đã tồn tại");
            db.Execute("""
                INSERT INTO member (id, roleId, email, password, givenName, surname, isVerified)
                SELECT @id, id, @email, @password, @givenName, @surname, 0 FROM role WHERE name = 'member'
                """, new
            {
                id = Guid.NewGuid().ToString("N"),
                email,
                password = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                givenName = dto.GivenName.Trim(),
                surname = dto.Surname?.Trim() ?? "",
            });
            return SendCode(db, mailer, email, "Xác thực tài khoản", "Đăng ký thành công. ");
        });

        api.MapPost("/send-code", (EmailDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            if (!Exists(db, "SELECT COUNT(*) FROM member WHERE email = @email", new { email }))
                return Fail("Email không tồn tại");
            return SendCode(db, mailer, email, "Mã xác thực tài khoản", "");
        });

        api.MapPost("/verify", (VerifyDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            if (!CheckCode(db, email, dto.Code)) return Fail("Mã xác thực không đúng hoặc đã hết hạn");
            db.Execute("UPDATE member SET isVerified = 1, verifyCode = NULL, codeExpired = NULL WHERE email = @email",
                new { email });
            return Ok("Xác thực email thành công");
        });

        api.MapPost("/login", (LoginDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            var row = db.QueryOne("SELECT password, isVerified FROM member WHERE email = @email", new { email });
            if (row == null) return Results.Ok(new { success = false, message = "Email không tồn tại" });
            if (!BCrypt.Net.BCrypt.Verify(dto.Password, (string)row["password"]!))
                return Results.Ok(new { success = false, message = "Sai mật khẩu" });
            if ((int)row["isVerified"]! == 0)
                return Results.Ok(new { success = false, needVerify = true, message = "Tài khoản chưa xác thực email" });
            var member = db.QueryOne($"SELECT {MemberColumns} WHERE m.email = @email", new { email });
            return Results.Ok(new { success = true, message = "Đăng nhập thành công", member });
        });

        api.MapPost("/forgot-password", (EmailDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            if (!Exists(db, "SELECT COUNT(*) FROM member WHERE email = @email", new { email }))
                return Fail("Email không tồn tại");
            return SendCode(db, mailer, email, "Mã đặt lại mật khẩu", "");
        });

        api.MapPost("/reset-password", (ResetPasswordDto dto) =>
        {
            var email = dto.Email.Trim().ToLower();
            if (dto.NewPassword.Length < 6) return Fail("Mật khẩu phải có ít nhất 6 ký tự");
            if (!CheckCode(db, email, dto.Code)) return Fail("Mã xác thực không đúng hoặc đã hết hạn");
            db.Execute("""
                UPDATE member SET password = @password, isVerified = 1, verifyCode = NULL, codeExpired = NULL
                WHERE email = @email
                """, new { email, password = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword) });
            return Ok("Đặt lại mật khẩu thành công");
        });

        api.MapPut("/members/{id}/password", (string id, ChangePasswordDto dto) =>
        {
            var hash = db.Scalar("SELECT password FROM member WHERE id = @id", new { id }) as string;
            if (hash == null) return Fail("Không tìm thấy tài khoản");
            if (!BCrypt.Net.BCrypt.Verify(dto.OldPassword, hash)) return Fail("Mật khẩu cũ không đúng");
            if (dto.NewPassword.Length < 6) return Fail("Mật khẩu mới phải có ít nhất 6 ký tự");
            db.Execute("UPDATE member SET password = @password WHERE id = @id",
                new { id, password = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword) });
            return Ok("Đổi mật khẩu thành công");
        });

        api.MapGet("/members", (string? email) => email == null
            ? db.Query($"SELECT {MemberColumns} ORDER BY m.email")
            : db.Query($"SELECT {MemberColumns} WHERE m.email = @email", new { email = email.Trim().ToLower() }));

        api.MapGet("/members/{id}", (string id) =>
            db.QueryOne($"SELECT {MemberColumns} WHERE m.id = @id", new { id }) is { } member
                ? Results.Ok(member)
                : Results.NotFound());

        api.MapPut("/members/{id}/role", (string id, RoleDto dto) =>
            db.Execute("UPDATE member SET roleId = @roleId WHERE id = @id", new { id, roleId = dto.RoleId }));

        api.MapDelete("/members/{id}", (string id) => db.Execute(DeleteMember, new { id }));

        api.MapGet("/members/{id}/responses", (string id) => db.Query("""
            SELECT r.id, r.surveyId, s.title AS surveyTitle, r.memberId, CONVERT(varchar(19), r.date, 120) AS date
            FROM response r JOIN survey s ON s.id = r.surveyId
            WHERE r.memberId = @id
            ORDER BY r.id DESC
            """, new { id }));
    }

    private static IResult SendCode(Db db, Mailer mailer, string email, string subject, string prefix)
    {
        var code = Random.Shared.Next(100000, 1000000).ToString();
        db.Execute("UPDATE member SET verifyCode = @code, codeExpired = DATEADD(MINUTE, 10, GETDATE()) WHERE email = @email",
            new { code, email });
        if (!mailer.Enabled)
            return Results.Ok(new { success = true, message = $"{prefix}Chế độ thử (chưa cấu hình email): mã của bạn là {code}" });
        try
        {
            mailer.Send(email, subject,
                $"<p>Mã xác thực của bạn là: <b style='font-size:20px'>{code}</b></p><p>Mã có hiệu lực trong 10 phút.</p>");
            return Results.Ok(new { success = true, message = $"{prefix}Mã xác thực đã được gửi đến {email}" });
        }
        catch (Exception ex)
        {
            return Fail("Không gửi được email: " + ex.Message);
        }
    }

    private static bool CheckCode(Db db, string email, string code) => Exists(db, """
        SELECT COUNT(*) FROM member WHERE email = @email AND verifyCode = @code AND codeExpired >= GETDATE()
        """, new { email, code = code.Trim() });

    public static bool Exists(Db db, string sql, object args) => db.Scalar(sql, args) is int n && n > 0;

    public static IResult Ok(string message) => Results.Ok(new { success = true, message });

    public static IResult Fail(string message) => Results.Ok(new { success = false, message });
}
