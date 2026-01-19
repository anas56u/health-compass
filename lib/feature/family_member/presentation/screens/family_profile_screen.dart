import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/routes/routes.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  final Color primaryColor = const Color(0xFF41BFAA);

  // بيانات وهمية للعرض (يمكنك استبدالها ببيانات Firebase الحقيقية)
  final String _userName = "سامي أحمد";
  final String _userEmail = "sami.ahmed@example.com";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "حسابي",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              // 1. بطاقة التعريف الشخصية
              _buildHeaderCard(),

              SizedBox(height: 30.h),

              // 2. قائمة الإعدادات
              _buildSectionTitle("إعدادات الحساب"),
              _buildSettingsTile(
                title: "تعديل الملف الشخصي",
                icon: Icons.person_outline_rounded,
                color: Colors.blue,
                onTap: () {
                  // TODO: الانتقال لصفحة تعديل الاسم ورقم الهاتف
                },
              ),
              _buildSettingsTile(
                title: "تغيير كلمة المرور",
                icon: Icons.lock_outline_rounded,
                color: Colors.orange,
                onTap: () {
                  // TODO: فتح حوار تغيير كلمة المرور
                },
              ),
              SizedBox(height: 25.h),

              _buildSectionTitle("عن التطبيق"),
              _buildSettingsTile(
                title: "سياسة الخصوصية",
                icon: Icons.privacy_tip_outlined,
                color: Colors.teal,
                onTap: () {},
              ),
              _buildSettingsTile(
                title: "تواصل مع الدعم",
                icon: Icons.headset_mic_outlined,
                color: Colors.indigo,
                onTap: () {},
              ),

              SizedBox(height: 40.h),

              // 3. زر تسجيل الخروج
              _buildLogoutButton(),

              SizedBox(height: 20.h),
              Text(
                "الإصدار 1.0.0",
                style: GoogleFonts.tajawal(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40.sp, color: primaryColor),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            _userName,
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            _userEmail,
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, right: 5.w),
      child: Align(
        alignment: Alignment.centerRight,
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

  Widget _buildSettingsTile({
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
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
            fontSize: 15.sp,
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

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () => _showLogoutDialog(),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              "تسجيل الخروج",
              style: GoogleFonts.tajawal(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "تسجيل الخروج",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "هل أنت متأكد أنك تريد تسجيل الخروج من التطبيق؟",
          style: GoogleFonts.tajawal(fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "إلغاء",
              style: GoogleFonts.tajawal(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // إغلاق الحوار
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // الانتقال لصفحة تسجيل الدخول وحذف كل الصفحات السابقة من الذاكرة
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              "خروج",
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
