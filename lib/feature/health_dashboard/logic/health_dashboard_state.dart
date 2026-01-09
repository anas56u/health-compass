part of 'health_dashboard_cubit.dart';

abstract class HealthDashboardState {
  const HealthDashboardState();
}

class HealthDashboardInitial extends HealthDashboardState {}

class HealthDashboardLoading extends HealthDashboardState {}

class HealthDashboardLoaded extends HealthDashboardState {
  final HealthDataModel latestData;
  final List<HealthDataModel> historyData;
  final double commitmentPercentage;
  final int totalTasks;
  final int completedTasks;
  final DateTime selectedDate;
  final bool isWeekly;

  const HealthDashboardLoaded({
    required this.latestData,
    required this.historyData,
    required this.commitmentPercentage,
    required this.totalTasks,
    required this.completedTasks,
    required this.selectedDate,
    required this.isWeekly,
  });

  // ✅ تحسين الأداء: مقارنة القيم لمنع التحديثات العشوائية
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthDashboardLoaded &&
        other.latestData == latestData &&
        other.commitmentPercentage == commitmentPercentage &&
        other.selectedDate == selectedDate &&
        other.isWeekly == isWeekly &&
        other.historyData.length == historyData.length; // مقارنة سريعة للطول
  }

  @override
  int get hashCode =>
      Object.hash(latestData, commitmentPercentage, selectedDate, isWeekly);
}

class HealthDashboardError extends HealthDashboardState {
  final String message;
  const HealthDashboardError(this.message);
}
