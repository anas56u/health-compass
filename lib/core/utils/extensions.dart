// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../themes/cubit/theme_cubit.dart';
// import '../themes/gender_theme.dart';
// import '../widgets/modern_dialogs.dart';

// extension BuildContextExtensions on BuildContext {
//   bool get isDarkMode {
//     return Theme.of(this).brightness == Brightness.dark;
//   }

//   // Navigation methods
//   void navigateTo(String routeName) =>
//       Navigator.pushReplacementNamed(this, routeName);

//   Future<dynamic> navigateToNamed(String routeName) async {
//     return Navigator.pushNamed(this, routeName);
//   }

//   Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
//     return Navigator.of(this).pushNamed(routeName, arguments: arguments);
//   }

//   Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
//     return Navigator.of(
//       this,
//     ).pushReplacementNamed(routeName, arguments: arguments);
//   }

//   Future<dynamic> pushNamedAndRemoveUntil(
//     String routeName, {
//     Object? arguments,
//     required RoutePredicate predicate,
//   }) {
//     return Navigator.of(
//       this,
//     ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
//   }

//   void pop() => Navigator.of(this).pop();

//   // Modern Dialog methods using ModernDialogs
//   Future<bool?> showConfirmationDialog({
//     required String title,
//     required String message,
//     String confirmText = 'Confirm',
//     String cancelText = 'Cancel',
//     IconData? icon,
//     List<Color>? iconGradient,
//     Color? confirmColor,
//     bool barrierDismissible = false,
//   }) {
//     return ModernDialogs.showConfirmationDialog(
//       context: this,
//       title: title,
//       message: message,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       icon: icon,
//       iconGradient: iconGradient,
//       confirmColor: confirmColor,
//       barrierDismissible: barrierDismissible,
//     );
//   }

//   Future<bool?> showDeleteConfirmationDialog({
//     required String title,
//     required String message,
//     String confirmText = 'Delete',
//     String cancelText = 'Cancel',
//     bool barrierDismissible = false,
//   }) {
//     return ModernDialogs.showDeleteConfirmationDialog(
//       context: this,
//       title: title,
//       message: message,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       barrierDismissible: barrierDismissible,
//     );
//   }

//   Future<void> showSuccessDialog({
//     required String title,
//     required String message,
//     String buttonText = 'Great!',
//     VoidCallback? onPressed,
//   }) {
//     return ModernDialogs.showSuccessDialog(
//       context: this,
//       title: title,
//       message: message,
//       buttonText: buttonText,
//       onPressed: onPressed,
//     );
//   }

//   Future<bool?> showExitConfirmationDialog({
//     String title = 'Exit App',
//     String message = 'Do you want to exit the app?',
//     String confirmText = 'Exit',
//     String cancelText = 'Cancel',
//     bool barrierDismissible = false,
//   }) {
//     return ModernDialogs.showExitConfirmationDialog(
//       context: this,
//       title: title,
//       message: message,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       barrierDismissible: barrierDismissible,
//     );
//   }

//   Future<void> showErrorDialog({
//     required String title,
//     required String message,
//     String buttonText = 'OK',
//     VoidCallback? onPressed,
//   }) {
//     return ModernDialogs.showErrorDialog(
//       context: this,
//       title: title,
//       message: message,
//       buttonText: buttonText,
//       onPressed: onPressed,
//     );
//   }

//   Future<void> showModernLoadingDialog({String? message}) {
//     return ModernDialogs.showLoadingDialog(context: this, message: message);
//   }

//   void hideLoadingDialog() {
//     Navigator.of(this).pop();
//   }

//   // Legacy dialog method (kept for backward compatibility)
//   Future<void> showSnackBarAsDialog({
//     required String message,
//     required bool isError,
//     required void Function()? onPressed,
//   }) async {
//     if (isError) {
//       return showErrorDialog(
//         title: 'Error',
//         message: message,
//         buttonText: 'Got it',
//         onPressed: onPressed,
//       );
//     } else {
//       return showSuccessDialog(
//         title: 'Success',
//         message: message,
//         buttonText: 'Got it',
//         onPressed: onPressed,
//       );
//     }
//   }

