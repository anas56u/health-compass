import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/core/models/medication_model.dart'; // ✅ تأكد من وجود الموديل
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';

// استيراد الشاشات الفرعية
import 'package:health_compass/feature/family_member/presentation/screens/family_profile_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/medication_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/vitals_history_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/patient_settings_screen.dart';
import 'package:health_compass/core/widgets/add_vitals_sheet.dart';

class FamilyMemberHomeScreen extends StatefulWidget {
  final String userPermission;

  const FamilyMemberHomeScreen({
    super.key,
    this.userPermission = 'interactive',
  });

  @override
  State<FamilyMemberHomeScreen> createState() => _FamilyMemberHomeScreenState();
}

class _FamilyMemberHomeScreenState extends State<FamilyMemberHomeScreen> {
  final Color primaryColor = const Color(0xFF41BFAA);
  final Color bgColor = const Color(0xFFF5F7FA);

  bool get canEdit => widget.userPermission == 'interactive';

  bool _isCheckingLinkedPatients = true;
  bool _hasLinkedPatients = false;

  // ✅ متغير لحفظ ID المريض الحالي لتمريره للشاشات الأخرى
  String? _currentPatientId;

  @override
  void initState() {
    super.initState();
    _fetchLinkedPatientAndLoadData();
  }

  // دالة لجلب المريض المرتبط
  Future<void> _fetchLinkedPatientAndLoadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final List linkedPatients = doc.data()?['linked_patients'] ?? [];

        if (linkedPatients.isNotEmpty) {
          String firstPatientId = linkedPatients.first;

          if (mounted) {
            setState(() {
              _hasLinkedPatients = true;
              _isCheckingLinkedPatients = false;
              _currentPatientId = firstPatientId; // ✅ حفظ الـ ID
            });
            // تحميل بيانات الداشبورد (البروفايل + العلامات الحيوية)
            context.read<FamilyCubit>().loadDashboardData(firstPatientId);
          }
        } else {
          if (mounted) {
            setState(() {
              _hasLinkedPatients = false;
              _isCheckingLinkedPatients = false;
              _currentPatientId = null;
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching linked patient: $e");
        if (mounted) {
          setState(() => _isCheckingLinkedPatients = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _buildBody(),
        // الزر العائم يظهر فقط إذا كان هناك مريض
        floatingActionButton: (canEdit && _hasLinkedPatients)
            ? FloatingActionButton(
                onPressed: () => _showAddVitalsSheet(context),
                backgroundColor: primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    // 1. حالة التحميل الأولية
    if (_isCheckingLinkedPatients) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // 2. حالة عدم وجود مرضى
    if (!_hasLinkedPatients) {
      return _buildNoLinkedPatientState();
    }

    // 3. حالة وجود مريض (BlocBuilder)
    return BlocBuilder<FamilyCubit, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoading) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        } else if (state is FamilyError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 10.h),
                Text(
                  state.message,
                  style: GoogleFonts.tajawal(fontSize: 16.sp),
                ),
                TextButton(
                  onPressed: _fetchLinkedPatientAndLoadData,
                  child: Text("إعادة المحاولة", style: GoogleFonts.tajawal()),
                ),
              ],
            ),
          );
        } else if (state is FamilyLoaded) {
          final profile = state.patientProfile;
          final vitals = state.vitals;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(profile),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientStatusCard(profile),
                      SizedBox(height: 25.h),

                      // --- قسم العلامات الحيوية ---
                      _buildSectionHeader("العلامات الحيوية", () {
                        if (_currentPatientId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VitalsHistoryScreen(
                                patientId: _currentPatientId!, // ✅ تمرير الـ ID
                              ),
                            ),
                          );
                        }
                      }),
                      SizedBox(height: 15.h),
                      _buildVitalsGrid(vitals),

                      SizedBox(height: 25.h),

