import 'package:projectck/answer.dart';
import 'package:projectck/api_helper.dart';
import 'package:projectck/choice_stat.dart';

class AnswerRepository {
  static Future<int> add(Answer obj) async {
    return ApiHelper.toInt(await ApiHelper.post('/answers', obj.toMap()));
  }

  static Future<List<ChoiceStat>> getChoiceStats(int questionId) async {
    var data = await ApiHelper.getList('/questions/$questionId/stats');
    return data.map(ChoiceStat.fromMap).toList();
  }

  static Future<double> getAverageRating(int questionId) async {
    var data = await ApiHelper.get('/questions/$questionId/average');
    return data is num ? data.toDouble() : 0;
  }

  static Future<List<String>> getTextAnswers(int questionId) async {
    var data = await ApiHelper.get('/questions/$questionId/texts');
    return data is List ? data.cast<String>() : [];
  }
}
