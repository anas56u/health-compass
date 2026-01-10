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

  // ✅ 1. متغيرات الحالة الجديدة
  bool _isWeeklyView = true;
  String _userName = "مستخدم"; // اسم افتراضي

  void initDashboard() {
    _currentSelectedDate = DateTime.now();

    // ✅ 2. جلب الاسم عند البدء
    _fetchUserName();

    _fetchHealthHistory();
    _listenToTasksForDate(_currentSelectedDate);
  }

  // ✅ 3. دالة لجلب اسم المستخدم الحقيقي
  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      // الاسم من المصادقة كبداية
      _userName = user.displayName ?? "مستخدم";

      // محاولة جلب الاسم التفصيلي من Firestore
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // تحقق من اسم الحقل في الداتابيز لديك (name أو fullName)
          if (data.containsKey('name')) {
            _userName = data['name'];
          } else if (data.containsKey('fullName')) {
            _userName = data['fullName'];
          }
        }
      } catch (e) {
        print("Error fetching name: $e");
      }
      // تحديث الواجهة بالاسم الجديد
      _emitUpdatedState();
    }
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
    // تحويل التاريخ لنفس صيغة التخزين (YYYY-MM-DD)
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
        systolic: 0,
        diastolic: 0,
        weight: 0,
        date: _currentSelectedDate,
      );
    }

    final int totalTasks = _cachedTasks.length;
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
        totalTasks: totalTasks,
        completedTasks: completedCount,
        selectedDate: _currentSelectedDate,
        isWeekly: _isWeeklyView,
        userName: _userName,
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
