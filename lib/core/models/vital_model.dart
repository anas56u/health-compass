import 'package:cloud_firestore/cloud_firestore.dart';

class VitalModel {
  final String? id; // ✅ 1. إضافة حقل المعرف (ضروري للحذف)
  final String type;
  final String value;
  final String unit;
  final String status;
  final DateTime date;

  VitalModel({
    this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    required this.date,
  });

  // ✅ 2. استقبال معرف المستند (docId) هنا
  factory VitalModel.fromMap(Map<String, dynamic> map, String docId) {
    return VitalModel(
      id: docId, // تخزين المعرف
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      unit: map['unit'] ?? '',
      status: map['status'] ?? 'normal',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
