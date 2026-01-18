abstract class HealthState {}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthConnectNotInstalled extends HealthState {}

class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
}

// في ملف HealthState.dart

// الحالة الأساسية للبيانات (تأكد أنها موجودة كما هي)
class HealthLoaded extends HealthState {
  final double heartRate;
  final int systolic;
  final int diastolic;
  final double bloodGlucose;

  HealthLoaded({
    required this.heartRate,
    required this.systolic,
    required this.diastolic,
    required this.bloodGlucose,
  });

  @override
  List<Object> get props => [heartRate, systolic, diastolic, bloodGlucose];
}

// ✅ التعديل هنا: HealthCritical يرث الآن من HealthLoaded
class HealthCritical extends HealthLoaded {
  final String message;
  final double criticalValue; // القيمة الخطرة
  final String vitalType;     // نوع القياس الخطر

  HealthCritical({
    required this.message,
    required this.criticalValue,
    required this.vitalType,
    // يجب تمرير القيم الأساسية للأب (HealthLoaded)
    required double heartRate,
    required int systolic,
    required int diastolic,
    required double bloodGlucose,
  }) : super( // نمرر البيانات للكلاس الأب ليحفظها
          heartRate: heartRate,
          systolic: systolic,
          diastolic: diastolic,
          bloodGlucose: bloodGlucose,
        );

  @override
  List<Object> get props => [message, criticalValue, vitalType, heartRate, systolic, diastolic, bloodGlucose];
}