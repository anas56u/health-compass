import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart'; // تأكد من اسم الملف (كبير/صغير)
import 'package:health_compass/feature/auth/data/model/user_model.dart';
import 'package:health_compass/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserModel> getUserData({required String uid}) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        
        print("🔍 Debugging User Data:");
        print("User ID: $uid");
        print("User Type from DB: '${data['user_type']}'"); 

        final userType = data['user_type'];

        if (userType != null && userType.toString().trim().toLowerCase() == 'patient') {
          print("✅ Success: Converting to PatientModel");
          return PatientModel.fromMap(data);
        } else {
          print("⚠️ Warning: Converting to normal UserModel because type is not patient");
          return UserModel.fromMap(data);
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("❌ Error in getUserData: $e");
      throw Exception(e.toString());
    }
  }
  @override
  Future<void> registerUser({
    required UserModel user,
    required String password,
    File? imagefile,
  }) async {
    try {
      await remoteDataSource.registerUser(
        userModel: user,
        password: password,
        imagefile: imagefile,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    return await remoteDataSource.resetPassword(email: email);
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }
}