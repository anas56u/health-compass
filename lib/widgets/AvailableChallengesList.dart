 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/widgets/ChallengeCard.dart';

Widget AvailableChallengesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3 متاحة',
                  style: GoogleFonts.tajawal(
                    color: const Color(0xFF009688),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'التحديات المتاحة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const ChallengeCard(
            title: 'الالتزام بالادوية',
            subtitle: 'التزم بأخذ ادويتك لمدة 7 ايام متتالية',
            badgeText: 'أسبوعياً',
            badgeColor: Color(0xFFD1C4E9),
            badgeTextColor: Color(0xFF5E35B1),
            timeText: 'متبقي يومان',
            progressText: "من الايام التي تم انجازها 7/5",
            points: 'نقطة 500+',
            percent: 0.7,
            primaryColor: Color(0xFF006994),
            icon: Icons.medication,
          ),

          const ChallengeCard(
            title: 'الالتزام بالمشي',
            subtitle: 'امشي 3000 خطوة اليوم',
            badgeText: 'يومياً',
            badgeColor: Color(0xFFC8E6C9),
            badgeTextColor: Color(0xFF2E7D32),
            timeText: 'متبقي 5 ساعات',
            progressText: '1500/3000 خطوة',
            points: 'نقطة 100+',
            percent: 0.5,
            primaryColor: Color(0xFF43A047),
            icon: Icons.directions_walk,
          ), const ChallengeCard(
            title: 'الالتزام بقراءة افضل',
            subtitle: 'حافظ على قراءة بمعدل ال %80',
            badgeText: 'شهرياً',
            badgeColor: Color(0xFFFFCCBC),
            badgeTextColor: Color(0xFFD84315),
            timeText: 'متبقي 18 يوم',
            progressText: '12/30 من الايام تم انجازها',
            points: 'نقطة 500+',
            percent: 0.4, 
            primaryColor: Color(0xFFFF7043),
            icon: Icons.insights,
          ),
        ],
      ),
    );
  }
