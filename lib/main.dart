import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/services/background_service.dart';
import 'package:health_compass/core/services/notification_service.dart';
import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';
import 'package:health_compass/feature/Reminders/presentation/cubits/reminder_cubit.dart';
import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:health_compass/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeCubit.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/SimpleBlocObserver.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/health_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_compass/core/widgets/EmergencyScreen.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  final Box<ReminderModel> reminderBox = await Hive.openBox<ReminderModel>(
    'reminders',
  );

  final notificationService = NotificationService();
  await notificationService.init();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await notificationService.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

  try {
    debugPrint("Attemping to start background service...");
    await initializeBackgroundService();
  } catch (e) {
    debugPrint("❌ Failed to start background service: $e");
  }

  await initializeDateFormatting();

  runApp(
    MyApp(
      reminderBox: reminderBox,
      notificationService: notificationService,
      // تمرير التفاصيل للتطبيق
      launchDetails: notificationAppLaunchDetails,
    ),
  );
}

// حولنا MyApp إلى StatefulWidget لمراقبة الحالة (اختياري ولكنه أفضل)
class MyApp extends StatefulWidget {
  final Box<ReminderModel> reminderBox;
  final NotificationService notificationService;
  final NotificationAppLaunchDetails? launchDetails;

  const MyApp({
    super.key,
    required this.reminderBox,
    required this.notificationService,
    this.launchDetails,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(),
    );
    final familyRepository = FamilyRepository();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => RemindersCubit(
                widget.reminderBox,
                widget.notificationService,
              ),
            ),
            BlocProvider(create: (context) => HealthCubit()),
            BlocProvider(
              create: (context) =>
                  UserCubit(authRepository: authRepository)..getUserData(),
            ),
            BlocProvider(create: (context) => SignupCubit(authRepository)),
            BlocProvider(create: (context) => FamilyCubit(familyRepository)),
            BlocProvider(create: (context) => DoctorHomeCubit()),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Health Compass',
            theme: ThemeData(
              useMaterial3: true,
              primaryColor: const Color(0xFF41BFAA),
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            ),

            // 🔥 التعديل الجوهري هنا 🔥
            // حذفنا initialRoute واستخدمنا home مع دالة الفحص
            home: _determineHomeScreen(),

            onGenerateRoute: AppRouter().generateRoute,
          ),
        );
      },
    );
  }

  // هذه الدالة تقرر أي شاشة تظهر أولاً
  Widget _determineHomeScreen() {
    // هل تم فتح التطبيق بسبب إشعار طوارئ؟
    if (widget.launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = widget.launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.contains('emergency')) {
        debugPrint("🚨 Emergency Launch Detected! Opening Emergency Screen...");

        // استخراج القيمة
        final parts = payload.split('_');
        double value = 0.0;
        if (parts.length > 1) {
          value = double.tryParse(parts[1]) ?? 0.0;
        }

        return EmergencyScreen(
          message: "تنبيه: تم رصد مؤشر حيوي خطير!",
          value: value,
        );
      }
    }

    // الوضع الطبيعي
    return const SplashScreen();
  }
}
