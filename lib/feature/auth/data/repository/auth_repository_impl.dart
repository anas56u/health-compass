import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> registerUser({
    required UserModel user,
    required String password,
  }) async {
    return await remoteDataSource.registerUser(
      userModel: user,
      password: password,
    );
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
