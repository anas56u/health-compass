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
  final String userName;

  const HealthDashboardLoaded({
    required this.latestData,
    required this.historyData,
    required this.commitmentPercentage,
    required this.totalTasks,
    required this.completedTasks,
    required this.selectedDate,
    required this.isWeekly,
    required this.userName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthDashboardLoaded &&
        other.latestData == latestData &&
        other.commitmentPercentage == commitmentPercentage &&
        other.totalTasks == totalTasks &&
        other.completedTasks == completedTasks &&
        other.selectedDate == selectedDate &&
        other.isWeekly == isWeekly &&
        other.userName == userName &&
        // ✅ تحسين مقارنة القوائم لضمان دقة البيانات المعروضة
        _compareLists(other.historyData, historyData);
  }

  // دالة مساعدة لمقارنة القوائم بدقة
  bool _compareLists(List<HealthDataModel> list1, List<HealthDataModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    latestData,
    commitmentPercentage,
    totalTasks,
    completedTasks,
    selectedDate,
    isWeekly,
    userName,
    historyData.length, // إضافة طول القائمة للـ hash
  );
}

class HealthDashboardError extends HealthDashboardState {
  final String message;
  const HealthDashboardError(this.message);
}
