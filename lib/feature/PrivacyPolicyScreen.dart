import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
            child: Column(
              children: [
                _buildIntroSection(),
                SizedBox(height: 25.h),
                _buildPolicyCard(
                  Icons.info_outline_rounded,
                  "جمع المعلومات",
                  "نحن نجمع البيانات الصحية الضرورية فقط لضمان دقة المتابعة الطبية، وتشمل قراءات العلامات الحيوية وجداول الأدوية التي يتم إدخالها.",
                ),
                _buildPolicyCard(
                  Icons.lock_outline_rounded,
                  "أمان البيانات",
                  "يتم حماية جميع البيانات باستخدام تقنيات تشفير متطورة، مما يضمن عدم وصول أي شخص غير مخول إلى معلوماتك الصحية الخاصة.",
                ),
                _buildPolicyCard(
                  Icons.people_outline_rounded,
                  "المشاركة المحدودة",
                  "تظهر بيانات المريض فقط لأفراد العائلة الذين تمت الموافقة على ربط حساباتهم، ولا نقوم بمشاركة أي بيانات مع جهات خارجية.",
                ),
                SizedBox(height: 30.h),
                _buildFinalNote(),
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
      centerTitle: true,
      title: Text(
        "سياسة الخصوصية",
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

  Widget _buildIntroSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: primaryColor,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "خصوصيتك هي أولويتنا",
          style: GoogleFonts.tajawal(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "نلتزم في Health Compass بحماية بياناتك الصحية بأعلى معايير الأمان العالمية لضمان تجربة آمنة وموثوقة.",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 13.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyCard(IconData icon, String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: primaryColor, size: 24.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalNote() {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "آخر تحديث: يناير 2026",
          style: GoogleFonts.tajawal(
            fontSize: 11.sp,
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "استخدامك للتطبيق يعني موافقتك على شروط الخصوصية المذكورة أعلاه.",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 11.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
