// الحالة المجردة (Abstract)
abstract class HealthState {}

// الحالة الأولية (عندما يفتح التطبيق)
class HealthInitial extends HealthState {}

// حالة جلب البيانات (يظهر شريط تحميل)
class HealthLoading extends HealthState {}

// الحالة التي تعني أن التطبيق غير مُثبت
class HealthConnectNotInstalled extends HealthState {}

// حالة وجود خطأ (يعرض رسالة الخطأ)
class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
}

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
}