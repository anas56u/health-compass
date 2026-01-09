import 'package:health_compass/feature/achievements/data/model/challenge_model.dart';
import 'package:health_compass/feature/achievements/data/model/reward_model.dart';

// الحالة الأب (Abstract)
abstract class AchievementsState {}

// الحالة المبدئية
class AchievementsInitial extends AchievementsState {}

// حالة التحميل (Loading)
class AchievementsLoading extends AchievementsState {}

// حالة الخطأ (Error)
class AchievementsError extends AchievementsState {
  final String message;
  AchievementsError(this.message);
}

// حالة نجاح التحميل (Loaded)
class AchievementsLoaded extends AchievementsState {
  final List<ChallengeModel> allChallenges;
  final int totalPoints;
  final int currentLevel;
  final double levelProgress;
  final List<RewardModel> rewards;

  AchievementsLoaded({
    required this.allChallenges,
    required this.totalPoints,
    required this.currentLevel,
    required this.levelProgress,
    required this.rewards,
  });
}
