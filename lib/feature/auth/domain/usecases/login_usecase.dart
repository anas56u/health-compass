import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserCredential> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      throw Exception('البريد الإلكتروني مطلوب');
    }

    if (password.isEmpty) {
      throw Exception('كلمة المرور مطلوبة');
    }

    if (password.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    return await repository.login(email: email, password: password);
  }
}
