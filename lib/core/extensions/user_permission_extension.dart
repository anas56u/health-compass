import 'package:health_compass/feature/auth/data/model/user_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';

extension UserPermission on UserModel {
  /// ترجع true إذا كان المستخدم لديه صلاحية التعديل والإضافة
  bool get canEdit {
    if (this is PatientModel || this is DoctorModel) {
      return true; // المريض والطبيب دائماً يمكنهم التعديل
    } else if (this is FamilyMemberModel) {
      return (this as FamilyMemberModel).permission == 'interactive';
    }
    return false; // أي حالة أخرى
  }
}
