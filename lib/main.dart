import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:health_compass/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/SimpleBlocObserver.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/health_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 الخطأ عندك هنا: يجب أن تبدأ بـ MaterialApp
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Compass',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      // 👇 وهنا تضع شاشتك
      home: const ChatBotScreen(),
    );
  }
}
// void main() async {
//   Bloc.observer = SimpleBlocObserver();

//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//       return  MultiBlocProvider(
//           providers: [
//             BlocProvider(create: (context) => HealthCubit()),

//             BlocProvider(
//               create: (context) => SignupCubit(
//                 AuthRepositoryImpl(
//                   remoteDataSource: AuthRemoteDataSourceImpl(),
//                 ),
//               ),
//             ),
//           ],
//           child: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             initialRoute: AppRoutes.splash,
//             onGenerateRoute: AppRouter().generateRoute,
//           ),
//         );
//       },
//     );
//   }
// }
