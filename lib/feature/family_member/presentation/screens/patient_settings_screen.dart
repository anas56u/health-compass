import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';

class PatientSettingsScreen extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic>? patientData;

  const PatientSettingsScreen({
    super.key,
    required this.patientId,
    this.patientData,
  });

  final Color primaryColor = const Color(0xFF41BFAA);

  @override
  Widget build(BuildContext context) {
    // جلب البيانات مع دعم حقل full_name الموجود في قاعدة بياناتك
    final String name =
        patientData?['full_name'] ?? patientData?['name'] ?? "مريض غير معروف";
    final String? image = patientData?['profileImage'];
    final String email = patientData?['email'] ?? "لا يوجد بريد إلكتروني مسجل";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(context),
        body: BlocListener<FamilyCubit, FamilyState>(
          listener: (context, state) {
            // الاستماع لحالة الخطأ أو النجاح عند إلغاء الربط
            if (state is FamilyError) {
              _showSnackBar(context, state.message, Colors.red);
            } else if (state is FamilyOperationSuccess) {
              _showSnackBar(context, state.message, Colors.green);
              Navigator.pop(context); // العودة للشاشة الرئيسية بعد نجاح العملية
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                _buildPatientInfoCard(name, email, image),
                const Spacer(), // دفع زر الإجراء للأسفل لسهولة الاستخدام
                _buildUnlinkSection(context),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "تفاصيل الربط",
        style: GoogleFonts.tajawal(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(String name, String email, String? imageUrl) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Icon(Icons.person_rounded, color: primaryColor, size: 50.sp)
                  : null,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            email,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: Colors.grey[500],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            "ارتباط نشط",
            style: GoogleFonts.tajawal(
              color: Colors.green[700],
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlinkSection(BuildContext context) {
    return Column(
      children: [
        Text(
          "هل ترغب في إنهاء متابعة هذا المريض؟",
          style: GoogleFonts.tajawal(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: () => _showUnlinkDialog(context),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link_off_rounded,
                  color: Colors.red[700],
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  "إلغاء ربط الحساب",
                  style: GoogleFonts.tajawal(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUnlinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        title: Text(
          "تأكيد إلغاء الربط",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "عند تأكيد هذا الإجراء، ستتم إزالة المريض من قائمتك ولن تتمكن من الوصول لبياناته الصحية مرة أخرى.",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "تراجع",
                    style: GoogleFonts.tajawal(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // استدعاء دالة إلغاء الربط من الكيوبت
                      context.read<FamilyCubit>().unlinkPatient(
                        user.uid,
                        patientId,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "تأكيد الحذف",
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
