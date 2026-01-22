import 'package:flutter/material.dart';
// تذكر استيراد الموديل الذي أنشأناه
import 'package:health_compass/feature/achievements/data/model/reward_model.dart';

class RewardsSection extends StatelessWidget {
  final int userPoints; // نقاط المستخدم الحالية
  final List<RewardModel> rewards; // قائمة المكافآت

  const RewardsSection({
    super.key,
    required this.userPoints,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            // --- رأس القسم (العنوان والنقاط) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "متجر المكافآت",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // عرض النقاط ديناميكياً
                Text(
                  "مجموع النقاط $userPoints", 
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- عرض القائمة أو حالة الفراغ ---
            if (rewards.isEmpty)
              _buildEmptyState()
            else
              ...rewards.map((reward) {
                return Column(
                  children: [
                    RewardTile(
                      title: reward.title,
                      subtitle: reward.subtitle,
                      pointsCost: reward.pointsCost,
                      icon: reward.icon,
                      // يمكنك هنا إضافة منطق: هل يستطيع المستخدم الشراء؟
                      canAfford: userPoints >= reward.pointsCost, 
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "لا توجد مكافآت متاحة حالياً",
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}

// --- الويدجت الفرعي (Tile) ---
class RewardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pointsCost;
  final IconData icon;
  final bool canAfford; // إضافة جميلة لتمييز المكافآت المتاحة للشراء

  const RewardTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pointsCost,
    required this.icon,
    this.canAfford = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // أيقونة المكافأة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // تغيير لون الخلفية إذا كان الرصيد غير كافٍ (اختياري)
              color: canAfford ? const Color(0xFF1565C0) : Colors.grey,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 15),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    // تغيير لون النص إذا لم يكن متاحاً
                    color: canAfford ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // زر/شارة النقاط
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // لون برتقالي إذا متاح، رمادي إذا غير متاح
              color: canAfford ? const Color(0xFFFF8F00) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatPoints(pointsCost), // دالة لتنسيق الرقم
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة بسيطة لإضافة الفواصل للأرقام (1000 -> 1,000)
  // في المشاريع الحقيقية نستخدم مكتبة intl
  String _formatPoints(int points) {
    if (points >= 1000) {
      // هذه طريقة بسيطة جداً، يمكنك تحسينها لاحقاً
      final s = points.toString();
      return "${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}";
    }
    return points.toString();
  }
}