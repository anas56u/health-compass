import 'dart:ui';

import 'package:flutter/material.dart';

class CompletedChallengesSection extends StatelessWidget {
  const CompletedChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "التحديات التي تم اجتيازها",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            const ChallengeCard(
              title: "متابعة حالتك الصحية",
              subtitle: "متابعة قياساتك لمدة 30 يوم متتالية",
              points: "300+",
              icon: Icons.monitor_heart,
              iconColor: Color(0xFFD32F2F),
              isCompleted: true,
            ),

            const SizedBox(height: 15),

            const ChallengeCard(
              title: "7-ايام متتالية",
              subtitle: "اكمل التحديات اليومية لمدة 7 ايام متتالية",
              points: "250+",
              icon: Icons.emoji_events,
              iconColor: Color(0xFFFFA000),
              isCompleted: true,
            ),

            const SizedBox(height: 15),

            const ChallengeCard(
              title: "الشهر المثالي",
              subtitle: "اكمل كل التحديات المطلوبة لمدة شهر",
              points: "500+",
              icon: Icons.lock,
              iconColor: Colors.grey,
              isCompleted: false,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String points;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
    required this.iconColor,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? iconColor : Colors.grey.shade200,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                "نقطة $points",
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
