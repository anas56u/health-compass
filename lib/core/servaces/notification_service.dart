import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // تأكد من إضافة هذه المكتبة
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

Future<void> init() async {
    tz.initializeTimeZones();

    try {
      // التعديل هنا: الإصدار الجديد يرجع كائن TimezoneInfo، ونحن نأخذ منه الـ identifier
      final String timeZoneName = await FlutterTimezone.getLocalTimezone()
          .then((info) => info.identifier); 
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ Timezone set to Device Location: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Failed to get device timezone. Setting to Amman. Error: $e");
      // في حال الفشل، نضع توقيت عمان (أو أي توقيت افتراضي تريده)
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    // ... (باقي كود الدالة كما هو تماماً دون تغيير)
    const AndroidInitializationSettings initializationSettingsAndroid =
AndroidInitializationSettings('@drawable/notification_icon');
    
    // ... الخ

    // إعدادات iOS
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

    // طلب الإذن (للأندرويد 13+)
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
    debugPrint("Attempting to schedule reminder: $title at $time");
    
    await requestExactAlarmsPermission();

    for (int day in days) {
      try {
        final scheduledTime = _nextInstanceOfDayAndTime(day, time);
        debugPrint("📅 Scheduling for day: $day at: $scheduledTime (Local Time)");

        await _scheduleForDay(id, day, time, title, body);
        
        // التكرارات المزعجة (بعد 5 و 10 دقائق)
        await _scheduleForDay(id + 1000, day, time.add(const Duration(minutes: 5)), "تذكير: $title", "تنبيه 1: لم تقم بالمهمة!");
        await _scheduleForDay(id + 2000, day, time.add(const Duration(minutes: 10)), "تذكير: $title", "تنبيه 2: لا تنسَ صحتك!");
        
        debugPrint("✅ Schedule Successful for day $day");
      } catch (e) {
        debugPrint("❌ ERROR Scheduling: $e");
      }
    }
  }
  
  Future<void> _scheduleForDay(int baseId, int day, DateTime time, String title, String? body) async {
     // تم حذف المتغير uiLocalNotificationDateInterpretation لأنه لم يعد موجوداً في الإصدار الجديد
     await flutterLocalNotificationsPlugin.zonedSchedule(
        baseId + (day * 100),
        title,
        body,
        _nextInstanceOfDayAndTime(day, time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel_id_v3', // قمنا بتحديث الـ ID للقناة
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
    // استخدام التوقيت المحلي (الذي تم ضبطه في init ليكون عمان أو غيرها)
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
        debugPrint("User Selected: ${time.hour}:${time.minute}");
debugPrint("Scheduled TZ Time: $scheduledDate");
debugPrint("Current TZ Time: $now");
        
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}