class Response {
  final int? id;
  final int surveyId;
  final String? surveyTitle;
  final String memberId;
  final String? date;
  Response({
    required this.id,
    required this.surveyId,
    required this.surveyTitle,
    required this.memberId,
    required this.date,
  });
  factory Response.fromMap(Map<String, dynamic> map) {
    return Response(
      id: map['id'],
      surveyId: map['surveyId'],
      surveyTitle: map.containsKey('surveyTitle') ? map['surveyTitle'] : null,
      memberId: map['memberId'],
      date: map['date'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'surveyId': surveyId,
      'memberId': memberId,
      if (date != null) 'date': date,
    };
  }
}
