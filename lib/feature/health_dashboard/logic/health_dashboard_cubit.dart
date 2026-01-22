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

    _healthSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('health_readings')
        .orderBy('timestamp', descending: true)
        .limit(limit * 50) // زدنا اللييمت لنضمن جلب كل قراءات اليوم الدقيقة
        .snapshots()
        .listen((snapshot) {
          // ✅ ألغينا منطق uniqueData الذي كان يحذف القراءات في نفس الدقيقة
          // نأخذ كل البيانات كما هي من القاعدة
          _cachedHistory = snapshot.docs
              .map((doc) => HealthDataModel.fromMap(doc.data()))
              .toList();
          
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
      // فلترة بيانات اليوم المحدد
      final todaysReadings = _cachedHistory.where((element) {
        return element.date.year == _currentSelectedDate.year &&
            element.date.month == _currentSelectedDate.month &&
            element.date.day == _currentSelectedDate.day;
      }).toList();

      if (todaysReadings.isEmpty) {
        displayData = HealthDataModel(
            heartRate: 0, sugar: 0, systolic: 0, diastolic: 0, weight: 0, date: _currentSelectedDate);
      } else {
        // ترتيب من القديم للحديث للدمج الصحيح
        todaysReadings.sort((a, b) => a.date.compareTo(b.date));

        // متغيرات لتجميع أحدث القيم
        double lastHeartRate = 0;
        int lastSugar = 0;
        int lastSystolic = 0;
        int lastDiastolic = 0;
        double lastWeight = 0;

        // ✅ Loop يمر على كل القراءات ويحدث القيم إذا كانت أكبر من صفر
        for (var reading in todaysReadings) {
          if (reading.heartRate > 0) lastHeartRate = reading.heartRate;
          if (reading.sugar > 0) lastSugar = reading.sugar; // هنا سيحفظ الـ 101 ولن يصفرها لأن القراءات اللاحقة لا تحتوي على مفتاح sugar أصلاً
          if (reading.systolic > 0) {
            lastSystolic = reading.systolic;
            lastDiastolic = reading.diastolic;
          }
          if (reading.weight > 0) lastWeight = reading.weight;
        }

        displayData = HealthDataModel(
          heartRate: lastHeartRate,
          sugar: lastSugar,
          systolic: lastSystolic,
          diastolic: lastDiastolic,
          weight: lastWeight,
          date: todaysReadings.last.date,
        );
        
        print("📊 Dashboard Data: Sugar=$lastSugar, HR=$lastHeartRate");
      }
    } catch (e) {
      print("Error: $e");
      displayData = HealthDataModel(
          heartRate: 0, sugar: 0, systolic: 0, diastolic: 0, weight: 0, date: _currentSelectedDate);
    }

    // حساب التاسكات (بدون تغيير)
    final int totalTasks = _cachedTasks.length;
    final int completedCount = _cachedTasks.where((t) => t.isCompleted).length;
    double percentage = totalTasks > 0 ? completedCount / totalTasks : 0.0;

    emit(HealthDashboardLoaded(
      latestData: displayData,
      historyData: _cachedHistory,
      commitmentPercentage: percentage,
      totalTasks: totalTasks,
      completedTasks: completedCount,
      selectedDate: _currentSelectedDate,
      isWeekly: _isWeeklyView,
      userName: _userName,
    ));
  }
  @override
  Future<void> close() {
    _healthSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}
