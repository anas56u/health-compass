import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:health_compass/feature/auth/data/model/user_model.dart';
import 'package:health_compass/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
 
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
      return await remoteDataSource.getUserData(uid: uid);
    } catch (e) {
      rethrow;
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
