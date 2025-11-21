import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.darkBackground,
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.poppins().fontFamily,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primaryPurple,
    tertiary: AppColors.primaryPink,
    surface: AppColors.darkSurface,
    error: AppColors.darkError,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.white,
    onError: AppColors.white,
  ),

  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.white),
  ),

  // Text Theme
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: AppColors.white,
    displayColor: AppColors.white,
    fontFamily: AppFonts.fontFamilySTCForward,
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.darkSecondary,
      disabledForegroundColor: AppColors.textSecondary,
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
    fillColor: AppColors.darkSurface,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.darkSecondary, width: 1.5),
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
      borderSide: BorderSide(color: AppColors.darkError, width: 1.5),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.darkError, width: 2),
    ),

    hintStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),

    labelStyle: AppTextStyling.fontFamilyTajawal.copyWith(
      color: AppColors.white.withValues(alpha: 0.7),
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
      return AppColors.darkSecondary;
    }),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.white.withValues(alpha: 0.1),
    thickness: 1,
    space: 20,
  ),

  // Icon Theme
  iconTheme: IconThemeData(color: AppColors.iconBlue, size: 24),
);
