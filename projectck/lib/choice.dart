class Choice {
  final int? id;
  final int questionId;
  final String content;
  Choice({required this.id, required this.questionId, required this.content});
  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      id: map['id'],
      questionId: map['questionId'],
      content: map['content'],
    );
  }
  Map<String, Object?> toMap() {
    return {'id': id, 'questionId': questionId, 'content': content};
  }
}
