import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repository/auth_repository.dart';
import '../../../data/model/user_model.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;

  SignupCubit(this._authRepository) : super(SignupInitial());

  Future<void> registerUser({
    required UserModel userModel,
    required String password,
    File? profileImage, // <--- إضافة هذا
  }) async {
    emit(SignupLoading());
    try {
      await _authRepository.registerUser(
        user: userModel,
        password: password,
        imagefile: profileImage, // <--- تمريرها للريبو
      );
      emit(SignupSuccess());
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}
