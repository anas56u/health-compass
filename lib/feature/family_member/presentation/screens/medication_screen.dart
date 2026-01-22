import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';
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
    return BlocListener<FamilyCubit, FamilyState>(
      listener: (context, state) {
        if (state is FamilyOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.tajawal()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is FamilyOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.tajawal()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Directionality(
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
            // الاستماع المباشر لقائمة أدوية المريض من الـ Repository
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "لا توجد أدوية مسجلة حالياً",
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildMedCard(BuildContext context, MedicationModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الدواء
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
          // بيانات الدواء (الاسم والجرعة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // تم التعديل لاستخدام medicationName من الموديل الجديد
                  med.medicationName,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  // تم التعديل لاستخدام dosage و time من الموديل الجديد
                  "${med.dosage} • ${med.time} ${med.period}",
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // زر الحذف (يظهر فقط لمن لديه صلاحية التعديل)
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

  void _confirmDelete(BuildContext context, MedicationModel med) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "حذف الدواء؟",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد من حذف '${med.medicationName}'؟ لا يمكن التراجع عن هذا الإجراء.",
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // استدعاء دالة الحذف من الكيوبيت لضمان تحديث واجهة المريض أيضاً
                context.read<FamilyCubit>().deleteMedication(userId, med.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "حذف",
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
