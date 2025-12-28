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
  StreamSubscription? _challengesProgressSubscription; // [Best Practice]: فصل الاستماع للداتا
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
   // 2. تحديث تحدي المشي (تحويله من خطوات إلى أيام)
    ChallengeModel(
      id: '2',
      title: 'نشاط المشي الصباحي',
      subtitle: 'قم بالمشي صباحاً لمدة 7 أيام', // تغير الوصف
      points: 400, // يمكنك تعديل النقاط
      type: ChallengeType.weekly, // أصبح أسبوعياً (تراكمي)
      totalSteps: 7, // الهدف: 7 أيام بدلاً من 3000 خطوة
      currentSteps: 0,
      icon: Icons.directions_walk,
      color: const Color(0xFF43A047),
    ),
   ChallengeModel(
      id: '3',
      title: 'متابعة المؤشرات الحيوية',
      subtitle: 'سجل قياساتك (ضغط/سكري) لمدة 7 أيام',
      points: 300,
      type: ChallengeType.weekly,
      totalSteps: 7, 
      currentSteps: 0,
      icon: Icons.monitor_heart,
      color: const Color(0xFFD32F2F),
    ),
  ];
 void subscribeToUserData() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    _userSubscription?.cancel();
    _challengesProgressSubscription?.cancel();

    emit(ahievementloading());
    _userSubscription=_firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (isClosed) return;
     _listenToChallengesProgress(userId, snapshot);
    }, onError: (e) {
      print("Error fetching user data: $e");
    });
  }
  void _listenToChallengesProgress(String userId, DocumentSnapshot userSnapshot) {
    _challengesProgressSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges_progress')
        .snapshots()
        .listen((progressSnapshot) {
      
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      final int currentPoints = userData?['totalPoints'] ?? 0;
      final int level = (currentPoints / 1000).floor() + 1;
      final double progress = (currentPoints % 1000) / 1000;

     
      Map<String, int> serverProgressMap = {};
      for (var doc in progressSnapshot.docs) {
        serverProgressMap[doc.id] = doc.data()['currentSteps'] ?? 0;
      }

     
      List<ChallengeModel> updatedChallenges = _fixedChallenges.map((challenge) {
        int serverSteps = serverProgressMap[challenge.id] ?? 0;
        
        return challenge.copyWith(currentSteps: serverSteps);
      }).toList();

      emit(AchievementsLoaded(
        allChallenges: updatedChallenges,
        rewards: _fixedRewards,
        totalPoints: currentPoints,
        currentLevel: level,
        levelProgress: progress,
      ));
    }, onError: (e) {
      print("Error fetching challenges progress: $e");
    });
  }

 

  @override
  Future<void> close() {
    _userSubscription?.cancel(); 
    return super.close();
  }
}
