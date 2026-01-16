import 'package:flutter/material.dart';
import 'widgets/doctor_bottom_nav.dart';
import 'home/pages/doctor_home_page.dart';
import 'home/pages/notifications_page.dart';
import 'home/pages/chat_page.dart';
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

  static final List<Widget> _pages = [
    const DoctorHomePage(),
    const NotificationsPage(),
    const ChatPage(),
    const AppointmentsPage(),
    
  ];

  void _onNavTap(BuildContext context, int index) {
    // Since we're using StatelessWidget, we need to rebuild the entire widget tree
    // with the new index. For a simple demo, we'll use Navigator replacement
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
    const ChatPage(),
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
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: index,
        onTap: (newIndex) => _onNavTap(context, newIndex),
      ),
    );
  }
}

