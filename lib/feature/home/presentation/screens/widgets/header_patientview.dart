import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/feature/health_tracking/presentation/HealthStatus_Card.dart';

// ignore: camel_case_types
class header_patientview extends StatelessWidget {
  const header_patientview({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. تغليف الودجت بالكامل لفرض الاتجاه من اليمين لليسار
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 440,
        child: Stack(
          children: [
            // الخلفية الخضراء
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
            
            // المحتوى الرئيسي (البروفايل والنصوص)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  // ✅ في وضع RTL، الـ Start تعني اليمين تلقائياً
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف العلوي: صورة البروفايل والتنبيهات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // صورة البروفايل (ستظهر على اليمين)
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, state) {
                            String? imageUrl;
                            if (state is UserLoaded) {
                              imageUrl = state.userModel.profileImage;
                            }

                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.profileSettings,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2), // إطار أبيض جمالي
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 24, // حجم أكبر قليلاً للوضوح
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      (imageUrl != null && imageUrl.isNotEmpty)
                                          ? NetworkImage(imageUrl)
                                          : null,
                                  child: (imageUrl == null || imageUrl.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          color: Color(0xFF00796B),
                                          size: 28,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // أيقونة التنبيهات (ستظهر على اليسار)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15), // خلفية شفافة للأيقونة
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // نصوص الترحيب
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        String firstName = 'يا بطل';
                        if (state is UserLoaded) {
                          firstName = state.userModel.fullName.split(' ').first;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلاً بعودتك، $firstName ...',
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'نتمنى لك دوام الصحة والعافية ✨',
                              style: GoogleFonts.tajawal(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // بطاقة الحالة الصحية
            Positioned(
              left: 15,
              right: 15,
              bottom: 40,
              child: const HealthStatusCard(),
            ),
          ],
        ),
      ),
    );
  }
}