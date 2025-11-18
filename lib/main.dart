import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/cubits/SimpleBlocObserver.dart';
import 'package:health_compass/cubits/health_cubit/health_cubit.dart';
import 'package:health_compass/screens/PatientView_body.dart';
import 'package:health_compass/screens/doctor_info.dart';
import 'package:health_compass/screens/family_member_info.dart';
import 'package:health_compass/screens/login_page.dart';
import 'package:health_compass/screens/patient_info.dart';
import 'package:health_compass/screens/user_type.dart';
import 'package:health_compass/screens/splash_screens.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:health_compass/widgets/custom_textfild.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HealthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FamilyMemberInfoScreen(),
      ),
    );
  }
}
