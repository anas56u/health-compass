import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 إضافة
import 'package:firebase_auth/firebase_auth.dart';     // 👈 إضافة
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. طلب الإذن
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // 🔥🔥🔥 خطوة جديدة هامة جداً: حفظ التوكن عند فتح التطبيق 🔥🔥🔥
    await _saveTokenToDatabase();

    // الاستماع لتحديثات التوكن (في حال تغير التوكن أثناء عمل التطبيق)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(token: newToken);
    });

    // 2. إعداد معالجة الرسائل القادمة والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'رسالة جديدة',
          body: message.notification!.body ?? '',
        );
      }
    });

    // 3. إعداد معالجة الرسائل في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. إنشاء قنوات الإشعارات
    const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
      'reminders_channel_id_v2',
      'Reminders Notifications',
      description: 'Important reminders channel',
      importance: Importance.max,
    );

    // قناة الدردشة
    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_channel_id', 
      'Chat Notifications',
      description: 'Notifications for new messages',
      importance: Importance.max,
      playSound: true, // تأكد من تفعيل الصوت
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(chatChannel); // إنشاء القناة الثانية

    // تهيئة Timezone
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone().then((info) => info.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    // إعدادات التهيئة
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

  // 🔥 دالة حفظ التوكن الجديدة
  Future<void> _saveTokenToDatabase({String? token}) async {
    try {
      // 1. الحصول على المستخدم الحالي
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 2. الحصول على التوكن (إما الممرر أو جلبه من فايربيز)
      final fcmToken = token ?? await _firebaseMessaging.getToken();
      
      if (fcmToken != null) {
        // 3. تحديث قاعدة البيانات
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
        debugPrint("✅ Token updated successfully for user: ${user.uid}");
      }
    } catch (e) {
      debugPrint("❌ Error saving token: $e");
    }
  }

  // دالة عرض الإشعار
  Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel_id', // نفس الـ ID المعرف في الأعلى
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/notification_icon', // تأكد من وجود الأيقونة
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  // ... (باقي دوال الجدولة scheduleAnnoyingReminder وغيرها تبقى كما هي)
  Future<void> scheduleAnnoyingReminder({
    required int id,
    required String title,
    required String? body,
    required DateTime time,
    required List<int> days,
  }) async {
    await requestExactAlarmsPermission();
    for (int day in days) {
      await _scheduleForDay(id, day, time, title, body);
      await _scheduleForDay(
          id + 1000, day, time.add(const Duration(minutes: 5)), "تذكير: $title", "تنبيه 1: لم تقم بالمهمة!");
      await _scheduleForDay(
          id + 2000, day, time.add(const Duration(minutes: 10)), "تذكير: $title", "تنبيه 2: لا تنسَ صحتك!");
    }
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> days,
  }) async {
    await requestExactAlarmsPermission();
    final now = DateTime.now();
    final scheduleTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    for (int day in days) {
      final int uniqueNotificationId = int.parse("$id$day");
      await _scheduleForDay(uniqueNotificationId, day, scheduleTime, title, body);
    }
  }

  Future<void> cancelMedicationReminders(int id, List<int> days) async {
    for (int day in days) {
       final int uniqueNotificationId = int.parse("$id$day");
       await flutterLocalNotificationsPlugin.cancel(uniqueNotificationId);
    }
  }

  Future<void> cancelTodayAnnoyance(int baseId, int day) async {
    final id1 = (baseId + 1000) + (day * 100); 
    final id2 = (baseId + 2000) + (day * 100); 
    await flutterLocalNotificationsPlugin.cancel(id1);
    await flutterLocalNotificationsPlugin.cancel(id2);
  }

  Future<void> cancelAnnoyingReminder(int id, List<int> days) async {
    for (int day in days) {
      final List<int> idsToCancel = [
        id + (day * 100),          
        (id + 1000) + (day * 100), 
        (id + 2000) + (day * 100), 
      ];
      for (var finalId in idsToCancel) {
        await flutterLocalNotificationsPlugin.cancel(finalId);
      }
    }
  }

  Future<void> _scheduleForDay(
      int baseId, int day, DateTime time, String title, String? body) async {
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
}