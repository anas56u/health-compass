abstract class DoctorRequestsState {}
class DoctorRequestsInitial extends DoctorRequestsState {}
class DoctorRequestsLoading extends DoctorRequestsState {}
class DoctorRequestsSuccess extends DoctorRequestsState {} 
class DoctorRequestsError extends DoctorRequestsState {
  final String message;
  DoctorRequestsError(this.message);
}