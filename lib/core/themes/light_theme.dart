import 'package:flutter/material.dart';
import '../core.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  brightness: Brightness.light,
  fontFamily: AppFonts.fontFamilySTCForward,

  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primaryPurple,
    tertiary: AppColors.primaryPink,
    surface: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.textDark,
    onError: AppColors.white,
  ),

  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.textDark),
  ),

  // Text Theme
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: AppColors.textDark,
    displayColor: AppColors.textGrey,
    fontFamily: AppFonts.fontFamilySTCForward,
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.textSecondary,
      disabledForegroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: AppTextStyling.fontFamilyTajawal.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      elevation: 0,
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputBackground,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.inputBorder, width: 1.5),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primaryPurple, width: 1.5),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),

    hintStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),

    labelStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.textGrey,
      fontSize: 14,
    ),

    prefixIconColor: AppColors.iconPurple,
    suffixIconColor: AppColors.iconBlue,
  ),

  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.5);
      }
      return AppColors.textSecondary.withValues(alpha: 0.3);
    }),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.background,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.textSecondary.withValues(alpha: 0.2),
    thickness: 1,
    space: 20,
  ),

  // Icon Theme
  iconTheme: IconThemeData(color: AppColors.iconBlue, size: 24),
);
