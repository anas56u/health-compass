import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';

class HealthCubit extends Cubit<HealthState> {
  final Health health = Health();
  Timer? _timer;

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

      // 1. جلب البيانات الأساسية (نبضات القلب والضغط)
      double heartRate = await _getMostRecentData(HealthDataType.HEART_RATE, startTime, now);
      double systolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_SYSTOLIC, startTime, now);
      double diastolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_DIASTOLIC, startTime, now);

      // 2. معالجة الجلوكوز (Debug Logic)
      double bloodGlucose = 0.0; // تعريف المتغير مرة واحدة هنا

      try {
        print("🔎 DEBUG: Fetching Glucose List...");
        
        // جلب القائمة الخام
        List<HealthDataPoint> glucoseList = await health.getHealthDataFromTypes(
          startTime: startTime,
          endTime: now,
          types: [HealthDataType.BLOOD_GLUCOSE],
        );

        print("🔎 DEBUG: Found ${glucoseList.length} glucose records.");

        if (glucoseList.isNotEmpty) {
          // ترتيب القائمة لتكون الأحدث أولاً
          glucoseList.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          
          final recent = glucoseList.first;
          print("🔎 DEBUG: Most recent glucose raw value: ${recent.value}");

          if (recent.value is NumericHealthValue) {
            bloodGlucose = (recent.value as NumericHealthValue).numericValue.toDouble();
          }
        }
      } catch (e) {
        print("⚠️ Error fetching glucose specific data: $e");
      }

      // 3. تحديث الواجهة
      emit(
        HealthLoaded(
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose, // استخدام القيمة النهائية
        ),
      );

    } catch (e) {
      print("CRITICAL ERROR in fetchHealthData: $e");
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchHealthData();
    });
  }
}