import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:intl/intl.dart' hide TextDirection;

class VitalsHistoryScreen extends StatelessWidget {
  final String patientId; // المعرف الخاص بالمريض

  const VitalsHistoryScreen({super.key, required this.patientId});

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
            "سجل العلامات الحيوية",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<List<VitalModel>>(
          // ✅ 1. جلب البيانات من Repository
          stream: FamilyRepository().getPatientVitals(patientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF41BFAA)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monitor_heart_outlined,
                      size: 60,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "لا توجد قراءات مسجلة",
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ترتيب البيانات من الأحدث للأقدم
            final vitals = snapshot.data!;
            // vitals.sort((a, b) => b.date.compareTo(a.date));

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vitals.length,
              itemBuilder: (context, index) {
                final vital = vitals[index];
                return _buildVitalCard(context, vital);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVitalCard(BuildContext context, VitalModel vital) {
    // تحديد الأيقونة واللون بناءً على نوع القياس
    IconData icon;
    Color color;
    String title;

    switch (vital.type) {
      case 'pressure':
        title = "ضغط الدم";
        icon = Icons.speed_rounded;
        color = Colors.redAccent;
        break;
      case 'sugar':
        title = "السكر";
        icon = Icons.water_drop_rounded;
        color = Colors.blueAccent;
        break;
      case 'heart':
        title = "نبض القلب";
        icon = Icons.favorite_rounded;
        color = Colors.pinkAccent;
        break;
      default:
        title = "قياس آخر";
        icon = Icons.health_and_safety;
        color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // الأيقونة الجانبية
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),

          // تفاصيل القراءة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      vital.value,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        vital.unit,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  // ✅ الآن سيعمل DateFormat بشكل صحيح
                  DateFormat('yyyy/MM/dd - hh:mm a', 'en').format(vital.date),
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // ✅ زر الحذف
          IconButton(
            onPressed: () => _confirmDelete(context, vital),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ دالة عرض نافذة التأكيد
  void _confirmDelete(BuildContext context, VitalModel vital) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "حذف القراءة؟",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Text(
          "هل أنت متأكد من حذف هذه القراءة (${vital.value} ${vital.unit})؟",
          style: GoogleFonts.tajawal(),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إلغاء",
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteVitalFromFirestore(context, vital.id);
            },
            child: Text("حذف", style: GoogleFonts.tajawal(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ دالة الحذف الفعلية من Firebase
  Future<void> _deleteVitalFromFirestore(
    BuildContext context,
    String? docId,
  ) async {
    if (docId == null || docId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId) // معرف المريض
          .collection('vitals') // اسم المجموعة في Firebase
          .doc(docId) // معرف المستند
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حذف القراءة بنجاح"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل الحذف: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
