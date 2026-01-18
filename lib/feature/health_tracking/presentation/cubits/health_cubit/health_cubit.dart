import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthCubit extends Cubit<HealthState> {
  final Health health = Health(); 
  Timer? _timer;
  DateTime? _lastDismissTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ متغير لتتبع وضع الطوارئ
  bool _isEmergencyMode = false;

  HealthCubit() : super(HealthInitial()) {
    health.configure();
    
    Future.delayed(Duration.zero, () {
      print("🚀 HealthCubit Started");
      fetchHealthData();
      _startContinuousMonitoring();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void resetEmergencyMode() {
    print("💚 User is safe. Snoozing alerts for 2 minutes.");
    _isEmergencyMode = false;
    _lastDismissTime = DateTime.now(); // 👈 نسجل الوقت الحالي
    
    // ملاحظة: لا نستدعي fetchHealthData فوراً هنا لنعطي فرصة للمؤقت الطبيعي
  }

  Future<void> requestPermissions() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_GLUCOSE, 
      HealthDataType.WEIGHT,
    ];

    try {
      await health.requestAuthorization(types);
    } catch (e) {
      print("❌ Error requesting permissions: $e");
    }
  }

  Future<void> installHealthConnect() async {
    try {
      await health.installHealthConnect();
    } catch (e) {
      emit(HealthError("خطأ في محاولة التثبيت: $e"));
    }
  }

  Future<void> fetchHealthData() async {
    // 1. إذا كنا في وضع الطوارئ حالياً، نوقف التنفيذ
    if (_isEmergencyMode) return;

    // ✅ 2. فحص "الغفوة" (Snooze Logic)
    if (_lastDismissTime != null) {
      final difference = DateTime.now().difference(_lastDismissTime!);
      // إذا لم تمر دقيقتان منذ آخر إلغاء، نتجاهل الفحص
      if (difference.inMinutes < 2) {
        print("zzz Snoozing alerts... ($difference passed)");
        return; 
      } else {
        // انتهت الدقيقتان، نصفر المتغير لنبدأ الحماية من جديد
        _lastDismissTime = null; 
      }
    }

    if (state is HealthInitial) emit(HealthLoading());

    try {
      await requestPermissions();

      if (Platform.isAndroid) {
        final status = await health.getHealthConnectSdkStatus();
        if (status == HealthConnectSdkStatus.sdkUnavailable) {
          emit(HealthConnectNotInstalled());
          return;
        }
      }

      final now = DateTime.now();
      final startTime = now.subtract(const Duration(hours: 48)); 

      print("🔄 Fetching Data...");

      double heartRate = await _getMostRecentData(HealthDataType.HEART_RATE, startTime, now);
      double systolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_SYSTOLIC, startTime, now);
      double diastolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_DIASTOLIC, startTime, now);
      double weight = await _getMostRecentData(HealthDataType.WEIGHT, startTime, now);
      double bloodGlucose = await _getMostRecentData(HealthDataType.BLOOD_GLUCOSE, startTime, now);

      print("📊 DATA: HR: $heartRate | BP: $systolic/$diastolic | Glu: $bloodGlucose");

      // ✅ 3. فحص القيم الخطرة (Emergency Logic)
      
      // أ) فحص القلب
      if (heartRate > 120 || (heartRate < 40 && heartRate > 0)) {
        _triggerEmergency(
          message: "معدل ضربات القلب غير طبيعي ($heartRate bpm)!", 
          value: heartRate, 
          type: "Heart Rate",
          // 👇 التعديل هنا: تمرير باقي البيانات
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return; 
      }

      // ب) فحص ضغط الدم
      if (systolic > 180 || (systolic < 90 && systolic > 0)) {
        _triggerEmergency(
          message: "ضغط الدم وصل لمرحلة حرجة ($systolic)!", 
          value: systolic, 
          type: "Blood Pressure",
          // 👇 التعديل هنا: تمرير باقي البيانات
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return;
      }

      // ج) فحص السكر
      if (bloodGlucose > 300 || (bloodGlucose < 70 && bloodGlucose > 0)) {
        _triggerEmergency(
          message: "مستوى السكر في الدم خطير ($bloodGlucose)!", 
          value: bloodGlucose, 
          type: "Glucose",
          // 👇 التعديل هنا: تمرير باقي البيانات
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return;
      }

      // ✅ 4. المسار الطبيعي (إذا لم يكن هناك طوارئ)
      await _uploadToFirestore(
        heartRate: heartRate,
        systolic: systolic.toInt(),
        diastolic: diastolic.toInt(),
        bloodGlucose: bloodGlucose.toInt(),
        weight: weight == 0 ? 75.0 : weight,
      );

      emit(
        HealthLoaded(
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        ),
      );

    } catch (e) {
      print("❌ Error in fetchHealthData: $e");
    }
  }

  // ✅ دالة التنبيه (محدثة لتستقبل كل شيء)
  void _triggerEmergency({
    required String message,
    required double value,
    required String type,
    required double heartRate,
    required int systolic,
    required int diastolic,
    required double bloodGlucose,
  }) {
    print("🚨 EMERGENCY TRIGGERED: $message");
    _isEmergencyMode = true; 
    
    emit(HealthCritical(
      message: message,
      criticalValue: value,
      vitalType: type,
      // نمرر البيانات للحالة ليظل الكارت ظاهراً
      heartRate: heartRate,
      systolic: systolic,
      diastolic: diastolic,
      bloodGlucose: bloodGlucose,
    ));
  }

  Future<void> _uploadToFirestore({
    required double heartRate,
    required int systolic,
    required int diastolic,
    required int bloodGlucose,
    required double weight,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      if (heartRate == 0 && bloodGlucose == 0) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('health_readings')
          .add({
            'heartRate': heartRate,
            'systolic': systolic,
            'diastolic': diastolic,
            'bloodGlucose': bloodGlucose,
            'weight': weight,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("❌ Firebase Upload Failed: $e");
    }
  }

  Future<double> _getMostRecentData(HealthDataType type, DateTime start, DateTime end) async {
    try {
      final data = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [type],
      );

      if (data.isNotEmpty) {
        data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final mostRecent = data.first;
        if (mostRecent.value is NumericHealthValue) {
           return (mostRecent.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void _startContinuousMonitoring() {
    print("⏰ Monitoring started (every 5 seconds)");
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchHealthData();
    });
  }
}