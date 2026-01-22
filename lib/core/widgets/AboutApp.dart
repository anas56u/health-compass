import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/widgets/ContactSupportScreen.dart';
import 'package:health_compass/core/widgets/PrivacyPolicyScreen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  final Color primaryColor = const Color(0xFF41BFAA);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              _buildAppLogoSection(),
              SizedBox(height: 25.h),
              _buildAboutContent(),
              SizedBox(height: 20.h),
              _buildInteractiveLinks(
                context,
              ), // تمرير الـ context لتفعيل الملاحة
              SizedBox(height: 30.h),
              _buildFooter(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      title: Text(
        "عن التطبيق",
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

  Widget _buildAppLogoSection() {
    return Column(
      children: [
        Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Image.asset('assets/images/logo.jpeg', fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "Health Compass",
          style: GoogleFonts.tajawal(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            "الإصدار 1.0.0",
            style: GoogleFonts.tajawal(
              fontSize: 11.sp,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.description_rounded,
            "عن المشروع",
            "نظام ذكي متكامل يربط بين المريض وعائلته لضمان مراقبة العلامات الحيوية وجداول الأدوية بدقة، مما يوفر راحة البال والسرعة في الاستجابة الصحية.",
          ),
          SizedBox(height: 25.h),
          _buildInfoRow(
            Icons.verified_user_rounded,
            "مهمتنا",
            "تسخير التكنولوجيا لخدمة الإنسانية، وتسهيل رعاية كبار السن والمرضى من خلال المتابعة اللحظية والتنبيهات الذكية.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          description,
          textAlign: TextAlign.justify,
          style: GoogleFonts.tajawal(
            fontSize: 13.sp,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveLinks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: "سياسة الخصوصية",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          _buildLinkTile(
            icon: Icons.support_agent_rounded,
            title: "تواصل مع فريق الدعم",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSupportScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: Colors.blueGrey[700], size: 20.sp),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.sp,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(width: 6.w),
        Text(
          "تم التطوير لدعم الرعاية الصحية الرقمية",
          style: GoogleFonts.tajawal(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 40.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "© 2026 Health Compass Project",
          style: GoogleFonts.tajawal(
            fontSize: 10.sp,
            color: Colors.grey[400],
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
