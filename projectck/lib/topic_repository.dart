import 'package:projectck/api_helper.dart';
import 'package:projectck/topic.dart';

class TopicRepository {
  static Future<List<Topic>> getTopics() async {
    var data = await ApiHelper.getList('/topics');
    return data.map(Topic.fromMap).toList();
  }
}
