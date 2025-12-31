import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/themes/app_text_styling.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // ✅ تعريف ألوان الثيم لضمان التناسق
  final Color _primaryTeal = const Color(0xFF0D9488);
  final Color _secondaryCyan = const Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    // أنيميشن النبض للخلفية المتوهجة
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // جعلتها أبطأ قليلاً لتبدو أهدأ
    )..repeat(reverse: true);

    // أنيميشن للمعان الخفيف (Shimmer)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      // ✅ ضبط الهوامش ليكون البار عائماً بشكل جميل
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: SizedBox(
        height: 75.h, // ارتفاع مناسب للأصابع
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. التوهج الخلفي (Glow) - تم تعديل الألوان لتناسب الثيم
            Positioned(
              bottom: 0,
              left: 20.w,
              right: 20.w,
              height: 50.h,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryTeal.withOpacity(
                            0.3 * _pulseController.value,
                          ),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: _secondaryCyan.withOpacity(
                            0.2 * _pulseController.value,
                          ),
                          blurRadius: 40,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 2. جسم البار الزجاجي (Glassmorphism Body)
            ClipRRect(
              borderRadius: BorderRadius.circular(32.r), // زوايا أكثر دائرية
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    // تأثير تدرج لوني متحرك ببطء شديد
                    final value = _shimmerController.value;
                    return Container(
                      decoration: BoxDecoration(
                        // خلفية متدرجة تتماشى مع الثيم
                        gradient: LinearGradient(
                          colors: [
                            _primaryTeal.withOpacity(0.9),
                            Color.lerp(
                              _primaryTeal,
                              _secondaryCyan,
                              0.5,
                            )!.withOpacity(0.95),
                            const Color(0xFF0F766E).withOpacity(0.9),
                          ],
                          begin: Alignment(-1.0 + value, -1.0),
                          end: Alignment(1.0 - value, 1.0),
                          transform: const GradientRotation(math.pi / 4),
                        ),
                        borderRadius: BorderRadius.circular(32.r),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.white.withOpacity(0.2), // حدود زجاجية
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                          _buildNavItem(
                            1,
                            Icons.medication_liquid_rounded,
                            'الأدوية',
                          ),
                          _buildNavItem(
                            2,
                            Icons.family_restroom_rounded,
                            'العائلة',
                          ), // أيقونة أنسب للعائلة
                          _buildNavItem(
                            3,
                            Icons.smart_toy_rounded,
                            'مساعدك',
                          ), // أيقونة ورسمية أفضل للـ AI
                          _buildNavItem(
                            4,
                            Icons.emoji_events_rounded,
                            'إنجازات',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء العنصر الواحد
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة مع أنيميشن الحركة والتكبير
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack, // حركة "نطاطة"
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              builder: (context, animValue, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    -5 * animValue,
                  ), // الأيقونة ترتفع قليلاً عند التحديد
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent, // خلفية خفيفة للأيقونة النشطة
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isSelected ? 26.sp : 24.sp,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(
                              0.6,
                            ), // لون غير النشط أبيض شفاف
                    ),
                  ),
                );
              },
            ),

            // النص (يظهر فقط عند التحديد أو يكون صغيراً جداً)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isSelected
                  ? 20.h
                  : 0, // إخفاء النص للعناصر غير النشطة لتوفير المساحة
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  style: AppTextStyling.fontFamilySTCForward.copyWith(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // نقطة صغيرة أسفل العنصر النشط (اختياري، يضيف لمسة جمالية)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 2.h),
              width: isSelected ? 4.w : 0,
              height: isSelected ? 4.w : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
