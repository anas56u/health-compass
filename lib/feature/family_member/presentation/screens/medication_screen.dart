import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_edit_medication_screen.dart';

class MedicationScreen extends StatelessWidget {
  final bool canEdit; // للتحكم بظهور زر الإضافة (للمراقب فقط)

  const MedicationScreen({super.key, this.canEdit = true});

  final Color primaryColor = const Color(0xFF41BFAA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        // ✅ 2. الزر العائم (يظهر فقط إذا كان canEdit = true)
        floatingActionButton: canEdit
            ? FloatingActionButton(
                onPressed: () {
                  // الانتقال إلى شاشة إضافة دواء جديد
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditMedicationScreen(),
                    ),
                  );
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- الشريط العلوي المرن ---
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true, // يثبت الشريط عند التمرير لأسفل
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

            // --- قائمة الأدوية ---
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // قسم الصباح
                  _buildSectionHeader("أدوية الصباح"),
                  _buildMedCard(
                    "Panadol Extra",
                    "حبة بعد الفطور",
                    "09:00 ص",
                    Icons.wb_sunny_rounded,
                    Colors.orange,
                  ),
                  _buildMedCard(
                    "Vitamin D",
                    "حبة واحدة",
                    "10:00 ص",
                    Icons.wb_sunny_rounded,
                    Colors.orange,
                  ),

                  const SizedBox(height: 25),

                  // قسم المساء
                  _buildSectionHeader("أدوية المساء"),
                  _buildMedCard(
                    "Aspirin 81mg",
                    "حبة قبل النوم",
                    "10:00 م",
                    Icons.nights_stay_rounded,
                    Colors.indigo,
                  ),
                  _buildMedCard(
                    "Atorvastatin",
                    "حبة واحدة",
                    "10:30 م",
                    Icons.nights_stay_rounded,
                    Colors.indigo,
                  ),

                  const SizedBox(
                    height: 80,
                  ), // مساحة إضافية في الأسفل عشان الزر العائم ما يغطي آخر عنصر
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets مساعدة للتصميم ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMedCard(
    String name,
    String instruction,
    String time,
    IconData icon,
    Color iconColor,
  ) {
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$instruction • $time",
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // زر تعديل (يظهر فقط إذا كان مسموح التعديل)
          if (canEdit)
            IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.grey[400]),
              onPressed: () {
                // TODO: يمكن إضافة الانتقال لصفحة التعديل هنا مستقبلاً
              },
            ),
        ],
      ),
    );
  }
}
