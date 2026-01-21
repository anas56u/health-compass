import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // أو استخدام Bloc حسب مشروعك
import 'package:health_compass/feature/family_member/logic/family_cubit.dart'; // استيراد الكيوبيت الخاص بك

class AddVitalsSheet extends StatefulWidget {
  final String patientId;

  const AddVitalsSheet({super.key, required this.patientId});

  @override
  State<AddVitalsSheet> createState() => _AddVitalsSheetState();
}

class _AddVitalsSheetState extends State<AddVitalsSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _pressureController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  final Color primaryColor = const Color(0xFF169086);

  // دالة لتحديد نص العنوان بناءً على نوع المستخدم
  String _getSheetTitle() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == widget.patientId) {
      return 'تسجيل قراءاتي الصحية';
    } else {
      return 'إضافة قراءة للمريض';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getSheetTitle(), // استخدام العنوان الديناميكي
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _sugarController,
              label: 'مستوى السكر (mg/dL)',
              icon: Icons.bloodtype_outlined,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 15),
            _buildField(
              controller: _pressureController,
              label: 'ضغط الدم (mmHg)',
              icon: Icons.speed,
              color: Colors.blueAccent,
            ),

            const SizedBox(height: 25),
            _buildField(controller: _heartRateController, label: "نبضات القلب (bpm)", icon: Icons.favorite_rounded, color: Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _onSavePressed(),
                child: Text(
                  'حفظ البيانات',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final sugar = double.tryParse(_sugarController.text);
      final pressure = _pressureController.text;
      final heartRate = double.tryParse(_heartRateController.text);
      // التأكد أننا لا نرسل بيانات فارغة تماماً
      if (sugar == null && pressure.isEmpty && heartRate == null) {
        return; 
      }
      context.read<FamilyCubit>().addVital(
        patientId: widget.patientId,
        sugar: sugar,
        pressure: pressure,
        heartRate: heartRate,
      );

      Navigator.pop(context);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color),
        labelText: label,
        labelStyle: GoogleFonts.tajawal(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) => val!.isEmpty ? 'مطلوب' : null,
    );
  }
}
