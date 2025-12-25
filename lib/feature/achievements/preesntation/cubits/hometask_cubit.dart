import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/achievements/data/model/daily_tracking_model.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_state.dart';

class HometaskCubit extends Cubit<HometaskState> {
  HometaskCubit() : super(HomeInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    _firestore
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

    // نستخدم Transaction لضمان تحديث النقاط والمهمة معاً بأمان
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // إنشاء مستند لليوم إذا لم يوجد
        transaction.set(docRef, {
          'tasks': {taskId: isCompleted},
          'steps': 0,
        });
      } else {
        // تحديث المهمة فقط
        transaction.update(docRef, {'tasks.$taskId': isCompleted});
      }

      // إضافة النقاط للمستخدم (فقط إذا أصبحت المهمة مكتملة)
      if (isCompleted) {
        // نقرأ النقاط الحالية ونضيف عليها
        // (ملاحظة: لتبسيط الكود هنا استخدمنا FieldValue.increment)
        transaction.update(userRef, {
          'totalPoints': FieldValue.increment(rewardPoints),
        });
      } else {
        // خصم النقاط إذا ألغى المهمة
        transaction.update(userRef, {
          'totalPoints': FieldValue.increment(-rewardPoints),
        });
      }
    });
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
}
