import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String instructions;
  final String time;
  final String period;
  final List<int> daysOfWeek;
  final bool isActive;
  final DateTime createdAt;
  final int notificationId; // <--- حقل جديد

  MedicationModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.instructions,
    required this.time,
    required this.period,
    required this.daysOfWeek,
    this.isActive = true,
    required this.createdAt, required this.notificationId,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      medicationName: data['medicationName'] ?? '',
      dosage: data['dosage'] ?? '',
      instructions: data['instructions'] ?? '',
      time: data['time'] ?? '',
      period: data['period'] ?? '',
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notificationId: data['notificationId'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
      'time': time,
      'period': period,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationId': notificationId, // <--- حفظ في قاعدة البيانات
    };
  }

  MedicationModel copyWith({
    String? id,
    String? medicationName,
    String? dosage,
    String? instructions,
    String? time,
    String? period,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    int? notificationId,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      time: time ?? this.time,
      period: period ?? this.period,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
