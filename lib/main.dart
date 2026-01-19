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
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  Bloc.observer = SimpleBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase (يجب أن تكون الأولى دائماً لأن الإشعارات تعتمد عليها)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. تهيئة Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  final Box<ReminderModel> reminderBox = await Hive.openBox<ReminderModel>(
    'reminders',
  );

  // 3. تهيئة الإشعارات (الآن ستعمل لأن Firebase جاهز)
  final notificationService = NotificationService();
  await notificationService.init();
try {
    debugPrint("Attemping to start background service...");
    await initializeBackgroundService();
    debugPrint("Background service initialization called.");
  } catch (e) {
    debugPrint("❌ Failed to start background service: $e");
  }
  // 4. تهيئة تنسيق التاريخ
  await initializeDateFormatting();

  runApp(
    MyApp(reminderBox: reminderBox, notificationService: notificationService),
  );
}

class MyApp extends StatelessWidget {
  // ... (باقي الكلاس كما هو بدون تغيير)
  final Box<ReminderModel> reminderBox;
  final NotificationService notificationService;



  const MyApp({
    super.key,
    required this.reminderBox,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(),
    );

    // ✅ إنشاء مستودع العائلة
    final familyRepository = FamilyRepository();

    

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // --- الكيوبتات القديمة ---
            BlocProvider(
              create: (context) =>
                  RemindersCubit(reminderBox, notificationService),
            ),
            BlocProvider(create: (context) => HealthCubit()),
            BlocProvider(
              create: (context) =>
                  UserCubit(authRepository: authRepository)..getUserData(),
            ),
            BlocProvider(create: (context) => SignupCubit(authRepository)),

            // ✅✅ إضافة FamilyCubit الجديد هنا ليصبح متاحاً للتطبيق بالكامل ✅✅
            BlocProvider(create: (context) => FamilyCubit(familyRepository)),
            BlocProvider(
              create: (context) => DoctorHomeCubit(),
            )
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey, // 👈 اربطه هنا
            debugShowCheckedModeBanner: false,
            title: 'Health Compass',
            theme: ThemeData(
              useMaterial3: true,
              primaryColor: const Color(0xFF41BFAA),
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            ),
            // إعدادات التوجيه (Routing)
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter().generateRoute,
          ),
        );
      },
    );
  }
}