//   // Enhanced SnackBar methods
//   void showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(this).clearSnackBars();
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFFF6B6B),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 4),
//         elevation: 6,
//       ),
//     );
//   }

//   void showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(this).clearSnackBars();
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF4CAF50),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//         elevation: 6,
//       ),
//     );
//   }

//   void showInfoSnackBar(String message) {
//     ScaffoldMessenger.of(this).clearSnackBars();
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF4A90E2),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//         elevation: 6,
//       ),
//     );
//   }

//   void showWarningSnackBar(String message) {
//     ScaffoldMessenger.of(this).clearSnackBars();
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.warning_outlined, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFFF9800),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//         elevation: 6,
//       ),
//     );
//   }

//   void showSnackBar(String message) {
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   // Custom SnackBar with action
//   void showActionSnackBar({
//     required String message,
//     required String actionLabel,
//     required VoidCallback onActionPressed,
//     Color? backgroundColor,
//     IconData? icon,
//   }) {
//     ScaffoldMessenger.of(this).clearSnackBars();
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             if (icon != null) ...[
//               Icon(icon, color: Colors.white),
//               const SizedBox(width: 8),
//             ],
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: backgroundColor ?? const Color(0xFF4A90E2),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 4),
//         elevation: 6,
//         action: SnackBarAction(
//           label: actionLabel,
//           textColor: Colors.white,
//           backgroundColor: Colors.white.withValues(alpha: 0.2),
//           onPressed: onActionPressed,
//         ),
//       ),
//     );
//   }
// }

// extension StringExtension on String? {
//   bool isNullOrEmpty() => this == null || this == "";
// }

// extension ListExtension<T> on List<T>? {
//   bool isNullOrEmpty() => this == null || this!.isEmpty;
// }

// extension SafeEmitOnCubit<T> on Cubit<T> {
//   void safeEmit(T state) {
//     if (!isClosed) emit(state);
//   }
// }

// extension SafeEmitOnBloc<Event, State> on Bloc<Event, State> {
//   void safeEmit(State state) {
//     if (!isClosed) emit(state);
//   }
// }

// // ============ Theme Extensions ============
// extension ThemeContextExtensions on BuildContext {
//   /// Get ThemeCubit instance
//   ThemeCubit get themeCubit => read<ThemeCubit>();

//   /// Get current theme state
//   ThemeState get themeState => watch<ThemeCubit>().state;

//   /// Get current gender theme
//   GenderTheme get genderTheme => themeState.genderTheme;

//   /// Get current theme mode
//   ThemeMode get themeMode => themeState.themeMode;

//   /// Check if current theme is for girls
//   bool get isGirlTheme => genderTheme == GenderTheme.girl;

//   /// Check if current theme is for boys
//   bool get isBoyTheme => genderTheme == GenderTheme.boy;

//   /// Check if current theme is general (guest mode)
//   bool get isGeneralTheme => genderTheme == GenderTheme.general;

//   /// Change theme mode (light/dark/system)
//   void changeThemeMode(ThemeMode mode) {
//     themeCubit.changeTheme(mode);
//   }

//   /// Set gender theme (boy/girl/general)
//   void setGenderTheme(GenderTheme gender) {
//     themeCubit.setGender(gender);
//   }

//   /// Set gender theme from integer (0 = boy, 1 = girl)
//   void setGenderThemeFromInt(int value) {
//     themeCubit.setGenderFromInt(value);
//   }

//   /// Set general theme for guest mode
//   void setGeneralTheme() {
//     themeCubit.setGeneralTheme();
//   }

//   /// Get primary color based on current gender theme
//   Color get primaryColor {
//     final theme = Theme.of(this);
//     return theme.colorScheme.primary;
//   }

//   /// Get secondary color based on current gender theme
//   Color get secondaryColor {
//     final theme = Theme.of(this);
//     return theme.colorScheme.secondary;
//   }

//   /// Get tertiary color based on current gender theme
//   Color get tertiaryColor {
//     final theme = Theme.of(this);
//     return theme.colorScheme.tertiary;
//   }
// }
