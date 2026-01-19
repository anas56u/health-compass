import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:health_compass/core/services/notification_service.dart';

// 👇 1. إضافة استيراد Firebase والخيارات (تأكد من صحة المسار)
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart'; 

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
      initialNotificationTitle: 'تطبيق Health Compass يعمل',
      initialNotificationContent: 'يتم مراقبة حالتك الصحية',
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

  debugPrint("🚀 خدمة المراقبة الشاملة (قلب، ضغط، سكري) بدأت...");

  final Health health = Health(); 

  // المؤقت يعمل كل دقيقة
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        
        try {
          // 1. تحديد البيانات المطلوبة (قلب، ضغط انقباضي، سكري)
          var types = [
            HealthDataType.HEART_RATE,
            HealthDataType.BLOOD_PRESSURE_SYSTOLIC, // الضغط العالي هو الأخطر عادة في الطوارئ
            HealthDataType.BLOOD_GLUCOSE,
          ];
          
          final now = DateTime.now();
          final earlier = now.subtract(const Duration(minutes: 5));

          // 2. جلب البيانات
          List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
            startTime: earlier,
            endTime: now, 
            types: types,
          );

          healthData = health.removeDuplicates(healthData);

          if (healthData.isNotEmpty) {
            
            // متغيرات لتخزين آخر القيم (للعرض في الإشعار)
            String statusText = "الوضع مستقر";
            bool dangerDetected = false;

            // 3. فحص كل قراءة وتحديد الخطر
            for (var point in healthData) {
              double value = 0.0;
              
              // استخراج القيمة الرقمية
              if (point.value is NumericHealthValue) {
                 value = (point.value as NumericHealthValue).numericValue.toDouble();
              } else {
                 value = double.tryParse(point.value.toString()) ?? 0.0;
              }

              // --- منطق فحص القلب ---
              if (point.type == HealthDataType.HEART_RATE) {
                debugPrint("💓 HR: $value");
                if (value > 120) { // حد الخطر للقلب
                  dangerDetected = true;
                  statusText = "خطر: تسارع نبضات القلب ($value)";
                }
              }
              
              // --- منطق فحص الضغط (Systolic) ---
              else if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
                debugPrint("🩸 BP: $value");
                if (value > 140) { // حد الخطر للضغط (140 يعتبر مرتفع)
                  dangerDetected = true;
                  statusText = "خطر: ضغط دم مرتفع جداً ($value)";
                }
              }

              // --- منطق فحص السكري ---
              else if (point.type == HealthDataType.BLOOD_GLUCOSE) {
                debugPrint("🍬 Glucose: $value");
                // ملاحظة: وحدة القياس تعتمد على المصدر (mg/dL أو mmol/L)
                // هنا نفترض mg/dL (الشائع في الأجهزة)
                if (value > 300 || value < 70) { // سكري مرتفع جداً أو هبوط حاد
                  dangerDetected = true;
                  statusText = "خطر: مستوى السكر غير طبيعي ($value)";
                }
              }
            }

            // تحديث الإشعار الثابت
            service.setForegroundNotificationInfo(
              title: "Health Compass: مراقبة نشطة",
              content: statusText,
            );

            // 🔥 إطلاق الإنذار إذا وجد خطر في أي منهم 🔥
            if (dangerDetected) {
               debugPrint("🚨 CRITICAL HEALTH VALUE DETECTED - ALERTING 🚨");
               await notificationService.showCriticalAlert();
            }

          } else {
            debugPrint("⚠️ لا توجد بيانات حديثة (آخر 5 دقائق)");
          }

        } catch (e) {
          debugPrint("❌ Error reading health data: $e");
        }
      }
    }
  });
}