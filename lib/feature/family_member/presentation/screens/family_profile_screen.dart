import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  final Color primaryColor = const Color(0xFF41BFAA);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    // ✅ BlocProvider محلي: يتم إنشاء الكيوبت وإغلاقه تلقائياً عند الخروج من الشاشة
    return BlocProvider(
      create: (context) => FamilyCubit(FamilyRepository())..loadMyProfile(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(context),
          body: BlocConsumer<FamilyCubit, FamilyState>(
            listener: (context, state) {
              if (state is FamilyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.tajawal()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is FamilyLoading) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (state is FamilyProfileLoaded) {
                return _buildContent(context, state.userModel);
              } else if (state is FamilyError) {
                return _buildErrorState(context);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _buildContent(BuildContext context, FamilyMemberModel user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          // 1. بطاقة المعلومات
          _buildUserInfoCard(user),

          SizedBox(height: 30.h),

          // 2. إعدادات الحساب
          _buildSectionHeader("إعدادات الحساب"),
          _buildSettingsTile(
            title: "تعديل الملف الشخصي",
            icon: Icons.person_outline_rounded,
            color: Colors.blue,
            onTap: () {
              // TODO: الانتقال لصفحة التعديل
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

          // 3. عن التطبيق
          _buildSectionHeader("عن التطبيق"),
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

          // 4. الخروج
          _buildLogoutButton(context),

          SizedBox(height: 20.h),
          Text(
            "الإصدار 1.0.0",
            style: GoogleFonts.tajawal(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Widgets Components ---

  Widget _buildUserInfoCard(FamilyMemberModel user) {
    final hasImage = user.profileImage != null && user.profileImage!.isNotEmpty;

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
                backgroundImage: hasImage
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: !hasImage
                    ? Icon(Icons.person, size: 40.sp, color: primaryColor)
                    : null,
              ),
              // أيقونة التعديل الصغيرة
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(6.w),
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
            user.fullName,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          if (user.relation.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  user.relation,
                  style: GoogleFonts.tajawal(
                    color: primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
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

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
          SizedBox(height: 10.h),
          Text(
            "حدث خطأ أثناء تحميل البيانات",
            style: GoogleFonts.tajawal(fontSize: 16.sp),
          ),
          TextButton(
            onPressed: () => context.read<FamilyCubit>().loadMyProfile(),
            child: Text(
              "إعادة المحاولة",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
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
              Navigator.pop(dialogContext); // إغلاق الحوار

              // ✅ استخدام context الخاص بالـ Screen (الممرر للدالة) للوصول للكيوبت
              await context.read<FamilyCubit>().logout();

              if (context.mounted) {
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
