import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/feature/achievements/preesntation/widgets/ChallengeCard.dart';
// تأكد أن المسار صحيح للنموذج الذي أنشأناه سابقاً
import 'package:health_compass/feature/achievements/data/model/challenge_model.dart';

class AvailableChallengesList extends StatelessWidget {
  final List<ChallengeModel> challenges;

  const AvailableChallengesList({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- قسم العنوان ---
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenges.length} متاحة', // الرقم يتغير ديناميكياً
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

          // --- قسم توليد البطاقات ديناميكياً ---
          // نقوم بالمرور على كل تحدي في القائمة وتحويله لبطاقة
          ...challenges.map((challenge) {
            return Column(
              children: [
                ChallengeCard(
                  title: challenge.title,
                  subtitle: challenge.subtitle,
                  // نستخدم دوال مساعدة لتحديد الألوان والنصوص بناءً على النوع
                  badgeText: _getBadgeText(challenge.type),
                  badgeColor: _getBadgeColor(challenge.type),
                  badgeTextColor: _getBadgeTextColor(challenge.type),
                  
                  // حسابات بسيطة للعرض
                  timeText: 'مستمر', // يمكنك إضافة منطق للوقت لاحقاً
                  progressText: '${challenge.currentSteps}/${challenge.totalSteps} من الخطوات',
                  points: 'نقطة ${challenge.points}+',
                  
                  // النسبة المئوية (تأكدنا في الموديل أنها بين 0 و 1)
                  percent: challenge.progressPercent,
                  
                  primaryColor: challenge.color,
                  icon: challenge.icon,
                ),
                const SizedBox(height: 15), // مسافة بين كل بطاقة والأخرى
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- دوال مساعدة (Helper Methods) لترتيب الكود ---
  // الهدف: فصل منطق التصميم (الألوان) عن منطق البيانات

  String _getBadgeText(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return 'يومياً';
      case ChallengeType.weekly:
        return 'أسبوعياً';
      case ChallengeType.monthly:
        return 'شهرياً';
    }
  }

  Color _getBadgeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return const Color(0xFFC8E6C9); // أخضر فاتح
      case ChallengeType.weekly:
        return const Color(0xFFD1C4E9); // بنفسجي فاتح
      case ChallengeType.monthly:
        return const Color(0xFFFFCCBC); // برتقالي فاتح
    }
  }

  Color _getBadgeTextColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return const Color(0xFF2E7D32); // أخضر غامق
      case ChallengeType.weekly:
        return const Color(0xFF5E35B1); // بنفسجي غامق
      case ChallengeType.monthly:
        return const Color(0xFFD84315); // برتقالي غامق
    }
  }
}