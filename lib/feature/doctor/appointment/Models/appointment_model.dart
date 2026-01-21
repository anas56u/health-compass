import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? doctorImage;

  // بيانات الموعد المشتركة
  final DateTime date;
  final String timeString;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String type;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.doctorImage,
    required this.date,
    required this.timeString,
    required this.status,
    required this.type,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      patientId: map['patient_id'] ?? '',
      patientName: map['patient_name'] ?? 'مريض',
      doctorId: map['doctor_id'] ?? '',
      doctorName: map['doctor_name'] ?? 'دكتور',
      doctorImage: map['doctor_image'],
      date: (map['date'] as Timestamp).toDate(),
      timeString: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      type: map['type'] ?? 'زيارة عامة',
    );
  }
}
