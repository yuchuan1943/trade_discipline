import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 每日定时提醒（本地通知）。仅 Android 支持，web 调试时为 no-op。
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool get _supported => !kIsWeb;

  static Future<void> init() async {
    if (!_supported) return;
    tz_data.initializeTimeZones();
    await _setLocalLocation();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> _setLocalLocation() async {
    String tzName = 'Asia/Shanghai';
    try {
      tzName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      // 回退默认时区
    }
    try {
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    }
  }

  static Future<void> requestPermissions() async {
    if (!_supported) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyReminder(int hour, int minute) async {
    await cancelDailyReminder();
    if (!_supported) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_quiz_reminder',
        '每日交易复盘提醒',
        channelDescription: '每天提醒进行交易守则问答',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      0,
      '交易复盘时间到',
      '花几分钟完成今日交易守则问答吧',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    if (!_supported) return;
    await _plugin.cancel(0);
  }
}
