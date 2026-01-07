import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/Reminders/preesntation/screens/Reminders_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/AppointmentBooking.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart';

// --- استيراد ملفات Auth حسب المسارات الحالية في مشروعك ---
import 'package:health_compass/feature/auth/presentation/screen/splash_screen.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/splash_screens.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/signup_page.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/forgotpass_page.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/patient_info.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/doctor_info.dart'; //
import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart'; //
import 'package:health_compass/feature/family_invite/family_invite.dart';

// --- استيراد ملفات Home ---
import 'package:health_compass/feature/home/presentation/PatientView_body.dart'; //

// --- استيراد ملفات Achievements ---
// ملاحظة: المسار يحتوي على كلمة 'preesntation' كما هو في ملفاتك
import 'package:health_compass/feature/achievements/preesntation/screens/achievements_page.dart'; //

// --- استيراد الكيوبت والـ DI ---
import 'package:health_compass/feature/auth/presentation/cubit/cubit/login_cubit.dart'; //
import 'package:health_compass/feature/auth/di/auth_di.dart';
import 'package:health_compass/feature/profile/patient_profile.dart'; //

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    // استقبال البيانات الممررة (إن وجدت)
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      // 1. شاشات البداية
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onBoarding:
        // OnboardingPageView موجودة داخل ملف splash_screens.dart
        return MaterialPageRoute(builder: (_) => const OnboardingPageView());

      // 2. المصادقة واختيار المستخدم
      case AppRoutes.userType:
        return MaterialPageRoute(
          builder: (_) =>
              UserType(email: args['email'], password: args['password']),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthDI.loginCubit,
            child: const LoginPage(),
          ),
        );
        

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const signup_page());

      case AppRoutes.forgetPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());

      case AppRoutes.patientInfo:
        return MaterialPageRoute(
          builder: (_) => PatientInfoScreen(
            email: args['email'],
            password: args['password'],
          ),
        );

      case AppRoutes.doctorInfo:
        return MaterialPageRoute(
          builder: (_) => DoctorInfoScreen(
            email: args['email'],
            password: args['password'],
          ),
        );

      case AppRoutes.familyMemberInfo:
        return MaterialPageRoute(builder: (_) => FamilyMemberInfoScreen());

      case AppRoutes.patientHome:
        return MaterialPageRoute(builder: (_) => const Patientview_body());

      case AppRoutes.achievements:
        return MaterialPageRoute(builder: (_) => const AchievementsPage());
      case AppRoutes.appointmentBooking:
        return MaterialPageRoute(
          builder: (_) => const AppointmentBookingScreen(),
        );
        case AppRoutes.profileSettings:
        return MaterialPageRoute(
          builder: (_) => const PatientProfilePage(),
        );
        case AppRoutes.familyInvite:
        return MaterialPageRoute(
          builder: (_) => const FamilyInvitePage(),
        );
        case AppRoutes.reamindersPage:
        return MaterialPageRoute(
          builder: (_) => const RemindersPage(),
        );
        case AppRoutes.chatScreen:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
