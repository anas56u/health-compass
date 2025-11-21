// import 'package:flutter/material.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import '../../cache/shared_pref_helper.dart';
// import '../../constants/constants.dart';
// import '../gender_theme.dart';

// class ThemeState {
//   final ThemeMode themeMode;
//   final GenderTheme genderTheme;

//   const ThemeState({
//     this.themeMode = ThemeMode.system,
//     this.genderTheme = GenderTheme.boy,
//   });

//   ThemeState copyWith({ThemeMode? themeMode, GenderTheme? genderTheme}) {
//     return ThemeState(
//       themeMode: themeMode ?? this.themeMode,
//       genderTheme: genderTheme ?? this.genderTheme,
//     );
//   }
// }

// class ThemeCubit extends HydratedCubit<ThemeState> {
//   ThemeCubit() : super(const ThemeState());

//   void changeTheme(ThemeMode mode) {
//     final newState = state.copyWith(themeMode: mode);
//     emit(newState);
//     _printThemeChange(
//       'Theme Mode',
//       mode.toString(),
//       newState.genderTheme.toString(),
//     );
//   }

//   void setGender(GenderTheme gender) {
//     final newState = state.copyWith(genderTheme: gender);
//     emit(newState);
//     _printThemeChange(
//       'Gender Theme',
//       gender.toString(),
//       newState.themeMode.toString(),
//     );
//   }

//   void setGenderFromInt(int value) {
//     final gender = GenderTheme.fromInt(value);
//     final newState = state.copyWith(genderTheme: gender);
//     emit(newState);
//     _printThemeChange(
//       'Gender Theme (from Int)',
//       gender.toString(),
//       newState.themeMode.toString(),
//     );
//   }

//   /// Check if user is in guest mode and set general theme
//   Future<void> checkGuestMode() async {
//     final isLoggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);
//     if (isLoggedIn == false || isLoggedIn == null) {
//       // User is in guest mode, use general theme
//       final newState = state.copyWith(genderTheme: GenderTheme.general);
//       emit(newState);
//       _printThemeChange(
//         'Guest Mode',
//         'General Theme',
//         newState.themeMode.toString(),
//       );
//     }
//   }

//   /// Set general theme for guest mode
//   void setGeneralTheme() {
//     final newState = state.copyWith(genderTheme: GenderTheme.general);
//     emit(newState);
//     _printThemeChange(
//       'General Theme',
//       'General',
//       newState.themeMode.toString(),
//     );
//   }

//   void _printThemeChange(
//     String changeType,
//     String newValue,
//     String otherValue,
//   ) {
//     // Use state after emit to get the latest values
//     final currentState = state;
//     print('═══════════════════════════════════════════════════════════');
//     print('🎨 THEME CHANGED: $changeType');
//     print('   New Value: $newValue');
//     if (changeType.contains('Theme Mode')) {
//       print('   Gender Theme: $otherValue');
//     } else {
//       print('   Theme Mode: $otherValue');
//     }
//     print('   Current Gender Theme: ${currentState.genderTheme}');
//     print(
//       '   Full State: ThemeMode=${currentState.themeMode}, GenderTheme=${currentState.genderTheme}',
//     );
//     print('═══════════════════════════════════════════════════════════');
//   }

//   @override
//   ThemeState? fromJson(Map<String, dynamic> json) {
//     ThemeMode themeMode = ThemeMode.system;
//     if (json["themeMode"] == "light") {
//       themeMode = ThemeMode.light;
//     } else if (json["themeMode"] == "dark") {
//       themeMode = ThemeMode.dark;
//     }

//     GenderTheme genderTheme = GenderTheme.boy;
//     if (json["genderTheme"] == "girl") {
//       genderTheme = GenderTheme.girl;
//     } else if (json["genderTheme"] == "general") {
//       genderTheme = GenderTheme.general;
//     }

//     return ThemeState(themeMode: themeMode, genderTheme: genderTheme);
//   }

//   @override
//   Map<String, dynamic>? toJson(ThemeState state) {
//     String themeModeStr = "system";
//     if (state.themeMode == ThemeMode.light) {
//       themeModeStr = "light";
//     } else if (state.themeMode == ThemeMode.dark) {
//       themeModeStr = "dark";
//     }

//     String genderThemeStr = "boy";
//     if (state.genderTheme == GenderTheme.girl) {
//       genderThemeStr = "girl";
//     } else if (state.genderTheme == GenderTheme.general) {
//       genderThemeStr = "general";
//     }

//     return {"themeMode": themeModeStr, "genderTheme": genderThemeStr};
//   }
// }
