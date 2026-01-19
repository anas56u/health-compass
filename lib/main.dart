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
import 'package:permission_handler/permission_handler.dart';
// 👇 1. إضافة استيراد SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  final Box<ReminderModel> reminderBox = await Hive.openBox<ReminderModel>('reminders');

  final notificationService = NotificationService();
  await notificationService.init();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await notificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  // طلب الإذن الضروري للفتح من الخلفية
  await _requestSystemAlertWindowPermission();

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
      launchDetails: notificationAppLaunchDetails, 
    ),
  );
}

Future<void> _requestSystemAlertWindowPermission() async {
  if (!await Permission.systemAlertWindow.isGranted) {
    debugPrint("⚠️ System Alert Window permission not granted. Requesting...");
    await Permission.systemAlertWindow.request();
  } else {
    debugPrint("✅ System Alert Window permission is granted.");
  }
}

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

// 👇 2. إضافة WidgetsBindingObserver لمراقبة حالة التطبيق
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  
  // متغيرات لتخزين حالة الطوارئ
  bool _isEmergencyFromBackground = false;
  double _emergencyValue = 0.0;

  @override
  void initState() {
    super.initState();
    // تسجيل المراقب
    WidgetsBinding.instance.addObserver(this);
    // فحص فوري عند فتح التطبيق
    _checkEmergencyState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // هذه الدالة تعمل عندما يعود التطبيق للعمل (Resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkEmergencyState();
    }
  }

  // 👇 3. دالة قراءة الذاكرة (SharedPreferences)
  Future<void> _checkEmergencyState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // قراءة العلامة التي وضعتها Background Service
      bool isEmergency = prefs.getBool('is_emergency_active') ?? false;
      
      if (isEmergency) {
        double val = prefs.getDouble('emergency_value') ?? 0.0;
        
        debugPrint("🚨 FOUND EMERGENCY FLAG IN MEMORY: $val");

        // تنظيف العلامة حتى لا تظهر للأبد
        await prefs.setBool('is_emergency_active', false);

        setState(() {
          _isEmergencyFromBackground = true;
          _emergencyValue = val;
        });
      }
    } catch (e) {
      debugPrint("Error checking emergency state: $e");
    }
  }

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
              create: (context) =>
                  RemindersCubit(widget.reminderBox, widget.notificationService),
            ),
            BlocProvider(create: (context) => HealthCubit()),
            BlocProvider(
              create: (context) =>
                  UserCubit(authRepository: authRepository)..getUserData(),
            ),
            BlocProvider(create: (context) => SignupCubit(authRepository)),
            BlocProvider(create: (context) => FamilyCubit(familyRepository)),
            BlocProvider(
              create: (context) => DoctorHomeCubit(),
            )
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
            
            // 👇 4. استخدام الدالة المعدلة التي تفحص الذاكرة والإشعارات معاً
            home: _determineHomeScreen(),
            
            onGenerateRoute: AppRouter().generateRoute,
          ),
        );
      },
    );
  }

  Widget _determineHomeScreen() {
    // الأولوية 1: الفتح الإجباري من الخلفية (عن طريق SharedPrefs)
    if (_isEmergencyFromBackground) {
      return EmergencyScreen(
        message: "تنبيه: تم رصد مؤشر حيوي خطير أثناء العمل في الخلفية!",
        value: _emergencyValue,
      );
    }

    // الأولوية 2: الفتح عن طريق الضغط على الإشعار
    if (widget.launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = widget.launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.contains('emergency')) {
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