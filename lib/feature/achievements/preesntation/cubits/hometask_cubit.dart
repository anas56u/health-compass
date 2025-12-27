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

  // الحصول على تاريخ اليوم كـ ID للمستند (2023-10-27)
  String get _todayDocId {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // 1. الاستماع للبيانات بشكل حقيقي (Real-time Stream)
  void startTracking() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(HomeLoading());
    _trackingSubscription?.cancel();

    _trackingSubscription=_firestore
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
              // إذا لم يبدأ اليوم بعد، نرسل بيانات فارغة (أصفار)
              emit(HomeLoaded(DailyTrackingModel(steps: 0, tasksStatus: {})));
            }
          },
          onError: (e) {
            emit(HomeError(e.toString()));
          },
        );
  }

  // 2. دالة إنجاز المهمة (تحديث الفايربيس)
  // 2. دالة إنجاز المهمة (تحديث الفايربيس)
  Future<void> toggleTask(
    String taskId,
    bool isCompleted,
    int rewardPoints,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_tracking')
        .doc(_todayDocId);

    final userRef = _firestore.collection('users').doc(userId);

    try {
      // نستخدم Transaction لضمان سلامة البيانات
      await _firestore.runTransaction((transaction) async {
        final dailySnapshot = await transaction.get(docRef);
        final userSnapshot = await transaction.get(userRef); // قراءة وثيقة المستخدم

        // 1. تحديث حالة المهمة اليومية
        if (!dailySnapshot.exists) {
          transaction.set(docRef, {
            'tasks': {taskId: isCompleted},
            'steps': 0,
          });
        } else {
          transaction.update(docRef, {'tasks.$taskId': isCompleted});
        }

        // 2. تحديث نقاط المستخدم (بأمان)
        int pointsChange = isCompleted ? rewardPoints : -rewardPoints;

        if (!userSnapshot.exists) {
          // إذا لم يكن للمستخدم وثيقة، ننشئ واحدة جديدة بالنقاط المبدئية
          transaction.set(userRef, {
            'totalPoints': pointsChange > 0 ? pointsChange : 0, // لا نبدأ بسالب
            'email': _auth.currentUser?.email, // إضافة بيانات أساسية اختيارياً
          });
        } else {
          // إذا كانت موجودة، نحدث النقاط فقط
          transaction.update(userRef, {
            'totalPoints': FieldValue.increment(pointsChange),
          });
        }
      });
    } catch (e) {
      // طباعة الخطأ في الكونسول للمساعدة في الـ Debugging
      debugPrint("Error triggering task: $e");
      // يمكنك هنا إرسال حالة خطأ للواجهة إذا أردت
       emit(HomeError("فشل تحديث المهمة: تأكد من الاتصال بالإنترنت"));
    }
  }
  // 3. دالة تحديث الخطوات
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
