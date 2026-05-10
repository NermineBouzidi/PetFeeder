import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'schedule_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    // Set your local timezone — change to your actual timezone string
    // Full list: https://pub.dev/documentation/timezone/latest/
    tz.setLocalLocation(tz.getLocation('Africa/Tunis'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermission() async {
    // Android: request notification + exact alarm permissions
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission(); // v17 correct method
      await androidImpl.requestExactAlarmsPermission();   // needed on Android 12+
    }

    // iOS: permissions are requested automatically via DarwinInitializationSettings
  }

  // Call this whenever a schedule is created, updated, toggled, or deleted
  Future<void> rescheduleForSchedule(ScheduleModel s) async {
    if (s.id == null) return;

    // Always cancel existing notifications for this schedule first
    await _cancelForSchedule(s.id!);

    // If paused or no days selected, stop here
    if (!s.isActive || s.days.isEmpty) return;

    for (final day in s.days) {
      // 1️⃣ Upcoming reminder — 5 minutes before feeding
      final reminderMinute = s.time.minute < 5
          ? s.time.minute + 55
          : s.time.minute - 5;
      final reminderHourAdjust = s.time.minute < 5 ? -1 : 0;

      await _scheduleWeekly(
        id: _notifId(s.id!, day, isReminder: true),
        title: '🐾 Feeding soon — ${s.label}',
        body: '${s.grams}g scheduled in 5 minutes',
        weekday: _toTzWeekday(day),
        hour: s.time.hour + reminderHourAdjust,
        minute: reminderMinute,
      );

      // 2️⃣ Delivery confirmation — at exact feeding time
      await _scheduleWeekly(
        id: _notifId(s.id!, day, isReminder: false),
        title: '✅ Whisker fed — ${s.label}',
        body: '${s.grams}g delivered on time!',
        weekday: _toTzWeekday(day),
        hour: s.time.hour,
        minute: s.time.minute,
      );
    }
  }

  Future<void> cancelAllForSchedule(int scheduleId) async {
    await _cancelForSchedule(scheduleId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<void> _cancelForSchedule(int scheduleId) async {
    // Each schedule: up to 7 days × 2 notif types = 14 notifications
    for (int day = 0; day < 7; day++) {
      await _plugin.cancel(_notifId(scheduleId, day, isReminder: true));
      await _plugin.cancel(_notifId(scheduleId, day, isReminder: false));
    }
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // tz ISO weekday: Mon=1 … Sun=7
    required int hour,
    required int minute,
  }) async {
    // Clamp hour in case of midnight rollover (e.g. 00:03 reminder → hour=-1 → 23)
    final adjustedHour = hour < 0 ? 23 : (hour > 23 ? 0 : hour);

    final now = tz.TZDateTime.now(tz.local);

    // Start from today at the scheduled time
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      adjustedHour,
      minute,
    );

    // Advance day by day until we hit the right weekday AND it's in the future
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'whisker_feeding',           // channel id
      'Feeding Schedules',         // channel name
      channelDescription: 'Upcoming and delivered feeding reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // repeat weekly
    );
  }

  // Produces a unique stable int ID per schedule+day+type combination
  // scheduleId * 100 + day * 2 + (0 for reminder, 1 for delivered)
  // Works as long as scheduleId < 1000 (safe for typical use)
  int _notifId(int scheduleId, int day, {required bool isReminder}) =>
      scheduleId * 100 + day * 2 + (isReminder ? 0 : 1);

  // Convert JS weekday (0=Sun … 6=Sat) to tz ISO weekday (1=Mon … 7=Sun)
  int _toTzWeekday(int jsDay) => jsDay == 0 ? 7 : jsDay;
}