import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
final  String text;
final double  size;
final FontWeight? weight;

  const CustomText({super.key, required this.text, required this.size , this.weight});
  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: size,
          color: const Color(0xFF000000),
          fontWeight: weight ?? FontWeight.normal,
        ),
      ),
    );
  }
}
