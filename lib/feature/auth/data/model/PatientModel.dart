import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class PatientModel extends UserModel {
  final String diseaseType;
  final String? diagnosisYear;
  final bool isTakingMeds;
  final String? specificDisease;
  final bool hasOtherIssues;
  final List<String> doctorIds; 

  PatientModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    super.profileImage,
    required this.diseaseType,
    this.diagnosisYear,
    this.isTakingMeds = false,
    this.specificDisease,
    this.hasOtherIssues = false,
    this.doctorIds = const [], 
  }) : super(userType: 'patient');

  @override
  PatientModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? diseaseType,
    String? diagnosisYear,
    bool? isTakingMeds,
    String? specificDisease,
    bool? hasOtherIssues,
    List<String>? doctorIds,
  }) {
    return PatientModel(
      uid: uid ?? this.uid, 
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: this.createdAt, 
      profileImage: profileImage ?? this.profileImage,
      diseaseType: diseaseType ?? this.diseaseType,
      diagnosisYear: diagnosisYear ?? this.diagnosisYear,
      isTakingMeds: isTakingMeds ?? this.isTakingMeds,
      specificDisease: specificDisease ?? this.specificDisease,
      hasOtherIssues: hasOtherIssues ?? this.hasOtherIssues,
      doctorIds: doctorIds ?? this.doctorIds,

    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'created_at': Timestamp.fromDate(createdAt),
      'profile_image': profileImage, 
      'disease_type': diseaseType,
      'diagnosis_year': diagnosisYear,
      'is_taking_meds': isTakingMeds,
      'specific_disease': specificDisease,
      'has_other_issues': hasOtherIssues,
      'doctor_ids': doctorIds,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      profileImage: map['profile_image'], // 4. استرجاع رابط الصورة عند قراءة البيانات
      diseaseType: map['disease_type'] ?? '',
      diagnosisYear: map['diagnosis_year'],
      isTakingMeds: map['is_taking_meds'] ?? false,
      specificDisease: map['specific_disease'],
      hasOtherIssues: map['has_other_issues'] ?? false,
      doctorIds: List<String>.from(map['doctor_ids'] ?? []),
    );
  }
}