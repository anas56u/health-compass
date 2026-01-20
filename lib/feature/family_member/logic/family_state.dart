import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';

abstract class FamilyState {}

/// الحالة الابتدائية عند فتح التطبيق
class FamilyInitial extends FamilyState {}

/// حالة التحميل العامة (تستخدم عند بدء جلب البيانات)
class FamilyLoading extends FamilyState {}

/// حالة نجاح ربط مريض جديد
class FamilyLinkSuccess extends FamilyState {}

/// حالة تظهر عندما لا يمتلك فرد العائلة أي مرضى مرتبطين بحسابه
class FamilyNoLinkedPatients extends FamilyState {}

/// حالة الخطأ العامة (لعرض رسائل الخطأ في الواجهة)
class FamilyError extends FamilyState {
  final String message;
  FamilyError(this.message);
}

/// حالة تحميل خاصة بالعمليات (مثل إضافة دواء أو حذف قياس حيوي)
/// تستخدم لإظهار مؤشر تحميل صغير أو منع الضغط المتكرر
class FamilyOperationLoading extends FamilyState {}

/// حالة نجاح العملية (إضافة/حذف) مع رسالة تأكيد للمستخدم
class FamilyOperationSuccess extends FamilyState {
  final String message;
  FamilyOperationSuccess(this.message);
}

/// حالة فشل عملية معينة (مثل فشل الحذف)
class FamilyOperationError extends FamilyState {
  final String message;
  FamilyOperationError(this.message);
}

/// الحالة الأهم: حالة اكتمال تحميل لوحة التحكم (Dashboard)
/// تحتوي على كل البيانات اللازمة لعرض الشاشة الرئيسية للمريض المختار
class FamilyDashboardLoaded extends FamilyState {
  final List<Map<String, dynamic>> allPatients; // قائمة بجميع المرضى المرتبطين
  final String selectedPatientId; // معرف المريض المختار حالياً
  final Map<String, dynamic>
  currentProfile; // بيانات الملف الشخصي للمريض (الاسم، الصورة)
  final List<VitalModel> currentVitals; // القياسات الحيوية الأخيرة للمريض

  FamilyDashboardLoaded({
    required this.allPatients,
    required this.selectedPatientId,
    required this.currentProfile,
    required this.currentVitals,
  });
}

/// حالة اكتمال تحميل الملف الشخصي لفرد العائلة نفسه
class FamilyProfileLoaded extends FamilyState {
  final FamilyMemberModel userModel;
  FamilyProfileLoaded(this.userModel);
}
