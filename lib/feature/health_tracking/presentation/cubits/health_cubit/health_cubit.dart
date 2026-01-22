import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthCubit extends Cubit<HealthState> {
  final Health health = Health();
  Timer? _timer;
  DateTime? _lastDismissTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserCubit userCubit;
  StreamSubscription? _userSubscription;

  bool _isEmergencyMode = false;

  HealthCubit(this.userCubit) : super(HealthInitial()) {
    health.configure();
    _monitorUserStatus();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }

  // 2️⃣ دالة مراقبة حالة المستخدم
  void _monitorUserStatus() {
    void checkAndStart(UserState state) {
      if (state is UserLoaded && state.userModel is PatientModel) {
        if (_timer == null || !_timer!.isActive) {
          print("✅ User Ready (Patient). Starting Health Monitoring...");
          fetchHealthData();
          _startContinuousMonitoring();
        }
      } else {
        _stopMonitoring();
      }
    }

    // ❌ لقد قمت بحذف الدالة من هنا لأن مكانها كان خاطئاً

    checkAndStart(userCubit.state);

    _userSubscription = userCubit.stream.listen((state) {
      checkAndStart(state);
    });
  }

  // ✅ 3️⃣ دالة حفظ القراءات اليدوية (مكانها الصحيح هنا: دالة تابعة للكلاس مباشرة)
 Future<void> saveManualReadingsToFirestore({
    double? heartRate,
    int? systolic,
    int? diastolic,
    double? bloodGlucose,
    double weight = 0.0,
  }) async {
    print("📥 [Cubit] 5. وصل الطلب للدالة saveManualReadingsToFirestore"); // Log 6
    print("📦 [Cubit] البيانات المستلمة: قلب=$heartRate, ضغط=$systolic/$diastolic, سكر=$bloodGlucose");
    
    await _uploadToFirestore(
      heartRate: heartRate ?? 0.0,
      systolic: systolic ?? 0,
      diastolic: diastolic ?? 0,
      bloodGlucose: (bloodGlucose ?? 0).toInt(),
      weight: weight,
    );
  }

  void _stopMonitoring() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      print("🛑 Monitoring Stopped (User not loaded or not a patient).");
    }
  }

  void _startContinuousMonitoring() {
    print("⏰ Monitoring started (every 5 seconds)");
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchHealthData();
    });
  }

  void resetEmergencyMode() {
    print("💚 User is safe. Snoozing alerts for 2 minutes.");
    _isEmergencyMode = false;
    _lastDismissTime = DateTime.now();
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

  // دالة فحص القراءات اليدوية للطوارئ
  void checkManualReadings({
    double? heartRate,
    int? systolic,
    int? diastolic,
    double? bloodGlucose,
  }) {
    if (heartRate != null) {
      if (heartRate > 120 || (heartRate < 40 && heartRate > 0)) {
        _triggerEmergency(
          message: "معدل ضربات القلب غير طبيعي (يدوي: $heartRate)!",
          value: heartRate,
          type: "Heart Rate",
          heartRate: heartRate,
          systolic: systolic ?? 0,
          diastolic: diastolic ?? 0,
          bloodGlucose: bloodGlucose ?? 0,
        );
        return;
      }
    }

    if (systolic != null) {
      if (systolic > 180 || (systolic < 90 && systolic > 0)) {
        _triggerEmergency(
          message: "ضغط الدم وصل لمرحلة حرجة (يدوي: $systolic)!",
          value: systolic.toDouble(),
          type: "Blood Pressure",
          heartRate: heartRate ?? 0,
          systolic: systolic,
          diastolic: diastolic ?? 0,
          bloodGlucose: bloodGlucose ?? 0,
        );
        return;
      }
    }

    if (bloodGlucose != null) {
      if (bloodGlucose > 300 || (bloodGlucose < 70 && bloodGlucose > 0)) {
        _triggerEmergency(
          message: "مستوى السكر في الدم خطير (يدوي: $bloodGlucose)!",
          value: bloodGlucose,
          type: "Glucose",
          heartRate: heartRate ?? 0,
          systolic: systolic ?? 0,
          diastolic: diastolic ?? 0,
          bloodGlucose: bloodGlucose,
        );
        return;
      }
    }
  }

  Future<void> fetchHealthData() async {
bool isWatchEnabled = await SharedPrefHelper.getBool('health_data_source');
    if (!isWatchEnabled) {
      print("🛑 Watch Sync is OFF. Skipping auto-fetch.");
      return; 
    }
    final userState = userCubit.state;
    if (userState is! UserLoaded || userState.userModel is! PatientModel) {
      return;
    }

    if (_isEmergencyMode) return;

    if (_lastDismissTime != null) {
      final difference = DateTime.now().difference(_lastDismissTime!);
      if (difference.inMinutes < 2) {
        print("zzz Snoozing alerts... ($difference passed)");
        return;
      } else {
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
      double weight = await _getMostRecentData(
        HealthDataType.WEIGHT,
        startTime,
        now,
      );
      double bloodGlucose = await _getMostRecentData(
        HealthDataType.BLOOD_GLUCOSE,
        startTime,
        now,
      );

      print(
        "📊 DATA: HR: $heartRate | BP: $systolic/$diastolic | Glu: $bloodGlucose",
      );

      if (heartRate > 120 || (heartRate < 40 && heartRate > 0)) {
        _triggerEmergency(
          message: "معدل ضربات القلب غير طبيعي ($heartRate bpm)!",
          value: heartRate,
          type: "Heart Rate",
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return;
      }

      if (systolic > 180 || (systolic < 90 && systolic > 0)) {
        _triggerEmergency(
          message: "ضغط الدم وصل لمرحلة حرجة ($systolic)!",
          value: systolic,
          type: "Blood Pressure",
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return;
      }

      if (bloodGlucose > 300 || (bloodGlucose < 70 && bloodGlucose > 0)) {
        _triggerEmergency(
          message: "مستوى السكر في الدم خطير ($bloodGlucose)!",
          value: bloodGlucose,
          type: "Glucose",
          heartRate: heartRate,
          systolic: systolic.toInt(),
          diastolic: diastolic.toInt(),
          bloodGlucose: bloodGlucose,
        );
        return;
      }

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
      emit(HealthError("فشل في جلب البيانات: $e"));
    }
  }

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

    emit(
      HealthCritical(
        message: message,
        criticalValue: value,
        vitalType: type,
        heartRate: heartRate,
        systolic: systolic,
        diastolic: diastolic,
        bloodGlucose: bloodGlucose,
      ),
    );
  }

 Future<void> _uploadToFirestore({
    required double heartRate,
    required int systolic,
    required int diastolic,
    required int bloodGlucose,
    required double weight,
  }) async {
    final uid = _auth.currentUser?.uid;
    print("☁️ [Cubit] 6. بدأت عملية الرفع للمستخدم: $uid");

    if (uid == null) return;

    try {
      // ✅ التغيير الجذري: نستخدم Map ديناميكية
      final Map<String, dynamic> data = {
        'timestamp': FieldValue.serverTimestamp(),
      };

      // ✅ نضيف القيم فقط إذا كانت حقيقية (أكبر من صفر)
      if (heartRate > 0) data['heartRate'] = heartRate;
      if (systolic > 0) data['systolic'] = systolic;
      if (diastolic > 0) data['diastolic'] = diastolic;
      if (bloodGlucose > 0) data['bloodGlucose'] = bloodGlucose;
      if (weight > 0) data['weight'] = weight;

      // إذا كانت الـ Map تحتوي فقط على التوقيت، لا نرفع شيئاً!
      if (data.length <= 1) {
        print("⚠️ [Cubit] تم تجاهل الرفع لأن جميع القيم أصفار");
        return;
      }

      print("⏳ [Cubit] جاري رفع البيانات الصالحة فقط: $data");

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('health_readings')
          .add(data);

      print("✅ [Cubit] 7. تمت عملية الرفع بنجاح!");
    } catch (e) {
      print("❌ [Cubit] فشل الرفع: $e");
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
        if (mostRecent.value is NumericHealthValue) {
          return (mostRecent.value as NumericHealthValue).numericValue
              .toDouble();
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
