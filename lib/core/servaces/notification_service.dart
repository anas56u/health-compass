// ------------------ NotificationService ------------------
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    debugPrint("🔥 NotificationService INIT CALLED");

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminders_channel_id_v2',
      'Reminders Notifications',
      description: 'Important reminders channel',
      importance: Importance.max,
    );



    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    tz.initializeTimeZones();

    try {
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone().then((info) => info.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ Timezone set to Device Location: $timeZoneName");
    } catch (e) {
      debugPrint(
          "⚠️ Failed to get device timezone. Setting to Amman. Error: $e");
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification Clicked: ${response.payload}");
      },
      
    );

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleAnnoyingReminder({
    required int id,
    required String title,
    required String? body,
    required DateTime time,
    required List<int> days,
  }) async {
    await requestExactAlarmsPermission();

    for (int day in days) {
      final scheduledTime = _nextInstanceOfDayAndTime(day, time);
      debugPrint("📅 Scheduling for day: $day at: $scheduledTime");

      await _scheduleForDay(id, day, time, title, body);

      await _scheduleForDay(
          id + 1000, day, time.add(const Duration(minutes: 5)), "تذكير: $title", "تنبيه 1: لم تقم بالمهمة!");
      await _scheduleForDay(
          id + 2000, day, time.add(const Duration(minutes: 10)), "تذكير: $title", "تنبيه 2: لا تنسَ صحتك!");
    }
  }

  Future<void> _scheduleForDay(
      int baseId, int day, DateTime time, String title, String? body) async {
        final scheduledDate = _nextInstanceOfDayAndTime(day, time);
    
    debugPrint("🔔 تمت الجدولة: ID=$baseId | اليوم=$day | التاريخ والموعد=${scheduledDate.toString()}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      baseId + (day * 100),
      title,
      body,
      _nextInstanceOfDayAndTime(day, time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel_id_v2',
          'Reminders Notifications',
          channelDescription: 'Important reminders channel',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, DateTime time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
