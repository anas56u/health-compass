import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/feature/patient/data/repo/patient_repo.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';
import '../../../auth/data/model/doctormodel.dart';

class AvailableDoctorsScreen extends StatefulWidget {
  const AvailableDoctorsScreen({super.key});

  @override
  State<AvailableDoctorsScreen> createState() => _AvailableDoctorsScreenState();
}

class _AvailableDoctorsScreenState extends State<AvailableDoctorsScreen> {
  // الألوان الأساسية للتطبيق لضمان التناسق البصري
  final Color _primaryColor = const Color(0xFF0D9488);
  final Color _backgroundFab = const Color(0xFFF8F9FA);

  // تعريف المستودع (Repository) للوصول لبيانات الطلبات
  final DoctorRequestsRepo _requestsRepo = DoctorRequestsRepo();

  @override
  Widget build(BuildContext context) {
    // استخدام Directionality لضمان دعم اللغة العربية بشكل صحيح
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundFab,
        appBar: _buildAppBar(),
        body: FutureBuilder<List<DoctorModel>>(
          // جلب كافة الأطباء المتاحين في النظام
          future: PatientRepo().getAllDoctors(),
          builder: (context, snapshot) {
            // حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            // حالة حدوث خطأ في جلب البيانات
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            // حالة عدم وجود بيانات (قائمة فارغة)
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final doctors = snapshot.data!;

            // استخدام StreamBuilder لمراقبة الطلبات المرسلة (Pending)
            return StreamBuilder<List<String>>(
              stream: _requestsRepo.getSentRequestsIds(),
              builder: (context, sentSnapshot) {
                // استخدام StreamBuilder آخر لمراقبة الأطباء المرتبطين فعلياً (Linked)
                return StreamBuilder<List<String>>(
                  stream: _requestsRepo.getLinkedDoctorsIds(),
                  builder: (context, linkedSnapshot) {
                    final sentIds = sentSnapshot.data ?? [];
                    final linkedIds = linkedSnapshot.data ?? [];

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      physics:
                          const BouncingScrollPhysics(), // إضافة تأثير ارتداد سلس عند التمرير
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];

                        // منطق تحديد حالة الطبيب بالنسبة للمريض الحالي
                        String status = "none";
                        if (linkedIds.contains(doctor.uid)) {
                          status = "linked"; // الطبيب مرتبط بالمريض
                        } else if (sentIds.contains(doctor.uid)) {
                          status = "pending"; // الطلب معلق بانتظار الموافقة
                        }

                        return _buildDoctorCard(context, doctor, status);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // بناء شريط التطبيق العلوي
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "الأطباء المتاحون",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          fontFamily: 'Tajawal',
        ),
      ),
      centerTitle: true,
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
    );
  }

  // بناء كرت الطبيب الفردي
  Widget _buildDoctorCard(
    BuildContext context,
    DoctorModel doctor,
    String status,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // صورة الطبيب الشخصية
            _buildDoctorAvatar(doctor),
            SizedBox(width: 14.w),

            // معلومات الطبيب (الاسم والتخصص)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "د. ${doctor.fullName}",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // منع Overflow في الأسماء الطويلة
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doctor.specialization,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                      fontFamily: 'Tajawal',
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis, // منع Overflow في النصوص الطويلة
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // زر الحالة التفاعلي (ارتباط / قيد الانتظار / مرتبط)
            _buildStatusButton(context, doctor, status),
          ],
        ),
      ),
    );
  }

  // ويدجت صورة الطبيب
  Widget _buildDoctorAvatar(DoctorModel doctor) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _primaryColor.withOpacity(0.1), width: 1.5),
      ),
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: _primaryColor.withOpacity(0.05),
        backgroundImage:
            doctor.profileImage != null && doctor.profileImage!.isNotEmpty
            ? NetworkImage(doctor.profileImage!)
            : null,
        child: doctor.profileImage == null || doctor.profileImage!.isEmpty
            ? Icon(Icons.person, color: _primaryColor, size: 28.r)
            : null,
      ),
    );
  }

  // منطق بناء الزر بناءً على حالة العلاقة بين المريض والطبيب
  Widget _buildStatusButton(
    BuildContext context,
    DoctorModel doctor,
    String status,
  ) {
    // الحالة 1: الطبيب مرتبط بالفعل (مقبول)
    if (status == "linked") {
      return _buildLabel(Colors.green, Icons.check_circle_outline, "مرتبط");
    }

    // الحالة 2: تم إرسال طلب وهو بانتظار موافقة الطبيب
    if (status == "pending") {
      return _buildLabel(
        Colors.orange,
        Icons.hourglass_empty_rounded,
        "قيد الانتظار",
      );
    }

    // الحالة 3: لا توجد علاقة (إظهار زر الطلب)
    return SizedBox(
      height: 34.h,
      child: ElevatedButton(
        onPressed: () => _handleSendRequest(context, doctor),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          "ارتباط",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }

  // ويدجت الملصقات (Labels) للحالات غير النشطة
  Widget _buildLabel(Color color, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // معالجة إرسال طلب الارتباط
  Future<void> _handleSendRequest(
    BuildContext context,
    DoctorModel doctor,
  ) async {
    try {
      await PatientRepo().sendLinkRequest(doctor.uid, doctor.fullName);
      if (mounted) {
        _showSnackBar(
          context,
          "تم إرسال طلب الارتباط للدكتور ${doctor.fullName}",
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, "حدث خطأ: $e", Colors.redAccent);
      }
    }
  }

  // ويدجت رسالة التأكيد المنبثقة
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  // واجهة القائمة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 80.r,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "لا يوجد أطباء متاحون حالياً",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // واجهة حالة الخطأ
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          "حدث خطأ أثناء جلب البيانات: $error",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 14.sp,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }
}
