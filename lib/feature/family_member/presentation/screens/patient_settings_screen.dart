import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // تأكد من استيراد ScreenUtil
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';

class PatientSettingsScreen extends StatelessWidget {
  // ✅ نستقبل بيانات المريض كاملة لعرضها (الاسم، الصورة، إلخ)
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
    // نستخرج البيانات (مع قيم افتراضية للحماية من الـ Null)
    final String name = patientData?['name'] ?? "مريض غير معروف";
    final String? image = patientData?['profileImage'];
    final String email = patientData?['email'] ?? "لا يوجد بريد إلكتروني";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            "إعدادات المريض",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
        ),
        // ✅ BlocListener للاستماع لنتائج عملية الحذف
        body: BlocListener<FamilyCubit, FamilyState>(
          listener: (context, state) {
            if (state is FamilyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // 1. بطاقة تفاصيل المريض
                _buildPatientInfoCard(name, email, image),

                SizedBox(height: 30.h),

                // 2. خيارات الإعدادات
                _buildSettingTile(
                  title: "التنبيهات والإشعارات",
                  icon: Icons.notifications_active_rounded,
                  color: Colors.orange,
                  onTap: () {
                    // TODO: فتح إعدادات التنبيهات الخاصة بهذا المريض
                  },
                ),
                _buildSettingTile(
                  title: "تعديل الصلاحيات",
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: فتح صفحة الصلاحيات
                  },
                ),

                SizedBox(height: 40.h),

                // 3. زر إلغاء الربط (خطر)
                _buildUnlinkButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(String name, String email, String? imageUrl) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: primaryColor.withOpacity(0.1),
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Icon(Icons.person, color: primaryColor, size: 35.sp)
                : null,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),
                Text(
                  email,
                  style: GoogleFonts.tajawal(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "متصل",
                    style: GoogleFonts.tajawal(
                      color: Colors.green,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
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
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16.sp,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildUnlinkButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () => _showUnlinkDialog(context),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.link_off_rounded, color: Colors.red, size: 24.sp),
        ),
        title: Text(
          "إلغاء ربط المريض",
          style: GoogleFonts.tajawal(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Text(
          "سيتم إزالة المريض من قائمتك نهائياً",
          style: GoogleFonts.tajawal(
            color: Colors.red.withOpacity(0.6),
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }

  void _showUnlinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10.w),
            Text(
              "تأكيد إلغاء الربط",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "هل أنت متأكد من حذف هذا المريض من قائمتك؟ لن تتمكن من متابعة حالته الصحية بعد الآن.",
          style: GoogleFonts.tajawal(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "تراجع",
              style: GoogleFonts.tajawal(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // إغلاق النافذة

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // ✅ استدعاء الكيوبت (نصل إليه عبر الـ context الأصلي للشاشة)
                context.read<FamilyCubit>().unlinkPatient(user.uid, patientId);

                // العودة للشاشة الرئيسية
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              "نعم، إلغاء",
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
}
