import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationStatus { taken, notTaken, pending }

class MedicationLogModel {
  final String id;
  final String medicationId;
  final String userId;
  final String date;
  final MedicationStatus status;
  final DateTime? takenAt;

  MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.date,
    required this.status,
    this.takenAt,
  });

  factory MedicationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationLogModel(
      id: doc.id,
      medicationId: data['medicationId'] ?? '',
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      status: _statusFromString(data['status'] ?? 'pending'),
      takenAt: data['takenAt'] != null
          ? (data['takenAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicationId': medicationId,
      'userId': userId,
      'date': date,
      'status': statusToString(status),
      'takenAt': takenAt != null ? Timestamp.fromDate(takenAt!) : null,
    };
  }

  static MedicationStatus _statusFromString(String status) {
    switch (status) {
      case 'taken':
        return MedicationStatus.taken;
      case 'notTaken':
        return MedicationStatus.notTaken;
      default:
        return MedicationStatus.pending;
    }
  }

  static String statusToString(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return 'taken';
      case MedicationStatus.notTaken:
        return 'notTaken';
      case MedicationStatus.pending:
        return 'pending';
    }
  }

  MedicationLogModel copyWith({
    String? id,
    String? medicationId,
    String? userId,
    String? date,
    MedicationStatus? status,
    DateTime? takenAt,
  }) {
    return MedicationLogModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}
