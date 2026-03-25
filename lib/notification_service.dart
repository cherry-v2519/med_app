import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Function(String action, String payload)? onAction;

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final action = response.actionId ?? "";
        final payload = response.payload ?? "";

        if (action.isNotEmpty) {
          onAction?.call(action, payload);
        }
      },
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future showNotification(
    String title,
    String body, {
    String payload = "",
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'med_channel',
      'Medicine Reminder',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      actions: [
        AndroidNotificationAction('taken', 'Taken'),
        AndroidNotificationAction('snooze', 'Remind 2 min'),
      ],
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future cancelAll() async {
    await _notifications.cancelAll();
  }
}