import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core.dart';

class CustomRichText extends StatelessWidget {
  final GestureRecognizer? recognizer;
  final String firstText;
  final String secondText;

  const CustomRichText({
    super.key,
    this.recognizer,
    required this.firstText,
    required this.secondText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstText,
            style: AppTextStyling.fontFamilySTCForward.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.textGrey,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: secondText,
            style: AppTextStyling.fontFamilySTCForward.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            recognizer: recognizer,
          ),
        ],
      ),
    );
  }
}
