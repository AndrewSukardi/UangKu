import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(android: androidSettings);

    await plugin.initialize(settings: settings);

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showTestNotification() async {
    const details = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
     

    await plugin.show(
      id: 0, //DateTime.now().millisecondsSinceEpoch ~/ 1000
      title: 'Hello Flutter 👋',
      body: 'This is a test notification',
      notificationDetails: const NotificationDetails(android: details),
    );
  }
}
