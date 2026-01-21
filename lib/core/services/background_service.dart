import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:health_compass/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      initialNotificationTitle: 'Health Compass',
      initialNotificationContent: 'مراقبة المؤشرات الحيوية نشطة...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );

  await service.startService();
}

Future<void> _sendDebugLog(String message) async {
  // دالة اختيارية لإرسال Logs، يمكنك إيقافها لاحقاً لتقليل الإزعاج
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'debug_logs_channel',
    'Debug Logs',
    importance: Importance.min,
    priority: Priority.min,
    playSound: false, 
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    'System Log 🛠️',
    message,
    const NotificationDetails(android: androidDetails),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (Firebase.apps.isEmpty) { // تجنب التهيئة المكررة
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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

  debugPrint("🚀 خدمة المراقبة الحقيقية بدأت...");
  
  final Health health = Health();

  // فحص كل دقيقة (مدة مناسبة للحفاظ على البطارية ومراقبة الصحة)
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        try {
          // ====================================================
          // 🟢 وضع البيانات الحقيقية (REAL DATA MODE) 🟢
          // ====================================================
          
          bool dangerDetected = false;
          String dangerTitle = "";
          String dangerBody = "";
          double criticalValue = 0.0;

          // أنواع البيانات المطلوب مراقبتها
          var types = [
            HealthDataType.HEART_RATE,
            HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
            HealthDataType.BLOOD_GLUCOSE,
          ];
          
          final now = DateTime.now();
          // نعود 15 دقيقة للوراء لضمان التقاط أي قراءة حديثة تمت مزامنتها
          final earlier = now.subtract(const Duration(minutes: 15)); 

          // محاولة جلب البيانات من Google Fit / Health Connect
          // ملاحظة: يجب أن يكون المستخدم قد منح أذونات Health مسبقاً داخل التطبيق
          List<HealthDataPoint> healthData = [];
          try {
            healthData = await health.getHealthDataFromTypes(
              startTime: earlier,
              endTime: now, 
              types: types,
            );
            // إزالة التكرار
            healthData = health.removeDuplicates(healthData);
          } catch (e) {
            debugPrint("⚠️ تعذر جلب البيانات الصحية: $e");
            // لن نرسل إشعار خطأ للمستخدم لكي لا نزعجه، فقط Console
          }

          if (healthData.isNotEmpty) {
            debugPrint("📊 تم العثور على ${healthData.length} قراءة حديثة");

            // تحليل البيانات
            for (var point in healthData) {
              double value = 0.0;
              
              if (point.value is NumericHealthValue) {
                 value = (point.value as NumericHealthValue).numericValue.toDouble();
              } else {
                 // محاولة تحويل احتياطية
                 value = double.tryParse(point.value.toString()) ?? 0.0;
              }

              debugPrint("فحص القيمة: ${point.typeString} = $value");

              // 1. فحص القلب (Heart Rate)
              if (point.type == HealthDataType.HEART_RATE) {
                if (value > 120) { // الحد الخطر
                  dangerDetected = true;
                  dangerTitle = "خطر: تسارع نبضات القلب!";
                  dangerBody = "نبضات القلب وصلت إلى ${value.toInt()} bpm. يرجى الراحة فوراً.";
                  criticalValue = value;
                  break; // وجدنا خطراً، نتوقف عن الفحص لإطلاق الإنذار
                }
              }
              // 2. فحص ضغط الدم (Blood Pressure)
              else if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
                if (value > 160) { // الحد الخطر
                  dangerDetected = true;
                  dangerTitle = "خطر: ارتفاع ضغط الدم!";
                  dangerBody = "الضغط الانقباضي مرتفع جداً (${value.toInt()} mmHg).";
                  criticalValue = value;
                  break;
                }
              }
              // 3. فحص السكري (Blood Glucose)
              else if (point.type == HealthDataType.BLOOD_GLUCOSE) {
                // القيم تعتمد على الوحدة (mg/dL أو mmol/L)، نفترض هنا mg/dL
                if (value > 300 || value < 70) { 
                  dangerDetected = true;
                  dangerTitle = "خطر: اضطراب سكر الدم!";
                  dangerBody = "مستوى السكر وصل إلى $value. يرجى اتخاذ إجراء.";
                  criticalValue = value;
                  break;
                }
              }
            }
          } else {
            debugPrint("📭 لا توجد بيانات صحية جديدة في آخر 15 دقيقة");
          }

          // إذا تم اكتشاف خطر حقيقي
          if (dangerDetected) {
             debugPrint("🚨 حالة طوارئ حقيقية! القيمة: $criticalValue");
             
             // 1. 💾 تسجيل حالة الطوارئ في الذاكرة (مهم جداً لـ main.dart)
             final prefs = await SharedPreferences.getInstance();
             await prefs.setBool('is_emergency_active', true);
             await prefs.setDouble('emergency_value', criticalValue);

             // 2. 🔊 إطلاق الصوت والإشعار
             await notificationService.showCriticalAlert(
               title: dangerTitle,
               body: dangerBody,
               detectedValue: criticalValue
             );

             // 3. ⚡ إجبار التطبيق على الفتح (Android Intent)
             try {
               AndroidIntent intent = const AndroidIntent(
                 action: 'android.intent.action.MAIN',
                 package: 'com.example.health_compass', 
                 componentName: 'com.example.health_compass.MainActivity',
                 category: 'android.intent.category.LAUNCHER',
                 flags: [
                   Flag.FLAG_ACTIVITY_NEW_TASK,
                   Flag.FLAG_ACTIVITY_REORDER_TO_FRONT,
                   Flag.FLAG_ACTIVITY_SINGLE_TOP,
                   Flag.FLAG_ACTIVITY_CLEAR_TOP,
                   Flag.FLAG_ACTIVITY_BROUGHT_TO_FRONT, 
                 ],
                 arguments: <String, dynamic>{
                   'from_background': true,
                 },
               );
               await intent.launch();
               debugPrint("🚀 تم إطلاق التطبيق بنجاح!");
             } catch (e) {
               debugPrint("❌ فشل إجبار التطبيق على الفتح: $e");
             }
          }

        } catch (e) {
          debugPrint("❌ خطأ غير متوقع في الخلفية: $e");
        }
      }
    }
  });
}