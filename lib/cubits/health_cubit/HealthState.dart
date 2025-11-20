abstract class HealthState {}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthConnectNotInstalled extends HealthState {}

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