import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    // v21 방식
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );

    // Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fridge_channel',
          '유통기한 알림',
          channelDescription: '유통기한 알림 채널',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),

      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,

      // v21에서 required
      matchDateTimeComponents: null,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'timer_channel',
        '타이머 알림',
        channelDescription: '타이머 알림 채널',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}