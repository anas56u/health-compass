import 'package:flutter/material.dart';
import 'package:health_compass/core/constants/size_config.dart';
import 'package:health_compass/core/widgets/AchievementsHeader_Card.dart';
import 'package:health_compass/core/widgets/AvailableChallengesList.dart';
import 'package:health_compass/core/widgets/CompletedChallenges.dart';
import 'package:health_compass/core/widgets/Custom_Clipper.dart';
import 'package:health_compass/core/widgets/RewardsSection.dart';
import 'package:health_compass/core/widgets/custom_app_bar.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
              

                  const AchievementsHeaderCard(),
                  SizedBox(height: 35),
                  AvailableChallengesList(),
                  SizedBox(height: 25),
                  const CompletedChallengesSection(),
                  SizedBox(height: 25),
                  const RewardsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

