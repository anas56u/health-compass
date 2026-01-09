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
    if (taskId == 'medication') {
      // تأكد من الـ taskId الفعلي لديك
      return {
        'id': '1', // معرف تحدي الأدوية
        'target': 7, // الهدف: 7 أيام
        'reward': 500, // الجائزة: 500 نقطة
      };
    }
    // مثال: المشي
    if (taskId == 'morning_walk') {
      return {
        'id': '2', // معرف تحدي المشي في achievements_cubit
        'target': 7, // الهدف: 7 أيام
        'reward': 400, // الجائزة
      };
    }
    // مثال: الصحة والضغط
    if (taskId == 'vital_signs') {
      return {
        'id': '3',
        'target': 7, // الهدف: 7 أيام
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
              emit(HomeLoaded(DailyTrackingModel(tasksStatus: {})));
            }
          },
          onError: (e) {
            emit(HomeError(e.toString()));
          },
        );
  }

  // --- 2. المنطق الجديد (Core Logic) ---
  // --- 2. المنطق الجديد (Core Logic) ---
  Future<void> toggleTask(String taskId, bool isCompleted) async {
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
        // ============================================================
        // 1. مرحلة القراءة (READS PHASE)
        // ============================================================

        // أ. قراءة ملف اليوم (للتأكد من حالة الـ Checkbox)
        final dailySnapshot = await transaction.get(dailyDocRef);

        // ب. التحضير لقراءة التحدي
        DocumentSnapshot? challengeSnapshot;
        DocumentReference? challengeRef;
        Map<String, dynamic>? config;

        // نفحص هل هذه عملية "إتمام" مهمة (Check) وليست إلغاء (Uncheck)
        if (isCompleted) {
          config = _getChallengeConfig(taskId);

          if (config != null) {
            final String challengeId = config['id'];
            challengeRef = _firestore
                .collection('users')
                .doc(userId)
                .collection('challenges_progress')
                .doc(challengeId);

            // نقرأ بيانات التحدي الحالية (كم يوم أنجز؟ ومتى كان آخر تحديث؟)
            challengeSnapshot = await transaction.get(challengeRef);
          }
        }

        // ============================================================
        // 2. مرحلة الكتابة (WRITES PHASE)
        // ============================================================

        // أ. تحديث حالة المهمة اليومية (UI Checkbox) - يتم دائماً
        if (!dailySnapshot.exists) {
          transaction.set(dailyDocRef, {
            'tasks': {taskId: isCompleted},
          });
        } else {
          transaction.update(dailyDocRef, {'tasks.$taskId': isCompleted});
        }

        // ب. منطق التحديات الذكي (Smart Challenge Logic)
        if (config != null && challengeRef != null) {
          final int targetSteps = config['target'];
          final int bigReward = config['reward'];

          int currentdays = 0;
          Timestamp? lastUpdated;

          // استخراج البيانات إذا كانت موجودة
          if (challengeSnapshot != null && challengeSnapshot.exists) {
            final data = challengeSnapshot.data() as Map<String, dynamic>?;
            currentdays = data?['currentSteps'] ?? 0;
            lastUpdated = data?['lastUpdated'] as Timestamp?;
          }

          // [Best Practice]: التحقق من "هل تم التحديث اليوم؟"
          bool canIncrement = true;

          if (lastUpdated != null) {
            final DateTime lastDate = lastUpdated.toDate();
            final DateTime now = DateTime.now();

            // مقارنة السنة والشهر واليوم فقط (تجاهل الوقت)
            if (lastDate.year == now.year &&
                lastDate.month == now.month &&
                lastDate.day == now.day) {
              canIncrement = false; // لقد قمت بالتحديث اليوم بالفعل!
            }
          }

          // الشرط الذهبي: نزيد العداد فقط إذا لم نحدث اليوم + لم نصل للهدف بعد
          if (canIncrement && currentdays < targetSteps) {
            int newSteps = currentdays + 1;

            transaction.set(challengeRef, {
              'currentSteps': newSteps,
              'lastUpdated':
                  FieldValue.serverTimestamp(), // نسجل وقت اللحظة الحالية
            }, SetOptions(merge: true));

            // التحقق من الفوز وإعطاء الجائزة الكبرى
            if (newSteps == targetSteps) {
              transaction.update(userRef, {
                'totalPoints': FieldValue.increment(bigReward),
              });
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Error triggering task: $e");
      emit(HomeError("فشل تحديث المهمة: $e"));
    }
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}
