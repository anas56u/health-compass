import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class PatientModel extends UserModel {
  final String diseaseType;
  final String? diagnosisYear;
  final bool isTakingMeds;
  final String? specificDisease;
  final bool hasOtherIssues;

  PatientModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    required this.diseaseType,
    this.diagnosisYear,
    this.isTakingMeds = false,
    this.specificDisease,
    this.hasOtherIssues = false,
  }) : super(userType: 'patient');

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'created_at': Timestamp.fromDate(createdAt),
      'disease_type': diseaseType,
      'diagnosis_year': diagnosisYear,
      'is_taking_meds': isTakingMeds,
      'specific_disease': specificDisease,
      'has_other_issues': hasOtherIssues,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      diseaseType: map['disease_type'] ?? '',
      diagnosisYear: map['diagnosis_year'],
      isTakingMeds: map['is_taking_meds'] ?? false,
      specificDisease: map['specific_disease'],
      hasOtherIssues: map['has_other_issues'] ?? false,
    );
  }
}