import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDataModel {
  final double heartRate;
  final int sugar;
  final int systolic; // ✅ الضغط الانقباضي (رقم)
  final int diastolic; // ✅ الضغط الانبساطي (رقم)
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

  // ✅ Getter لدمج الضغط كنص عند الحاجة للعرض فقط
  String get bloodPressure => "$systolic/$diastolic";

  factory HealthDataModel.fromMap(Map<String, dynamic> map) {
    // ✅ منطق ذكي لاستخراج الضغط سواء كان مخزناً كنص أو أرقام
    int sys = 0;
    int dia = 0;

    if (map['systolic'] != null) {
      sys = (map['systolic'] as num).toInt();
      dia = (map['diastolic'] as num).toInt();
    } else if (map['bloodPressure'] != null) {
      // محاولة فك النص "120/80" في حال كان التخزين القديم نصياً
      try {
        final parts = (map['bloodPressure'] as String).split('/');
        sys = int.parse(parts[0]);
        dia = int.parse(parts[1]);
      } catch (_) {}
    }

    return HealthDataModel(
      heartRate: (map['heartRate'] ?? 0).toDouble(),
      sugar: (map['bloodGlucose'] ?? 0).toInt(),
      systolic: sys,
      diastolic: dia,
      weight: (map['weight'] ?? 0).toDouble(),
      date: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

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
