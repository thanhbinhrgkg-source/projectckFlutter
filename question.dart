class Question {
  static const Map<String, String> types = {
    'single': 'Chọn một',
    'multiple': 'Chọn nhiều',
    'rating': 'Đánh giá 1 - 5',
    'text': 'Tự luận',
  };
  final int? id;
  final int surveyId;
  final String content;
  final String type;
  Question({
    required this.id,
    required this.surveyId,
    required this.content,
    required this.type,
  });
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      surveyId: map['surveyId'],
      content: map['content'],
      type: map['type'],
    );
  }
  Map<String, Object?> toMap() {
    return {'id': id, 'surveyId': surveyId, 'content': content, 'type': type};
  }
}
