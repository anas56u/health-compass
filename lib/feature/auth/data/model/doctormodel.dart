import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class DoctorModel extends UserModel {
  final String specialization;
  final String licenseNumber;
  final String experienceYears;
  final String clinicLocation;
  final String hospitalName;

  DoctorModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    required this.specialization,
    required this.licenseNumber,
    required this.experienceYears,
    required this.clinicLocation,
    required this.hospitalName,
  }) : super(userType: 'doctor');

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'created_at': Timestamp.fromDate(createdAt),
      'specialization': specialization,
      'license_number': licenseNumber,
      'experience_years': experienceYears,
      'clinic_location': clinicLocation,
      'hospital_name': hospitalName,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      uid: map['uid'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      specialization: map['specialization'] ?? '',
      licenseNumber: map['license_number'] ?? '',
      experienceYears: map['experience_years'] ?? '',
      clinicLocation: map['clinic_location'] ?? '',
      hospitalName: map['hospital_name'] ?? '',
    );
  }
}