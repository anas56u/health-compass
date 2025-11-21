import 'package:flutter/material.dart';
import 'package:health_compass/core/themes/app_colors.dart';

class AppGradient {
  static final Gradient appBarGradient = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final Gradient logoGradient = LinearGradient(
    colors: [
      Color(0xFF14B8A6), // أخضر فاتح (mint)
      Color(0xFF0D9488), // أخضر مزرق (teal)
      Color(0xFF0369A1), // أزرق
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
  static final Gradient buttomGradient = LinearGradient(
    colors: [
      Color(0xFF00C9A7), // أخضر mint من اليسار
      Color(0xFF0B5F6E), // أزرق بترولي غامق لليمين
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final Gradient profileGradient = LinearGradient(
    colors: [AppColors.profileGradientStart, AppColors.profileGradientEnd],
    stops: [0.0, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static final Gradient loginGradientGirl = LinearGradient(
    colors: [
      Color(0xFFFFF5F8),
      Color(0xFFFFE4EC),
      Color(0xFFE8B4D9),
      Color(0xFFF8BBD9),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static final Gradient loginGradientBoy = LinearGradient(
    colors: [
      Color(0xFFE3F2FD), // أزرق فاتح
      Color(0xFF64B5F6), // أزرق متوسط
      Color(0xFF42A5F5), // أزرق قوي
      Color(0xFF1E88E5), // أزرق غامق
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradient للـ StatusBar للبنت (وردي/بنفسجي)
  static final Gradient statusBarGradientGirl = LinearGradient(
    colors: [
      Color(0xFFF8BBD9), // وردي
      Color(0xFFE8B4D9), // بنفسجي ناعم
      Color(0xFFF3E5F5), // لافندر فاتح
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient للـ StatusBar للولد (أزرق)
  static final Gradient statusBarGradientBoy = LinearGradient(
    colors: [
      Color(0xFF1E88E5), // أزرق غامق
      Color(0xFF42A5F5), // أزرق قوي
      Color(0xFF64B5F6), // أزرق متوسط
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient للـ StatusBar العام (لـ guest mode)
  static final Gradient statusBarGradientGeneral = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
