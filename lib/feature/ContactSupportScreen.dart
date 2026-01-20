import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

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
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
          child: Column(
            children: [
              _buildSupportHeader(),
              SizedBox(height: 30.h),
              _buildContactCard(
                Icons.email_outlined,
                "البريد الإلكتروني",
                "support@healthcompass.com",
                "للاستفسارات العامة والدعم الفني",
              ),
              _buildContactCard(
                Icons.location_city_rounded,
                "المقر الرئيسي",
                "معان، الأردن",
                "جامعة الحسين بن طلال - مشروع التخرج",
              ),
              SizedBox(height: 40.h),
              _buildResponseTimeNote(),
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
        "الدعم والمساعدة",
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

  Widget _buildSupportHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.headset_mic_rounded,
            color: primaryColor,
            size: 50.sp,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "كيف يمكننا مساعدتك؟",
          style: GoogleFonts.tajawal(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "فريقنا جاهز للرد على استفساراتكم ومساعدتكم في استخدام التطبيق",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 13.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
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
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(icon, color: primaryColor, size: 26.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.tajawal(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeNote() {
    return Column(
      children: [
        Icon(Icons.access_time, color: Colors.grey[400], size: 20.sp),
        SizedBox(height: 8.h),
        Text(
          "وقت الاستجابة المتوقع: خلال 24 ساعة",
          style: GoogleFonts.tajawal(
            fontSize: 12.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
