import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationTimeSlot extends StatelessWidget {
  final String time;
  final String period; // ص للصباح، م للمساء

  const MedicationTimeSlot({
    super.key,
    required this.time,
    this.period = 'ص',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            period,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

