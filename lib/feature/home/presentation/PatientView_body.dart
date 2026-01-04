import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/widgets/Accessibility_facilities.dart';
import 'package:health_compass/core/widgets/WeeklyChallenge.dart';
import 'package:health_compass/core/widgets/bottom_nav_bar.dart';
import 'package:health_compass/core/widgets/daily_tasks.dart';
import 'package:health_compass/core/widgets/header_patientview.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_cubit.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_state.dart';
import 'package:health_compass/feature/achievements/preesntation/screens/achievements_page.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart';
import 'package:health_compass/feature/family_invite/family_invite.dart';
import 'package:health_compass/feature/medications/pages/medications_page.dart';

class Patientview_body extends StatefulWidget {
  const Patientview_body({super.key});

  @override
  State<Patientview_body> createState() => _Patientview_bodyState();
}

class _Patientview_bodyState extends State<Patientview_body> {
  int _selectedIndex = 0;
  final Color _backgroundColor = const Color(0xFFF9FAFB); // خلفية فاتحة جداً

  final List<Widget> _pages = [
    const HomeContent(),
    const MedicationsPage(),
   const FamilyInvitePage(),
    const SizedBox(),
    const AchievementsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل تريد تسجيل الخروج؟',
            style: GoogleFonts.tajawal(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'خروج',
                style: GoogleFonts.tajawal(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (shouldLogout == true && mounted) {
      await SharedPrefHelper.clearLoginData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 3) {
      return ChatBotScreen(onBack: () => setState(() => _selectedIndex = 0));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,

        appBar: AppBar(
          title: Text(
            'الرئيسية',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D9488),
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'خروج',
              onPressed: _handleLogout,
            ),
          ],
        ),

        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),

        body: _pages[_selectedIndex],
      ),
    );
  }
}

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
                  // رسالة خطأ بسيطة وواضحة
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
            const SizedBox(height: 10),
            buildWeeklyChallenges(),

            // مسافة للبار السفلي
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
