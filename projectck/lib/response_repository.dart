import 'package:projectck/api_helper.dart';
import 'package:projectck/response.dart';

class ResponseRepository {
  static Future<int> add(Response obj) async {
    return ApiHelper.toInt(await ApiHelper.post('/responses', obj.toMap()));
  }

  static Future<bool> isExisted(int surveyId, String memberId) async {
    var data = await ApiHelper.get(
      '/responses/exists${ApiHelper.query({'surveyId': surveyId, 'memberId': memberId})}',
    );
    return data == true;
  }

  static Future<int> countBySurvey(int surveyId) async {
    return ApiHelper.toInt(await ApiHelper.get('/surveys/$surveyId/count'));
  }

  static Future<List<Response>> getResponsesByMember(String memberId) async {
    var data = await ApiHelper.getList('/members/$memberId/responses');
    return data.map(Response.fromMap).toList();
  }
}
