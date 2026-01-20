import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDataModel {
  final double heartRate;
  final int sugar;
  final int systolic;
  final int diastolic;
  final double weight;
  final DateTime date;

  HealthDataModel({
    required this.heartRate,
    required this.sugar,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.date,
  });

  String get bloodPressure => "$systolic/$diastolic";

  factory HealthDataModel.fromMap(Map<String, dynamic> map) {
    int sys = 0;
    int dia = 0;

    // 1. منطق استخراج ضغط الدم (دعم التخزين الرقمي والنصي)
    if (map['systolic'] != null) {
      sys = (map['systolic'] as num).toInt();
      dia = (map['diastolic'] as num).toInt();
    } else if (map['bloodPressure'] != null ||
        map['value'] != null && map['type'] == 'pressure') {
      // دعم المسار الموحد في health_readings حيث تكون القيمة في حقل 'value'
      try {
        final String rawValue =
            (map['value'] ?? map['bloodPressure']) as String;
        final parts = rawValue.split('/');
        sys = int.parse(parts[0]);
        dia = int.parse(parts[1]);
      } catch (_) {}
    }

    // 2. معالجة السكر بناءً على التسميات المختلفة في Firestore
    int sugarValue = 0;
    if (map['type'] == 'sugar') {
      sugarValue = int.tryParse(map['value'].toString()) ?? 0;
    } else {
      sugarValue = (map['bloodGlucose'] ?? 0).toInt();
    }

    return HealthDataModel(
      heartRate:
          (map['heartRate'] ??
                  (map['type'] == 'heart'
                      ? double.tryParse(map['value'].toString())
                      : 0.0))
              .toDouble(),
      sugar: sugarValue,
      systolic: sys,
      diastolic: dia,
      weight: (map['weight'] ?? 0).toDouble(),
      date:
          (map['date'] as Timestamp?)?.toDate() ??
          (map['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}

class TaskModel {
  final String id;
  final bool isCompleted;

  TaskModel({required this.id, required this.isCompleted});
  static List<TaskModel> fromMap(Map<String, dynamic> tasksMap) {
    return tasksMap.entries.map((entry) {
      return TaskModel(id: entry.key, isCompleted: entry.value == true);
    }).toList();
  }
}
