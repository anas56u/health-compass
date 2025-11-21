import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'dark_theme.dart';
import 'gender_theme.dart';
import 'light_theme.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static ThemeData light = lightTheme;
  static ThemeData dark = darkTheme;

  /// Build light theme based on gender
  static ThemeData buildLight(GenderTheme gender) {
    // Use general theme for guest mode
    if (gender == GenderTheme.general) {
      return lightTheme; // Return default theme without modifications
    }

    // Girls theme - More pink colors
    if (gender == GenderTheme.girl) {
      return lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(
          primary: AppColors.primaryPink,
          secondary: AppColors.primaryPinkLight,
          tertiary: AppColors.primaryPinkVeryLight,
          surface: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.textDark,
          onError: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.textSecondary,
            disabledForegroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryPinkLight,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primaryPink, width: 2),
          ),
          prefixIconColor: AppColors.primaryPink,
          suffixIconColor: AppColors.primaryPinkLight,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryPink;
            }
            return AppColors.textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryPink.withValues(alpha: 0.5);
            }
            return AppColors.textSecondary.withValues(alpha: 0.3);
          }),
        ),
        bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: AppColors.primaryPink,
          unselectedItemColor: AppColors.textSecondary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryPink, size: 24),
      );
    }

    // Boys theme - More blue colors
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlueLight,
        tertiary: AppColors.primaryBlueDark,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textDark,
        onError: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.textSecondary,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryBlueLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        prefixIconColor: AppColors.primaryBlue,
        suffixIconColor: AppColors.primaryBlueLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue.withValues(alpha: 0.5);
          }
          return AppColors.textSecondary.withValues(alpha: 0.3);
        }),
      ),
      bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme.copyWith(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryBlue, size: 24),
    );
  }

  /// Build dark theme based on gender
  static ThemeData buildDark(GenderTheme gender) {
    // Use general theme for guest mode
    if (gender == GenderTheme.general) {
      return darkTheme; // Return default theme without modifications
    }

    // Girls theme - More pink colors
    if (gender == GenderTheme.girl) {
      return darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(
          primary: AppColors.primaryPink,
          secondary: AppColors.primaryPinkLight,
          tertiary: AppColors.primaryPinkVeryLight,
          surface: AppColors.darkSurface,
          error: AppColors.darkError,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.white,
          onError: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.darkSecondary,
            disabledForegroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: darkTheme.inputDecorationTheme.copyWith(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryPinkLight,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primaryPink, width: 2),
          ),
          prefixIconColor: AppColors.primaryPink,
          suffixIconColor: AppColors.primaryPinkLight,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryPink;
            }
            return AppColors.textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryPink.withValues(alpha: 0.5);
            }
            return AppColors.darkSecondary;
          }),
        ),
        bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: AppColors.primaryPink,
          unselectedItemColor: AppColors.textSecondary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryPink, size: 24),
      );
    }

    // Boys theme - More blue colors
    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlueLight,
        tertiary: AppColors.primaryBlueDark,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.darkSecondary,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: darkTheme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryBlueLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        prefixIconColor: AppColors.primaryBlue,
        suffixIconColor: AppColors.primaryBlueLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue.withValues(alpha: 0.5);
          }
          return AppColors.darkSecondary;
        }),
      ),
      bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme.copyWith(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryBlue, size: 24),
    );
  }
}
