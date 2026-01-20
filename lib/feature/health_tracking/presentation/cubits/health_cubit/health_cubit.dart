import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
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

  // ✅ متغير لتتبع وضع الطوارئ
  bool _isEmergencyMode = false;

  // 1️⃣ الـ Constructor: نظيف ويعتمد فقط على المراقبة
  HealthCubit(this.userCubit) : super(HealthInitial()) {
    health.configure();
    _monitorUserStatus(); // 👈 نقطة البداية الصحيحة
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }

  // 2️⃣ دالة مراقبة حالة المستخدم (الدينامو)
  void _monitorUserStatus() {
    // دالة داخلية لفحص الحالة واتخاذ القرار
    void checkAndStart(UserState state) {
      // الشرط: المستخدم تم تحميله + نوعه مريض
      if (state is UserLoaded && state.userModel is PatientModel) {
        // إذا لم يكن العداد يعمل، ابدأه فوراً
        if (_timer == null || !_timer!.isActive) {
          print("✅ User Ready (Patient). Starting Health Monitoring...");
          fetchHealthData(); // جلب أولي فوري
          _startContinuousMonitoring(); // تشغيل العداد الدوري
        }
      } else {
        // إذا كان يحمل (Loading) أو دكتور أو غير مسجل دخول -> توقف
        _stopMonitoring();
      }
    }

    // أ) افحص الحالة الحالية فوراً عند فتح التطبيق
    checkAndStart(userCubit.state);

    // ب) استمع لأي تغييرات مستقبلية (مثلاً تسجيل دخول/خروج)
    _userSubscription = userCubit.stream.listen((state) {
      checkAndStart(state);
    });
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

  // 3️⃣ دالة إعادة تعيين الطوارئ (عند ضغط زر "أنا بخير")
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

  // 4️⃣ الدالة الرئيسية لجلب البيانات
  Future<void> fetchHealthData() async {
    // تحقق مزدوج (Double Check) للأمان
    final userState = userCubit.state;
    if (userState is! UserLoaded || userState.userModel is! PatientModel) {
      return;
    }

    // إذا كنا في وضع الطوارئ حالياً، لا نفعل شيباً جديداً
    if (_isEmergencyMode) return;

    // فحص الغفوة (Snooze)
    if (_lastDismissTime != null) {
      final difference = DateTime.now().difference(_lastDismissTime!);
      if (difference.inMinutes < 2) {
        print("zzz Snoozing alerts... ($difference passed)");
        return;
      } else {
        _lastDismissTime = null; // انتهت الغفوة
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

      // --- 🚨 منطق فحص الطوارئ ---

      // أ) القلب
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

      // ب) ضغط الدم
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

      // ج) السكر
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

      // ✅ المسار الطبيعي (تحديث البيانات ورفعها لفايربيس)
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
      // تجنب رفع بيانات فارغة تماماً
      if (heartRate == 0 && bloodGlucose == 0 && systolic == 0) return;

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
}