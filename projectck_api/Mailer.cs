using System.Net;
using System.Net.Mail;

namespace ProjectckApi;

public class Mailer(IConfiguration config)
{
    public bool Enabled =>
        !string.IsNullOrWhiteSpace(config["Smtp:User"]) && !string.IsNullOrWhiteSpace(config["Smtp:Password"]);

    public void Send(string to, string subject, string body)
    {
        using var client = new SmtpClient(config["Smtp:Host"], int.Parse(config["Smtp:Port"] ?? "587"))
        {
            EnableSsl = true,
            Credentials = new NetworkCredential(config["Smtp:User"], config["Smtp:Password"]),
        };
        using var message = new MailMessage(
            new MailAddress(config["Smtp:User"]!, config["Smtp:FromName"] ?? "Khảo Sát Doanh Nghiệp"),
            new MailAddress(to))
        {
            Subject = subject,
            Body = body,
            IsBodyHtml = true,
        };
        client.Send(message);
    }
}
