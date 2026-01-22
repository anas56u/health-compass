import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_bot_screen.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';
import 'package:health_compass/feature/family_member/presentation/screens/family_profile_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/medication_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/vitals_history_screen.dart';
import 'package:health_compass/feature/family_member/presentation/screens/patient_settings_screen.dart';
import 'package:health_compass/core/widgets/add_vitals_sheet.dart';
import 'package:health_compass/feature/family_member/data/family_repository.dart';

class FamilyMemberHomeScreen extends StatefulWidget {
  const FamilyMemberHomeScreen({super.key});

  @override
  State<FamilyMemberHomeScreen> createState() => _FamilyMemberHomeScreenState();
}

class _FamilyMemberHomeScreenState extends State<FamilyMemberHomeScreen> {
  final Color primaryColor = const Color(0xFF41BFAA);
  final Color secondaryColor = const Color(0xFF1B8E8C);
  final Color chatbotColor = const Color(0xFF0D9488);
  final Color bgColor = const Color(0xFFF8FAFC);

  String _userPermission = 'read_only';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<FamilyCubit>().loadMyProfile().then((_) {
        if (mounted) context.read<FamilyCubit>().initFamilyHome(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<FamilyCubit, FamilyState>(
        listener: (context, state) {
          if (state is FamilyProfileLoaded) {
            setState(() => _userPermission = state.userModel.permission);
          }
          if (state is FamilyLinkSuccess) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null)
              context.read<FamilyCubit>().initFamilyHome(user.uid);
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: BlocBuilder<FamilyCubit, FamilyState>(
              builder: (context, state) {
                if (state is FamilyLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                } else if (state is FamilyDashboardLoaded) {
                  return _buildDashboardContent(context, state);
                } else if (state is FamilyError) {
                  return _buildErrorState(state.message);
                }
                return _buildNoLinkedPatientState();
              },
            ),
          ),
          floatingActionButton: _buildAnimatedFAB(),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    FamilyDashboardLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null)
          await context.read<FamilyCubit>().initFamilyHome(user.uid);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildModernAppBar(state),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDynamicHeader(state.currentProfile['name'] ?? 'المريض'),
                SizedBox(height: 15.h),
                // ✅ إضافة بطاقة الحالة الصحية
                _buildPatientStatusCard(state.currentProfile),
                SizedBox(height: 25.h),
                _buildSectionHeader(
                  "آخر القراءات الحيوية",
                  Icons.analytics_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VitalsHistoryScreen(
                        patientId: state.selectedPatientId,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // ✅ إضافة شبكة القراءات (النبض، السكر، الضغط)
                _buildVitalsGrid(state.currentVitals),
                SizedBox(height: 25.h),
                _buildSectionHeader(
                  "الأدوية المجدولة",
                  Icons.medication_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicationScreen(
                        canEdit: _userPermission == 'interactive',
                        userId: state.selectedPatientId,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildRealMedicationList(state.selectedPatientId),
                SizedBox(height: 80.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ويدجت عرض العلامات الحيوية في شبكة
  Widget _buildVitalsGrid(List<VitalModel> vitals) {
    if (vitals.isEmpty) return _buildEmptyState("لا توجد قراءات مسجلة اليوم");
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.6,
      ),
      itemCount: vitals.length,
      itemBuilder: (context, index) {
        final vital = vitals[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vital.type,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 5.h),
              FittedBox(
                child: Text(
                  "${vital.value} ${vital.unit}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ بطاقة الحالة الصحية العلوية
  Widget _buildPatientStatusCard(Map<String, dynamic> profile) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 30.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "حالة ${profile['name'] ?? 'المريض'} مستقرة",
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "تم التحديث الآن",
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- شريط التطبيق العلوي ---
  Widget _buildModernAppBar(FamilyDashboardLoaded state) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      expandedHeight: 80.h,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: CircleAvatar(
          backgroundImage: const AssetImage('assets/images/logo.jpeg'),
          radius: 20.r,
        ),
      ),
      title: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 160.w),
        child: _buildPatientSelector(state),
      ),
      actions: [
        _buildAppBarAction(Icons.account_circle_outlined, primaryColor, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
          );
        }),
        _buildAppBarAction(Icons.smart_toy_outlined, chatbotColor, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatBotScreen()),
          );
        }),
        _buildAppBarAction(Icons.settings_outlined, Colors.black87, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientSettingsScreen(
                patientId: state.selectedPatientId,
                patientData: state.currentProfile,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPatientSelector(FamilyDashboardLoaded state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedPatientId,
          isDense: true,
          isExpanded: true,
          items: [
            ...state.allPatients.map(
              (p) => DropdownMenuItem(
                value: p['id'],
                child: Text(
                  p['name'] ?? 'مريض',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const DropdownMenuItem(value: "add_new", child: Text("+ ربط مريض")),
          ],
          onChanged: (val) {
            if (val == "add_new") {
              Navigator.pushNamed(context, AppRoutes.linkPatient);
            } else if (val != null) {
              context.read<FamilyCubit>().selectPatient(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRealMedicationList(String patientId) {
    return StreamBuilder<List<MedicationModel>>(
      stream: FamilyRepository().getPatientMedications(patientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return _buildEmptyState("لا توجد أدوية");
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length > 3 ? 3 : snapshot.data!.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) => _buildMedCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildMedCard(MedicationModel med) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_liquid_outlined,
            color: primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              med.medicationName,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 12.sp,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader(String name) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Text(
      "أهلاً بك،\nكيف حال $name اليوم؟",
      style: GoogleFonts.tajawal(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    ),
  );

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onTap) {
    return Row(
      children: [
        Icon(icon, color: secondaryColor, size: 20.sp),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(
            "عرض الكل",
            style: TextStyle(color: primaryColor, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFAB() {
    return BlocBuilder<FamilyCubit, FamilyState>(
      builder: (context, state) {
        if (state is FamilyDashboardLoaded &&
            _userPermission == 'interactive') {
          return FloatingActionButton.extended(
            onPressed: () =>
                _showAddVitalsSheet(context, state.selectedPatientId),
            backgroundColor: primaryColor,
            icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
            label: Text(
              "إضافة قراءة",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildNoLinkedPatientState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80.sp,
            color: primaryColor.withOpacity(0.2),
          ),
          SizedBox(height: 20.h),
          Text(
            "لم تقم بربط أي مريض",
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.linkPatient),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              "ربط مريض الآن",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildEmptyState(String msg) => Center(
    child: Padding(
      padding: EdgeInsets.all(20.h),
      child: Text(
        msg,
        style: GoogleFonts.tajawal(color: Colors.grey[400], fontSize: 11.sp),
      ),
    ),
  );

  Widget _buildErrorState(String msg) => Center(child: Text(msg));

  void _showAddVitalsSheet(BuildContext context, String pid) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddVitalsSheet(patientId: pid),
      );

  Widget _buildAppBarAction(IconData icon, Color color, VoidCallback onTap) =>
      IconButton(
        icon: Icon(icon, color: color, size: 24.sp),
        onPressed: onTap,
      );
}
