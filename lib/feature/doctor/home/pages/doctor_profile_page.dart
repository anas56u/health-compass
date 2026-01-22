import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/AboutApp.dart';
import 'package:health_compass/feature/ContactSupportScreen.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  final Color primaryColor = const Color(0xFF0D9488);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(context),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
              );
            } else if (state is UserLoaded) {
              return _buildContent(context, state.userModel);
            } else {
              return _buildErrorState(context);
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "الملف الشخصي",
        style: GoogleFonts.tajawal(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
              size: 18.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic doctor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          _buildUserInfoCard(context, doctor),
          SizedBox(height: 30.h),

          _buildSectionHeader("إعدادات الحساب المهني"),
          _buildSettingsTile(
            title: "تعديل المعلومات المهنية",
            subtitle: "تحديث التخصص، المواعيد، أو الصورة",
            icon: Icons.edit_note_rounded,
            color: Colors.blueAccent,
            onTap: () {
              // Navigator.pushNamed(context, AppRoutes.editDoctorProfile);
            },
          ),
          _buildSettingsTile(
            title: "الأمان والخصوصية",
            subtitle: "تغيير كلمة المرور وإعدادات الدخول",
            icon: Icons.shield_outlined,
            color: Colors.orangeAccent,
            onTap: () => _showChangePasswordDialog(context, doctor.email),
          ),

          SizedBox(height: 20.h),
          _buildSectionHeader("الدعم والمساعدة"),
          _buildSettingsTile(
            title: "مركز المساعدة للطبيب",
            subtitle: "تواصل مع الإدارة التقنية",
            icon: Icons.support_agent,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSupportScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            title: "عن التطبيق",
            subtitle: "الشروط والأحكام المهنية",
            icon: Icons.info_outline_rounded,
            color: Colors.indigoAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
          SizedBox(height: 40.h),

          _buildLogoutButton(context),

          SizedBox(height: 25.h),
          _buildFooterVersion(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, dynamic doctor) {
    final hasImage =
        doctor.profileImage != null && doctor.profileImage!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: backgroundColor,
                  backgroundImage: hasImage
                      ? NetworkImage(doctor.profileImage!)
                      : null,
                  child: !hasImage
                      ? Icon(
                          Icons.person_rounded,
                          size: 50.sp,
                          color: primaryColor,
                        )
                      : null,
                ),
              ),
              _buildCameraBadge(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            "د. ${doctor.fullName}",
            style: GoogleFonts.tajawal(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            doctor.email,
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraBadge() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 8.w, left: 8.w),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey[800],
            ),
          ),
          const Spacer(),
          Container(height: 1, width: 40.w, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(fontSize: 12.sp, color: Colors.grey[500]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.sp,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.red[200]!, width: 1.5),
            color: Colors.red[50]?.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red[700], size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                "تسجيل الخروج",
                style: GoogleFonts.tajawal(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterVersion() {
    return Column(
      children: [
        Text(
          "Health Compass App - Doctor Portal",
          style: GoogleFonts.tajawal(
            fontSize: 13.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "الإصدار 1.0.0",
          style: GoogleFonts.tajawal(fontSize: 11.sp, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: Colors.red[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "عذراً، حدث خطأ في تحميل البيانات",
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => context.read<UserCubit>().getUserData(),
            child: Text(
              "إعادة المحاولة",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
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
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Icon(Icons.logout_rounded, color: Colors.red, size: 40.sp),
        content: Text(
          "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.read<UserCubit>().clearUserData();
                }
                await SharedPrefHelper.clearLoginData();
                await SharedPrefHelper.removeData("user_type");

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Logout Error: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("تأكيد", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "تغيير كلمة المرور",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني:\n$email",
          style: GoogleFonts.tajawal(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إرسال رابط التعيين بنجاح")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              "إرسال الرابط",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
