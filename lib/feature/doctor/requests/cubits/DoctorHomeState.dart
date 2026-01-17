
import 'package:health_compass/feature/doctor/models/DoctorStatsModel.dart';

abstract class DoctorHomeState {}

class DoctorHomeInitial extends DoctorHomeState {}

class DoctorHomeLoading extends DoctorHomeState {}

class DoctorHomeSuccess extends DoctorHomeState {
  final DoctorStatsModel stats; // نحمل البيانات هنا عند النجاح
  final List<dynamic> recentPatients; // يمكننا أيضاً تمرير قائمة المرضى هنا

  DoctorHomeSuccess({required this.stats, required this.recentPatients});
}

class DoctorHomeFailure extends DoctorHomeState {
  final String errorMessage;

  DoctorHomeFailure(this.errorMessage);
}