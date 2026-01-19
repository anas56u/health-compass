import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:health_compass/core/widgets/EmergencyScreen.dart';
import 'package:health_compass/main.dart'; // تأكد أن الـ navigatorKey متاح هنا
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

  Future<void> init({bool requestPermission = true}) async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone().then((info) => info.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
      'reminders_channel_id_v2',
      'Reminders Notifications',
      description: 'Important reminders channel',
      importance: Importance.max,
    );

    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_channel_id',
      'Chat Notifications',
      description: 'Notifications for new messages',
      importance: Importance.max,
      playSound: true,
    );

    // قناة الطوارئ - حرجة جداً
    const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_channel_01', 
      'Critical Alerts',
      description: 'Used for critical health alerts',
      importance: Importance.max, // High importance for full screen intent
      playSound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(remindersChannel);
    await androidImplementation?.createNotificationChannel(chatChannel);
    await androidImplementation?.createNotificationChannel(emergencyChannel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    if (requestPermission) {
      debugPrint("🔔 Requesting Permissions (Foreground Mode)...");
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Critical alerts usually need request
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted Firebase permission');
      }

      if (Platform.isAndroid) {
        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      }
      
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    }

    try {
      await _saveTokenToDatabase();
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(token: newToken);
      });
    } catch (e) {
      debugPrint("⚠️ Token setup warning: $e");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'رسالة جديدة',
          body: message.notification!.body ?? '',
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // ✅ دالة معالجة الضغط على الإشعار لفتح الشاشة
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.contains('emergency')) {
      // استخراج القيمة من الـ payload: example: "emergency_150.0"
      final parts = response.payload!.split('_');
      double value = 0.0;
      if (parts.length > 1) {
        value = double.tryParse(parts[1]) ?? 0.0;
      }

      // التأكد من أن التوجيه يتم في الـ Main Thread
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => EmergencyScreen(
              message: "تنبيه: تم رصد مؤشر حيوي خطير!",
              value: value,
            ),
          ),
          (route) => false, // إزالة كل الشاشات السابقة للتركيز على الطوارئ
        );
      }
    }
  }

  // 🔥 الدالة المعدلة لإطلاق إنذار الطوارئ
  Future<void> showCriticalAlert({
    required String title, 
    required String body, 
    required double detectedValue
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel_01', 
      'Critical Alerts',
      channelDescription: 'Used for critical health alerts',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'تنبيه صحي حرج!',
      
      // ✅ تفعيل الظهور الكامل فوق شاشة القفل
      fullScreenIntent: true,
      
      // خصائص التنبيه
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      
      // جعل الإشعار يستمر ولا يختفي بسهولة
      ongoing: true,
      autoCancel: false,
      
      // إضافة أزرار للإشعار تظهر على الشاشة
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_app', 
          'فتح التطبيق حالاً',
          showsUserInterface: true, // هذا يفتح التطبيق عند الضغط
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      999,
      title, 
      body,
      platformChannelSpecifics,
      payload: 'emergency_$detectedValue', // تمرير القيمة في الـ Payload
    );
  }

  Future<void> _saveTokenToDatabase({String? token}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final fcmToken = token ?? await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      debugPrint("❌ Error saving token: $e");
    }
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/notification_icon',
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

  // ... (باقي الدوال كما هي)
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