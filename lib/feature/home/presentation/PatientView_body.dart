import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/widgets/Accessibility_facilities.dart';
import 'package:health_compass/core/widgets/EmergencyScreen.dart'; //
import 'package:health_compass/core/widgets/WeeklyChallenge.dart';
import 'package:health_compass/core/widgets/bottom_nav_bar.dart';
import 'package:health_compass/core/widgets/daily_tasks.dart';
import 'package:health_compass/core/widgets/header_patientview.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_cubit.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_state.dart';
import 'package:health_compass/feature/achievements/preesntation/screens/achievements_page.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart';
import 'package:health_compass/feature/family_invite/family_invite.dart';
import 'package:health_compass/feature/medications/pages/medications_page_firebase.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/health_cubit.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';
import 'package:health_compass/feature/patient/data/repo/patient_repo.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart'; 
import 'package:health_compass/feature/auth/data/model/PatientModel.dart'; 

class Patientview_body extends StatefulWidget {
  const Patientview_body({super.key});

  @override
  State<Patientview_body> createState() => _Patientview_bodyState();
}

class _Patientview_bodyState extends State<Patientview_body> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().getUserData();
    });
  }

  int _selectedIndex = 0;
  final Color _backgroundColor = const Color(0xFFF9FAFB);

  final List<Widget> _pages = [
    const HomeContent(),
    const MedicationsPageFirebase(),
    const FamilyInvitePage(),
    const SizedBox(),
    const AchievementsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 3) {
      return ChatBotScreen(onBack: () => setState(() => _selectedIndex = 0));
    }

    return BlocListener<HealthCubit, HealthState>(
      // ✅ 2. تحويل الـ listener إلى async لنتمكن من انتظار جلب البيانات
      listener: (context, state) async {
        if (state is HealthCritical) {
          
          // متغيرات لتخزين الأرقام
          String? fetchedDoctorPhone;
          String? fetchedFamilyPhone;

          // أ. الحصول على بيانات المستخدم الحالي من UserCubit
          final userState = context.read<UserCubit>().state;
          
          if (userState is UserLoaded && userState.userModel is PatientModel) {
            // ب. إذا كان المستخدم مريضاً ومحملاً، نقوم بجلب الأرقام
            final currentPatient = userState.userModel as PatientModel;
            final patientRepo = PatientRepo(); // إنشاء نسخة من الريبو
            
            // ج. استدعاء الدالة وانتظار النتيجة
            // ملاحظة: هذا الإجراء سريع جداً عادةً، لكن يمكن إضافة مؤشر تحميل إذا أردت
            final contacts = await patientRepo.getEmergencyContacts(currentPatient);
            
            fetchedDoctorPhone = contacts['doctor'];
            fetchedFamilyPhone = contacts['family'];
          }

          // د. التحقق مما إذا كان السياق (context) لا يزال صالحاً بعد العملية غير المتزامنة
          if (!context.mounted) return;

          // هـ. التوجيه لصفحة الطوارئ مع تمرير الأرقام الحقيقية
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmergencyScreen(
                message: state.message,
                value: state.criticalValue,
                // تمرير الأرقام التي تم جلبها (قد تكون null وهذا مقبول في تصميم الشاشة)
                doctorPhoneNumber: fetchedDoctorPhone,
                familyPhoneNumber: fetchedFamilyPhone,
              ),
            ),
          ).then((_) {
            // عند العودة من صفحة الطوارئ
            context.read<HealthCubit>().resetEmergencyMode();
          });
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          bottomNavigationBar: BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          body: _pages[_selectedIndex],
        ),
      ),
    );
  }
}

// ... (HomeContent remains the same as your code)
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HometaskCubit()..startTracking(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            header_patientview(),
            const SizedBox(height: 20),
            BlocBuilder<HometaskCubit, HometaskState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  );
                } else if (state is HomeLoaded) {
                  return DailyTasksList(
                    tasksStatus: state.dailyData.tasksStatus,
                  );
                } else if (state is HomeError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.message,
                            style: GoogleFonts.tajawal(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 10),
            AccessibilityFacilities(),
           
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}