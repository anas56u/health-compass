// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/core/themes/font_weight_helper.dart';

// import '../core.dart';

// class ModernErrorState extends StatelessWidget {
//   final IconData? icon;
//   final String title;
//   final String? subtitle;
//   final String? buttonText;
//   final VoidCallback? onButtonPressed;
//   final List<Color>? gradientColors;
//   final double? iconSize;
//   final double? containerSize;
//   final bool showRetryButton;
//   final String? secondaryButtonText;
//   final VoidCallback? onSecondaryButtonPressed;

//   const ModernErrorState({
//     super.key,
//     this.icon,
//     required this.title,
//     this.subtitle,
//     this.buttonText,
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.showRetryButton = true,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   });

//   // Pre-built error states for common scenarios
//   const ModernErrorState.network({
//     super.key,
//     this.buttonText = 'Try Again',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.wifi_off_rounded,
//        title = 'No Internet Connection',
//        subtitle = 'Please check your internet connection\nand try again',
//        showRetryButton = true;

//   const ModernErrorState.server({
//     super.key,
//     this.buttonText = 'Retry',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.cloud_off_rounded,
//        title = 'Server Error',
//        subtitle = 'Something went wrong on our end.\nWe\'re working to fix it',
//        showRetryButton = true;

//   const ModernErrorState.timeout({
//     super.key,
//     this.buttonText = 'Try Again',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.access_time_rounded,
//        title = 'Request Timeout',
//        subtitle = 'The request took too long to complete.\nPlease try again',
//        showRetryButton = true;

//   const ModernErrorState.notFound({
//     super.key,
//     this.buttonText = 'Go Back',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.search_off_rounded,
//        title = 'Not Found',
//        subtitle = 'The content you\'re looking for\ncouldn\'t be found',
//        showRetryButton = true;

//   const ModernErrorState.unauthorized({
//     super.key,
//     this.buttonText = 'Login',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.lock_outline_rounded,
//        title = 'Access Denied',
//        subtitle = 'You don\'t have permission to access\nthis content',
//        showRetryButton = true;

//   const ModernErrorState.generic({
//     super.key,
//     this.buttonText = 'Try Again',
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//     this.secondaryButtonText,
//     this.onSecondaryButtonPressed,
//   }) : icon = Icons.error_outline_rounded,
//        title = 'Something Went Wrong',
//        subtitle = 'We encountered an unexpected error.\nPlease try again later',
//        showRetryButton = true;

//   @override
//   Widget build(BuildContext context) {
//     final defaultGradient = gradientColors ?? [AppColors.red, AppColors.error];

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Animated Error Icon Container
//             TweenAnimationBuilder<double>(
//               duration: const Duration(milliseconds: 800),
//               tween: Tween(begin: 0.0, end: 1.0),
//               curve: Curves.elasticOut,
//               builder: (context, value, child) {
//                 return Transform.scale(
//                   scale: value,
//                   child: Container(
//                     width: containerSize,
//                     height: containerSize,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: defaultGradient,
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(containerSize! / 2),
//                       boxShadow: [
//                         BoxShadow(
//                           color: defaultGradient.first.withValues(
//                             alpha: 0.3 * value,
//                           ),
//                           blurRadius: 20 * value,
//                           offset: Offset(0, 10 * value),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       icon ?? Icons.error_outline_rounded,
//                       size: iconSize,
//                       color: Colors.white,
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 32),

