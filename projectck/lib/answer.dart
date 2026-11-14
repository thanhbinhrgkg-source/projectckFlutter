class Answer {
  final int? id;
  final int responseId;
  final int questionId;
  final int? choiceId;
  final String? content;
  Answer({
    required this.id,
    required this.responseId,
    required this.questionId,
    required this.choiceId,
    required this.content,
  });
  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      responseId: map['responseId'],
      questionId: map['questionId'],
      choiceId: map['choiceId'],
      content: map['content'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'responseId': responseId,
      'questionId': questionId,
      'choiceId': choiceId,
      'content': content,
    };
  }
}
