import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';

// --- States (الحالات) ---
abstract class FamilyState {}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

// ✅ حالة جديدة: نجاح عملية الربط (للتوجيه)
class FamilyLinkSuccess extends FamilyState {}

class FamilyLoaded extends FamilyState {
  final Map<String, dynamic> patientProfile;
  final List<VitalModel> vitals;
  // الأدوية ستأتي عبر Stream لذا لا نضعها هنا
  FamilyLoaded(this.patientProfile, this.vitals);
}

class FamilyError extends FamilyState {
  final String message;
  FamilyError(this.message);
}

// --- Cubit (المنطق) ---
class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepository _repo;

  FamilyCubit(this._repo) : super(FamilyInitial());

  // 1. دالة لجلب كل بيانات لوحة التحكم (Dashboard)
  Future<void> loadDashboardData(String patientId) async {
    emit(FamilyLoading());
    try {
      // جلب البروفايل
      final profile = await _repo.getPatientProfile(patientId);

      // جلب العلامات الحيوية
      final vitals = await _repo.getRecentVitals(patientId);

      emit(FamilyLoaded(profile, vitals));
    } catch (e) {
      emit(FamilyError("فشل تحميل البيانات: $e"));
    }
  }

  // 2. دالة لربط مريض جديد
  Future<void> linkPatient(String familyUid, String code) async {
    emit(FamilyLoading()); // إطلاق حالة التحميل
    try {
      // الاتصال بالمستودع
      await _repo.linkPatientByCode(familyUid, code);

      // ✅ إطلاق حالة النجاح الخاصة بالربط
      emit(FamilyLinkSuccess());
    } catch (e) {
      // تنسيق رسالة الخطأ
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      emit(FamilyError(errorMsg));
    }
  }

  // ✅✅ 3. دالة إلغاء الربط (هذه هي الدالة التي كانت ناقصة)
  Future<void> unlinkPatient(String familyUid, String patientId) async {
    // ملاحظة: يمكننا إطلاق Loading هنا إذا أردنا إظهار مؤشر تحميل،
    // لكننا نفضل إبقاء التجربة سلسة والعودة للبداية بعد النجاح.
    try {
      await _repo.unlinkPatient(familyUid, patientId);

      // بعد الحذف بنجاح، نرجع للحالة الأولية (Initial)
      // هذا سيجعل الشاشة الرئيسية تكتشف أن القائمة أصبحت فارغة عند إعادة التحميل
      emit(FamilyInitial());
    } catch (e) {
      emit(FamilyError("فشل الحذف: $e"));
    }
  }
}
