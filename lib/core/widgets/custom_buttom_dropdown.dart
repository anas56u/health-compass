import 'package:flutter/material.dart';
import '../core.dart'; // تأكد من المسار الصحيح مثل CustomButton

class CustomDropdownButton extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final List<String> items;
  final double? width;
  final double height;
  final Gradient? gradient;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final Border? border;

  const CustomDropdownButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.width,
    this.height = 50,
    this.gradient,
    this.textColor,
    this.borderRadius = 16,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [AppColors.buttonBlueStart, AppColors.buttonBlueEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.buttonBlueEnd,
              borderRadius: BorderRadius.circular(12),
              iconEnabledColor: textColor ?? AppColors.white,
              style: AppTextStyling.fontFamilySTCForward.copyWith(
                color: textColor ?? AppColors.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
