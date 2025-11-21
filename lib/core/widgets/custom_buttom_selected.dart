// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/core/core.dart';
// import 'package:kid_flix_app/core/themes/app_colors.dart';
// import 'package:kid_flix_app/core/themes/app_text_styling.dart';
// import 'package:kid_flix_app/core/utils/extensions.dart';

// class CustomButtonSelected extends StatelessWidget {
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
//   final bool isSelected; // جديد

//   const CustomButtonSelected({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.width,
//     this.height = 56,
//     this.backgroundColor,
//     this.textColor,
//     this.fontSize = 18,
//     this.fontWeight = FontWeight.bold,
//     this.icon,
//     this.isLoading = false,
//     this.borderRadius = 30,
//     this.gradient,
//     this.border,
//     this.isSelected = false, // افتراضياً غير محدد
//   });

//   @override
//   Widget build(BuildContext context) {
//     // استخدام الـ extensions للثيمات فقط عند التحديد
//     final isGirlTheme = isSelected ? context.isGirlTheme : false;
//     final primaryColor = isSelected ? context.primaryColor : null;

//     // إنشاء gradient حسب الثيم فقط عند التحديد
//     Gradient? themeGradient;
//     if (isSelected && gradient == null && backgroundColor == null) {
//       themeGradient = LinearGradient(
//         colors: isGirlTheme
//             ? [AppColors.primaryPink, AppColors.primaryPinkLight]
//             : [AppColors.primaryBlue, AppColors.primaryBlueLight],
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//       );
//     }

//     return Container(
//       width: width ?? double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: isSelected
//             ? (gradient ??
//                   (backgroundColor != null
//                       ? LinearGradient(
//                           colors: [backgroundColor!, backgroundColor!],
//                         )
//                       : themeGradient))
//             : null,
//         color: isSelected ? null : Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(borderRadius),
//         border: border,
//         boxShadow: isSelected && primaryColor != null
//             ? [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ]
//             : [],
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
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           valueColor: AlwaysStoppedAnimation(
//                             textColor ?? Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         text,
//                         style: AppTextStyling.fontFamilySTCForward.copyWith(
//                           fontSize: fontSize,
//                           fontWeight: fontWeight,
//                           color: textColor ?? Colors.white,
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
//                           color: isSelected
//                               ? (textColor ?? Colors.white)
//                               : Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                       Text(
//                         text,
//                         style: AppTextStyling.fontFamilySTCForward.copyWith(
//                           fontSize: fontSize,
//                           fontWeight: fontWeight,
//                           color: isSelected
//                               ? (textColor ?? Colors.white)
//                               : Colors.grey.shade600,
//                           letterSpacing: 0.5,
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
