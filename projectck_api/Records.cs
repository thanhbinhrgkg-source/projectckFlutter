namespace ProjectckApi;

public record LoginDto(string Email, string Password);
public record RegisterDto(string Email, string Password, string GivenName, string? Surname);
public record EmailDto(string Email);
public record VerifyDto(string Email, string Code);
public record ResetPasswordDto(string Email, string Code, string NewPassword);
public record ChangePasswordDto(string OldPassword, string NewPassword);
public record RoleDto(int RoleId);
public record RoleNameDto(string Name);
public record StatusDto(int IsOpen);
public record SurveyDto(int? Id, int TopicId, string MemberId, string Title, string Description, int IsOpen);
public record QuestionDto(int SurveyId, string Content, string Type);
public record ChoiceDto(int QuestionId, string Content);
public record ResponseDto(int SurveyId, string MemberId);
public record AnswerDto(int ResponseId, int QuestionId, int? ChoiceId, string? Content);
public record OrderItemDto(int ProductId, int Quantity);
public record OrderDto(string MemberId, string FullName, string Phone, string Address, string? Note,
    string PaymentMethod, List<OrderItemDto> Items);
public record OrderStatusDto(int StatusId);
public record CancelOrderDto(string MemberId);
