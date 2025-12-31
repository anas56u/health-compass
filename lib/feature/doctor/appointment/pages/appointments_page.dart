import 'package:flutter/material.dart';
import '../widgets/day_selector.dart';
import '../widgets/time_slot.dart';
import '../widgets/appointment_card.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'جدول المواعيد(يومي)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const DaySelector(),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimeSlotWithAppointment('9:00', null),
                  _buildTimeSlotWithAppointment('9:30', null),
                  _buildTimeSlotWithAppointment(
                    '10:00',
                    const AppointmentCard(
                      patientName: 'حليم المجالي',
                      appointmentType: 'سكري نوع 2.زياره روتينيه',
                      duration: '30 دقيقة',
                      isConfirmed: false,
                    ),
                  ),
                  _buildTimeSlotWithAppointment('10:30', null),
                  _buildTimeSlotWithAppointment('11:00', null),
                  _buildTimeSlotWithAppointment('11:30', null),
                  _buildTimeSlotWithAppointment('12:00', null),
                  _buildTimeSlotWithAppointment(
                    '12:30',
                    const AppointmentCard(
                      patientName: 'رايه الامامي',
                      appointmentType: 'الضغط والسكري.زياره لاول مره',
                      duration: '30 دقيقة',
                      isConfirmed: true,
                    ),
                  ),
                  _buildTimeSlotWithAppointment('13:00', null),
                  _buildTimeSlotWithAppointment('13:30', null),
                  _buildTimeSlotWithAppointment('14:00', null),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotWithAppointment(String time, Widget? appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimeSlot(time: time),
          const SizedBox(width: 12),
          if (appointment != null)
            Expanded(child: appointment)
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
