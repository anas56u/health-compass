import 'package:cloud_firestore/cloud_firestore.dart';

class VitalModel {
  final String type; // 'heart', 'pressure', 'sugar', 'weight'
  final String value;
  final String unit;
  final String status; // 'normal', 'high', 'low'
  final DateTime date;

  VitalModel({
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    required this.date,
  });

  factory VitalModel.fromMap(Map<String, dynamic> map) {
    return VitalModel(
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      unit: map['unit'] ?? '',
      status: map['status'] ?? 'normal',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
