import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// تأكد من استيراد الـ Service الخاص بك
import 'package:health_compass/core/services/notification_service.dart';
import 'package:health_compass/core/widgets/custom_button.dart';

class AddEditMedicationScreen extends StatefulWidget {
  const AddEditMedicationScreen({super.key});

  @override
  State<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final Color primaryColor = const Color(0xFF0D9488); // تم توحيد اللون مع الثيم

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
              _buildLabel("اسم الدواء"),
              _buildTextField(
                _nameController,
                "مثال: Panadol",
                Icons.medication_outlined,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("الجرعة"),
                        _buildTextField(
                          _doseController,
                          "500mg",
                          Icons.scale_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("الشكل"),
                        _buildTextField(
                          _typeController,
                          "أقراص",
                          Icons.category_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
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
                    ...selectedTimes
                        .map((time) => _buildTimeTile(time))
                        .toList(),
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
              // زر الحفظ
              custom_button(
                buttonText: "حفظ وجدولة التنبيه",
                width: double.infinity,
                onPressed: _saveAndSchedule,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !selectedTimes.contains(picked)) {
      setState(() => selectedTimes.add(picked));
    }
  }

  Future<void> _saveAndSchedule() async {
    if (_nameController.text.isEmpty) return;

    try {
      // ✅ 1. جدولة التنبيهات باستخدام السيرفس
      int baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (var time in selectedTimes) {
        final now = DateTime.now();
        final scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        await NotificationService().scheduleAnnoyingReminder(
          id: baseId,
          title: "وقت دواء: ${_nameController.text}",
          body: "الجرعة: ${_doseController.text}",
          time: scheduledDate,
          days: [1, 2, 3, 4, 5, 6, 7], // يومياً
        );
        baseId += 10;
      }

      // ✅ 2. حفظ البيانات في Firebase Firestore
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users') // أو collection('family_members')...
            .doc(user.uid)
            .collection('medications')
            .add({
              'name': _nameController.text,
              'dose': _doseController.text,
              'type': _typeController.text,
              'times': selectedTimes
                  .map((t) => '${t.hour}:${t.minute}')
                  .toList(),
              'created_at': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم الحفظ وتفعيل التنبيهات ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
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
        prefixIcon: Icon(icon, color: Colors.grey[400]),
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
            "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
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
}
