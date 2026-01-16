import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/domain/usecases/login_usecase.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());

    try {
      // 1. تنفيذ عملية تسجيل الدخول
      final userCredential = await loginUseCase(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      String userType = 'patient';
      String route = AppRoutes.patientHome;

      String permission = 'interactive';

      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data()!;

            // ✅✅ التعديل هنا: استخدام user_type بدلاً من userType
            userType = data['user_type'] ?? 'patient';

            if (userType == 'family_member') {
              permission = data['permission'] ?? 'view_only';
            }

            if (userType == 'family_member') {
              final List linkedPatients = data['linked_patients'] ?? [];
              if (linkedPatients.isNotEmpty) {
                route = AppRoutes.familyHome;
              } else {
                route = AppRoutes.linkPatient;
              }
            } else if (userType == 'doctor') {
              // route = AppRoutes.doctorHome;
            } else {
              route = AppRoutes.patientHome;
            }
          }
        } catch (e) {
          print("Error fetching user role: $e");
        }
      }

      // 3. حفظ البيانات في الكاش
      await SharedPrefHelper.saveLoginState(
        isLoggedIn: true,
        email: user?.email,
        userId: user?.uid,
      );

      // 4. إرسال حالة النجاح مع الصلاحية
      emit(
        LoginSuccess(
          message: 'تم تسجيل الدخول بنجاح',
          user: user,
          userType: userType,
          route: route,
          permission: permission, // ✅ تمرير الصلاحية للواجهة
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(error: e.message ?? 'حدث خطأ أثناء تسجيل الدخول'));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }
}
