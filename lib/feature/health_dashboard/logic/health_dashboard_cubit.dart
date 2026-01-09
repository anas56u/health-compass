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
  bool _isWeeklyView = true;

  void initDashboard() {
    _currentSelectedDate = DateTime.now();
    _fetchHealthHistory();
    _listenToTasksForDate(_currentSelectedDate);
  }

  void toggleViewMode(bool isWeekly) {
    if (_isWeeklyView == isWeekly) return;
    _isWeeklyView = isWeekly;
    emit(HealthDashboardLoading());
    _fetchHealthHistory();
  }

  void changeSelectedDate(DateTime date) {
    _currentSelectedDate = date;
    _listenToTasksForDate(date);
    _emitUpdatedState();
  }

  void _fetchHealthHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _healthSubscription?.cancel();
    final int limit = _isWeeklyView ? 7 : 30;

    _healthSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('health_readings')
        .orderBy('timestamp', descending: true)
        .limit(limit)
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

  void _listenToTasksForDate(DateTime date) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _tasksSubscription?.cancel();
    // استخدام تنسيق ISO للتاريخ لضمان تطابقه مع التخزين
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
    // 1. البحث عن القراءة الصحية
    HealthDataModel displayData;
    try {
      displayData = _cachedHistory.firstWhere((element) {
        // مقارنة السنة والشهر واليوم فقط
        return element.date.year == _currentSelectedDate.year &&
            element.date.month == _currentSelectedDate.month &&
            element.date.day == _currentSelectedDate.day;
      });
    } catch (e) {
      displayData = HealthDataModel(
        heartRate: 0,
        sugar: 0,
        systolic: 0,
        diastolic: 0,
        weight: 0,
        date: _currentSelectedDate,
      );
    }

    // 2. ✅ حساب المهام ديناميكياً (إصلاح المنطق)
    final int totalTasks = _cachedTasks.length; // لم يعد 3 ثابتاً
    final int completedCount = _cachedTasks.where((t) => t.isCompleted).length;

    double percentage = 0.0;
    if (totalTasks > 0) {
      percentage = completedCount / totalTasks;
    }

    emit(
      HealthDashboardLoaded(
        latestData: displayData,
        historyData: _cachedHistory,
        commitmentPercentage: percentage,
        totalTasks: totalTasks, // نرسل العدد الحقيقي
        completedTasks: completedCount,
        selectedDate: _currentSelectedDate,
        isWeekly: _isWeeklyView,
      ),
    );
  }

  @override
  Future<void> close() {
    _healthSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}
