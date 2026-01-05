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
    super.profileImage, // 1. تمرير الصورة للأب
    required this.specialization,
    required this.licenseNumber,
    required this.experienceYears,
    required this.clinicLocation,
    required this.hospitalName,
  }) : super(userType: 'doctor');

  // 2. تنفيذ دالة copyWith
  @override
  DoctorModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? specialization,
    String? licenseNumber,
    String? experienceYears,
    String? clinicLocation,
    String? hospitalName,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      hospitalName: hospitalName ?? this.hospitalName,
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
      'profile_image': profileImage, // 3. حفظ الرابط
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
      profileImage: map['profile_image'], // 4. استرجاع الرابط
      specialization: map['specialization'] ?? '',
      licenseNumber: map['license_number'] ?? '',
      experienceYears: map['experience_years'] ?? '',
      clinicLocation: map['clinic_location'] ?? '',
      hospitalName: map['hospital_name'] ?? '',
    );
  }
}