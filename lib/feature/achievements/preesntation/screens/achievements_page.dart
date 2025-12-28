import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/widgets/AchievementsHeader_Card.dart';
import 'package:health_compass/core/widgets/AvailableChallengesList.dart';
import 'package:health_compass/core/widgets/CompletedChallenges.dart';
import 'package:health_compass/core/widgets/Custom_Clipper.dart';
import 'package:health_compass/core/widgets/RewardsSection.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/achievements_cubit.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/achievements_state.dart';
// ... import your widgets and cubit

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AchievementsCubit()..subscribeToUserData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: BlocBuilder<AchievementsCubit, AchievementsState>(
          builder: (context, state) {
            if (state is AchievementsLoaded) {
              
              final activeChallenges = state.allChallenges.where((e) => !e.isCompleted).toList();
              final completedChallenges = state.allChallenges.where((e) => e.isCompleted).toList();

              return SingleChildScrollView(
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
                          AchievementsHeaderCard(
                            points: state.totalPoints,
                            level: state.currentLevel,
                            progress: state.levelProgress,
                          ),
                          const SizedBox(height: 35),
                          
                          AvailableChallengesList(challenges: activeChallenges),
                          
                          const SizedBox(height: 25),
                          
                          CompletedChallengesSection(challenges: completedChallenges),
                          
                          const SizedBox(height: 25),
                          
                          RewardsSection(userPoints: state.totalPoints, rewards: state.rewards,),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}