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

  // ✅✅ التصحيح هنا: استخدام تنسيق ISO القياسي (YYYY-MM-DD)
  // هذا يضمن أن التاريخ يكون "2026-01-09" بدلاً من "2026-1-9"
  String get _todayDocId {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  // --- 1. إعدادات التحديات ---
  Map<String, dynamic>? _getChallengeConfig(String taskId) {
    if (taskId == 'medication') return {'id': '1', 'target': 7, 'reward': 500};
    if (taskId == 'morning_walk')
      return {'id': '2', 'target': 7, 'reward': 400};
    if (taskId == 'vital_signs') return {'id': '3', 'target': 7, 'reward': 300};
    return null;
  }

  // --- Start Tracking ---
  void startTracking() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(HomeLoading());
    _trackingSubscription?.cancel();

    _trackingSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId) // سيستخدم الصيغة الصحيحة الآن
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final data = DailyTrackingModel.fromJson(snapshot.data()!);
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

  // --- 2. المنطق الموحد (Unified Logic) ---
  Future<void> toggleTask(String taskId, bool isCompleted) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // 1. مسار التتبع القديم
    final dailyDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId);

    // 2. ✅ مسار الداشبورد (الآن التاريخ متطابق!)
    final dashboardTaskRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tasks')
        .doc(_todayDocId) // 2026-01-09
        .collection('tasks_list')
        .doc(taskId);

    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        // --- قراءة ---
        final dailySnapshot = await transaction.get(dailyDocRef);

        DocumentSnapshot? challengeSnapshot;
        DocumentReference? challengeRef;
        Map<String, dynamic>? config;

        if (isCompleted) {
          config = _getChallengeConfig(taskId);
          if (config != null) {
            final String challengeId = config['id'];
            challengeRef = _firestore
                .collection('users')
                .doc(userId)
                .collection('challenges_progress')
                .doc(challengeId);
            challengeSnapshot = await transaction.get(challengeRef);
          }
        }

        // --- كتابة ---

        // أ. تحديث Daily Tracking (للصفحة الحالية)
        if (!dailySnapshot.exists) {
          transaction.set(dailyDocRef, {
            'tasks': {taskId: isCompleted},
          });
        } else {
          transaction.update(dailyDocRef, {'tasks.$taskId': isCompleted});
        }

        // ب. ✅ تحديث Daily Tasks (للداشبورد)
        transaction.set(dashboardTaskRef, {
          'id': taskId,
          'isCompleted': isCompleted,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ج. منطق التحديات
        if (config != null && challengeRef != null) {
          final int targetSteps = config['target'];
          final int bigReward = config['reward'];
          int currentSteps = 0;
          Timestamp? lastUpdated;

          if (challengeSnapshot != null && challengeSnapshot.exists) {
            final data = challengeSnapshot.data() as Map<String, dynamic>?;
            currentSteps = data?['currentSteps'] ?? 0;
            lastUpdated = data?['lastUpdated'] as Timestamp?;
          }

          bool canIncrement = true;
          if (lastUpdated != null) {
            final DateTime lastDate = lastUpdated.toDate();
            final DateTime now = DateTime.now();
            if (lastDate.year == now.year &&
                lastDate.month == now.month &&
                lastDate.day == now.day) {
              canIncrement = false;
            }
          }

          if (canIncrement && currentSteps < targetSteps) {
            int newSteps = currentSteps + 1;
            transaction.set(challengeRef, {
              'currentSteps': newSteps,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

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
