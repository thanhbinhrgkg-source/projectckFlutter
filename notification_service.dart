import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'khao_sat_dn',
      'Khảo sát doanh nghiệp',
      channelDescription: 'Thông báo đơn hàng, khảo sát và tài khoản',
      importance: Importance.max,
      priority: Priority.high,
    ),
    windows: WindowsNotificationDetails(),
  );

  static Future<void> init() async {
    try {
      await _plugin.initialize(
        settings: InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          windows: WindowsInitializationSettings(
            appName: 'Khảo Sát Doanh Nghiệp',
            appUserModelId: 'ProjectCK.KhaoSatDoanhNghiep',
            guid: 'a3f1c2d4-5b6e-4f70-8a91-b2c3d4e5f601',
          ),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  static Future<void> show(int id, String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('Notification show error: $e');
    }
  }
}
