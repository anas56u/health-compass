import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/model/user_model.dart';

abstract class AuthRepository {
  Future<UserCredential> login({
    required String email,
    required String password,
  });

 Future<void> registerUser({
    required UserModel user,
    required String password,
    File? imagefile, 
  });
Future<UserModel> getUserData({required String uid});
  Future<void> logout();

  Future<void> resetPassword({required String email});

  User? getCurrentUser();
}
