import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:health_compass/feature/doctor/models/DoctorStatsModel.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeState.dart';
// import your model and repo here

class DoctorHomeCubit extends Cubit<DoctorHomeState> {
  // نحتاج لـ Repository لجلب البيانات (سنفترض وجوده)
  // final DoctorRepository _doctorRepo; 

  DoctorHomeCubit() : super(DoctorHomeInitial());

  Future<void> getDashboardData() async {
    emit(DoctorHomeLoading()); // 1. أبلغ الـ UI بأننا بدأنا التحميل

    try {
      // محاكاة لجلب البيانات من الـ Backend (أو Firebase)
      // في الحقيقة ستكون: final patients = await _doctorRepo.getPatients();
      
      // لنفترض أن هذه هي البيانات الراجعة (List of Patients)
      final List<Map<String, dynamic>> dummyPatients = [
        {'name': 'هدى', 'status': 'stable'},
        {'name': 'أحمد', 'status': 'critical'}, // طارئة
        {'name': 'علي', 'status': 'stable'},
        {'name': 'سارة', 'status': 'stable'},
        {'name': 'خالد', 'status': 'critical'}, // طارئة
      ];

      // --- اللوجيك (Business Logic) ---
      // هنا نقوم بحساب الأرقام بدلاً من الاعتماد على الـ Backend فقط
      
      final int total = dummyPatients.length;
      
      // حساب الحالات المستقرة (filter)
      final int stable = dummyPatients.where((p) => p['status'] == 'stable').length;
      
      // حساب الحالات الطارئة
      final int emergency = dummyPatients.where((p) => p['status'] == 'critical').length;

      // إنشاء الموديل
      final stats = DoctorStatsModel(
        totalPatients: total,
        stableCases: stable,
        emergencyCases: emergency,
      );

      // 2. النجاح وإرسال البيانات
      emit(DoctorHomeSuccess(stats: stats, recentPatients: dummyPatients));
      
    } catch (e) {
      // 3. الفشل
      emit(DoctorHomeFailure(e.toString()));
    }
  }
}