import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/cache/onboarding_manager.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/themes/app_gradient.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/doctor/doctor_main_screen.dart';
import 'package:health_compass/feature/doctor/home/pages/doctor_home_page.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/presentation/screens/family_member_home_screen.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/feature/auth/presentation/screen/splash_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _checkAuthStatus();
  }

  void _initAnimations() {
    // Scale Animation - للتكبير والتصغير
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Fade Animation - للظهور التدريجي
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Pulse Animation - نبضات متكررة
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _scaleController.forward();
    _fadeController.forward();

    // بدء النبضات المتكررة بعد انتهاء الأنيميشن الأول
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

 Future<void> _checkAuthStatus() async {
  await Future.delayed(const Duration(milliseconds: 2500));

  // 1. فحص حالة تسجيل الدخول
  final isLoggedIn = await SharedPrefHelper.isUserLoggedIn();

  if (!mounted) return;

  if (isLoggedIn) {
    // ... (الكود الخاص بتوجيه المستخدم المسجل كما هو لم يتغير) ...
    final userType = await SharedPrefHelper.getString('user_type');
    Widget startScreen;
    if (userType == 'doctor') {
      startScreen = const DoctorMainScreen(); 
    } else if (userType == 'family_member') {
      startScreen = BlocProvider(
          create: (context) => FamilyCubit(FamilyRepository()),
          child: const FamilyMemberHomeScreen(),
      );
    } else {
      startScreen = const Patientview_body();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => startScreen),
    );
  } else {
    // 👇 التعديل الجوهري هنا 👇
    
    // 2. إذا لم يكن مسجل دخول، نفحص هل شاهد الـ Onboarding من قبل؟
    final hasSeenOnboarding = await OnboardingManager.hasSeenOnboarding();

    if (hasSeenOnboarding) {
      // ✅ إذا شاهدها سابقاً، نذهب لصفحة الدخول مباشرة
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      // ❌ إذا لم يشاهدها (أول مرة يفتح التطبيق)، نعرض شاشات الترحيب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreens()),
      );
    }
  }
}

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: Listenable.merge([
                _scaleController,
                _fadeController,
                _pulseController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // App Name with Fade Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.easeOut,
                      ),
                    ),
                child: Column(
                  children: [
                    Text(
                      'بوصلة الصحة',
                      style: AppTextStyling.fontFamilyTajawal.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'دليلك الصحي الشامل',
                      style: AppTextStyling.fontFamilyTajawal.copyWith(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Loading Indicator with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري التحميل...',
                    style: AppTextStyling.fontFamilyTajawal.copyWith(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
