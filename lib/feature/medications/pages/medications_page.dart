import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/medication_day_selector.dart';
import '../widgets/medication_time_slot.dart';
import '../widgets/medication_card.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  int selectedDayIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header with gradient
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'جدول الادويه(يومي)',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MedicationDaySelector(
                    selectedIndex: selectedDayIndex,
                    onDaySelected: (index) {
                      setState(() {
                        selectedDayIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Medication schedule list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimeSlotWithMedication(
                    '8:00',
                    'ص',
                    const MedicationCard(
                      medicationName: 'Metformin 500mg',
                      dosage: 'حبه واحده',
                      instructions: 'بعد الأكل',
                      status: MedicationStatus.taken,
                    ),
                  ),
                  _buildTimeSlotWithMedication(
                    '10:00',
                    'ص',
                    const MedicationCard(
                      medicationName: 'Captopril',
                      dosage: 'حبه واحده',
                      instructions: 'قبل الأكل',
                      status: MedicationStatus.notTaken,
                    ),
                  ),
                  _buildTimeSlotWithMedication('12:00', 'م', null),
                  _buildTimeSlotWithMedication(
                    '2:00',
                    'م',
                    const MedicationCard(
                      medicationName: 'Metformin 500mg',
                      dosage: 'حبه واحده',
                      instructions: 'بعد الأكل',
                      status: MedicationStatus.pending,
                    ),
                  ),
                  _buildTimeSlotWithMedication('4:00', 'م', null),
                  _buildTimeSlotWithMedication(
                    '6:00',
                    'م',
                    const MedicationCard(
                      medicationName: 'Captopril',
                      dosage: 'حبه واحده',
                      instructions: 'قبل الأكل',
                      status: MedicationStatus.pending,
                    ),
                  ),
                  _buildTimeSlotWithMedication(
                    '8:00',
                    'م',
                    const MedicationCard(
                      medicationName: 'Glimepiride',
                      dosage: 'حبه واحده',
                      instructions: 'قبل النوم',
                      status: MedicationStatus.pending,
                    ),
                  ),
                  _buildTimeSlotWithMedication('10:00', 'م', null),
                  _buildTimeSlotWithMedication('12:00', 'ص', null),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotWithMedication(
    String time,
    String period,
    Widget? medication,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: medication != null
                      ? const Color(0xFF0D9488)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: medication != null
                        ? const Color(0xFF0D9488)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: medication != null ? 120 : 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Time slot
          MedicationTimeSlot(time: time, period: period),
          const SizedBox(width: 12),
          // Medication card or empty space
          if (medication != null)
            Expanded(child: medication)
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

