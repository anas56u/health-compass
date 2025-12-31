import 'package:flutter/material.dart';
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
        // Ensure text handles wrapping correctly if it's long
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2, // Prevents text from taking up too much vertical space
        style: AppTextStyling.fontFamilyTajawal.copyWith(
          fontSize: size,
          // Change pure black to a softer dark color (Better for eyes)
          color: const Color(0xFF1D2635),
          // Increase height slightly to prevent cutting off Arabic letters
          height: 1.2,
          letterSpacing: 0,
          fontWeight:
              weight ?? FontWeight.w700, // w700 is usually cleaner than w800
        ),
      ),
    );
  }
}
