using ProjectckApi;

var builder = WebApplication.CreateBuilder(args);
var db = new Db(builder.Configuration.GetConnectionString("KhaoSat")!);
var mailer = new Mailer(builder.Configuration);
builder.WebHost.UseUrls(builder.Configuration["Urls"] ?? "http://0.0.0.0:5100");

var app = builder.Build();
var webRoot = Path.Combine(app.Environment.ContentRootPath, "wwwroot");
Directory.CreateDirectory(Path.Combine(webRoot, "uploads"));
var files = new FileStore(webRoot);
app.UseStaticFiles();

var api = app.MapGroup("/api");

api.MapGet("/health", () => new
{
    status = "ok",
    database = db.Scalar("SELECT DB_NAME()"),
    server = db.Scalar("SELECT @@SERVERNAME"),
    email = mailer.Enabled ? "smtp" : "demo",
});

api.MapAuth(db, mailer);
api.MapSurvey(db);
api.MapShop(db, files);
api.MapOrder(db, builder.Configuration);

app.Run();
