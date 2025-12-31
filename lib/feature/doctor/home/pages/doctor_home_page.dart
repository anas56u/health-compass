import 'package:flutter/material.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_stats_card.dart';
import '../widgets/appointment_list_item.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const DoctorHeader(doctorName: 'محمد أبو موسى'),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DoctorStatsCard(
                          icon: Icons.people_outline,
                          title: 'عدد المرضى',
                          value: '156',
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DoctorStatsCard(
                          icon: Icons.check_circle_outline,
                          title: 'الحالات المستقره',
                          value: '142',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DoctorStatsCard(
                          icon: Icons.emergency,
                          title: 'الحالات الطارئه',
                          value: '14',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
    );
  }
}
