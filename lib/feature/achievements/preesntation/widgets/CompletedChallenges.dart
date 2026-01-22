import 'dart:ui';
import 'package:flutter/material.dart';
// تأكد من استدعاء الموديل الخاص بك
import 'package:health_compass/feature/achievements/data/model/challenge_model.dart';

class CompletedChallengesSection extends StatelessWidget {
  // 1. تحديد نوع البيانات بدقة
  final List<ChallengeModel> challenges;

  const CompletedChallengesSection({
    super.key, 
    required this.challenges
  });

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

            // 2. التحقق من وجود بيانات قبل العرض
            if (challenges.isEmpty)
              _buildEmptyState()
            else
              // 3. تحويل القائمة إلى ويدجت
              ...challenges.map((challenge) {
                return Column(
                  children: [
                    CompletedChallengeTile(
                      title: challenge.title,
                      subtitle: challenge.subtitle,
                      points: "${challenge.points}+", // تحويل الرقم لنص
                      icon: challenge.icon,
                      iconColor: challenge.color,
                      isCompleted: challenge.isCompleted,
                    ),
                    const SizedBox(height: 15),
                  ],
                );
              }).toList(),
              
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ويدجت بسيط يظهر في حال لم يكمل المستخدم أي تحدي بعد
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "لم تقم بإتمام أي تحدي بعد، ابدأ الآن!",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ),
    );
  }
}

// 4. قمنا بتغيير الاسم ليكون أكثر دقة ومنعاً للتضارب مع الكارد الرئيسية
class CompletedChallengeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String points;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;

  const CompletedChallengeTile({
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
              // تغيير اللون بناءً على حالة الاكتمال
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