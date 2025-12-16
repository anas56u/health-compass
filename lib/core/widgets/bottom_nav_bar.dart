import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart'; // <--- أضف هذا السطر المهم
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
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Animated background glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF667eea,
                        ).withOpacity(0.3 * _pulseController.value),
                        blurRadius: 40 + (20 * _pulseController.value),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFFf093fb,
                        ).withOpacity(0.2 * _pulseController.value),
                        blurRadius: 60 + (30 * _pulseController.value),
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Main navigation bar
          ClipRRect(
            borderRadius: BorderRadius.circular(36.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  final value = _waveController.value;
                  return Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                     gradient: LinearGradient(
  colors: [
    Color.lerp(
      const Color(0xFF0D9488), // Teal 600 - اللون الأساسي
      const Color(0xFF14B8A6), // Teal 500 - أفتح شوي
      math.sin(value * math.pi),
    )!,
    const Color(0xFF0F766E), // Teal 700 - أغمق
    Color.lerp(
      const Color(0xFF06B6D4), // Cyan 500 - أزرق مخضر
      const Color(0xFF0891B2), // Cyan 600
      math.cos(value * math.pi),
    )!,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
                      borderRadius: BorderRadius.circular(36.r),
                      border: Border.all(
                        width: 2,
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.5),
                      ),
                      boxShadow: [
                        // Use a soft tinted glow instead of black to avoid a dark background feel
                        BoxShadow(
                          color: (isDark
                              ? const Color(0xFF667eea).withOpacity(0.28)
                              : Colors.black.withOpacity(0.08)),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                          spreadRadius: -8,
                        ),
                        if (isDark)
                          BoxShadow(
                            color: const Color(0xFFf093fb).withOpacity(0.22),
                            blurRadius: 50,
                            offset: const Offset(0, 18),
                            spreadRadius: -10,
                          ),
                      ],
                    ),
                    child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildNavItem(
      context: context,
      index: 0,
      icon: Icons.home_rounded,
      label: 'الرئيسية',
      isSelected: widget.currentIndex == 0,
      isDark: isDark,
    ),
    _buildNavItem(
      context: context,
      index: 1,
      icon: Icons.medication_liquid_outlined,
      label: 'الأدوية',
      isSelected: widget.currentIndex == 1,
      isDark: isDark,
    ),
    _buildNavItem(
      context: context,
      index: 2,
      icon: Icons.group,
      label: 'العائلة',
      isSelected: widget.currentIndex == 2,
      isDark: isDark,
    ),
    _buildNavItem(
      context: context,
      index: 3,
      icon: Icons.mic,
      label: 'AI',
      isSelected: widget.currentIndex == 3,
      isDark: isDark,
    ),
    _buildNavItem(
      context: context,
      index: 4,
      icon: Icons.emoji_events_outlined,
      label: 'الإنجازات',
      isSelected: widget.currentIndex == 4,
      isDark: isDark,
      
    ),
  ],
)

                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTap(index),
          borderRadius: BorderRadius.circular(28.r),
          splashColor: const Color(0xFF764ba2).withOpacity(0.2),
          //    highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(isDark ? 0.08 : 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with bounce animation (shadow aligns to item container)
                TweenAnimationBuilder<double>(
                  key: ValueKey('icon-$index-$isSelected'),
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: isSelected ? scale : 0.88,
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white.withOpacity(0.45)
                                  : const Color(0xFF6c757d)),
                        size: isSelected ? 28.sp : 25.sp,
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                // Label with scale animation
                TweenAnimationBuilder<double>(
                  key: ValueKey('label-$index-$isSelected'),
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        style: AppTextStyling.fontFamilySTCForward.copyWith(
                          fontSize: isSelected ? 12.5.sp : 11.sp,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white.withOpacity(0.45)
                                    : const Color(0xFF6c757d)),
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: isSelected ? 0.8 : 0.3,
                          shadows: isSelected
                              ? [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
