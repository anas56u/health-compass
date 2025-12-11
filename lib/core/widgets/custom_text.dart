import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/themes/app_text_styling.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight? weight;

  const CustomText({
    super.key,
    required this.text,
    required this.size,
    this.weight,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: AppTextStyling.fontFamilyTajawal.copyWith(
          fontSize: size,
          color: const Color(0xFF000000),
          height: 1,
          letterSpacing: 0,
          fontWeight: weight ?? FontWeight.w800,
        ),
      ),
    );
  }
}
