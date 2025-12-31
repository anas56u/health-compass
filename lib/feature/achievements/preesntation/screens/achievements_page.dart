import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// تأكد من المسارات الصحيحة للويدجتس الخاصة بك
import 'package:health_compass/core/widgets/AchievementsHeader_Card.dart';
import 'package:health_compass/core/widgets/AvailableChallengesList.dart';
import 'package:health_compass/core/widgets/CompletedChallenges.dart';
import 'package:health_compass/core/widgets/Custom_Clipper.dart';
import 'package:health_compass/core/widgets/RewardsSection.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/achievements_cubit.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/achievements_state.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // توحيد لون الثيم مع باقي التطبيق
    final Color primaryColor = const Color(0xFF0D9488);

    return BlocProvider(
      create: (context) => AchievementsCubit()..subscribeToUserData(),
      child: Directionality(
        textDirection: TextDirection.rtl, // ✅ ضمان الاتجاه العربي
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ وعصري
          body: BlocBuilder<AchievementsCubit, AchievementsState>(
            builder: (context, state) {
              if (state is AchievementsLoaded) {
                final activeChallenges = state.allChallenges
                    .where((e) => !e.isCompleted)
                    .toList();
                final completedChallenges = state.allChallenges
                    .where((e) => e.isCompleted)
                    .toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // حركة تمرير مرنة
                  child: Stack(
                    children: [
                      // الخلفية العلوية المقصوصة
                      ClipPath(
                        clipper: Custom_Clipper(),
                        child: Container(
                          height: 280,
                          decoration: BoxDecoration(
                            // تدرج لوني يعطي مظهراً احترافياً
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // محتوى الصفحة
                      SafeArea(
                        child: Column(
                          children: [
                            AchievementsHeaderCard(
                              points: state.totalPoints,
                              level: state.currentLevel,
                              progress: state.levelProgress,
                            ),

                            const SizedBox(height: 35),

                            AvailableChallengesList(
                              challenges: activeChallenges,
                            ),

                            const SizedBox(height: 25),

                            CompletedChallengesSection(
                              challenges: completedChallenges,
                            ),

                            const SizedBox(height: 25),

                            RewardsSection(
                              userPoints: state.totalPoints,
                              rewards: state.rewards,
                            ),

                            // مسافة سفلية لضمان عدم اختفاء المحتوى خلف البار السفلي
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // حالة التحميل
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