                      // --- قسم الأدوية ---
                      _buildSectionHeader("الأدوية القادمة", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicationScreen(canEdit: canEdit),
                          ),
                        );
                      }),
                      SizedBox(height: 15.h),

                      // ✅✅ قائمة الأدوية الحقيقية (StreamBuilder)
                      _buildRealMedicationList(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // حالة افتراضية (نادراً ما تظهر)
        return Center(
          child: Text("جاري التحميل...", style: GoogleFonts.tajawal()),
        );
      },
    );
  }

  // --- Widgets ---

  // ✅ قائمة الأدوية الحقيقية المرتبطة بـ Firebase
  Widget _buildRealMedicationList() {
    if (_currentPatientId == null) return const SizedBox();

    return StreamBuilder<List<MedicationModel>>(
      stream: FamilyRepository().getPatientMedications(_currentPatientId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              "لا توجد أدوية مسجلة حالياً",
              style: GoogleFonts.tajawal(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        final medications = snapshot.data!;
        // عرض أول 3 أدوية فقط في الشاشة الرئيسية
        final displayList = medications.take(3).toList();

        return Column(
          children: displayList.map((med) {
            // منطق بسيط للحالة (يمكن تطويره حسب الوقت الفعلي)
            MedicationStatus status = MedicationStatus.pending;

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildMedicationCard(
                med.name,
                med.dose,
                med.times.isNotEmpty ? med.times.first : "--:--",
                status,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(Map<String, dynamic> profile) {
    final String name = profile['name'] ?? "مريض";

    return SliverAppBar(
      backgroundColor: bgColor,
      elevation: 0,
      expandedHeight: 80.h,
      floating: true,
      pinned: false,
      leading: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: const AssetImage('assets/images/logo.jpeg'),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "مرحباً بك 👋",
            style: GoogleFonts.tajawal(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
          Text(
            "تتابع: $name",
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FamilyProfileScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {
            if (_currentPatientId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientSettingsScreen(
                    patientId: _currentPatientId!, // ✅ تمرير الـ ID
                  ),
                ),
              );
            }
          },
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  Widget _buildPatientStatusCard(Map<String, dynamic> profile) {
    final String name = profile['name'] ?? "المريض";
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "حالة $name مستقرة",
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "اضغط لعرض التفاصيل الكاملة",
                  style: GoogleFonts.tajawal(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              "عرض الكل",
              style: GoogleFonts.tajawal(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsGrid(List<VitalModel> vitals) {
    if (vitals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          "لا توجد قراءات حديثة",
          style: GoogleFonts.tajawal(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 1.5,
      ),
      itemCount: vitals.length,
      itemBuilder: (context, index) {
        final vital = vitals[index];
        IconData icon = Icons.monitor_heart_outlined;
        Color color = Colors.orange;
        String title = "قراءة";

        if (vital.type == 'pressure') {
          title = "ضغط الدم";
          color = Colors.redAccent;
          icon = Icons.speed_rounded;
        } else if (vital.type == 'sugar') {
          title = "السكر";
          color = Colors.blueAccent;
          icon = Icons.water_drop_rounded;
        } else if (vital.type == 'heart') {
          title = "نبض القلب";
          color = Colors.pinkAccent;
          icon = Icons.favorite_rounded;
        }

        return _buildVitalCard(
          title: title,
          value: vital.value,
          unit: vital.unit,
          icon: icon,
          color: color,
        );
      },
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.tajawal(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Text(
                  unit,
                  style: GoogleFonts.tajawal(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(
    String name,
    String dose,
    String time,
    MedicationStatus status,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case MedicationStatus.taken:
        statusColor = Colors.green;
        statusText = "تم أخذها";
        statusIcon = Icons.check_circle_rounded;
        break;
      case MedicationStatus.pending:
        statusColor = Colors.orange;
        statusText = "قادم";
        statusIcon = Icons.access_time_filled_rounded;
        break;
      case MedicationStatus.missed:
        statusColor = Colors.red;
        statusText = "فائتة";
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "$dose • $time",
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 20.sp),
              Text(
                statusText,
                style: GoogleFonts.tajawal(fontSize: 10.sp, color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ودجت الحالة الفارغة (بدون مريض)
  Widget _buildNoLinkedPatientState() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: bgColor,
          elevation: 0,
          pinned: false,
          // ✅ هذا السطر يمنع ظهور زر الرجوع التلقائي
          automaticallyImplyLeading: false,
          title: Text(
            "مرحباً بك 👋",
            style: GoogleFonts.tajawal(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // زر الوصول للبروفايل
            IconButton(
              icon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyProfileScreen(),
                  ),
                );
              },
            ),
            SizedBox(width: 10.w),
          ],
        ),

        // محتوى الحالة الفارغة
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 60.sp,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "لا يوجد مريض مرتبط",
                    style: GoogleFonts.tajawal(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "لم تقم بربط أي مريض بحسابك بعد. قم بإضافة مريض لمتابعة حالته الصحية.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.linkPatient,
                        ).then((_) {
                          _fetchLinkedPatientAndLoadData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "ربط مريض الآن",
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddVitalsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVitalsBottomSheet(),
    );
  }
}

enum MedicationStatus { taken, pending, missed }
