import 'package:projectck/api_helper.dart';
import 'package:projectck/survey.dart';

class SurveyRepository {
  static Future<int> add(Survey obj) async {
    return ApiHelper.toInt(await ApiHelper.post('/surveys', obj.toMap()));
  }

  static Future<int> update(Survey obj) async {
    return ApiHelper.toInt(
      await ApiHelper.put('/surveys/${obj.id}', obj.toMap()),
    );
  }

  static Future<int> updateStatus(int id, int isOpen) async {
    return ApiHelper.toInt(
      await ApiHelper.put('/surveys/$id/status', {'isOpen': isOpen}),
    );
  }

  static Future<int> delete(int id) async {
    return ApiHelper.toInt(await ApiHelper.delete('/surveys/$id'));
  }

  static Future<Survey?> getSurveyById(int id) async {
    var data = await ApiHelper.getOne('/surveys/$id');
    if (data != null) {
      return Survey.fromMap(data);
    }
    return null;
  }

  static Future<List<Survey>> getSurveys() async {
    var data = await ApiHelper.getList('/surveys');
    return data.map(Survey.fromMap).toList();
  }

  static Future<List<Survey>> getSurveysByMember(String memberId) async {
    var data = await ApiHelper.getList(
      '/surveys${ApiHelper.query({'memberId': memberId})}',
    );
    return data.map(Survey.fromMap).toList();
  }

  static Future<List<Survey>> getOpenSurveys(String keyword) async {
    var data = await ApiHelper.getList(
      '/surveys${ApiHelper.query({'open': 1, 'keyword': keyword})}',
    );
    return data.map(Survey.fromMap).toList();
  }

  static Future<List<Survey>> getOpenSurveysByTopic(
    int topicId,
    String keyword,
  ) async {
    var data = await ApiHelper.getList(
      '/surveys${ApiHelper.query({'open': 1, 'topicId': topicId, 'keyword': keyword})}',
    );
    return data.map(Survey.fromMap).toList();
  }
}
