import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';

class PatientSettingsScreen extends StatelessWidget {
  // ✅ جديد: استقبال ID المريض لنتمكن من حذفه
  final String patientId;

  const PatientSettingsScreen({super.key, required this.patientId});

  final Color primaryColor = const Color(0xFF41BFAA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            "إعدادات المريض",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ... (كارت البروفايل يمكن أن يبقى كما هو) ...
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: primaryColor, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ملف المريض",
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "ID: $patientId", // عرض الـ ID للتأكيد
                          style: GoogleFonts.tajawal(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // خيارات الإعدادات
              _buildSettingTile(
                title: "التنبيهات والإشعارات",
                icon: Icons.notifications_active_rounded,
                color: Colors.orange,
              ),
              _buildSettingTile(
                title: "تعديل الصلاحيات",
                icon: Icons.admin_panel_settings_rounded,
                color: Colors.blue,
              ),

              const SizedBox(height: 40),

              // ✅ زر الحذف
              ListTile(
                onTap: () => _showUnlinkDialog(context),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.link_off_rounded, color: Colors.red),
                ),
                title: Text(
                  "إلغاء ربط المريض",
                  style: GoogleFonts.tajawal(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ✅ نافذة تأكيد الحذف
  void _showUnlinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "تأكيد إلغاء الربط",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "هل أنت متأكد من حذف هذا المريض من قائمتك؟ لن تتلقى أي تنبيهات بعد الآن.",
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "تراجع",
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الـ Dialog

              // ✅ تنفيذ الحذف الفعلي
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // استدعاء الكيوبت
                context.read<FamilyCubit>().unlinkPatient(user.uid, patientId);

                // العودة للشاشة الرئيسية
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              "نعم، إلغاء الربط",
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
