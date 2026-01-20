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
    final String name = patientData?['name'] ?? "مريض غير معروف";
    final String? image = patientData?['profileImage'];
    final String email = patientData?['email'] ?? "لا يوجد بريد إلكتروني";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(context),
        body: BlocListener<FamilyCubit, FamilyState>(
          listener: (context, state) {
            if (state is FamilyError) {
              _showSnackBar(context, state.message, Colors.red);
            } else if (state is FamilyOperationSuccess) {
              _showSnackBar(context, state.message, Colors.green);
              // العودة للشاشة الرئيسية بعد نجاح إلغاء الربط
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildPatientInfoCard(name, email, image),
                SizedBox(height: 30.h),

                _buildSectionHeader("تخصيص المتابعة"),
                _buildSettingTile(
                  title: "التنبيهات والإشعارات",
                  subtitle: "إدارة تنبيهات الأدوية والقياسات",
                  icon: Icons.notifications_active_rounded,
                  color: Colors.orange,
                  onTap: () {},
                ),
                _buildSettingTile(
                  title: "صلاحيات الوصول",
                  subtitle: "تحديد ما يمكنك رؤيته أو تعديله",
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.blue,
                  onTap: () {},
                ),

                SizedBox(height: 40.h),
                _buildUnlinkButton(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "إعدادات المريض",
        style: GoogleFonts.tajawal(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPatientInfoCard(String name, String email, String? imageUrl) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundColor: primaryColor.withOpacity(0.1),
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Icon(Icons.person_rounded, color: primaryColor, size: 45.sp)
                : null,
          ),
          SizedBox(height: 15.h),
          Text(
            name,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: GoogleFonts.tajawal(
              color: Colors.grey[500],
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 8.w, bottom: 12.h),
        child: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.sp,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildUnlinkButton(BuildContext context) {
    return InkWell(
      onTap: () => _showUnlinkDialog(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[50]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off_rounded, color: Colors.red[700], size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              "إلغاء ربط هذا المريض",
              style: GoogleFonts.tajawal(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          "هل أنت متأكد؟",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "بإلغاء الربط، لن تتمكن من متابعة العلامات الحيوية لهذا المريض مرة أخرى إلا بطلب ربط جديد.",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "تراجع",
              style: GoogleFonts.tajawal(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // استخدام context الشاشة الأصلي لاستدعاء الكيوبت
                context.read<FamilyCubit>().unlinkPatient(user.uid, patientId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              "نعم، إلغاء الربط",
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.tajawal()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
