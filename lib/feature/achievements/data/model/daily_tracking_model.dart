// lib/feature/home/data/models/daily_tracking_model.dart

class DailyTrackingModel {
  final Map<String, bool> tasksStatus; 

  DailyTrackingModel({
    required this.tasksStatus,
  });

  factory DailyTrackingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DailyTrackingModel(tasksStatus: {});
    }
    return DailyTrackingModel(
      tasksStatus: Map<String, bool>.from(json['tasks'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasksStatus,
    };
  }
}