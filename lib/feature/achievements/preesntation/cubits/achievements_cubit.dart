import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/achievements/data/model/challenge_model.dart';
import 'package:health_compass/feature/achievements/data/model/reward_model.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _userSubscription;
  AchievementsCubit() : super(AchievementsInitial());
  final List<RewardModel> _fixedRewards = [
    RewardModel(
      title: "هدية مجانية",
      subtitle: "15 دقيقة مجانية لتجري بها مكالمة فيديو مع طبيبك",
      pointsCost: 1000,
      icon: Icons.card_giftcard,
    ),
    RewardModel(
      title: "عرض حصري",
      subtitle: "خصم 50% من قيمة فاتورتك من الصيدليات المعتمدة",
      pointsCost: 1000,
      icon: Icons.fitness_center,
    ),
    RewardModel(
      title: "استشارة تغذية",
      subtitle: "جلسة كاملة لتنظيم جدولك الغذائي",
      pointsCost: 2500, // مثال لمكافأة أغلى
      icon: Icons.restaurant_menu,
    ),
  ];
  // هذه هي البيانات الثابتة كما طلبت، لكننا وضعناها داخل الكيوبت
  // في التطبيقات الأكبر، عادة ما تأتي هذه القائمة من ملف Repository منفصل
  final List<ChallengeModel> _fixedChallenges = [
    ChallengeModel(
      id: '1',
      title: 'الالتزام بالادوية',
      subtitle: 'التزم بأخذ ادويتك لمدة 7 ايام متتالية',
      points: 500,
      type: ChallengeType.weekly,
      totalSteps: 7,
      currentSteps: 5, // هذا الرقم يمكن أن يأتي من قاعدة بيانات المستخدم لاحقاً
      icon: Icons.medication,
      color: const Color(0xFF006994),
    ),
    ChallengeModel(
      id: '2',
      title: 'الالتزام بالمشي',
      subtitle: 'امشي 3000 خطوة اليوم',
      points: 100,
      type: ChallengeType.daily,
      totalSteps: 3000,
      currentSteps: 1500,
      icon: Icons.directions_walk,
      color: const Color(0xFF43A047),
    ),
    ChallengeModel(
      id: '3',
      title: 'متابعة حالتك الصحية',
      subtitle: 'متابعة قياساتك لمدة 30 يوم متتالية',
      points: 300,
      type: ChallengeType.monthly,
      totalSteps: 30,
      currentSteps: 30, // مكتمل
      icon: Icons.monitor_heart,
      color: const Color(0xFFD32F2F),
    ),
    // يمكنك إضافة المزيد هنا...
  ];
 void subscribeToUserData() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    _userSubscription?.cancel();

    emit(ahievementloading()); // حالة تحميل مبدئية

    // نستمع للتغيرات في وثيقة المستخدم
    _userSubscription=_firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (isClosed) return;
      if (snapshot.exists) {
        final data = snapshot.data();
        
        // 1. جلب النقاط الحالية من الفايربيس (التي زادتها صفحة الهوم)
        final int currentPoints = data?['totalPoints'] ?? 0;

        // 2. حساب المستوى (لوجيك محلي)
        // مثال: المستوى 1 يبدأ من 0، كل 1000 نقطة مستوى جديد
        final int level = (currentPoints / 1000).floor() + 1;

        // 3. حساب نسبة التقدم للمستوى القادم
        final int pointsInCurrentLevel = currentPoints % 1000;
        final double progress = pointsInCurrentLevel / 1000;

        // 4. تحديث الواجهة فوراً
        emit(AchievementsLoaded(
          allChallenges: _fixedChallenges, // القائمة الثابتة
          rewards: _fixedRewards,          // القائمة الثابتة
          totalPoints: currentPoints,      // <--- هذا الرقم يأتي الآن من الفايربيس
          currentLevel: level,
          levelProgress: progress,
        ));
      }
    }, onError: (e) {
      // التعامل مع الأخطاء
      print("Error fetching user data: $e");
    });
  }

  void loadAchievementsData() {
    // 1. حساب مجموع النقاط للتحديات المكتملة فقط
    int points = 0;
    for (var challenge in _fixedChallenges) {
      if (challenge.isCompleted) {
        points += challenge.points;
      }
    }
    // ملاحظة: يمكنك إضافة نقاط أساسية للمستخدم إذا كان لديه رصيد سابق

    // 2. حساب المستوى (مثال: كل 1000 نقطة = مستوى)
    int level = (points / 1000).floor() + 1;

    // 3. حساب التقدم للمستوى التالي
    // مثال: إذا نقاطي 3250، باقي القسمة 250. الهدف 1000. النسبة 0.25
    int pointsInCurrentLevel = points % 1000;
    double progress = pointsInCurrentLevel / 1000;

    // 4. إرسال الحالة للواجهة
    emit(
      AchievementsLoaded(
        allChallenges: _fixedChallenges,
        totalPoints: points,
        currentLevel: level,
        levelProgress: progress,
        rewards: _fixedRewards,
      ),
    );
  }
  @override
  Future<void> close() {
    _userSubscription?.cancel(); // قطع الاتصال بالفايربيس
    return super.close();
  }
}
