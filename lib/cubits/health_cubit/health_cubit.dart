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
  PermissionStatus bodySensorsStatus = await Permission.sensors.request();
  
  PermissionStatus locationStatus = await Permission.location.request();

  if (bodySensorsStatus.isGranted && locationStatus.isGranted) {
    print("Permissions granted");
  } else {
    await openAppSettings();
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

    await requestPermissions(); 
    if (Platform.isAndroid) {
      final status = await health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) {
        emit(HealthConnectNotInstalled());
        return;
      }
    }
   
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_GLUCOSE,
    ];
    final permissions = types.map((e) => HealthDataAccess.READ).toList();

    try {
      bool requested = await health.requestAuthorization(types, permissions: permissions);

      if (requested) {
        final now = DateTime.now();
        final thirtyMinAgo = now.subtract(const Duration(minutes: 30));

        double heartRate = await _getMostRecentData(HealthDataType.HEART_RATE, thirtyMinAgo, now);
        double systolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_SYSTOLIC, thirtyMinAgo, now);
        double diastolic = await _getMostRecentData(HealthDataType.BLOOD_PRESSURE_DIASTOLIC, thirtyMinAgo, now);
        double bloodGlucose = await _getMostRecentData(HealthDataType.BLOOD_GLUCOSE, thirtyMinAgo, now);

        emit(HealthLoaded(
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        ));
      } else {
        emit(HealthError("لم يتم منح الأذونات"));
      }
    } catch (e) {
      emit(HealthError("خطأ: ${e.toString()}"));
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
