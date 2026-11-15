import 'package:projectck/api_helper.dart';
import 'package:projectck/choice.dart';

class ChoiceRepository {
  static Future<int> add(Choice obj) async {
    return ApiHelper.toInt(await ApiHelper.post('/choices', obj.toMap()));
  }

  static Future<List<Choice>> getChoicesByQuestion(int questionId) async {
    var data = await ApiHelper.getList('/questions/$questionId/choices');
    return data.map(Choice.fromMap).toList();
  }
}
