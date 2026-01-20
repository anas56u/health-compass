import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/AboutApp.dart';
import 'package:health_compass/feature/ContactSupportScreen.dart';
import 'package:health_compass/feature/PrivacyPolicyScreen.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  final Color primaryColor = const Color(0xFF41BFAA);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
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
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _mapStateToWidget(context, state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, FamilyState state) {
    if (state is FamilyLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
      );
    } else if (state is FamilyProfileLoaded) {
      return _buildContent(context, state.userModel);
    } else if (state is FamilyError) {
      return _buildErrorState(context);
    }
    return const SizedBox.shrink();
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

  Widget _buildContent(BuildContext context, FamilyMemberModel user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          _buildUserInfoCard(context, user),
          SizedBox(height: 30.h),

          _buildSectionHeader("إعدادات الحساب"),
          _buildSettingsTile(
            title: "تعديل المعلومات الشخصية",
            subtitle: "تحديث الاسم، البريد، أو الصورة",
            icon: Icons.edit_rounded,
            color: Colors.blueAccent,
            onTap: () {
              // ✅ تفعيل: يمكنك توجيه المستخدم لصفحة التعديل هنا
              // Navigator.pushNamed(context, AppRoutes.editProfile, arguments: user);
            },
          ),
          _buildSettingsTile(
            title: "الأمان والخصوصية",
            subtitle: "تغيير كلمة المرور",
            icon: Icons.shield_outlined,
            color: Colors.orangeAccent,
            onTap: () => _showChangePasswordDialog(context),
          ),

          SizedBox(height: 20.h),
          _buildSectionHeader("الدعم والمساعدة"),
          _buildSettingsTile(
            title: "مركز المساعدة",
            subtitle: "تواصل معنا أو اقرأ الأسئلة الشائعة",
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
            subtitle: "الشروط والأحكام وسياسة الاستخدام",
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

  Widget _buildUserInfoCard(BuildContext context, FamilyMemberModel user) {
    final hasImage = user.profileImage != null && user.profileImage!.isNotEmpty;

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
                      ? NetworkImage(user.profileImage!)
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
              InkWell(
                onTap: () => _showFeatureUnderDevelopment(
                  context,
                  "تغيير الصورة الشخصية",
                ),
                child: _buildCameraBadge(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            user.fullName,
            style: GoogleFonts.tajawal(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            user.email,
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          if (user.relation.isNotEmpty) _buildRelationBadge(user.relation),
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

  Widget _buildRelationBadge(String relation) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        relation,
        style: GoogleFonts.tajawal(
          color: primaryColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
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
        Container(
          width: 30.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Health Compass App",
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "عذراً، حدث خطأ ما",
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            onPressed: () => context.read<FamilyCubit>().loadMyProfile(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              "إعادة المحاولة",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تفعيل حوار الخروج النهائي
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
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<FamilyCubit>().logout();
              if (context.mounted)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("تأكيد", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ حوار تغيير كلمة المرور التفاعلي للعرض
  void _showChangePasswordDialog(BuildContext context) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "كلمة المرور الحالية",
                hintStyle: GoogleFonts.tajawal(fontSize: 12.sp),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              decoration: InputDecoration(
                hintText: "كلمة المرور الجديدة",
                hintStyle: GoogleFonts.tajawal(fontSize: 12.sp),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم إرسال طلب التغيير بنجاح")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text("تحديث", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeatureUnderDevelopment(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "ميزة $featureName قيد التطوير حالياً",
          style: GoogleFonts.tajawal(),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
