import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';

// --- States ---
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

// --- Cubit ---
class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepository _repo;

  FamilyCubit(this._repo) : super(FamilyInitial());

  List<Map<String, dynamic>> _cachedPatients = [];
  Map<String, dynamic> _cachedCurrentProfile = {};
  String? _cachedSelectedId;

  void _emitDashboard() async {
    if (_cachedSelectedId == null) return;
    try {
      final vitals = await _repo.getRecentVitals(_cachedSelectedId!);
      emit(
        FamilyDashboardLoaded(
          allPatients: _cachedPatients,
          selectedPatientId: _cachedSelectedId!,
          currentProfile: _cachedCurrentProfile,
          currentVitals: vitals,
        ),
      );
    } catch (e) {
      emit(FamilyError("فشل تحديث البيانات: $e"));
    }
  }

  Future<void> initFamilyHome(String familyUid) async {
    emit(FamilyLoading());
    try {
      _cachedPatients = await _repo.getLinkedPatientsProfiles(familyUid);
      if (_cachedPatients.isEmpty) {
        emit(FamilyNoLinkedPatients());
        return;
      }
      final firstPatientId = _cachedPatients.first['id'];
      await selectPatient(firstPatientId);
    } catch (e) {
      emit(FamilyError("فشل تحميل البيانات: $e"));
    }
  }

  Future<void> selectPatient(String patientId) async {
    final patientProfile = _cachedPatients.firstWhere(
      (p) => p['id'] == patientId,
      orElse: () => {},
    );

    if (patientProfile.isEmpty) {
      emit(FamilyError("بيانات المريض غير موجودة"));
      return;
    }

    emit(FamilyLoading());
    _cachedSelectedId = patientId;
    _cachedCurrentProfile = patientProfile;
    _emitDashboard();
  }

  // --- العمليات على العلامات الحيوية (Vitals) ---

  Future<void> addVital({
    required String patientId,
    double? sugar,
    String? pressure,
  }) async {
    emit(FamilyOperationLoading());
    try {
      await _repo.addVitalRecord(
        patientId: patientId,
        sugar: sugar,
        pressure: pressure,
      );
      emit(FamilyOperationSuccess("تم تسجيل القراءة بنجاح"));
      _emitDashboard();
    } catch (e) {
      emit(FamilyOperationError("حدث خطأ أثناء حفظ القراءة"));
      _emitDashboard();
    }
  }

  Future<void> deleteVital(String patientId, String vitalId) async {
    emit(FamilyOperationLoading());
    try {
      await _repo.deleteVital(patientId, vitalId);
      emit(FamilyOperationSuccess("تم حذف القراءة بنجاح"));
      _emitDashboard();
    } catch (e) {
      emit(FamilyOperationError("فشل الحذف: $e"));
      _emitDashboard();
    }
  }

  // --- العمليات على الأدوية (Medications) ---

  // ✅ تم التصحيح: استدعاء الـ Repository بدلاً من كتابة كود Firestore هنا
  Future<void> addMedicationsList(
    String patientId,
    List<Map<String, dynamic>> medicationsList,
  ) async {
    emit(FamilyOperationLoading());
    try {
      await _repo.addMedicationsBatch(
        patientId: patientId,
        medicationsList: medicationsList,
      );
      emit(FamilyOperationSuccess("تمت إضافة الدواء بجميع مواعيده بنجاح"));
      _emitDashboard();
    } catch (e) {
      emit(FamilyOperationError("فشل إضافة الأدوية: $e"));
      _emitDashboard();
    }
  }

  Future<void> deleteMedication(String patientId, String medId) async {
    try {
      await _repo.deleteMedication(patientId, medId);
      emit(FamilyOperationSuccess("تم حذف الدواء بنجاح"));
      _emitDashboard();
    } catch (e) {
      emit(FamilyOperationError("فشل الحذف: $e"));
      _emitDashboard();
    }
  }

  // --- إدارة الحساب والربط ---

  Future<void> linkPatient(String familyUid, String code) async {
    emit(FamilyLoading());
    try {
      await _repo.linkPatientByCode(familyUid, code);
      emit(FamilyLinkSuccess());
      await initFamilyHome(familyUid);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      emit(FamilyError(errorMsg));
    }
  }

  Future<void> unlinkPatient(String familyUid, String patientId) async {
    emit(FamilyOperationLoading());
    try {
      await _repo.unlinkPatient(familyUid, patientId);
      emit(FamilyOperationSuccess("تم إلغاء ربط المريض بنجاح"));
      await initFamilyHome(familyUid);
    } catch (e) {
      emit(FamilyError("فشل الحذف: $e"));
    }
  }

  Future<void> loadMyProfile() async {
    emit(FamilyLoading());
    try {
      final userModel = await _repo.getMyProfile();
      emit(FamilyProfileLoaded(userModel));
    } catch (e) {
      emit(FamilyError("فشل تحميل الملف الشخصي: $e"));
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      emit(FamilyError("فشل تسجيل الخروج"));
    }
  }
}
