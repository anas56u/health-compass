import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';

part 'health_dashboard_state.dart';

class HealthDashboardCubit extends Cubit<HealthDashboardState> {
  HealthDashboardCubit() : super(HealthDashboardInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  StreamSubscription? _healthSubscription;
  StreamSubscription? _tasksSubscription;

  List<HealthDataModel> _cachedHistory = [];
  List<TaskModel> _cachedTasks = [];
  DateTime _currentSelectedDate = DateTime.now();

  // ✅ متغير لتتبع الوضع الحالي (افتراضياً أسبوعي)
  bool _isWeeklyView = true;

  void initDashboard() {
    _currentSelectedDate = DateTime.now();
    _fetchHealthHistory(); // سيستخدم القيمة الافتراضية (أسبوعي)
    _listenToTasksForDate(_currentSelectedDate);
  }

  // ✅ دالة جديدة: التبديل بين أسبوعي وشهري
  void toggleViewMode(bool isWeekly) {
    if (_isWeeklyView == isWeekly) return; // لا تفعل شيئاً إذا لم يتغير الوضع

    _isWeeklyView = isWeekly;
    emit(HealthDashboardLoading()); // إظهار تحميل أثناء جلب البيانات الجديدة

    // إعادة جلب السجل بالعدد الجديد (7 أو 30)
    _fetchHealthHistory();
  }

  void changeSelectedDate(DateTime date) {
    _currentSelectedDate = date;
    // عند تغيير التاريخ، لا نحتاج لإعادة جلب السجل الصحي كاملاً، فقط نحدث الواجهة
    _listenToTasksForDate(date);
    _emitUpdatedState();
  }

  void _fetchHealthHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _healthSubscription?.cancel(); // إلغاء الاشتراك القديم

    // ✅ تحديد عدد الأيام بناءً على الوضع المختار
    final int limit = _isWeeklyView ? 7 : 30;

    _healthSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('health_readings')
        .orderBy('timestamp', descending: true)
        .limit(limit) // ✅ جلب 7 أو 30 قراءة
        .snapshots()
        .listen((snapshot) {
          _cachedHistory = snapshot.docs
              .map((doc) => HealthDataModel.fromMap(doc.data()))
              .toList()
              .reversed
              .toList();

          _emitUpdatedState();
        }, onError: (e) => emit(HealthDashboardError(e.toString())));
  }

  // ... (دالة _listenToTasksForDate تبقى كما هي) ...
  void _listenToTasksForDate(DateTime date) {
    // (نفس الكود السابق تماماً)
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _tasksSubscription?.cancel();
    final dateString = date.toIso8601String().split('T')[0];
    _tasksSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_tasks')
        .doc(dateString)
        .collection('tasks_list')
        .snapshots()
        .listen((snapshot) {
          _cachedTasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data()))
              .toList();
          _emitUpdatedState();
        });
  }

  void _emitUpdatedState() {
    HealthDataModel displayData;
    try {
      displayData = _cachedHistory.firstWhere((element) {
        return element.date.year == _currentSelectedDate.year &&
            element.date.month == _currentSelectedDate.month &&
            element.date.day == _currentSelectedDate.day;
      });
    } catch (e) {
      displayData = HealthDataModel(
        heartRate: 0,
        sugar: 0,
        bloodPressure: "",
        weight: 0,
        date: _currentSelectedDate,
      );
    }

    const int fixedTotalTasks = 3;
    final int completedCount = _cachedTasks.where((t) => t.isCompleted).length;
    double percentage = fixedTotalTasks > 0
        ? completedCount / fixedTotalTasks
        : 0.0;

    emit(
      HealthDashboardLoaded(
        latestData: displayData,
        historyData: _cachedHistory,
        commitmentPercentage: percentage,
        totalTasks: fixedTotalTasks,
        completedTasks: completedCount,
        selectedDate: _currentSelectedDate,
        isWeekly: _isWeeklyView, // ✅ تمرير الحالة للواجهة
      ),
    );
  }

  // ... (close تبقى كما هي) ...
  @override
  Future<void> close() {
    _healthSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}
