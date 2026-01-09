import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/routes/routes.dart';

// --- استيرادات الشاشات الموجودة ---
import 'package:health_compass/feature/Reminders/preesntation/screens/Reminders_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/AppointmentBooking.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screen.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screens.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/signup_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/forgotpass_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:health_compass/feature/auth/presentation/screen/patient_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/doctor_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart';
import 'package:health_compass/feature/family_invite/family_invite.dart';
import 'package:health_compass/feature/health_dashboard/ui/screens/health_dashboard_screen.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/feature/achievements/preesntation/screens/achievements_page.dart';
import 'package:health_compass/feature/profile/patient_profile.dart';

// --- استيراد الكيوبت والـ DI ---
import 'package:health_compass/feature/auth/presentation/cubit/cubit/login_cubit.dart';
import 'package:health_compass/feature/auth/di/auth_di.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onBoarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPageView());

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
        return MaterialPageRoute(builder: (_) => const PatientProfilePage());

      case AppRoutes.familyInvite:
        return MaterialPageRoute(builder: (_) => const FamilyInvitePage());

      case AppRoutes.reamindersPage:
        return MaterialPageRoute(builder: (_) => const RemindersPage());

      case AppRoutes.chatScreen:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      // --- ✅ إضافة المسار الجديد هنا ---
      case AppRoutes.healthDashboard:
        return MaterialPageRoute(builder: (_) => const HealthDashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
