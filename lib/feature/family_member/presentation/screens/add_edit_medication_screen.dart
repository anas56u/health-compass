import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final Color fieldColor = const Color(0xFFF5F7FA);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamilyCubit, FamilyState>(
      listener: (context, state) {
        if (state is FamilyOperationSuccess) {
          _showSnackBar(state.message, Colors.green);
          Navigator.pop(context);
        } else if (state is FamilyOperationError) {
          _showSnackBar(state.message, Colors.red);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("بيانات الدواء"),
                    _buildTextField(
                      _nameController,
                      "اسم الدواء (مثال: Panadol)",
                      Icons.medication_rounded,
                    ),
                    SizedBox(height: 15.h),
                    _buildTextField(
                      _doseController,
                      "الجرعة (مثال: حبة واحدة)",
                      Icons.scale_rounded,
                    ),
                    SizedBox(height: 15.h),
                    _buildTextField(
                      _typeController,
                      "تعليمات (مثال: بعد الأكل)",
                      Icons.info_outline_rounded,
                    ),
                    SizedBox(height: 30.h),
                    _buildLabel("مواعيد التذكير"),
                    _buildTimesContainer(),
                    SizedBox(height: 40.h),
                    _buildSubmitButton(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
      title: Text(
        "إضافة دواء جديد",
        style: GoogleFonts.tajawal(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildTimesContainer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          ...selectedTimes.map((time) => _buildTimeTile(time)),
          SizedBox(height: 5.h),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_alarm_rounded,
                    color: primaryColor,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "إضافة وقت آخر",
                    style: GoogleFonts.tajawal(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
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

  Widget _buildSubmitButton() {
    return BlocBuilder<FamilyCubit, FamilyState>(
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
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 10.h, right: 4.w),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
        fontSize: 15.sp,
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
      style: GoogleFonts.tajawal(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.tajawal(fontSize: 13.sp, color: Colors.grey),
        filled: true,
        fillColor: fieldColor,
        prefixIcon: Icon(icon, color: primaryColor, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildTimeTile(TimeOfDay time) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: primaryColor, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            _formatTime(time),
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red[400],
              size: 22.sp,
            ),
            onPressed: () => setState(() => selectedTimes.remove(time)),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return "$hour:$minute $period";
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
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("يرجى إدخال اسم الدواء", Colors.orange);
      return;
    }

    if (selectedTimes.isEmpty) {
      _showSnackBar("يرجى اختيار موعد واحد على الأقل", Colors.orange);
      return;
    }

    List<Map<String, dynamic>> medicationsList = [];
    int baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (var time in selectedTimes) {
      final String timeStr =
          "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}";
      final String periodStr = time.period == DayPeriod.am ? 'ص' : 'م';
      final int currentNotifyId =
          baseId + Random().nextInt(1000); // معرف فريد لكل تنبيه

      // ✅ الإصلاح الأساسي: استخدام المسميات الصحيحة لتطابق MedicationModel.fromFirestore
      medicationsList.add({
        'medicationName': _nameController.text.trim(), // تم التغيير من 'name'
        'dosage': _doseController.text.trim(), // تم التغيير من 'dose'
        'instructions': _typeController.text.trim(),
        'time': timeStr,
        'period': periodStr,
        'daysOfWeek': [1, 2, 3, 4, 5, 6, 7], // كل أيام الأسبوع كافتراضي
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationId': currentNotifyId, //
      });

      // جدولة التنبيهات المحلية لكل موعد
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

      try {
        await NotificationService().scheduleAnnoyingReminder(
          id: currentNotifyId,
          title: "موعد دواء: ${_nameController.text}",
          body: "الجرعة: ${_doseController.text}",
          time: scheduledDate,
          days: [1, 2, 3, 4, 5, 6, 7],
        );
      } catch (e) {
        debugPrint("خطأ في جدولة التنبيه: $e");
      }
    }

    if (mounted && medicationsList.isNotEmpty) {
      // إرسال البيانات المجهزة للـ Cubit لحفظها في Firestore
      context.read<FamilyCubit>().addMedicationsList(
        widget.userId,
        medicationsList,
      );
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
