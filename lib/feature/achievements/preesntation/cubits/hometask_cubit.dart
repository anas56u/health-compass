import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/achievements/data/model/daily_tracking_model.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_state.dart';

class HometaskCubit extends Cubit<HometaskState> {
  HometaskCubit() : super(HomeInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _trackingSubscription;

  String get _todayDocId {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // --- 1. إعدادات التحديات (قواعد اللعبة) ---
  // هذه الدالة تعيد لنا معلومات التحدي المرتبط بالمهمة:
  // [ID, TargetSteps, RewardPoints]
  Map<String, dynamic>? _getChallengeConfig(String taskId) {
    // مثال: إذا كانت المهمة تحتوي على كلمة "medicine"
    if (taskId.contains('medicine') || taskId == '1') { // تأكد من الـ taskId الفعلي لديك
      return {
        'id': '1',           // معرف تحدي الأدوية
        'target': 7,         // الهدف: 7 أيام
        'reward': 500,       // الجائزة: 500 نقطة
      };
    }
    // مثال: المشي
    if (taskId.contains('walk') || taskId == '2') {
      return {
        'id': '2',
        'target': 3000,      // الهدف
        'reward': 100,       // الجائزة
      };
    }
    // مثال: الصحة والضغط
    if (taskId.contains('pressure') || taskId == '3') {
      return {
        'id': '3',
        'target': 30,
        'reward': 300,
      };
    }
    return null; // لا يوجد تحدي مرتبط
  }

  // ... (دالة startTracking تبقى كما هي) ...
  void startTracking() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(HomeLoading());
    _trackingSubscription?.cancel();

    _trackingSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = DailyTrackingModel.fromJson(snapshot.data());
          emit(HomeLoaded(data));
        } else {
          emit(HomeLoaded(DailyTrackingModel(steps: 0, tasksStatus: {})));
        }
      },
      onError: (e) {
        emit(HomeError(e.toString()));
      },
    );
  }

  // --- 2. المنطق الجديد (Core Logic) ---
  Future<void> toggleTask(
    String taskId,
    bool isCompleted,
    // قمنا بإلغاء استخدام rewardPoints هنا لأن النقاط ستأتي من التحدي فقط
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final dailyDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId);

    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final dailySnapshot = await transaction.get(dailyDocRef);
        
        // أ. تحديث حالة المهمة اليومية (صح أو خطأ في الهوم بيج)
        if (!dailySnapshot.exists) {
          transaction.set(dailyDocRef, {
            'tasks': {taskId: isCompleted},
            'steps': 0,
          });
        } else {
          transaction.update(dailyDocRef, {'tasks.$taskId': isCompleted});
        }

        // ب. منطق التحديات (هنا التغيير الجذري)
        // 1. نجلب إعدادات التحدي المرتبط بهذه المهمة
        final config = _getChallengeConfig(taskId);

        // ننفذ فقط إذا كان هناك تحدي مرتبط وتم إنجاز المهمة (isCompleted == true)
        if (config != null && isCompleted) {
          final String challengeId = config['id'];
          final int targetSteps = config['target'];
          final int bigReward = config['reward'];

          final challengeRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('challenges_progress')
              .doc(challengeId);

          final challengeSnapshot = await transaction.get(challengeRef);

          // حساب التقدم الجديد
          int currentSteps = 0;
          if (challengeSnapshot.exists) {
            currentSteps = challengeSnapshot.data()?['currentSteps'] ?? 0;
          }
          int newSteps = currentSteps + 1;

          // تحديث التقدم في التحدي دائماً
          transaction.set(challengeRef, {
            'currentSteps': newSteps,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // ج. التحقق من لحظة الفوز (Winning Moment)
          // هل التقدم الجديد يساوي الهدف بالضبط؟
          if (newSteps == targetSteps) {
            // مبروك! لقد أتممت التحدي، الآن فقط نعطيك النقاط
            transaction.update(userRef, {
              'totalPoints': FieldValue.increment(bigReward),
            });
          }
          // ملاحظة: إذا كان newSteps > targetSteps لن نعطي نقاطاً إضافية
        }
        
        // لاحظ: قمنا بحذف الكود القديم الذي كان يعطي نقاطاً فورية خارج شرط التحدي
      });

    } catch (e) {
      debugPrint("Error triggering task: $e");
      emit(HomeError("فشل تحديث المهمة"));
    }
  }

  // ... (updateSteps و close تبقى كما هي) ...
   Future<void> updateSteps(int steps) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId)
        .set({'steps': steps}, SetOptions(merge: true));
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}