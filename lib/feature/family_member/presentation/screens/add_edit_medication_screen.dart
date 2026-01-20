import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/services/notification_service.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final String userId;

  const AddEditMedicationScreen({super.key, required this.userId});

  @override
  State<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final Color primaryColor = const Color(0xFF0D9488);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamilyCubit, FamilyState>(
      listener: (context, state) {
        if (state is FamilyOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is FamilyOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              "إضافة دواء جديد",
              style: GoogleFonts.tajawal(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("بيانات الدواء"),
                _buildTextField(
                  _nameController,
                  "اسم الدواء (مثال: Panadol)",
                  Icons.medication,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _doseController,
                  "الجرعة (مثال: 500mg)",
                  Icons.scale,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _typeController,
                  "تعليمات (مثال: بعد الأكل)",
                  Icons.info_outline,
                ),
                const SizedBox(height: 25),
                _buildLabel("مواعيد التذكير"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ...selectedTimes.map((time) => _buildTimeTile(time)),
                      InkWell(
                        onTap: _pickTime,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_alarm_rounded,
                                color: primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "إضافة وقت آخر",
                                style: GoogleFonts.tajawal(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<FamilyCubit, FamilyState>(
                  builder: (context, state) {
                    if (state is FamilyOperationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return custom_button(
                      buttonText: "حفظ وجدولة التنبيه",
                      width: double.infinity,
                      onPressed: _saveAndSchedule,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
        fontSize: 16,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTimeTile(TimeOfDay time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'ص' : 'م'}",
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => selectedTimes.remove(time)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (picked != null && !selectedTimes.contains(picked)) {
      setState(() => selectedTimes.add(picked));
    }
  }

  Future<void> _saveAndSchedule() async {
    if (_nameController.text.isEmpty) return;

    // 1. تجهيز قائمة البيانات للإرسال الجماعي (Batch)
    List<Map<String, dynamic>> medicationsList = [];
    int baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (var time in selectedTimes) {
      final String timeStr =
          "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}";
      final String periodStr = time.period == DayPeriod.am ? 'ص' : 'م';
      final int currentNotifyId = baseId++;

      // إضافة كائن الدواء للقائمة
      medicationsList.add({
        'medicationName': _nameController.text,
        'dosage': _doseController.text,
        'instructions': _typeController.text,
        'time': timeStr,
        'period': periodStr,
        'daysOfWeek': [0, 1, 2, 3, 4, 5, 6],
        'created_at': FieldValue.serverTimestamp(),
        'notificationId': currentNotifyId,
        'added_by_uid': FirebaseAuth.instance.currentUser?.uid,
      });

      // 2. جدولة التنبيه المحلي (يبقى لكل وقت بشكل مستقل)
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduledDate.isBefore(now))
        scheduledDate = scheduledDate.add(const Duration(days: 1));

      await NotificationService().scheduleAnnoyingReminder(
        id: currentNotifyId,
        title: "موعد دواء: ${_nameController.text}",
        body: "الجرعة: ${_doseController.text}",
        time: scheduledDate,
        days: [1, 2, 3, 4, 5, 6, 7],
      );
    }
    if (mounted && medicationsList.isNotEmpty) {
      context.read<FamilyCubit>().addMedicationsList(
        widget.userId,
        medicationsList,
      );
    }
  }
}
