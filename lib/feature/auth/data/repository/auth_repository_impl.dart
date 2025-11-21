import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
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
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.register(email: email, password: password);
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
