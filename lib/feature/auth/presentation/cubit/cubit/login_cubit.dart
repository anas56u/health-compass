import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/feature/auth/domain/usecases/login_usecase.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());

    try {
      final userCredential = await loginUseCase(
        email: email,
        password: password,
      );

      // Save login state to SharedPreferences
      await SharedPrefHelper.saveLoginState(
        isLoggedIn: true,
        email: userCredential.user?.email,
        userId: userCredential.user?.uid,
      );

      emit(
        LoginSuccess(
          message: 'تم تسجيل الدخول بنجاح',
          user: userCredential.user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(error: e.message ?? 'حدث خطأ أثناء تسجيل الدخول'));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }

  void reset() {
    emit(LoginInitial());
  }

  Future<void> logout() async {
    await SharedPrefHelper.clearLoginData();
    emit(LoginInitial());
  }
}
