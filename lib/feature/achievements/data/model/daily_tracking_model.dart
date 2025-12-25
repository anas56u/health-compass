// lib/feature/home/data/models/daily_tracking_model.dart

class DailyTrackingModel {
  final int steps;
  final Map<String, bool> tasksStatus; // مفتاح المهمة: هل اكتملت؟

  DailyTrackingModel({
    required this.steps,
    required this.tasksStatus,
  });

  // تحويل من JSON (Firebase)
  factory DailyTrackingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DailyTrackingModel(steps: 0, tasksStatus: {});
    }
    return DailyTrackingModel(
      steps: json['steps'] ?? 0,
      tasksStatus: Map<String, bool>.from(json['tasks'] ?? {}),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'tasks': tasksStatus,
    };
  }
}