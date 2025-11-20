import 'package:flutter/material.dart';
import 'package:health_compass/widgets/AchievementsHeader_Card.dart';
import 'package:health_compass/widgets/AvailableChallengesList.dart';
import 'package:health_compass/widgets/ChallengeCard.dart';
import 'package:health_compass/widgets/CustomAppBar.dart';
import 'package:health_compass/widgets/Custom_Clipper.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            ClipPath(
              clipper: Custom_Clipper(),
              child: Container(
                height: 280,
                decoration: const BoxDecoration(color: Color(0xFF009688)),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  CustomAppBar(context),

                  const AchievementsHeaderCard(),

                  AvailableChallengesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
