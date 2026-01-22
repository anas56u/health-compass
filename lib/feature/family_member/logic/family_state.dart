import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';

abstract class FamilyState {}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

class FamilyLinkSuccess extends FamilyState {}

class FamilyNoLinkedPatients extends FamilyState {}

class FamilyError extends FamilyState {
  final String message;
  FamilyError(this.message);
}

class FamilyOperationLoading extends FamilyState {}

class FamilyOperationSuccess extends FamilyState {
  final String message;
  FamilyOperationSuccess(this.message);
}

class FamilyOperationError extends FamilyState {
  final String message;
  FamilyOperationError(this.message);
}

class FamilyDashboardLoaded extends FamilyState {
  final List<Map<String, dynamic>> allPatients;
  final String selectedPatientId;
  final Map<String, dynamic> currentProfile;
  final List<VitalModel> currentVitals;

  FamilyDashboardLoaded({
    required this.allPatients,
    required this.selectedPatientId,
    required this.currentProfile,
    required this.currentVitals,
  });
}

class FamilyProfileLoaded extends FamilyState {
  final FamilyMemberModel userModel;
  FamilyProfileLoaded(this.userModel);
}
