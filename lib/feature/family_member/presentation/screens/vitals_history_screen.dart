import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';
import 'package:intl/intl.dart' hide TextDirection;

class VitalsHistoryScreen extends StatelessWidget {
  final String patientId;

  const VitalsHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<FamilyCubit, FamilyState>(
        // إضافة مستمع لإظهار رسائل الحذف
        listener: (context, state) {
          if (state is FamilyOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is FamilyOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
            // استخدام الـ Stream لضمان تحديث القائمة تلقائياً عند أي تغيير في Firestore
            stream: FamilyRepository().getPatientVitals(patientId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF41BFAA)),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final vitals = snapshot.data!;
              vitals.sort((a, b) => b.date.compareTo(a.date));

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
      ),
    );
  }

  // --- Widgets المساعدة لتقليل زحمة الكود ---

  Widget _buildVitalCard(BuildContext context, VitalModel vital) {
    final String safeType = (vital.type).trim().toLowerCase();
    IconData icon;
    Color color;
    String title;

    if (safeType.contains('pressure')) {
      title = "ضغط الدم";
      icon = Icons.speed_rounded;
      color = Colors.redAccent;
    } else if (safeType.contains('sugar')) {
      title = "السكر";
      icon = Icons.water_drop_rounded;
      color = Colors.blueAccent;
    } else {
      title = "نبض القلب";
      icon = Icons.favorite_rounded;
      color = Colors.pinkAccent;
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
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
                Text(
                  "${vital.value} ${vital.unit}",
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy/MM/dd - hh:mm a', 'en').format(vital.date),
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
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

  void _confirmDelete(BuildContext context, VitalModel vital) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "حذف القراءة؟",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد من حذف هذه القراءة؟",
            style: GoogleFonts.tajawal(),
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
                // ✅ استخدام الكيوبيت لضمان التحديث في كل مكان
                context.read<FamilyCubit>().deleteVital(patientId, vital.id!);
              },
              child: Text("حذف", style: GoogleFonts.tajawal(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "لا توجد قراءات مسجلة",
            style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text("حدث خطأ: $error", style: const TextStyle(color: Colors.red)),
    );
  }
}