//             // Error Title
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: AppTextStyling.fontFamilySTCForward.copyWith(
//                 fontSize: 24,
//                 fontWeight: FontWeightHelper.semiBold,
//                 color: AppColors.textDark,
//               ),
//             ),

//             // Error Subtitle
//             if (subtitle != null) ...[
//               const SizedBox(height: 12),
//               Text(
//                 subtitle!,
//                 textAlign: TextAlign.center,
//                 style: AppTextStyling.fontFamilySTCForward.copyWith(
//                   fontSize: 16,
//                   color: AppColors.textGrey,
//                   fontWeight: FontWeightHelper.medium,
//                   height: 1.5,
//                 ),
//               ),
//             ],

//             const SizedBox(height: 40),

//             // Buttons Row
//             FittedBox(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Secondary Button (if provided)
//                   if (secondaryButtonText != null &&
//                       onSecondaryButtonPressed != null) ...[
//                     _buildSecondaryButton(context),
//                     const SizedBox(width: 16),
//                   ],

//                   // Primary Retry Button
//                   if (showRetryButton && buttonText != null)
//                     _buildPrimaryButton(context, defaultGradient),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPrimaryButton(BuildContext context, List<Color> gradient) {
//     return GestureDetector(
//       onTap: onButtonPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: gradient.first.withValues(alpha: 0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Text(
//               buttonText!,
//               style: AppTextStyling.fontFamilySTCForward.copyWith(
//                 color: AppColors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeightHelper.semiBold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSecondaryButton(BuildContext context) {
//     return GestureDetector(
//       onTap: onSecondaryButtonPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: Colors.grey[300]!, width: 1.5),
//         ),
//         child: Text(
//           secondaryButtonText!,
//           style: AppTextStyling.fontFamilySTCForward.copyWith(
//             color: AppColors.textGrey,
//             fontSize: 16,
//             fontWeight: FontWeightHelper.medium,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Extension to easily use with different error types
// extension ErrorStateExtension on ModernErrorState {
//   static ModernErrorState fromException(
//     Exception exception, {
//     VoidCallback? onRetry,
//     VoidCallback? onSecondaryAction,
//     String? secondaryButtonText,
//   }) {
//     // You can customize this based on your error handling logic
//     if (exception.toString().contains('SocketException') ||
//         exception.toString().contains('NetworkException')) {
//       return ModernErrorState.network(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (exception.toString().contains('TimeoutException')) {
//       return ModernErrorState.timeout(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (exception.toString().contains('401') ||
//         exception.toString().contains('Unauthorized')) {
//       return ModernErrorState.unauthorized(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (exception.toString().contains('404') ||
//         exception.toString().contains('Not Found')) {
//       return ModernErrorState.notFound(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (exception.toString().contains('500') ||
//         exception.toString().contains('Server')) {
//       return ModernErrorState.server(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     }

//     return ModernErrorState.generic(
//       onButtonPressed: onRetry,
//       onSecondaryButtonPressed: onSecondaryAction,
//       secondaryButtonText: secondaryButtonText,
//     );
//   }

//   // New method to handle error from error message string
//   static ModernErrorState fromErrorMessage(
//     String? errorMessage, {
//     VoidCallback? onRetry,
//     VoidCallback? onSecondaryAction,
//     String? secondaryButtonText,
//   }) {
//     final message = errorMessage?.toLowerCase() ?? '';

//     if (message.contains('network') ||
//         message.contains('internet') ||
//         message.contains('connection')) {
//       return ModernErrorState.network(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (message.contains('timeout') || message.contains('time out')) {
//       return ModernErrorState.timeout(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (message.contains('unauthorized') ||
//         message.contains('not authorized') ||
//         message.contains('401')) {
//       return ModernErrorState.unauthorized(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (message.contains('not found') || message.contains('404')) {
//       return ModernErrorState.notFound(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     } else if (message.contains('server') ||
//         message.contains('500') ||
//         message.contains('internal error')) {
//       return ModernErrorState.server(
//         onButtonPressed: onRetry,
//         onSecondaryButtonPressed: onSecondaryAction,
//         secondaryButtonText: secondaryButtonText,
//       );
//     }

//     return ModernErrorState.generic(
//       onButtonPressed: onRetry,
//       onSecondaryButtonPressed: onSecondaryAction,
//       secondaryButtonText: secondaryButtonText,
//     );
//   }
// }
