import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

class AddVitalsBottomSheet extends StatefulWidget {
  const AddVitalsBottomSheet({super.key});

  @override
  State<AddVitalsBottomSheet> createState() => _AddVitalsBottomSheetState();
}

class _AddVitalsBottomSheetState extends State<AddVitalsBottomSheet> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _heartRateController = TextEditingController();

  final Color primaryColor = const Color(0xFF41BFAA);

  // المتغيرات الجديدة لتحسين UX
  DateTime selectedDate = DateTime.now();
  String selectedSugarContext = 'random'; // random, fasting, after_meal

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
            // مقبض السحب
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

            // الرأس مع التاريخ
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

                // زر تغيير التاريخ/الوقت
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
                          intl.DateFormat('h:mm a, d MMM').format(selectedDate),
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

            // قسم الضغط
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

            // قسم السكر والسياق
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
            // خيارات سياق السكر (Chips)
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

            // قسم النبض
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

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: منطق الحفظ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
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
}
