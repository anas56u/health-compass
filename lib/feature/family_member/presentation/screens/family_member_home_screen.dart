import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';
import 'package:health_compass/feature/family_member/presentation/screens/family_profile_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/medication_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/vitals_history_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/patient_settings_screen.dart';
import 'package:health_compass/core/widgets/add_vitals_sheet.dart';

class FamilyMemberHomeScreen extends StatefulWidget {
  const FamilyMemberHomeScreen({super.key});

  @override
  State<FamilyMemberHomeScreen> createState() => _FamilyMemberHomeScreenState();
}

class _FamilyMemberHomeScreenState extends State<FamilyMemberHomeScreen> {
  final Color primaryColor = const Color(0xFF41BFAA);
  final Color bgColor = const Color(0xFFF5F7FA);

  // متغير لتخزين الصلاحية القادمة من بيانات المستخدم
  String _userPermission = 'read_only';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 1. تهيئة البيانات الأساسية للمرضى المرتبطين
      context.read<FamilyCubit>().initFamilyHome(user.uid);
      // 2. جلب ملف المستخدم الشخصي لمعرفة الصلاحية (Permission)
      context.read<FamilyCubit>().loadMyProfile();
    }
  }

  // دالة للتحقق مما إذا كان المستخدم يملك صلاحية التعديل
  bool _canEdit(FamilyState state) {
    if (state is FamilyDashboardLoaded || state is FamilyProfileLoaded) {
      return _userPermission == 'interactive';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<FamilyCubit, FamilyState>(
        listener: (context, state) {
          // تحديث الصلاحية فور تحميل ملف المستخدم الشخصي
          if (state is FamilyProfileLoaded) {
            setState(() {
              _userPermission =
                  state.userModel.permission; // جلب الصلاحية من المودل
            });
          }

          if (state is FamilyOperationSuccess) {
            _showSnackBar(context, state.message, Colors.green);
          } else if (state is FamilyOperationError) {
            _showSnackBar(context, state.message, Colors.red);
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: BlocBuilder<FamilyCubit, FamilyState>(
            builder: (context, state) {
              if (state is FamilyLoading) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (state is FamilyError) {
                return _buildErrorState(state.message);
              } else if (state is FamilyNoLinkedPatients ||
                  state is FamilyInitial) {
                return _buildNoLinkedPatientState();
              } else if (state is FamilyDashboardLoaded) {
                return _buildDashboardContent(context, state);
              }
              return const SizedBox();
            },
          ),
          // التحكم بظهور زر الإضافة بناءً على الصلاحية في Firestore
          floatingActionButton: BlocBuilder<FamilyCubit, FamilyState>(
            builder: (context, state) {
              if (state is FamilyDashboardLoaded &&
                  _userPermission == 'interactive') {
                return FloatingActionButton(
                  onPressed: () =>
                      _showAddVitalsSheet(context, state.selectedPatientId),
                  backgroundColor: primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    FamilyDashboardLoaded state,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(state),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientStatusCard(state.currentProfile),
                SizedBox(height: 25.h),
                _buildSectionHeader("العلامات الحيوية", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VitalsHistoryScreen(
                        patientId: state.selectedPatientId,
                      ),
                    ),
                  );
                }),
                SizedBox(height: 15.h),
                _buildVitalsGrid(state.currentVitals),
                SizedBox(height: 25.h),
                _buildSectionHeader("الأدوية القادمة", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicationScreen(
                        canEdit:
                            _userPermission ==
                            'interactive', // تمرير الصلاحية المجلوبة
                        userId: state.selectedPatientId,
                      ),
                    ),
                  );
                }),
                SizedBox(height: 15.h),
                _buildRealMedicationList(state.selectedPatientId),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(FamilyDashboardLoaded state) {
    return SliverAppBar(
      backgroundColor: bgColor,
      elevation: 0,
      expandedHeight: 80.h,
      floating: true,
      pinned: false,
      leading: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo.jpeg'),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "مرحباً بك ",
            style: GoogleFonts.tajawal(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedPatientId,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              style: GoogleFonts.tajawal(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              items: [
                ...state.allPatients.map((patient) {
                  return DropdownMenuItem<String>(
                    value: patient['id'],
                    child: Text(patient['name'] ?? 'مريض بدون اسم'),
                  );
                }).toList(),
                // خيار الإضافة يظهر للجميع ولكن يتم التحكم فيه عند الضغط
                DropdownMenuItem<String>(
                  value: "add_new",
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "ربط مريض جديد",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (newId) {
                if (newId == "add_new") {
                  Navigator.pushNamed(context, AppRoutes.linkPatient).then((_) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null)
                      context.read<FamilyCubit>().initFamilyHome(user.uid);
                  });
                } else if (newId != null && newId != state.selectedPatientId) {
                  context.read<FamilyCubit>().selectPatient(newId);
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientSettingsScreen(
                patientId: state.selectedPatientId,
                patientData: state.currentProfile,
              ),
            ),
          ),
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

  Widget _buildVitalsGrid(List<VitalModel> vitals) {
    if (vitals.isEmpty) return _buildEmptyState("لا توجد قراءات حديثة");
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
        String title = vital.type == 'pressure'
            ? "ضغط الدم"
            : vital.type == 'sugar'
            ? "السكر"
            : "نبض القلب";
        if (vital.type == 'pressure') {
          color = Colors.redAccent;
          icon = Icons.speed_rounded;
        } else if (vital.type == 'sugar') {
          color = Colors.blueAccent;
          icon = Icons.water_drop_rounded;
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

  Widget _buildRealMedicationList(String patientId) {
    return StreamBuilder<List<MedicationModel>>(
      key: ValueKey(patientId),
      stream: FamilyRepository().getPatientMedications(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return _buildEmptyState("لا توجد أدوية مسجلة حالياً");
        return Column(
          children: snapshot.data!
              .take(3)
              .map(
                (med) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildMedicationCard(
                    med.name,
                    med.dose,
                    med.times.isNotEmpty ? med.times.first : "--:--",
                    MedicationStatus.pending,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMedicationCard(
    String name,
    String dose,
    String time,
    MedicationStatus status,
  ) {
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
          Icon(
            Icons.access_time_filled_rounded,
            color: Colors.orange,
            size: 20.sp,
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
          child: Text(
            "عرض الكل",
            style: GoogleFonts.tajawal(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(20.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Text(
      message,
      style: GoogleFonts.tajawal(color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  );

  Widget _buildErrorState(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 50, color: Colors.red),
        SizedBox(height: 10.h),
        Text(message, style: GoogleFonts.tajawal(fontSize: 16.sp)),
        TextButton(
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null)
              context.read<FamilyCubit>().initFamilyHome(user.uid);
          },
          child: Text("إعادة المحاولة", style: GoogleFonts.tajawal()),
        ),
      ],
    ),
  );

  Widget _buildNoLinkedPatientState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_add_alt_1_rounded, size: 60.sp, color: primaryColor),
        SizedBox(height: 20.h),
        Text(
          "لا يوجد مريض مرتبط",
          style: GoogleFonts.tajawal(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 30.h),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.linkPatient),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text(
            "ربط مريض الآن",
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  void _showAddVitalsSheet(BuildContext context, String patientId) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddVitalsSheet(patientId: patientId),
      );

  void _showSnackBar(BuildContext context, String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.tajawal()),
          backgroundColor: color,
        ),
      );
}

enum MedicationStatus { taken, pending, missed }
