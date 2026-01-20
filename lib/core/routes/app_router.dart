import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/Reminders/presentation/screens/Reminders_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/AppointmentBooking.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart';
import 'package:health_compass/feature/auth/presentation/screen/my_doctors.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screen.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screens.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/signup_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/forgotpass_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:health_compass/feature/auth/presentation/screen/patient_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/doctor_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart';
import 'package:health_compass/feature/family_invite/family_invite.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/health_dashboard/ui/screens/health_dashboard_screen.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/feature/achievements/preesntation/screens/achievements_page.dart';
import 'package:health_compass/feature/profile/patient_profile.dart';

import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/presentation/screens/family_member_home_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/link_patient_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/family_profile_screen.dart';
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
        return MaterialPageRoute(builder: (_) => const SignupPage());

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
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) =>
                AuthDI.signupCubit, // أو طريقتك في توفير الكيوبت
            child: FamilyMemberInfoScreen(
              email: args['email'],
              password: args['password'],
            ),
          ),
        );

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

      case AppRoutes.healthDashboard:
        return MaterialPageRoute(builder: (_) => const HealthDashboardScreen());

      case AppRoutes.chatBot:
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());

      case AppRoutes.my_doctors:
        return MaterialPageRoute(builder: (_) => const MyDoctorsScreen());

      case AppRoutes.familyHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => FamilyCubit(FamilyRepository()),
            child: const FamilyMemberHomeScreen(),
          ),
        );

      // 2. صفحة ربط المريض (إدخال الكود)
      case AppRoutes.linkPatient:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => FamilyCubit(FamilyRepository()),
            child: const LinkPatientScreen(), // تأكد من وجود const هنا
          ),
        );

      // 3. صفحة إعدادات الحساب الشخصي لفرد العائلة
      case AppRoutes.familyProfile:
        return MaterialPageRoute(builder: (_) => const FamilyProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
