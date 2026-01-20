import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/doctor/models/DoctorStatsModel.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeState.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';

class DoctorHomeCubit extends Cubit<DoctorHomeState> {
  final DoctorRequestsRepo _doctorRepo = DoctorRequestsRepo();

  DoctorHomeCubit() : super(DoctorHomeInitial());

  Future<void> getDashboardData() async {
    emit(DoctorHomeLoading());

    try {
      // جلب البيانات الحقيقية
      final List<PatientModel> myPatients = await _doctorRepo.getMyPatients();
      
      // حساب العدد الكلي (يبقى كما هو)
      final int total = myPatients.length;

      final stats = DoctorStatsModel(
        totalPatients: total,
        stableCases: 0, 
        emergencyCases: 0,
      );

      // تجهيز البيانات للواجهة
      final List<Map<String, dynamic>> patientsAsMap = myPatients.map((p) {
        return {
          'name': p.fullName,
          'image': p.profileImage,
          'disease': p.diseaseType,
          'has_issues': p.hasOtherIssues,
          // أضفنا هذا الحقل الجديد لعرضه في الكرت
          'specific_disease': p.specificDisease, 
        };
      }).toList();

      emit(DoctorHomeSuccess(stats: stats, recentPatients: patientsAsMap));
      
    } catch (e) {
      print('Error inside DoctorHomeCubit: $e');
      emit(DoctorHomeFailure(e.toString()));
    }
  }
}