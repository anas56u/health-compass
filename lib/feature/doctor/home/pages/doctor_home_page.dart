import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// تأكد من مسار الاستدعاء الصحيح للـ Cubit والـ States
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeCubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeState.dart'; 
// import 'path/to/doctor_home_state.dart'; // تأكد من استدعاء ملف الـ State إذا كان منفصلاً

import '../widgets/doctor_header.dart';
import '../widgets/doctor_stats_card.dart';
import '../widgets/appointment_list_item.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // عند إنشاء الصفحة، نقوم باستدعاء الدالة لجلب البيانات فوراً
      create: (context) => DoctorHomeCubit()..getDashboardData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const DoctorHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
                    // --- بداية منطقة الكروت الديناميكية ---
                    // نستخدم BlocBuilder للاستماع لتغيرات الحالة وتحديث الواجهة
                    BlocBuilder<DoctorHomeCubit, DoctorHomeState>(
                      builder: (context, state) {
                        
                        // الحالة 1: جاري التحميل
                        if (state is DoctorHomeLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                            ),
                          );
                        }

                        // الحالة 2: حدث خطأ
                        if (state is DoctorHomeFailure) {
                          return Center(child: Text(state.errorMessage));
                        }

                        // الحالة 3: نجاح (عرض البيانات)
                        if (state is DoctorHomeSuccess) {
                          return Row(
                            children: [
                              Expanded(
                                child: DoctorStatsCard(
                                  icon: Icons.people_outline,
                                  title: 'عدد المرضى',
                                  // نأخذ القيمة من الـ State بدلاً من الرقم الثابت
                                  value: state.stats.totalPatients.toString(),
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DoctorStatsCard(
                                  icon: Icons.check_circle_outline,
                                  title: 'الحالات المستقرة',
                                  value: state.stats.stableCases.toString(),
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DoctorStatsCard(
                                  icon: Icons.emergency,
                                  title: 'الحالات الطارئة',
                                  value: state.stats.emergencyCases.toString(),
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                        }

                        // الحالة الافتراضية (قبل تحميل أي شيء)
                        return const SizedBox();
                      },
                    ),
                    // --- نهاية منطقة الكروت ---

                    const SizedBox(height: 24),
                    
                    // بقية الواجهة كما هي
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'تصفح الكل',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Text(
                          'مرضى بحاجة متابعة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ملاحظة: يفضل أيضاً وضع هذه القائمة داخل BlocBuilder مستقبلاً
                    const AppointmentListItem(
                      patientName: 'هدى الرفاعي',
                      patientImage: '',
                      appointmentTime: 'عرض التفاصيل',
                      appointmentType: 'ارتفاع سكر الدم',
                    ),
                    const AppointmentListItem(
                      patientName: 'عبد الرحمن الاسعد',
                      patientImage: '',
                      appointmentTime: 'عرض التفاصيل',
                      appointmentType: 'تسارع في دقات القلب',
                    ),
                    const AppointmentListItem(
                      patientName: 'حليم المجالي',
                      patientImage: '',
                      appointmentTime: 'عرض التفاصيل',
                      appointmentType: 'ارتفاع سكر الدم',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}