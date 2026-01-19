import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVitalsBottomSheet extends StatefulWidget {
  final String? patientId; // ✅ استقبال معرف المريض (اختياري)

  const AddVitalsBottomSheet({super.key, this.patientId});

  @override
  State<AddVitalsBottomSheet> createState() => _AddVitalsBottomSheetState();
}

class _AddVitalsBottomSheetState extends State<AddVitalsBottomSheet> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _heartRateController = TextEditingController();

  final Color primaryColor = const Color(0xFF41BFAA);

  DateTime selectedDate = DateTime.now();
  String selectedSugarContext = 'random'; // random, fasting, after_meal
  bool _isLoading = false; // ✅ حالة التحميل

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        top: 15,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "تسجيل قراءة جديدة",
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => _pickDateTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          intl.DateFormat(
                            'h:mm a, d MMM',
                            'en',
                          ).format(selectedDate),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader(Icons.speed_rounded, "ضغط الدم"),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _systolicController,
                    label: "العلوي (SYS)",
                    hint: "120",
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    controller: _diastolicController,
                    label: "السفلي (DIA)",
                    hint: "80",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            _buildSectionHeader(Icons.water_drop_rounded, "سكر الدم"),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _sugarController,
                    label: "القيمة (mg/dL)",
                    hint: "95",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildContextChip("عشوائي", "random"),
                  const SizedBox(width: 10),
                  _buildContextChip("صائم", "fasting"),
                  const SizedBox(width: 10),
                  _buildContextChip("بعد الأكل", "after_meal"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildSectionHeader(Icons.favorite_rounded, "نبض القلب"),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _heartRateController,
                    label: "نبضات/دقيقة",
                    hint: "72",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveVitals, // ✅ ربط زر الحفظ
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "حفظ القراءة",
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.tajawal(color: Colors.grey[300]),
        labelStyle: GoogleFonts.tajawal(color: Colors.grey[500], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildContextChip(String label, String value) {
    bool isSelected = selectedSugarContext == value;
    return GestureDetector(
      onTap: () => setState(() => selectedSugarContext = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // ✅✅ منطق الحفظ في Firebase
  Future<void> _saveVitals() async {
    // 1. التأكد من وجود بيانات للحفظ
    if (_systolicController.text.isEmpty &&
        _sugarController.text.isEmpty &&
        _heartRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال قيمة واحدة على الأقل")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? targetUid =
          widget.patientId ?? FirebaseAuth.instance.currentUser?.uid;
      if (targetUid == null) throw "لم يتم العثور على المستخدم";

      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('vitals');

      // 2. حفظ ضغط الدم (إذا وجد)
      if (_systolicController.text.isNotEmpty &&
          _diastolicController.text.isNotEmpty) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'type': 'pressure',
          'value': "${_systolicController.text}/${_diastolicController.text}",
          'unit': 'mmHg',
          'date': Timestamp.fromDate(selectedDate),
          'status': 'normal', // يمكن إضافة منطق لحساب الحالة
        });
      }

      // 3. حفظ السكر (إذا وجد)
      if (_sugarController.text.isNotEmpty) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'type': 'sugar',
          'value': _sugarController.text,
          'unit': 'mg/dL',
          'context': selectedSugarContext, // حفظ السياق (صائم/فاطر)
          'date': Timestamp.fromDate(selectedDate),
          'status': 'normal',
        });
      }

      // 4. حفظ النبض (إذا وجد)
      if (_heartRateController.text.isNotEmpty) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'type': 'heart',
          'value': _heartRateController.text,
          'unit': 'bpm',
          'date': Timestamp.fromDate(selectedDate),
          'status': 'normal',
        });
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ القراءات بنجاح ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
