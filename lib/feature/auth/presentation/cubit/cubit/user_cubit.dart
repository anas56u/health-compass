import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/auth/domain/repository/auth_repository.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final AuthRepository authRepository;

  UserCubit({required this.authRepository}) : super(UserInitial());
  void clearUserData() {
    emit(UserInitial()); 
  }

  Future<void> getUserData() async {
    emit(UserLoading());
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel = await authRepository.getUserData(uid: currentUser.uid);
        emit(UserLoaded(userModel));
      } else {
        emit(UserError("لا يوجد مستخدم مسجل دخول حالياً"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}