import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 إضافة
import 'package:firebase_auth/firebase_auth.dart';     // 👈 إضافة
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:health_compass/core/widgets/EmergencyScreen.dart';
import 'package:health_compass/main.dart';
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
    // 1. تهيئة Timezone (آمن في الخلفية)
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone().then((info) => info.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    // 2. إنشاء قنوات الإشعارات (ضروري جداً للأندرويد لكي يظهر الإشعار)
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

    // نستخدم الـ Implementation الخاص بالأندرويد لإنشاء القنوات
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(remindersChannel);
    await androidImplementation?.createNotificationChannel(chatChannel);

    // 3. إعدادات التهيئة (Init Settings)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ⚠️ تعديل هام: نضبط هذه القيم على false لمنع الطلب التلقائي في iOS
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

    // 4. تهيئة البلاجن (Initialize Plugin)
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'emergency') {
          // التوجيه لشاشة الطوارئ
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const EmergencyScreen(
                message: "تم رصد حالة حرجة في الخلفية",
                value: 150,
              ),
            ),
          );
        }
      },
    );

    // 5. 🔥🔥🔥 منطقة الخطر: طلب الأذونات 🔥🔥🔥
    // لن يتم تنفيذ هذا الكود إذا كنا في الخلفية (requestPermission = false)
    if (requestPermission) {
      debugPrint("🔔 Requesting Permissions (Foreground Mode)...");
      
      // أ) طلب إذن Firebase
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted Firebase permission');
      }

      // ب) طلب إذن Local Notifications للأندرويد 13+
      if (Platform.isAndroid) {
        await androidImplementation?.requestNotificationsPermission();
      }
      
      // ج) طلب إذن iOS يدوياً
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

    // 6. التعامل مع التوكن والرسائل (آمن)
    // نضع حفظ التوكن داخل try-catch لتجنب أي مشاكل اتصال
    try {
      await _saveTokenToDatabase();
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(token: newToken);
      });
    } catch (e) {
      debugPrint("⚠️ Token setup warning: $e");
    }

    // 7. الاستماع للرسائل
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

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  Future<void> showCriticalAlert() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel_01', // ID مختلف للطوارئ
      'Critical Alerts',      // اسم القناة
      channelDescription: 'Used for critical health alerts',
      importance: Importance.max, // أقصى أهمية (يصدر صوت ويظهر فوق التطبيقات)
      priority: Priority.max,     // أقصى أولوية
      ticker: 'تنبيه صحي حرج!',
      
      // 🔥🔥🔥 هذا هو السطر السحري 🔥🔥🔥
      fullScreenIntent: true, 
      
      // خصائص التنبيه
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm, // يعامل كمنبه
      visibility: NotificationVisibility.public, // يظهر حتى والشاشة مقفلة
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      999, // ID ثابت للإشعار
      'خطر صحي!', 
      'تم رصد مؤشرات حيوية غير طبيعية. اضغط للمساعدة.',
      platformChannelSpecifics,
      payload: 'emergency', // سنستخدم هذا للتوجيه
    );
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