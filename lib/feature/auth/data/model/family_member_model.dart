import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_compass/feature/auth/data/model/user_model.dart';

class FamilyMemberModel extends UserModel {
  // ✅ 1. إضافة الحقول الجديدة
  final String relation;
  final String permission; // 'view_only' or 'interactive'

  FamilyMemberModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    super.profileImage,
    // ✅ 2. استقبالها في الكونستركتور
    required this.relation,
    required this.permission,
  }) : super(userType: 'family_member');

  @override
  FamilyMemberModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? relation, // إضافة
    String? permission, // إضافة
  }) {
    return FamilyMemberModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      // ✅ 3. تحديث copyWith
      relation: relation ?? this.relation,
      permission: permission ?? this.permission,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'created_at': Timestamp.fromDate(createdAt),
      'profile_image': profileImage,
      // ✅ 4. إضافتها هنا ليتم حفظها في Firebase
      'relation': relation,
      'permission': permission,
    };
  }

  factory FamilyMemberModel.fromMap(Map<String, dynamic> map) {
    return FamilyMemberModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      profileImage: map['profile_image'],
      // ✅ 5. قراءتها عند جلب البيانات
      relation: map['relation'] ?? 'son', // قيمة افتراضية
      permission: map['permission'] ?? 'view_only', // قيمة افتراضية
    );
  }
}
