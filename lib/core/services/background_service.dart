import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:health_compass/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
// 1. استيراد مكتبة الـ Intent
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', 
    'Health Compass Service', 
    description: 'Service is running in background',
    importance: Importance.low, 
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Health Compass يعمل',
      initialNotificationContent: 'مراقبة المؤشرات الحيوية نشطة',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // ignore
  }

  final notificationService = NotificationService();
  // لا نطلب الأذونات هنا لأننا في الخلفية
  await notificationService.init(requestPermission: false);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  debugPrint("🚀 خدمة المراقبة الشاملة بدأت...");

  final Health health = Health(); 

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        try {
          var types = [
            HealthDataType.HEART_RATE,
            HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
            HealthDataType.BLOOD_GLUCOSE,
          ];
          
          final now = DateTime.now();
          final earlier = now.subtract(const Duration(minutes: 2)); 

          // محاولة جلب البيانات
          List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
            startTime: earlier,
            endTime: now, 
            types: types,
          );

          healthData = health.removeDuplicates(healthData);

          if (healthData.isNotEmpty) {
            String statusText = "الوضع مستقر";
            bool dangerDetected = false;
            String dangerTitle = "";
            String dangerBody = "";
            double criticalValue = 0.0;

            for (var point in healthData) {
              double value = 0.0;
              if (point.value is NumericHealthValue) {
                 value = (point.value as NumericHealthValue).numericValue.toDouble();
              } else {
                 value = double.tryParse(point.value.toString()) ?? 0.0;
              }

              // --- تسارع القلب ---
              if (point.type == HealthDataType.HEART_RATE) {
                if (value > 120) {
                  dangerDetected = true;
                  dangerTitle = "خطر: تسارع شديد في القلب!";
                  dangerBody = "نبضات القلب وصلت إلى $value bpm. يرجى التوقف للراحة.";
                  criticalValue = value;
                  statusText = dangerTitle;
                }
              }
              // --- ارتفاع ضغط الدم ---
              else if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
                if (value > 160) {
                  dangerDetected = true;
                  dangerTitle = "خطر: ارتفاع ضغط الدم!";
                  dangerBody = "الضغط الانقباضي وصل إلى $value mmHg.";
                  criticalValue = value;
                  statusText = dangerTitle;
                }
              }
              // --- السكري ---
              else if (point.type == HealthDataType.BLOOD_GLUCOSE) {
                if (value > 300 || value < 70) {
                  dangerDetected = true;
                  dangerTitle = "خطر: مستوى السكر حرج!";
                  dangerBody = "مستوى الجلوكوز $value. يرجى اتخاذ إجراء فوري.";
                  criticalValue = value;
                  statusText = dangerTitle;
                }
              }
            }

            service.setForegroundNotificationInfo(
              title: "Health Compass: مراقبة نشطة",
              content: statusText,
            );

            if (dangerDetected) {
               debugPrint("🚨 CRITICAL DETECTED: $criticalValue - FORCE OPENING APP");
               
               // 1. إظهار الإشعار (للصوت والاهتزاز)
               await notificationService.showCriticalAlert(
                 title: dangerTitle,
                 body: dangerBody,
                 detectedValue: criticalValue
               );

               // 2. 🔥 الحل الجذري: إجبار التطبيق على الفتح 🔥
               AndroidIntent intent = const AndroidIntent(
                 action: 'android.intent.action.MAIN',
                 // لقد تأكدت من اسم الباكيج من ملفاتك المرفقة وهو صحيح
                 package: 'com.example.health_compass', 
                 componentName: 'com.example.health_compass.MainActivity',
                 category: 'android.intent.category.LAUNCHER',
                 flags: [
                   Flag.FLAG_ACTIVITY_NEW_TASK, // يفتح مهمة جديدة
                   Flag.FLAG_ACTIVITY_REORDER_TO_FRONT, // يجلبه للأمام إذا كان مفتوحاً
                   Flag.FLAG_ACTIVITY_SINGLE_TOP, // لا يكرر الشاشة
                   Flag.FLAG_ACTIVITY_CLEAR_TOP, // ينظف الستاك القديم
                 ],
                 arguments: <String, dynamic>{
                   'from_background': true, // مؤشر يمكن التقاطه لاحقاً
                 },
               );
               
               await intent.launch();
            }

          } 
        } catch (e) {
          debugPrint("❌ Background Service Error: $e");
        }
      }
    }
  });
}