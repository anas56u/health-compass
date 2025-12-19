import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';

abstract class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String userType;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap();

  factory UserModel.fromMap(Map<String, dynamic> map) {
   
    return map['user_type'] == 'doctor' 
        ? DoctorModel.fromMap(map) 
        : PatientModel.fromMap(map);
  }
}