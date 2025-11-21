import 'package:flutter/material.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/screens/PatientView_body.dart';
import 'package:health_compass/screens/forgotpass_page.dart';

class Routers {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case AppRoutes.loginView:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case AppRoutes.forgetPasswordView:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case AppRoutes.patientView:
        return MaterialPageRoute(builder: (_) => Patientview_body());
    }
    return null;
  }
}
