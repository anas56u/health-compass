import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';

// --- Cubit ---
class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepository _repo;

  FamilyCubit(this._repo) : super(FamilyInitial());

  List<Map<String, dynamic>> _cachedPatients = [];
  Map<String, dynamic> _cachedCurrentProfile = {};
  String? _cachedSelectedId;

  /// ✅ دالة مساعدة لمنع خطأ الـ Bad State (Cannot emit after close)
  void _safeEmit(FamilyState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// ✅ تحديث لوحة التحكم (تحديث البيانات الحيوية والاسم)
  void _emitDashboard() async {
    if (_cachedSelectedId == null) return;
    try {
      // جلب القياسات الحيوية للمريض المختار حالياً
      final vitals = await _repo.getRecentVitals(_cachedSelectedId!);

      _safeEmit(
        FamilyDashboardLoaded(
          allPatients: _cachedPatients,
          selectedPatientId: _cachedSelectedId!,
          currentProfile:
              _cachedCurrentProfile, // سيحتوي الآن على الاسم الصحيح "خالد"
          currentVitals: vitals,
        ),
      );
    } catch (e) {
      _safeEmit(FamilyError("فشل تحديث البيانات: $e"));
    }
  }

  /// ✅ تهيئة الشاشة الرئيسية وجلب قائمة المرضى
  Future<void> initFamilyHome(String familyUid) async {
    _safeEmit(FamilyLoading());
    try {
      _cachedPatients = await _repo.getLinkedPatientsProfiles(familyUid);

      if (_cachedPatients.isEmpty) {
        _safeEmit(FamilyNoLinkedPatients());
        return;
      }

      // اختيار أول مريض تلقائياً عند فتح التطبيق
      final firstPatientId = _cachedPatients.first['id'];
      await selectPatient(firstPatientId);
    } catch (e) {
      _safeEmit(FamilyError("فشل تحميل البيانات: $e"));
    }
  }

  /// ✅ تبديل المريض المختار (إصلاح مشكلة الاسم)
  Future<void> selectPatient(String patientId) async {
    // البحث عن بيانات المريض في القائمة التي تم جلبها من الـ Repository
    final patientProfile = _cachedPatients.firstWhere(
      (p) => p['id'] == patientId,
      orElse: () => {},
    );

    if (patientProfile.isEmpty) {
      _safeEmit(FamilyError("بيانات المريض غير موجودة"));
      return;
    }

    _safeEmit(FamilyLoading());

    // تحديث البيانات المؤقتة بالبيانات الجديدة (التي تم إصلاحها في الـ Repository)
    _cachedSelectedId = patientId;
    _cachedCurrentProfile = patientProfile;

    // استدعاء تحديث لوحة التحكم لجلب القياسات
    _emitDashboard();
  }

  // --- العمليات على العلامات الحيوية (Vitals) ---

  Future<void> addVital({
    required String patientId,
    double? sugar,
    String? pressure,
  }) async {
    _safeEmit(FamilyOperationLoading());
    try {
      await _repo.addVitalRecord(
        patientId: patientId,
        sugar: sugar,
        pressure: pressure,
      );
      _safeEmit(FamilyOperationSuccess("تم تسجيل القراءة بنجاح"));
      _emitDashboard(); // تحديث الواجهة فوراً
    } catch (e) {
      _safeEmit(FamilyOperationError("حدث خطأ أثناء حفظ القراءة"));
      _emitDashboard();
    }
  }

  Future<void> deleteVital(String patientId, String vitalId) async {
    _safeEmit(FamilyOperationLoading());
    try {
      await _repo.deleteVital(patientId, vitalId);
      _safeEmit(FamilyOperationSuccess("تم حذف القراءة بنجاح"));
      _emitDashboard();
    } catch (e) {
      _safeEmit(FamilyOperationError("فشل الحذف: $e"));
      _emitDashboard();
    }
  }

  // --- العمليات على الأدوية (Medications) ---

  Future<void> addMedicationsList(
    String patientId,
    List<Map<String, dynamic>> medicationsList,
  ) async {
    _safeEmit(FamilyOperationLoading());
    try {
      await _repo.addMedicationsBatch(
        patientId: patientId,
        medicationsList: medicationsList,
      );
      _safeEmit(FamilyOperationSuccess("تمت إضافة الدواء بجميع مواعيده بنجاح"));
      _emitDashboard();
    } catch (e) {
      _safeEmit(FamilyOperationError("فشل إضافة الأدوية: $e"));
      _emitDashboard();
    }
  }

  Future<void> deleteMedication(String patientId, String medId) async {
    try {
      await _repo.deleteMedication(patientId, medId);
      _safeEmit(FamilyOperationSuccess("تم حذف الدواء بنجاح"));
      _emitDashboard();
    } catch (e) {
      _safeEmit(FamilyOperationError("فشل الحذف: $e"));
      _emitDashboard();
    }
  }

  // --- إدارة الحساب والربط ---

  Future<void> linkPatient(String familyUid, String code) async {
    _safeEmit(FamilyLoading());
    try {
      await _repo.linkPatientByCode(familyUid, code);
      _safeEmit(FamilyLinkSuccess());
      if (!isClosed) await initFamilyHome(familyUid);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      _safeEmit(FamilyError(errorMsg));
    }
  }

  Future<void> unlinkPatient(String familyUid, String patientId) async {
    _safeEmit(FamilyOperationLoading());
    try {
      await _repo.unlinkPatient(familyUid, patientId);
      _safeEmit(FamilyOperationSuccess("تم إلغاء ربط المريض بنجاح"));
      if (!isClosed) await initFamilyHome(familyUid);
    } catch (e) {
      _safeEmit(FamilyError("فشل الحذف: $e"));
    }
  }

  Future<void> loadMyProfile() async {
    _safeEmit(FamilyLoading());
    try {
      final userModel = await _repo.getMyProfile();
      _safeEmit(FamilyProfileLoaded(userModel));
    } catch (e) {
      _safeEmit(FamilyError("فشل تحميل الملف الشخصي: $e"));
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _safeEmit(FamilyError("فشل تسجيل الخروج"));
    }
  }
}
