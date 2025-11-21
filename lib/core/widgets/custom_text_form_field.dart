// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import '../core.dart';
// import '../utils/extensions.dart';

// class CustomTextFormField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String label;
//   final String? icon;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;
//   final bool isPassword;
//   final bool? isPasswordVisible;
//   final VoidCallback? onTogglePasswordVisibility;
//   final ValueChanged<String>? onChanged;
//   final bool readOnly;
//   final VoidCallback? onTap;
//   final void Function(String)? onFieldSubmitted;
//   final FocusNode? focusNode;
//   final FocusNode? nextFocusNode;
//   final bool isLastField;
//   final TextInputAction? textInputAction;
//   final String? suffixSvgAsset;

//   const CustomTextFormField({
//     super.key,
//     this.controller,
//     required this.label,
//     this.icon,
//     this.validator,
//     this.keyboardType,
//     this.isPassword = false,
//     this.isPasswordVisible,
//     this.onTogglePasswordVisibility,
//     this.onChanged,
//     this.readOnly = false,
//     this.onTap,
//     this.onFieldSubmitted,
//     this.focusNode,
//     this.nextFocusNode,
//     this.isLastField = false,
//     this.textInputAction,
//     this.suffixSvgAsset,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor =
//         context.primaryColor; // استخدام primary color حسب gender theme
//     final TextInputAction effectiveTextInputAction =
//         textInputAction ??
//         (isLastField ? TextInputAction.done : TextInputAction.next);

//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.inputBackground : AppColors.darkSurface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isDark
//               ? primaryColor.withOpacity(0.9)
//               : primaryColor.withOpacity(0.5),
//           width: 2.5,
//         ),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword && !(isPasswordVisible ?? false),
//         keyboardType: keyboardType,
//         validator: validator,
//         onChanged: onChanged,
//         readOnly: readOnly,
//         onTap: onTap,
//         focusNode: focusNode,
//         textInputAction: effectiveTextInputAction,
//         onFieldSubmitted: (value) {
//           if (nextFocusNode != null && !isLastField) {
//             FocusScope.of(context).requestFocus(nextFocusNode);
//           } else {
//             FocusScope.of(context).unfocus();
//           }

//           if (onFieldSubmitted != null) {
//             onFieldSubmitted!(value);
//           }
//         },
//         inputFormatters: isPassword
//             ? [
//                 FilteringTextInputFormatter.allow(
//                   RegExp(r'[a-zA-Z0-9!@#$%^&*]'),
//                 ),
//               ]
//             : null,
//         style: AppTextStyling.fontFamilySTCForward.copyWith(
//           color: isDark ? AppColors.textDark : AppColors.textDark,
//         ),
//         decoration: InputDecoration(
//           hintText: label,
//           hintStyle: AppTextStyling.fontFamilySTCForward.copyWith(
//             color: isDark ? primaryColor : primaryColor.withOpacity(0.7),
//             fontSize: 15,
//             fontWeight: FontWeight.w400,
//           ),
//           prefixIcon: icon != null
//               ? Container(
//                   width: 36,
//                   height: 36,
//                   alignment: Alignment.center,
//                   child: SvgPicture.asset(
//                     icon!,
//                     width: 24,
//                     height: 24,
//                     color: primaryColor,
//                   ),
//                 )
//               : null,
//           suffixIcon: isPassword
//               ? IconButton(
//                   onPressed: onTogglePasswordVisibility,
//                   icon: Container(
//                     width: 22, // حجم مناسب للـ iconButton
//                     height: 22,
//                     alignment: Alignment.center,
//                     child: SvgPicture.asset(
//                       isPasswordVisible ?? false
//                           ? AppIcons.eye
//                           : AppIcons.eyeclosed,
//                       width: 22,
//                       height: 22,
//                       color: primaryColor,
//                     ),
//                   ),
//                 )
//               : null,

//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(color: AppColors.error, width: 1.5),
//           ),
//         ),
//       ),
//     );
//   }
// }
