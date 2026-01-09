import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';

// ✅ 1. استيراد مكتبات Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthCubit extends Cubit<HealthState> {
  final Health health = Health();
  Timer? _timer;

  // ✅ 2. تعريف Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HealthCubit() : super(HealthInitial()) {
    health.configure();
    fetchHealthData();
    _startContinuousMonitoring();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 14+ uses Health Connect natively
    } else {
      await Permission.sensors.request();
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
      final startTime = now.subtract(const Duration(hours: 24));

      // 1. جلب البيانات الأساسية
      double heartRate = await _getMostRecentData(
        HealthDataType.HEART_RATE,
        startTime,
        now,
      );
      double systolic = await _getMostRecentData(
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        startTime,
        now,
      );
      double diastolic = await _getMostRecentData(
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        startTime,
        now,
      );

      // ✅ جلب الوزن أيضاً (إذا لم يوجد سيرجع 0.0)
      double weight = await _getMostRecentData(
        HealthDataType.WEIGHT,
        startTime,
        now,
      );

      // 2. معالجة الجلوكوز
      double bloodGlucose = 0.0;

      try {
        List<HealthDataPoint> glucoseList = await health.getHealthDataFromTypes(
          startTime: startTime,
          endTime: now,
          types: [HealthDataType.BLOOD_GLUCOSE],
        );

        if (glucoseList.isNotEmpty) {
          glucoseList.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          final recent = glucoseList.first;
          if (recent.value is NumericHealthValue) {
            bloodGlucose = (recent.value as NumericHealthValue).numericValue
                .toDouble();
          }
        }
      } catch (e) {
        print("⚠️ Error fetching glucose specific data: $e");
      }

      // ✅✅ 3. الخطوة الجديدة: رفع البيانات إلى Firebase
      // سيقوم هذا بإنشاء الكولكشن تلقائياً إذا لم يكن موجوداً
      await _uploadToFirestore(
        heartRate: heartRate,
        systolic: systolic.toInt(),
        diastolic: diastolic.toInt(),
        bloodGlucose: bloodGlucose.toInt(),
        weight: weight == 0 ? 75.0 : weight, // قيمة افتراضية للوزن إذا لم يوجد
      );

      // 4. تحديث الواجهة المحلية
      emit(
        HealthLoaded(
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        ),
      );
    } catch (e) {
      print("CRITICAL ERROR in fetchHealthData: $e");
      // لا نوقف التطبيق، فقط نطبع الخطأ
    }
  }

  // ✅ دالة الرفع إلى Firestore
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
      // نتحقق من آخر قراءة تم رفعها لتجنب التكرار المفرط (اختياري، لكن جيد للأداء)
      // حالياً سنرفع كل 5 ثواني كما هو مطلوب للاختبار "الحي"

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
            'timestamp': FieldValue.serverTimestamp(), // وقت السيرفر
          });

      print("✅ Data uploaded to Firestore: HR=$heartRate, Glu=$bloodGlucose");
    } catch (e) {
      print("❌ Failed to upload data to Firestore: $e");
    }
  }

  Future<double> _getMostRecentData(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final data = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [type],
      );

      if (data.isNotEmpty) {
        data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final mostRecent = data.first;
        final value = mostRecent.value as NumericHealthValue;
        return value.numericValue.toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void _startContinuousMonitoring() {
    // تنبيه: هذا سيرفع وثيقة جديدة كل 5 ثواني!
    // ممتاز للاختبار، لكن في النسخة النهائية يفضل زيادة الوقت (مثلاً كل 15 دقيقة)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchHealthData();
    });
  }
}
