import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ تأكد من استيراد موديل العائلة للوصول لحقل permission
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import '../../../domain/repository/auth_repository.dart';
import '../../../data/model/user_model.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;

  SignupCubit(this._authRepository) : super(SignupInitial());

  Future<void> registerUser({
    required UserModel userModel,
    required String password,
    File? profileImage,
  }) async {
    emit(SignupLoading());
    try {
      await _authRepository.registerUser(
        user: userModel,
        password: password,
        imagefile: profileImage,
      );

      String permission = 'interactive';
      if (userModel is FamilyMemberModel) {
        permission = userModel.permission;
      }

      emit(SignupSuccess(userType: userModel.userType, permission: permission));
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}
