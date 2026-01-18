import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AchievementsHeaderCard extends StatelessWidget {

final int points;
  final int level;
  final double progress;

  const AchievementsHeaderCard({
    super.key,
    required this.points,
    required this.level,
    required this.progress,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              _buildCircleBadge(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 2),
                    Text(
                     'المستوى $level',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                colors: [Colors.orange.shade400, Colors.orange.shade700],
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      'صانع الإنجازات',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'كل إنجاز صغير يصنع الفرق',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              _buildCircleBadge(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.tajawal(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'للانتقال\nللمستوى 3',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        color: Colors.black87,
                        fontSize: 8,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                colors: [const Color(0xFFFFCA28), const Color(0xFFFFB300)],
              ),
            ],
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: LinearPercentIndicator(
              padding: EdgeInsets.zero,
              percent: 0.75,
              lineHeight: 12.0,
              animation: true,
              animationDuration: 1000,
              barRadius: const Radius.circular(10),
              backgroundColor: Colors.grey.shade200,
              linearGradient: const LinearGradient(
                colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
              ),
              isRTL: true,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFA000),
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                   ' $points' ,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA000),
                    ),
                  ),
                ],
              ),
              Text(
                'اجمع 5000 نقطه لتحصل على المكافأة',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBadge({
    required Widget content,
    required List<Color> colors,
  }) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }
}
