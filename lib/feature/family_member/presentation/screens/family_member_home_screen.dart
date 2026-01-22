import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/routes/routes.dart';
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

  // --- تحديث الـ AppBar لإضافة زر البروفايل ---
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
        // ✅ زر الملف الشخصي (البروفايل)
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
        SizedBox(width: 5.w),
      ],
    );
  }

  // --- واجهة عند عدم وجود مريض مع إضافة زر البروفايل ---
  Widget _buildNoLinkedPatientState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
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
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.linkPatient),
              icon: const Icon(Icons.link, color: Colors.white),
              label: const Text(
                "ربط مريض الآن",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, 45.h),
              ),
            ),
            SizedBox(height: 15.h),
            // ✅ زر إضافي للبروفايل هنا لسهولة الوصول
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
              ),
              icon: Icon(Icons.person_outline, color: primaryColor),
              label: Text("ملفي الشخصي", style: TextStyle(color: primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                minimumSize: Size(double.infinity, 45.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // المكونات المساعدة الأخرى (نفس الكود السابق مع إصلاح الـ Overflow)
  Widget _buildAppBarAction(IconData icon, Color color, VoidCallback onTap) =>
      IconButton(
        icon: Icon(icon, color: color, size: 24.sp),
        onPressed: onTap,
      );

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
                // ... باقي المحتوى كما هو في الكود السابق
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // (يتم إكمال باقي الـ widgets مثل _buildPatientSelector و _buildDynamicHeader كما في الكود السابق)
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

  void _showCustomSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildErrorState(String msg) => Center(child: Text(msg));

  void _showAddVitalsSheet(BuildContext context, String pid) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddVitalsSheet(patientId: pid),
      );
}
