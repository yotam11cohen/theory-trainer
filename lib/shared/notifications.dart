import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationScheduler {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static DateTime? _lastScheduledDate;
  static DateTime? _lastScheduledFor;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static int daysSinceActive(DateTime lastActive) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate =
        DateTime(lastActive.year, lastActive.month, lastActive.day);
    return todayDate.difference(lastDate).inDays;
  }

  static Future<void> scheduleRemindersIfNeeded(DateTime? lastActive) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (_lastScheduledDate == todayDate && _lastScheduledFor == lastActive) return;
    _lastScheduledDate = todayDate;
    _lastScheduledFor = lastActive;
    await _plugin.cancelAll();
    if (lastActive == null) return;
    final days = daysSinceActive(lastActive);
    if (days >= 7) {
      await _schedule(
        id: 2,
        title: 'קלירד — תאוריה',
        body: 'זכור מה למדת? חזרה קצרה תעזור!',
        daysFromNow: 1,
      );
    } else if (days >= 1) {
      await _schedule(
        id: 1,
        title: 'קלירד — תאוריה',
        body: 'יום ללא לימוד — בוא נמשיך!',
        daysFromNow: 1,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int daysFromNow,
  }) async {
    final when = DateTime.now().add(Duration(days: daysFromNow, hours: 9));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _toTZDateTime(when),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'cleared_reminders',
          'Study Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static tz.TZDateTime _toTZDateTime(DateTime dt) =>
      tz.TZDateTime.from(dt, tz.local);
}
