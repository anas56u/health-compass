import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/widgets/doctor_link_guard.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';
import 'package:health_compass/feature/auth/presentation/screen/AvailableDoctorsScreen.dart';
import 'package:health_compass/feature/patient/data/repo/patient_repo.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart';

class MyDoctorsScreen extends StatelessWidget {
  const MyDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Directionality لضمان محاذاة اللغة العربية بشكل صحيح
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DoctorLinkGuard(
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              "أطبائي",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                fontFamily: 'Tajawal',
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15.r),
              ),
            ),
          ),

          // زر إضافة طبيب جديد بتصميم عائم متجاوب
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvailableDoctorsScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF0D9488),
            icon: Icon(
              Icons.add_moderator_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            label: Text(
              "إضافة طبيب",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ),

          body: FutureBuilder<List<DoctorModel>>(
            future: PatientRepo().getAllDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(context);
              }

              final doctors = snapshot.data!;

              return ListView.separated(
                itemCount: doctors.length,
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  100.h,
                ), // زيادة الهامش السفلي للزر العائم
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _buildDoctorChatCard(context, doctors[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorChatCard(BuildContext context, DoctorModel doctor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(otherUser: doctor),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            child: Row(
              children: [
                // صورة الطبيب مع إطار دائري متجاوب
                _buildDoctorAvatar(doctor),

                SizedBox(width: 12.w),

                // معلومات الطبيب مع حماية كاملة من الـ Overflow
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
                          color: Colors.black87,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 14.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "تخصص ${doctor.specialization}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                fontFamily: 'Tajawal',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // أيقونة الحالة/المحادثة
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF0D9488),
                    size: 18.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorAvatar(DoctorModel doctor) {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0D9488).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 26.r,
        backgroundColor: Colors.grey[100],
        backgroundImage:
            (doctor.profileImage != null && doctor.profileImage!.isNotEmpty)
            ? NetworkImage(doctor.profileImage!)
            : null,
        child: (doctor.profileImage == null || doctor.profileImage!.isEmpty)
            ? Icon(Icons.person, color: Colors.grey[400], size: 28.r)
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 80.sp,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "لم تقم بربط أي طبيب بعد",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "يمكنك البدء بالبحث عن طبيبك الخاص لربط الحساب ومتابعة حالتك الصحية",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              "حدث خطأ أثناء تحميل البيانات، يرجى المحاولة لاحقاً",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
