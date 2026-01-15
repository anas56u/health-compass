import 'package:flutter/material.dart';
import 'package:health_compass/feature/doctor/home/pages/doctor_requstes_page.dart';

class DoctorHeader extends StatelessWidget {
  final String doctorName;

  const DoctorHeader({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const DoctorRequestsPage())
      );},
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF0D9488),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'مرحباً بك د.$doctorName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              'تابع تقدم الحاله الصحيه للمرضى',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
