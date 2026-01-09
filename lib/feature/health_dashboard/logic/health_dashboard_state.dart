part of 'health_dashboard_cubit.dart';

abstract class HealthDashboardState {}

class HealthDashboardInitial extends HealthDashboardState {}

class HealthDashboardLoading extends HealthDashboardState {}

class HealthDashboardLoaded extends HealthDashboardState {
  final HealthDataModel latestData;
  final List<HealthDataModel> historyData;
  final double commitmentPercentage;
  final int totalTasks;
  final int completedTasks;
  final DateTime selectedDate;
  final bool isWeekly; // ✅ الإضافة الجديدة: هل العرض أسبوعي؟

  HealthDashboardLoaded({
    required this.latestData,
    required this.historyData,
    required this.commitmentPercentage,
    required this.totalTasks,
    required this.completedTasks,
    required this.selectedDate,
    required this.isWeekly, // مطلوب الآن
  });
}

class HealthDashboardError extends HealthDashboardState {
  final String message;
  HealthDashboardError(this.message);
}
