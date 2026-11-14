namespace ProjectckApi;

public class FileStore(string webRoot)
{
    private static readonly string[] Extensions = [".jpg", ".jpeg", ".png", ".gif", ".webp"];

    public async Task<string?> Save(IFormFile? file, string folder)
    {
        if (file == null || file.Length == 0) return null;
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!Extensions.Contains(ext)) ext = ".jpg";
        var dir = Path.Combine(webRoot, "uploads", folder);
        Directory.CreateDirectory(dir);
        var name = Guid.NewGuid().ToString("N") + ext;
        await using var stream = File.Create(Path.Combine(dir, name));
        await file.CopyToAsync(stream);
        return $"/uploads/{folder}/{name}";
    }

    public void Delete(string? url)
    {
        if (string.IsNullOrWhiteSpace(url) || url.StartsWith("/uploads/seed/")) return;
        var uploads = Path.GetFullPath(Path.Combine(webRoot, "uploads"));
        var path = Path.GetFullPath(Path.Combine(webRoot, url.TrimStart('/').Replace('/', Path.DirectorySeparatorChar)));
        if (path.StartsWith(uploads) && File.Exists(path)) File.Delete(path);
    }
}
