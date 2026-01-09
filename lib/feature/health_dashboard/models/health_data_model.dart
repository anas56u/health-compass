import 'package:cloud_firestore/cloud_firestore.dart';

// نموذج البيانات الصحية
class HealthDataModel {
  final double heartRate;
  final int sugar;
  final String bloodPressure;
  final double weight;
  final DateTime date;

  HealthDataModel({
    required this.heartRate,
    required this.sugar,
    required this.bloodPressure,
    required this.weight,
    required this.date,
  });

  factory HealthDataModel.fromMap(Map<String, dynamic> map) {
    return HealthDataModel(
      heartRate: (map['heartRate'] ?? 0).toDouble(),
      sugar: (map['bloodGlucose'] ?? 0).toInt(),
      bloodPressure: "${map['systolic'] ?? 0}/${map['diastolic'] ?? 0}",
      weight: (map['weight'] ?? 0).toDouble(),
      date: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// نموذج المهام
class TaskModel {
  final String id;
  final bool isCompleted;

  TaskModel({required this.id, required this.isCompleted});

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
