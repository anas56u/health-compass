import 'package:flutter/material.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart'; // ✅ استيراد شاشة الشات بوت
import 'package:health_compass/feature/doctor/widgets/my_patientscreen.dart';
import 'widgets/doctor_bottom_nav.dart';
import 'home/pages/doctor_home_page.dart';
import 'home/pages/notifications_page.dart';
import 'appointment/pages/appointments_page.dart';

class DoctorMainScreen extends StatelessWidget {
  const DoctorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorMainScreenContent();
  }
}

class DoctorMainScreenContent extends StatelessWidget {
  const DoctorMainScreenContent({super.key});

  static int _currentIndex = 0;

  // ✅ القائمة الأصلية (4 صفحات فقط) للحفاظ على شريط التنقل نظيفاً
  static final List<Widget> _pages = [
    const DoctorHomePage(),
    const NotificationsPage(),
    MyPatientsScreen(),
    const AppointmentsPage(),
  ];

  void _onNavTap(BuildContext context, int index) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _DoctorMainScreenWithIndex(index: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // ✅ إضافة الزر العائم (FAB) للمساعد الذكي
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // استخدام push لفتح الشات بوت كصفحة جديدة فوق الحالية
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D9488), // لون الثيم
        elevation: 4,
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),

      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

class _DoctorMainScreenWithIndex extends StatelessWidget {
  final int index;

  const _DoctorMainScreenWithIndex({required this.index});

  static final List<Widget> _pages = [
    const DoctorHomePage(),
    const NotificationsPage(),
    MyPatientsScreen(),
    const AppointmentsPage(),
  ];

  void _onNavTap(BuildContext context, int newIndex) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _DoctorMainScreenWithIndex(index: newIndex),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[index],

      // ✅ تكرار الزر العائم هنا لضمان ظهوره في كل الصفحات عند التنقل
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D9488),
        elevation: 4,
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),

      bottomNavigationBar: DoctorBottomNav(
        currentIndex: index,
        onTap: (newIndex) => _onNavTap(context, newIndex),
      ),
    );
  }
}
