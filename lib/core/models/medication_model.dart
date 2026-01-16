import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dose;
  final String type;
  final List<String> times;
  final String status; // 'pending', 'taken', 'missed'

  MedicationModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.type,
    required this.times,
    required this.status,
  });

  // تحويل من Firestore إلى Object
  factory MedicationModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicationModel(
      id: docId,
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      type: map['type'] ?? '',
      times: List<String>.from(map['times'] ?? []),
      status: map['status'] ?? 'pending',
    );
  }

  // تحويل من Object إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dose': dose,
      'type': type,
      'times': times,
      'status': status,
    };
  }
}
