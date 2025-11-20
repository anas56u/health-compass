 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget CustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'الانجازات',
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
           
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), 
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }