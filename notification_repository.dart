import 'package:flutter/foundation.dart';
import 'package:projectck/api_helper.dart';
import 'package:projectck/app_notification.dart';
import 'package:projectck/notification_service.dart';
import 'package:projectck/session_helper.dart';

class NotificationRepository {
  static final ValueNotifier<int> unread = ValueNotifier(0);
  static int _lastId = -1;

  static Future<List<AppNotification>> getNotifications() async {
    var data = await ApiHelper.getList('/notifications');
    return data.map(AppNotification.fromMap).toList();
  }

  static Future<void> refresh() async {
    String? token = await SessionHelper.token;
    if (token == null) {
      reset();
      return;
    }
    var data = await ApiHelper.get('/notifications');
    if (data is! List) return;
    List<AppNotification> list = data
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromMap)
        .toList();
    unread.value = list.where((p) => !p.isRead).length;
    int maxId = 0;
    for (AppNotification item in list) {
      if (item.id > maxId) maxId = item.id;
    }
    if (_lastId >= 0) {
      var news = list
          .where((p) => p.id > _lastId && !p.isRead)
          .toList()
          .reversed;
      for (AppNotification item in news) {
        await NotificationService.show(item.id, item.title, item.content);
      }
    }
    _lastId = maxId;
  }

  static void reset() {
    _lastId = -1;
    unread.value = 0;
  }

  static Future<int> markRead(int id) async {
    int ret = ApiHelper.toInt(
      await ApiHelper.put('/notifications/$id/read', {}),
    );
    await refresh();
    return ret;
  }

  static Future<int> markAllRead() async {
    int ret = ApiHelper.toInt(
      await ApiHelper.put('/notifications/read-all', {}),
    );
    await refresh();
    return ret;
  }

  static Future<int> clear() async {
    int ret = ApiHelper.toInt(await ApiHelper.delete('/notifications'));
    await refresh();
    return ret;
  }
}
