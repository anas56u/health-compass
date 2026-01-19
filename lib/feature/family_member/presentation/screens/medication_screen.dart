import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_medication_screen.dart';

class MedicationScreen extends StatelessWidget {
  final bool canEdit;
  final String userId;

  const MedicationScreen({
    super.key,
    this.canEdit = true,
    required this.userId,
  });

  final Color primaryColor = const Color(0xFF41BFAA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        floatingActionButton: canEdit
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditMedicationScreen(userId: userId),
                    ),
                  );
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: StreamBuilder<List<MedicationModel>>(
          stream: FamilyRepository().getPatientMedications(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  leading: const BackButton(color: Colors.black),
                  title: Text(
                    "الأدوية الحالية",
                    style: GoogleFonts.tajawal(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "لا توجد أدوية مسجلة حالياً",
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final med = snapshot.data![index];
                        return _buildMedCard(context, med);
                      }, childCount: snapshot.data!.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Widgets والدوال المساعدة ---

  Widget _buildMedCard(BuildContext context, MedicationModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${med.dose} • ${med.times.isNotEmpty ? med.times.first : '--:--'}",
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(context, med),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ تم التعديل: تغليف الـ Dialog بـ Directionality لمنع الخطأ
  void _confirmDelete(BuildContext context, MedicationModel med) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "حذف الدواء؟",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد من حذف '${med.name}'؟ لا يمكن التراجع عن هذا الإجراء.",
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
                _deleteMedicationFromFirestore(context, med.id);
              },
              child: Text("حذف", style: GoogleFonts.tajawal(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تم التعديل: تغليف الـ SnackBar بـ Directionality لمنع الانهيار
  Future<void> _deleteMedicationFromFirestore(
    BuildContext context,
    String? docId,
  ) async {
    if (docId == null || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text("خطأ: لا يمكن العثور على معرف الدواء"),
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: const Text("تم حذف الدواء بنجاح"),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text("فشل الحذف: $e"),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
