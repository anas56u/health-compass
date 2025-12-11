import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/widgets/Accessibility_facilities.dart';
import 'package:health_compass/core/widgets/WeeklyChallenge.dart';
import 'package:health_compass/core/widgets/bottom_nav_bar.dart';
import 'package:health_compass/core/widgets/daily_tasks.dart';
import 'package:health_compass/core/widgets/header_patientview.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/feature/health_tracking/presentation/HealthStatus_Card.dart';

class Patientview_body extends StatefulWidget {
  const Patientview_body({super.key});

  @override
  State<Patientview_body> createState() => _Patientview_bodyState();
}

class _Patientview_bodyState extends State<Patientview_body> {
  int _selectedIndex = 0;
  final Color _activeColor = const Color(0xFF0D9488);
  final Color _inactiveColor = Colors.grey.shade600;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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
    return Scaffold(
      
      extendBody: true,
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: 
      BottomNavBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            header_patientview(),
            SizedBox(height: 20),
            DailyTasks(),
            AccessibilityFacilities(),
            buildWeeklyChallenges(),
          ],
        ),
      ),
    );
  }
}
