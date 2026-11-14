import 'package:projectck/choice.dart';

class ChoiceStat extends Choice {
  final int total;
  ChoiceStat({
    required super.id,
    required super.questionId,
    required super.content,
    required this.total,
  });
  @override
  Map<String, Object?> toMap() {
    var map = super.toMap();
    map['total'] = total;
    return map;
  }

  factory ChoiceStat.fromMap(Map<String, dynamic> map) {
    return ChoiceStat(
      id: map['id'],
      questionId: map['questionId'],
      content: map['content'],
      total: map['total'],
    );
  }
}
