import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';
import 'doctor_requests_state.dart';

class DoctorRequestsCubit extends Cubit<DoctorRequestsState> {
  final DoctorRequestsRepo _repo;

  DoctorRequestsCubit(this._repo) : super(DoctorRequestsInitial());

  Future<void> acceptPatient(String requestId, String patientId) async {
    emit(DoctorRequestsLoading());
    try {
      await _repo.acceptRequest(requestId, patientId);
      emit(DoctorRequestsSuccess());
    } catch (e) {
      emit(DoctorRequestsError(e.toString()));
    }
  }

  Future<void> rejectPatient(String requestId) async {
    emit(DoctorRequestsLoading());
    try {
      await _repo.rejectRequest(requestId);
      emit(DoctorRequestsSuccess());
    } catch (e) {
      emit(DoctorRequestsError(e.toString()));
    }
  }
}