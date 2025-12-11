import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyChallengeCard extends StatelessWidget {
  final String title;
  final int points;
  final double progress;
  final String description;
  final String remainingDays;
  final List<Color> colors;

  const WeeklyChallengeCard({
    super.key,
    required this.title,
    required this.points,
    required this.progress,
    required this.description,
    required this.remainingDays,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final double progressBarWidth = MediaQuery.of(context).size.width * 0.55;

    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '${points} نقطة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          Stack(
            children: [
              Container(
                height: 6,
                width: progressBarWidth,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: progressBarWidth * progress,
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  description,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                remainingDays,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class buildWeeklyChallenges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'تحديات الأسبوع',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 15),

          const WeeklyChallengeCard(
            title: 'تحدي الاسبوع',
            points: 850,
            progress: 0.7,
            description: 'التزم بأخذ الدواء في موعدها لمدة 7 أيام متتالية',
            remainingDays: 'متبقي 3 أيام',
            colors: [Color(0xFF00796B), Color(0xFF004D40)],
          ),

          const WeeklyChallengeCard(
            title: 'تحدي الاسبوع',
            points: 430,
            progress: 0.4,
            description: 'التزم بقياس الضغط لمدة 7 أيام متتالية',
            remainingDays: 'متبقي 3 أيام',
            colors: [Color(0xFF5D665E), Color(0xFF4C554E)],
          ),
        ],
      ),
    );
  }
}
