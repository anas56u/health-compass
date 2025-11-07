import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/widgets/Accessibility_facilities.dart';
import 'package:health_compass/widgets/Taskitem_buider.dart';
import 'package:health_compass/widgets/HealthStatus_Card.dart';
import 'package:health_compass/widgets/WeeklyChallenge.dart';
import 'package:health_compass/widgets/custom_text.dart';
import 'package:health_compass/widgets/daily_tasks.dart';
import 'package:health_compass/widgets/header_patientview.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        selectedItemColor: _activeColor,
        unselectedItemColor: _inactiveColor,

        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: _activeColor,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: _inactiveColor,
          fontSize: 11,
        ),

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_liquid_outlined),
            label: 'الادوية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'العائلة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'المساعد الصوتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'الإنجازات',
          ),
        ],
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
