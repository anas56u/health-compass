import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
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
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is FamilyOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
            // لا يزال استخدام StreamBuilder هنا مقبولاً لأنه متصل بـ Repo مباشرة
            // ولكن الآن الحذف يتم عبر الـ Cubit
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
                // Call Cubit
                context.read<FamilyCubit>().deleteMedication(userId, med.id!);
              },
              child: Text("حذف", style: GoogleFonts.tajawal(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
