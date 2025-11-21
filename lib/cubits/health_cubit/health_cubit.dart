import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_compass/cubits/health_cubit/HealthState.dart';

class HealthCubit extends Cubit<HealthState> {
  final Health health = Health();
  Timer? _timer;

  HealthCubit() : super(HealthInitial()) {
    health.configure();
    fetchHealthData();
    _startPeriodicUpdates();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> requestPermissions() async {
    // For Health Connect, we only need to use health.requestAuthorization
    // No need for separate permission_handler requests
    // Permission.sensors and Permission.location are for older Health APIs
    if (Platform.isAndroid) {
      // Health Connect handles its own permissions through the Health app
      print("Android: Using Health Connect permission flow");
    } else {
      // For iOS, request HealthKit permissions
      PermissionStatus bodySensorsStatus = await Permission.sensors.request();
      if (bodySensorsStatus.isGranted) {
        print("iOS: Permissions granted");
      }
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
    if (state is HealthInitial) {
      emit(HealthLoading());
    }

    try {
      await requestPermissions();

      if (Platform.isAndroid) {
        print("Checking Health Connect SDK status...");
        final status = await health.getHealthConnectSdkStatus();
        print("Health Connect SDK status: $status");

        if (status == HealthConnectSdkStatus.sdkUnavailable) {
          emit(HealthConnectNotInstalled());
          return;
        } else if (status ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          emit(HealthError("يرجى تحديث Health Connect من Google Play"));
          return;
        }
      }

      final types = [
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_GLUCOSE,
      ];

      print("Requesting authorization for types: $types");
      bool requested = await health.requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
      print("Authorization requested: $requested");

      if (requested) {
        final now = DateTime.now();
        final thirtyMinAgo = now.subtract(const Duration(minutes: 30));

        double heartRate = await _getMostRecentData(
          HealthDataType.HEART_RATE,
          thirtyMinAgo,
          now,
        );
        double systolic = await _getMostRecentData(
          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          thirtyMinAgo,
          now,
        );
        double diastolic = await _getMostRecentData(
          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          thirtyMinAgo,
          now,
        );
        double bloodGlucose = await _getMostRecentData(
          HealthDataType.BLOOD_GLUCOSE,
          thirtyMinAgo,
          now,
        );

        emit(
          HealthLoaded(
            heartRate: heartRate,
            systolic: systolic.toInt(),
            diastolic: diastolic.toInt(),
            bloodGlucose: bloodGlucose,
          ),
        );
      } else {
        emit(
          HealthError(
            "لم يتم منح الأذونات. يرجى:\n"
            "1. فتح تطبيق Health Connect\n"
            "2. منح الأذونات يدوياً\n"
            "3. إعادة فتح التطبيق",
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error in fetchHealthData: $e");
      print("Stack trace: $stackTrace");
      emit(HealthError("خطأ: ${e.toString()}"));
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
        final value = data.first.value as NumericHealthValue;
        return value.numericValue.toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void _startPeriodicUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      print("HealthCubit: [تحديث دوري] جاري جلب البيانات...");
      fetchHealthData();
    });
  }
}
