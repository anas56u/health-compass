// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/core/themes/font_weight_helper.dart';

// import '../core.dart';

// class ModernEmptyState extends StatelessWidget {
//   final IconData? icon;
//   final String title;
//   final String? subtitle;
//   final String? buttonText;
//   final VoidCallback? onButtonPressed;
//   final List<Color>? gradientColors;
//   final double? iconSize;
//   final double? containerSize;

//   const ModernEmptyState({
//     super.key,
//     this.icon,
//     required this.title,
//     this.subtitle,
//     this.buttonText,
//     this.onButtonPressed,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//   });

//   // Pre-built empty states for common scenarios
//   const ModernEmptyState.notifications({
//     super.key,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//   }) : icon = Icons.notifications_none_outlined,
//        title = 'No Notifications Yet',
//        subtitle =
//            'When you get notifications, they\'ll\nshow up here to keep you updated',
//        buttonText = 'Stay tuned!',
//        onButtonPressed = null;

//   const ModernEmptyState.search({
//     super.key,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//   }) : icon = Icons.search_off,
//        title = 'No Results Found',
//        subtitle =
//            'We couldn\'t find what you\'re looking for.\nTry adjusting your search terms',
//        buttonText = null,
//        onButtonPressed = null;

//   const ModernEmptyState.noData({
//     super.key,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//   }) : icon = Icons.inbox_outlined,
//        title = 'No Data Available',
//        subtitle =
//            'There\'s nothing to show here yet.\nCheck back later for updates',
//        buttonText = null,
//        onButtonPressed = null;

//   const ModernEmptyState.error({
//     super.key,
//     this.gradientColors,
//     this.iconSize = 60,
//     this.containerSize = 120,
//   }) : icon = Icons.error_outline,
//        title = 'Something Went Wrong',
//        subtitle =
//            'We encountered an error while loading.\nPlease try again later',
//        buttonText = 'Retry',
//        onButtonPressed = null;

//   @override
//   Widget build(BuildContext context) {
//     final defaultGradient =
//         gradientColors ?? [AppColors.primary, AppColors.primaryPurple];

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Animated Empty State Icon Container
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
//                       icon ?? Icons.inbox_outlined,
//                       size: iconSize,
//                       color: Colors.white,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 32),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: AppTextStyling.fontFamilySTCForward.copyWith(
//                 fontSize: 24,
//                 fontWeight: FontWeightHelper.semiBold,
//                 color: AppColors.textDark,
//               ),
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 12),
//               Text(
//                 subtitle!,
//                 textAlign: TextAlign.center,
//                 style: AppTextStyling.fontFamilySTCForward.copyWith(
//                   fontSize: 16,
//                   color: AppColors.textGrey,
//                   fontWeight: FontWeightHelper.medium,
//                   height: 1.4,
//                 ),
//               ),
//             ],
//             if (buttonText != null) ...[
//               const SizedBox(height: 40),
//               GestureDetector(
//                 onTap: onButtonPressed,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: defaultGradient,
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: defaultGradient.first.withValues(alpha: 0.3),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     buttonText!,
//                     style: AppTextStyling.fontFamilySTCForward.copyWith(
//                       color: AppColors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeightHelper.semiBold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
