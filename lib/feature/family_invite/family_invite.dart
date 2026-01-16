import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للنسخ للحافظة
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';

class FamilyInvitePage extends StatefulWidget {
  const FamilyInvitePage({super.key});

  @override
  State<FamilyInvitePage> createState() => _FamilyInvitePageState();
}

class _FamilyInvitePageState extends State<FamilyInvitePage> {
  final Color primaryColor = const Color(0xFF41BFAA);
  final Color bgColor = const Color(0xFFF5F7FA);

  final FamilyRepository _repository = FamilyRepository();
  String? _inviteCode;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _fetchInviteCode();
  }

  // دالة لجلب الكود (إما موجود مسبقاً أو توليد جديد)
  Future<void> _fetchInviteCode() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 1. محاولة جلب الكود الموجود
      String? code = await _repository.getExistingCode();

      // 2. إذا لم يوجد كود، نقوم بتوليد واحد جديد
      code ??= await _repository.generateAndSaveInviteCode();

      if (mounted) {
        setState(() {
          _inviteCode = code;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            "دعوة العائلة",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
        ),

        // زر عائم للمشاركة السريعة
        floatingActionButton: _inviteCode != null && !_isLoading && !_hasError
            ? FloatingActionButton.extended(
                onPressed: _shareCode,
                backgroundColor: primaryColor,
                elevation: 4,
                icon: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
                label: Text(
                  "مشاركة الرابط",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // حالة التحميل
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 15.h),
            Text(
              "جاري تحضير كود الدعوة...",
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // حالة الخطأ
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 50.sp),
            SizedBox(height: 15.h),
            Text(
              "حدث خطأ أثناء تحميل الكود",
              style: GoogleFonts.tajawal(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _fetchInviteCode,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // الحالة الطبيعية (عرض الكود)
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 80.h), // مساحة للزر العائم
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // عنوان ترحيبي
          Text(
            "شارك صحتك مع عائلتك ❤️",
            style: GoogleFonts.tajawal(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            "اتبع الخطوات التالية لربط حساب أحد أفراد عائلتك:",
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 30.h),

          // الخطوة 1: المسح الضوئي
          _buildStepHeader(1, "المسح الضوئي (الأسرع)"),
          SizedBox(height: 15.h),

          // بطاقة QR Code
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: _inviteCode!,
                  version: QrVersions.auto,
                  size: 180.sp,
                  foregroundColor: Colors.black87,
                  gapless: false,
                ),
                SizedBox(height: 15.h),
                Text(
                  "افتح تطبيق المرافق وامسح هذا الكود",
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),

          // الخطوة 2: النسخ اليدوي
          _buildStepHeader(2, "أو النسخ اليدوي"),
          SizedBox(height: 15.h),

          InkWell(
            onTap: _copyCodeToClipboard,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _isCopied ? Colors.green : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "كود الربط:",
                        style: GoogleFonts.tajawal(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        _inviteCode!,
                        style: GoogleFonts.changa(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: _isCopied
                          ? Colors.green.withOpacity(0.1)
                          : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                      color: _isCopied ? Colors.green : primaryColor,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildStepHeader(int number, String title) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "$number",
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
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
    );
  }

  // --- Functions ---

  void _shareCode() {
    if (_inviteCode != null) {
      Share.share(
        'مرحباً، تابع حالتي الصحية على تطبيق بوصلة الصحة باستخدام الكود: $_inviteCode',
      );
    }
  }

  void _copyCodeToClipboard() {
    if (_inviteCode != null) {
      Clipboard.setData(ClipboardData(text: _inviteCode!));
      setState(() => _isCopied = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10.w),
              Text("تم نسخ الكود بنجاح", style: GoogleFonts.tajawal()),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(20.w),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isCopied = false);
      });
    }
  }
}
