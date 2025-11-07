import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/widgets/HealthStatus_Card.dart';

class header_patientview extends StatelessWidget {
  const header_patientview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 440,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,

                        child: Icon(Icons.person, color: Color(0xFF00796B)),
                      ),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Text(
                    '.. اهلاً بعودتك يا حليم',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'نتمنى لك دوام الصحه',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 40,
            child: HealthStatusCard(),
          ),
        ],
      ),
    );
  }
}
