import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';
import 'package:intl/intl.dart';

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
  String _userName = "مستخدم";

  void initDashboard() {
    _currentSelectedDate = DateTime.now();
    _fetchUserName();
    _fetchHealthHistory();
    _listenToTasksForDate(_currentSelectedDate);
  }

  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      _userName = user.displayName ?? "مستخدم";
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('name')) {
            _userName = data['name'];
          } else if (data.containsKey('fullName')) {
            _userName = data['fullName'];
          }
        }
      } catch (e) {
        print("Error fetching name: $e");
      }
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

    // ✅ استخدام حقل 'date' بدلاً من 'timestamp' ليتوافق مع الـ Repository
    _healthSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('health_readings')
       .orderBy('timestamp', descending: true)
        .limit(limit * 2)
        .snapshots()
        .listen((snapshot) {
          final Map<String, HealthDataModel> uniqueData = {};

          for (var doc in snapshot.docs) {
            final data = HealthDataModel.fromMap(doc.data());

            // ✅ إنشاء مفتاح فريد لكل دقيقة (سنة-شهر-يوم-ساعة-دقيقة)
            // هذا يضمن أن أي قراءات مكررة في نفس الدقيقة ستظهر كقراءة واحدة فقط
            final String timeKey = DateFormat(
              'yyyyMMdd_HHmm',
            ).format(data.date);

            if (!uniqueData.containsKey(timeKey)) {
              uniqueData[timeKey] = data;
            }
          }

          // تحويل الـ Map إلى قائمة وترتيبها زمنياً
          _cachedHistory = uniqueData.values.toList().reversed.toList();
          _emitUpdatedState();
        }, onError: (e) => emit(HealthDashboardError(e.toString())));
  }

  void _listenToTasksForDate(DateTime date) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _tasksSubscription?.cancel();
    final dateString = "${date.year}-${date.month}-${date.day}";

    _tasksSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_tracking')
        .doc(dateString)
        .snapshots()
        .listen((docSnapshot) {
          if (docSnapshot.exists && docSnapshot.data() != null) {
            final data = docSnapshot.data()!;
            if (data.containsKey('tasks')) {
              // التأكد من استدعاء الدالة الستاتيكية الجديدة في الموديل
              _cachedTasks = TaskModel.fromMap(
                data['tasks'] as Map<String, dynamic>,
              );
            } else {
              _cachedTasks = [];
            }
          } else {
            _cachedTasks = [];
          }
          _emitUpdatedState(); // سيقوم بتحديث النسبة المئوية فوراً
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

    double percentage = totalTasks > 0 ? completedCount / totalTasks : 0.0;

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
