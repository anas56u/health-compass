import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  /// دالة لجدولة تذكير الدواء
  Future<void> scheduleMedicationReminder({
    required int id, // notificationId من الموديل
    required String title,
    required String body,
    required TimeOfDay time, // وقت الدواء
    required List<int> days, // أيام الأسبوع (1 = الاثنين ... 7 = الأحد)
  }) async {
    // التأكد من الصلاحيات (Android 12+)
    await requestExactAlarmsPermission();

    // تحويل TimeOfDay إلى DateTime لغايات الجدولة
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // المرور على الأيام المختارة وجدولة إشعار لكل يوم
    for (int day in days) {
      // ملاحظة: DateTime في فلاتر يعتبر (1 = الاثنين) و (7 = الأحد)
      // تأكد أن List<int> days القادمة من الموديل متوافقة مع هذا الترتيب
      // في الكود الحالي لديك يبدو أنك تستخدم index القائمة (0-6)، سنحتاج لضبط ذلك.
      
      // flutter_local_notifications يستخدم 1 للاثنين وتصل لـ 7 للأحد
      // إذا كانت مصفوفة الأيام لديك تبدأ من 0 للأحد، يجب عمل mapping
      int notificationDay = day; 
      
      // نقوم بتوليد ID فريد لكل يوم بناءً على ID الدواء الأصلي
      // مثلاً: الدواء رقم 55، يوم الاثنين (1) يصبح رقمه 5501
      // هذا يمنع تضارب الـ IDs
      final int uniqueNotificationId = int.parse("$id$day");

     

      await _scheduleForDay(
        uniqueNotificationId, 
        day, // اليوم المستهدف
        scheduleTime, 
        title, 
        body
      );
    }
  }

  Future<void> cancelMedicationReminders(int id, List<int> days) async {
    for (int day in days) {
       final int uniqueNotificationId = int.parse("$id$day");
       await flutterLocalNotificationsPlugin.cancel(uniqueNotificationId);
    }
    debugPrint("🗑️ تم حذف جميع تذكيرات الدواء رقم: $id");
  }

  Future<void> cancelTodayAnnoyance(int baseId, int day) async {
    final id1 = (baseId + 1000) + (day * 100); 
    final id2 = (baseId + 2000) + (day * 100); 

    await flutterLocalNotificationsPlugin.cancel(id1);
    await flutterLocalNotificationsPlugin.cancel(id2);
    
    debugPrint("🛑 تم إيقاف الإشعارات المزعجة لهذا اليوم (IDs: $id1, $id2)");
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
  Future<void> cancelAnnoyingReminder(int id, List<int> days) async {
    for (int day in days) {
      // 1. حساب الـ IDs بنفس معادلة الإنشاء بالضبط
      final List<int> idsToCancel = [
        id + (day * 100),          // ID التذكير الأساسي
        (id + 1000) + (day * 100), // ID التنبيه الأول
        (id + 2000) + (day * 100), // ID التنبيه الثاني
      ];

      // 2. المرور عليهم وحذفهم جميعاً
      for (var finalId in idsToCancel) {
        await flutterLocalNotificationsPlugin.cancel(finalId);
        debugPrint("🗑 تم حذف الإشعار المجدول رقم: $finalId");
      }
    }
  }
}
