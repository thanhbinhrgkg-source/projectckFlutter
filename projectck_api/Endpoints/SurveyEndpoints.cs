namespace ProjectckApi;

public static class SurveyEndpoints
{
    private const string SurveyColumns = """
        s.id, s.topicId, t.name AS topicName, s.memberId, s.title, s.description, s.isOpen,
        CONVERT(varchar(19), s.createdDate, 120) AS createdDate
        FROM survey s JOIN topic t ON t.id = s.topicId
        """;

    private const string DeleteSurvey = """
        SET XACT_ABORT ON;
        BEGIN TRAN;
        DELETE FROM answer WHERE responseId IN (SELECT id FROM response WHERE surveyId = @id);
        DELETE FROM response WHERE surveyId = @id;
        DELETE FROM answer WHERE questionId IN (SELECT id FROM question WHERE surveyId = @id);
        DELETE FROM choice WHERE questionId IN (SELECT id FROM question WHERE surveyId = @id);
        DELETE FROM question WHERE surveyId = @id;
        DELETE FROM survey WHERE id = @id;
        COMMIT;
        """;

    public static void MapSurvey(this RouteGroupBuilder api, Db db)
    {
        api.MapGet("/topics", () => db.Query("SELECT id, name, description FROM topic"));

        api.MapGet("/surveys", (string? memberId, int? open, int? topicId, string? keyword) =>
        {
            var where = new List<string>();
            if (memberId != null) where.Add("s.memberId = @memberId");
            if (open == 1) where.Add("s.isOpen = 1");
            if (topicId != null) where.Add("s.topicId = @topicId");
            if (!string.IsNullOrWhiteSpace(keyword)) where.Add("s.title LIKE @keyword");
            var sql = $"SELECT {SurveyColumns}"
                + (where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "")
                + " ORDER BY s.id DESC";
            return db.Query(sql, new { memberId, topicId, keyword = $"%{keyword?.Trim()}%" });
        });

        api.MapGet("/surveys/{id:int}", (int id) =>
            db.QueryOne($"SELECT {SurveyColumns} WHERE s.id = @id", new { id }) is { } survey
                ? Results.Ok(survey)
                : Results.NotFound());

        api.MapPost("/surveys", (SurveyDto dto) => db.Scalar("""
            INSERT INTO survey (topicId, memberId, title, description, isOpen)
            OUTPUT INSERTED.id
            VALUES (@TopicId, @MemberId, @Title, @Description, @IsOpen)
            """, dto));

        api.MapPut("/surveys/{id:int}", (int id, SurveyDto dto) => db.Execute("""
            UPDATE survey SET topicId = @TopicId, title = @Title, description = @Description, isOpen = @IsOpen
            WHERE id = @Id
            """, dto with { Id = id }));

        api.MapPut("/surveys/{id:int}/status", (int id, StatusDto dto) =>
            db.Execute("UPDATE survey SET isOpen = @isOpen WHERE id = @id", new { id, isOpen = dto.IsOpen }));

        api.MapDelete("/surveys/{id:int}", (int id) => db.Execute(DeleteSurvey, new { id }));

        api.MapGet("/surveys/{id:int}/questions", (int id) =>
            db.Query("SELECT id, surveyId, content, type FROM question WHERE surveyId = @id ORDER BY id", new { id }));

        api.MapGet("/surveys/{id:int}/count", (int id) =>
            db.Scalar("SELECT COUNT(*) FROM response WHERE surveyId = @id", new { id }));

        api.MapPost("/questions", (QuestionDto dto) => db.Scalar("""
            INSERT INTO question (surveyId, content, type) OUTPUT INSERTED.id
            VALUES (@SurveyId, @Content, @Type)
            """, dto));

        api.MapDelete("/questions/{id:int}", (int id) => db.Execute("""
            SET XACT_ABORT ON;
            BEGIN TRAN;
            DELETE FROM answer WHERE questionId = @id;
            DELETE FROM choice WHERE questionId = @id;
            DELETE FROM question WHERE id = @id;
            COMMIT;
            """, new { id }));

        api.MapGet("/questions/{id:int}/choices", (int id) =>
            db.Query("SELECT id, questionId, content FROM choice WHERE questionId = @id ORDER BY id", new { id }));

        api.MapGet("/questions/{id:int}/stats", (int id) => db.Query("""
            SELECT c.id, c.questionId, c.content, COUNT(a.id) AS total
            FROM choice c LEFT JOIN answer a ON a.choiceId = c.id
            WHERE c.questionId = @id
            GROUP BY c.id, c.questionId, c.content
            ORDER BY c.id
            """, new { id }));

        api.MapGet("/questions/{id:int}/average", (int id) =>
            db.Scalar("SELECT AVG(CAST(content AS FLOAT)) FROM answer WHERE questionId = @id", new { id }) ?? 0.0);

        api.MapGet("/questions/{id:int}/texts", (int id) => db.Query("""
            SELECT content FROM answer
            WHERE questionId = @id AND content IS NOT NULL AND content <> N''
            ORDER BY id DESC
            """, new { id }).Select(p => p["content"]));

        api.MapPost("/choices", (ChoiceDto dto) => db.Scalar("""
            INSERT INTO choice (questionId, content) OUTPUT INSERTED.id VALUES (@QuestionId, @Content)
            """, dto));

        api.MapGet("/responses/exists", (int surveyId, string memberId) =>
            db.Scalar("SELECT COUNT(*) FROM response WHERE surveyId = @surveyId AND memberId = @memberId",
                new { surveyId, memberId }) is int n && n > 0);

        api.MapPost("/responses", (ResponseDto dto) => db.Scalar("""
            INSERT INTO response (surveyId, memberId) OUTPUT INSERTED.id VALUES (@SurveyId, @MemberId)
            """, dto));

        api.MapPost("/answers", (AnswerDto dto) => db.Scalar("""
            INSERT INTO answer (responseId, questionId, choiceId, content) OUTPUT INSERTED.id
            VALUES (@ResponseId, @QuestionId, @ChoiceId, @Content)
            """, dto));
    }
}
