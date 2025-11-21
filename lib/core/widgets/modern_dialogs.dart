// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/core/themes/font_weight_helper.dart';

// import '../core.dart';

// class ModernDialogs {
//   // Confirmation Dialog
//   static Future<bool?> showConfirmationDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String confirmText = 'Confirm',
//     String cancelText = 'Cancel',
//     IconData? icon,
//     List<Color>? iconGradient,
//     Color? confirmColor,
//     bool barrierDismissible = false,
//   }) {
//     return showDialog<bool>(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: _buildConfirmationDialog(
//             context: dialogContext,
//             title: title,
//             message: message,
//             confirmText: confirmText,
//             cancelText: cancelText,
//             icon: icon,
//             iconGradient: iconGradient,
//             confirmColor: confirmColor,
//           ),
//         );
//       },
//     );
//   }

//   // Delete Confirmation Dialog
//   static Future<bool?> showDeleteConfirmationDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String confirmText = 'Delete',
//     String cancelText = 'Cancel',
//     bool barrierDismissible = false,
//   }) {
//     return showConfirmationDialog(
//       context: context,
//       title: title,
//       message: message,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       icon: Icons.delete_outline,
//       iconGradient: [AppColors.red, const Color(0xFFFF8E8E)],
//       confirmColor: AppColors.red,
//       barrierDismissible: barrierDismissible,
//     );
//   }

//   // Success Dialog
//   static Future<void> showSuccessDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String buttonText = 'Great!',
//     VoidCallback? onPressed,
//   }) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: _buildSuccessDialog(
//             context: dialogContext,
//             title: title,
//             message: message,
//             buttonText: buttonText,
//             onPressed: onPressed,
//           ),
//         );
//       },
//     );
//   }

//   // Error Dialog
//   static Future<void> showErrorDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String buttonText = 'OK',
//     VoidCallback? onPressed,
//   }) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: _buildErrorDialog(
//             context: dialogContext,
//             title: title,
//             message: message,
//             buttonText: buttonText,
//             onPressed: onPressed,
//           ),
//         );
//       },
//     );
//   }

//   // Exit Confirmation Dialog
//   static Future<bool?> showExitConfirmationDialog({
//     required BuildContext context,
//     String title = 'Exit App',
//     String message = 'Do you want to exit the app?',
//     String confirmText = 'Exit',
//     String cancelText = 'Cancel',
//     bool barrierDismissible = false,
//   }) {
//     return showConfirmationDialog(
//       context: context,
//       title: title,
//       message: message,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       icon: Icons.exit_to_app,
//       iconGradient: [AppColors.red, const Color(0xFFFF8E8E)],
//       confirmColor: AppColors.red,
//       barrierDismissible: barrierDismissible,
//     );
//   }

//   // Custom Dialog
//   static Future<T?> showCustomDialog<T>({
//     required BuildContext context,
//     required Widget child,
//     bool barrierDismissible = true,
//   }) {
//     return showDialog<T>(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: child,
//         );
//       },
//     );
//   }

//   // Loading Dialog
//   static Future<void> showLoadingDialog({
//     required BuildContext context,
//     String? message,
//   }) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 4,
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//                 ),
//               ),
//               if (message != null) ...[
//                 const SizedBox(height: 20),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: AppTextStyling.fontFamilySTCForward.copyWith(
//                     fontSize: 16,
//                     color: AppColors.textDark,
//                     fontWeight: FontWeightHelper.medium,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Private helper methods
//   static Widget _buildConfirmationDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String confirmText,
//     required String cancelText,
//     IconData? icon,
//     List<Color>? iconGradient,
//     Color? confirmColor,
//   }) {
//     final defaultGradient =
//         iconGradient ?? [AppColors.primary, const Color(0xFF5BA7F7)];
//     final defaultConfirmColor = confirmColor ?? AppColors.primary;

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (icon != null) ...[
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: defaultGradient,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Icon(icon, color: Colors.white, size: 30),
//             ),
//             const SizedBox(height: 20),
//           ],
//           Text(
//             title,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 20,
//               fontWeight: FontWeightHelper.semiBold,
//               color: AppColors.textDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 14,
//               color: AppColors.textGrey,
//               fontWeight: FontWeightHelper.medium,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 45,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TextButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     style: TextButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       cancelText,
//                       style: AppTextStyling.fontFamilySTCForward.copyWith(
//                         color: AppColors.textGrey,
//                         fontWeight: FontWeightHelper.semiBold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Container(
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: defaultConfirmColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TextButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     style: TextButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       confirmText,
//                       style: AppTextStyling.fontFamilySTCForward.copyWith(
//                         color: AppColors.white,
//                         fontWeight: FontWeightHelper.semiBold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildSuccessDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String buttonText,
//     VoidCallback? onPressed,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.green, Color(0xFF66BB6A)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: const Icon(Icons.check, color: Colors.white, size: 30),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 20,
//               fontWeight: FontWeightHelper.semiBold,
//               color: AppColors.textDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 14,
//               color: AppColors.textGrey,
//               fontWeight: FontWeightHelper.medium,
//             ),
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 45,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.green, Color(0xFF66BB6A)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   onPressed?.call();
//                 },
//                 style: TextButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   buttonText,
//                   style: AppTextStyling.fontFamilySTCForward.copyWith(
//                     color: AppColors.white,
//                     fontWeight: FontWeightHelper.semiBold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildErrorDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String buttonText,
//     VoidCallback? onPressed,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.red, Color(0xFFFF8E8E)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: const Icon(
//               Icons.error_outline,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 20,
//               fontWeight: FontWeightHelper.semiBold,
//               color: AppColors.textDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: AppTextStyling.fontFamilySTCForward.copyWith(
//               fontSize: 14,
//               color: AppColors.textGrey,
//               fontWeight: FontWeightHelper.medium,
//             ),
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 45,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.red, Color(0xFFFF8E8E)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   onPressed?.call();
//                 },
//                 style: TextButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   buttonText,
//                   style: AppTextStyling.fontFamilySTCForward.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeightHelper.semiBold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
