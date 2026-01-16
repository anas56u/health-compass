import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
// ✅ الحل: إخفاء TextDirection من intl لمنع التعارض مع Flutter
import 'package:intl/intl.dart' hide TextDirection;

class VitalsHistoryScreen extends StatefulWidget {
  // ✅ نحتاج معرفة المريض لجلب بياناته
  final String patientId;

  const VitalsHistoryScreen({super.key, required this.patientId});

  @override
  State<VitalsHistoryScreen> createState() => _VitalsHistoryScreenState();
}

class _VitalsHistoryScreenState extends State<VitalsHistoryScreen> {
  final Color primaryColor = const Color(0xFF41BFAA);
  String selectedFilter = 'all'; // افتراضياً عرض الكل

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // الآن سيعمل هذا السطر بدون مشاكل
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. الشريط العلوي
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: const BackButton(color: Colors.black),
              title: Text(
                "سجل القراءات",
                style: GoogleFonts.tajawal(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),

            // 2. فلاتر التصفية
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip("الكل", "all"),
                    _buildFilterChip("ضغط الدم", "pressure"),
                    _buildFilterChip("سكري", "sugar"),
                    _buildFilterChip("نبض القلب", "heart"),
                    _buildFilterChip("الوزن", "weight"),
                  ],
                ),
              ),
            ),

            // 3. ✅✅ قائمة القراءات الحقيقية (FutureBuilder)
            SliverFillRemaining(
              child: FutureBuilder<List<VitalModel>>(
                // عند تغيير الفلتر، سيتم استدعاء الدالة مجدداً
                future: FamilyRepository().getVitalsHistory(
                  widget.patientId,
                  type: selectedFilter,
                ),
                builder: (context, snapshot) {
                  // حالة التحميل
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // حالة الخطأ
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "خطأ: ${snapshot.error}",
                        style: GoogleFonts.tajawal(),
                      ),
                    );
                  }
                  // حالة القائمة الفارغة
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 50,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "لا توجد قراءات مسجلة",
                            style: GoogleFonts.tajawal(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  // عرض البيانات
                  final vitals = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vitals.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(vitals[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت الفلتر
  Widget _buildFilterChip(String label, String value) {
    bool isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) setState(() => selectedFilter = value);
        },
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.tajawal(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  // ✅ ودجت بناء العنصر (باستخدام البيانات الحقيقية)
  Widget _buildHistoryItem(VitalModel vital) {
    // تنسيق التاريخ
    String dateStr = DateFormat(
      'dd MMM yyyy • hh:mm a',
      'ar',
    ).format(vital.date);

    // تحديد الألوان حسب النوع
    IconData icon;
    Color color;

    switch (vital.type) {
      case 'pressure':
        icon = Icons.speed_rounded;
        color = Colors.indigo;
        break;
      case 'sugar':
        icon = Icons.bloodtype_rounded;
        color = Colors.pink;
        break;
      case 'heart':
        icon = Icons.favorite_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.monitor_weight_rounded;
        color = Colors.teal;
    }

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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${vital.value} ${vital.unit}",
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                dateStr, // التاريخ الحقيقي
                style: GoogleFonts.tajawal(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
