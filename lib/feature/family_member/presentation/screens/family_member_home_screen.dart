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

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<FamilyCubit>().initFamilyHome(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<FamilyCubit, FamilyState>(
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
          floatingActionButton: BlocBuilder<FamilyCubit, FamilyState>(
            builder: (context, state) {
              if (state is FamilyDashboardLoaded && canEdit) {
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

  // --- Widgets ---

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
                      builder: (context) => VitalsHistoryScreen(
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
                      builder: (context) => MedicationScreen(
                        canEdit: canEdit,
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
            "مرحباً بك 👋",
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
              items: state.allPatients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(patient['name'] ?? 'مريض بدون اسم'),
                );
              }).toList(),
              onChanged: (newId) {
                if (newId != null && newId != state.selectedPatientId) {
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientSettingsScreen(
                  patientId: state.selectedPatientId,
                  patientData: state.currentProfile,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  Widget _buildRealMedicationList(String patientId) {
    return StreamBuilder<List<MedicationModel>>(
      key: ValueKey(patientId),
      stream: FamilyRepository().getPatientMedications(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("لا توجد أدوية مسجلة حالياً");
        }
        final medications = snapshot.data!;
        final displayList = medications.take(3).toList();

        return Column(
          children: displayList.map((med) {
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
      return _buildEmptyState("لا توجد قراءات حديثة");
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
    Color statusColor = Colors.orange;
    String statusText = "قادم";
    IconData statusIcon = Icons.access_time_filled_rounded;

    if (status == MedicationStatus.taken) {
      statusColor = Colors.green;
      statusText = "تم أخذها";
      statusIcon = Icons.check_circle_rounded;
    } else if (status == MedicationStatus.missed) {
      statusColor = Colors.red;
      statusText = "فائتة";
      statusIcon = Icons.cancel_rounded;
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

  Widget _buildEmptyState(String message) {
    return Container(
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
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 10.h),
          Text(message, style: GoogleFonts.tajawal(fontSize: 16.sp)),
          TextButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                context.read<FamilyCubit>().initFamilyHome(user.uid);
              }
            },
            child: Text("إعادة المحاولة", style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLinkedPatientState() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: bgColor,
          elevation: 0,
          pinned: false,
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
            IconButton(
              icon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FamilyProfileScreen(),
                  ),
                );
              },
            ),
            SizedBox(width: 10.w),
          ],
        ),
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
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context.read<FamilyCubit>().initFamilyHome(
                              user.uid,
                            );
                          }
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

  void _showAddVitalsSheet(BuildContext context, String patientId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddVitalsSheet(patientId: patientId),
    );
  }
}

enum MedicationStatus { taken, pending, missed }
