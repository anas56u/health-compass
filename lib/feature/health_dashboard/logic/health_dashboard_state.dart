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
  final String userName; // ✅ (1) تمت إضافة متغير الاسم

  const HealthDashboardLoaded({
    required this.latestData,
    required this.historyData,
    required this.commitmentPercentage,
    required this.totalTasks,
    required this.completedTasks,
    required this.selectedDate,
    required this.isWeekly,
    required this.userName, // ✅ (2) أصبح مطلوباً في البناء
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthDashboardLoaded &&
        other.latestData == latestData &&
        other.commitmentPercentage == commitmentPercentage &&
        other.selectedDate == selectedDate &&
        other.isWeekly == isWeekly &&
        other.userName == userName && // ✅ (3) إدراجه في المقارنة
        other.historyData.length == historyData.length;
  }

  @override
  int get hashCode => Object.hash(
    latestData,
    commitmentPercentage,
    selectedDate,
    isWeekly,
    userName, // ✅ (4) إدراجه في الـ HashCode
  );
}

class HealthDashboardError extends HealthDashboardState {
  final String message;
  const HealthDashboardError(this.message);
}
