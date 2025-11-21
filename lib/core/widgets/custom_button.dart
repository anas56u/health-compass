// import 'package:flutter/material.dart';
// import '../core.dart'; // تأكد من المسار الصحيح
// import '../utils/extensions.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final double? width;
//   final double? height;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final IconData? icon;
//   final bool isLoading;
//   final double borderRadius;
//   final Gradient? gradient;
//   final Border? border;

//   const CustomButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.width,
//     this.height = 50,
//     this.backgroundColor,
//     this.textColor,
//     this.fontSize = 16,
//     this.fontWeight = FontWeight.w600,
//     this.icon,
//     this.isLoading = false,
//     this.borderRadius = 16,
//     this.gradient,
//     this.border,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // استخدام الـ extensions للثيمات
//     final primaryColor = context.primaryColor;
//     final isGirlTheme = context.isGirlTheme;

//     // إنشاء gradient حسب الثيم إذا لم يتم تحديد gradient أو backgroundColor
//     Gradient? themeGradient;
//     if (gradient == null && backgroundColor == null) {
//       themeGradient = LinearGradient(
//         colors: isGirlTheme
//             ? [AppColors.primaryPink, AppColors.primaryPinkLight]
//             : [AppColors.primaryBlue, AppColors.primaryBlueLight],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       );
//     }

//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         gradient:
//             gradient ??
//             (backgroundColor != null
//                 ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
//                 : themeGradient ??
//                       LinearGradient(
//                         colors: [
//                           AppColors.buttonBlueStart,
//                           AppColors.buttonBlueEnd,
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )),
//         borderRadius: BorderRadius.circular(borderRadius),
//         border: border,
//         boxShadow: [
//           BoxShadow(
//             color: (backgroundColor ?? primaryColor).withValues(alpha: 0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: isLoading ? null : onPressed,
//           borderRadius: BorderRadius.circular(borderRadius),
//           child: Container(
//             child: isLoading
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           valueColor: AlwaysStoppedAnimation(
//                             textColor ?? AppColors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         text,
//                         style: AppTextStyling.fontFamilySTCForward.copyWith(
//                           fontSize: fontSize,
//                           fontWeight: fontWeight,
//                           color: textColor ?? AppColors.white,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   )
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (icon != null) ...[
//                         Icon(
//                           icon,
//                           size: fontSize! + 4,
//                           color: textColor ?? AppColors.white,
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                       Text(
//                         text,
//                         style: AppTextStyling.fontFamilySTCForward.copyWith(
//                           fontSize: fontSize,
//                           fontWeight: fontWeight,
//                           color: textColor ?? AppColors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
