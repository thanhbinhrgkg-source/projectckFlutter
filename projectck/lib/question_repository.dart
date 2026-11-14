import 'package:projectck/api_helper.dart';
import 'package:projectck/question.dart';

class QuestionRepository {
  static Future<int> add(Question obj) async {
    return ApiHelper.toInt(await ApiHelper.post('/questions', obj.toMap()));
  }

  static Future<int> delete(int id) async {
    return ApiHelper.toInt(await ApiHelper.delete('/questions/$id'));
  }

  static Future<List<Question>> getQuestionsBySurvey(int surveyId) async {
    var data = await ApiHelper.getList('/surveys/$surveyId/questions');
    return data.map(Question.fromMap).toList();
  }
}
