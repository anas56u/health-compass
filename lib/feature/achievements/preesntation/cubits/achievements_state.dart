

import 'package:health_compass/feature/achievements/data/model/challenge_model.dart';
import 'package:health_compass/feature/achievements/data/model/reward_model.dart';

abstract class AchievementsState {}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final List<ChallengeModel> allChallenges;
  final int totalPoints;
  final int currentLevel;
  final double levelProgress; 
  final List<RewardModel> rewards; // <-- أضفنا هذه// نسبة التقدم للمستوى التالي

  AchievementsLoaded({
    required this.allChallenges,
    required this.totalPoints,
    required this.currentLevel,
    required this.levelProgress, required this.rewards,
  });

}
class ahievementloading extends AchievementsState {}