import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/health_cubit.dart';
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
      // 1. استخراج القيم
      final sugar = double.tryParse(_sugarController.text);
      final heartRate = double.tryParse(_heartRateController.text);
      
      // تحليل نص الضغط (مثلاً "120/80")
      int? systolic;
      int? diastolic;
      final pressureText = _pressureController.text;
      
      if (pressureText.isNotEmpty && pressureText.contains('/')) {
        final parts = pressureText.split('/');
        if (parts.length == 2) {
          systolic = int.tryParse(parts[0].trim());
          diastolic = int.tryParse(parts[1].trim());
        }
      } else if (pressureText.isNotEmpty) {
        // في حال أدخل المستخدم رقم واحد فقط نعتبره الانقباضي
        systolic = int.tryParse(pressureText.trim());
      }

      // التأكد أننا لا نرسل بيانات فارغة تماماً
      if (sugar == null && pressureText.isEmpty && heartRate == null) {
        return; 
      }

      // 2. إرسال البيانات للحفظ في قاعدة البيانات (كما كان سابقاً)
      context.read<FamilyCubit>().addVital(
        patientId: widget.patientId,
        sugar: sugar,
        pressure: pressureText,
        heartRate: heartRate,
      ); 

      // 3. ✅ فحص الطوارئ (الإضافة الجديدة)
      // نرسل البيانات لـ HealthCubit ليفحصها ويطلق الإنذار إذا لزم الأمر
      // نستخدم listen: false أو read لأننا داخل دالة
      context.read<HealthCubit>().checkManualReadings(
        heartRate: heartRate,
        systolic: systolic,
        diastolic: diastolic,
        bloodGlucose: sugar,
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
