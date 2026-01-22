import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/AboutApp.dart';
import 'package:health_compass/feature/ContactSupportScreen.dart';
import 'package:health_compass/feature/PrivacyPolicyScreen.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/core/widgets/add_vitals_sheet.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  static const primaryTurquoise = Color(0xFF169086);
  static const lightCardBg = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryTurquoise,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildProfileHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: lightCardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 25.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHealthSummaryCard(),
                        SizedBox(height: 25.h),
                        _buildSectionLabel("الخدمات الصحية"),
                        _buildActionTile(
                          icon: Icons.add_chart_rounded,
                          title: "إضافة قراءة يدوية",
                          subtitle: "سجل العلامات الحيوية الآن",
                          onTap: _showVitalsSheet,
                        ),
                        _buildActionTile(
                          icon: Icons.timer_outlined,
                          title: "أوقات الصيام",
                          subtitle: "إدارة وتنظيم ساعات الصيام",
                          onTap: () => _showFastingBottomSheet(context),
                        ),
                        _buildSourceToggle(),
                        SizedBox(height: 25.h),
                        _buildSectionLabel("الدعم والخصوصية"),
                        _buildActionTile(
                          icon: Icons.info_outline_rounded,
                          title: "عن التطبيق",
                          subtitle: "تعرف على مشروع بوصلة الصحة",
                          onTap: () => _navigateTo(const AboutAppScreen()),
                        ),
                        _buildActionTile(
                          icon: Icons.security_outlined,
                          title: "سياسة الخصوصية",
                          subtitle: "كيف نحمي بياناتك وصلاحياتك",
                          onTap: () => _navigateTo(const PrivacyPolicyScreen()),
                        ),
                        _buildActionTile(
                          icon: Icons.support_agent_rounded,
                          title: "تواصل معنا",
                          subtitle: "فريق الدعم الفني جاهز لمساعدتك",
                          onTap: () =>
                              _navigateTo(const ContactSupportScreen()),
                        ),
                        SizedBox(height: 25.h),
                        _buildSectionLabel("إدارة الحساب"),
                        _buildActionTile(
                          icon: Icons.logout_rounded,
                          title: "تسجيل الخروج",
                          subtitle: "الخروج الآمن من الحساب",
                          isDestructive: true,
                          onTap: _onLogoutPressed,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "الملف الشخصي",
        style: GoogleFonts.tajawal(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String name = "جاري التحميل...";
        String email = "";
        String image = 'https://i.pravatar.cc/150?img=11';

        if (state is UserLoaded) {
          name = state.userModel.fullName;
          email = state.userModel.email;
          if (state.userModel.profileImage?.isNotEmpty ?? false) {
            image = state.userModel.profileImage!;
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38.r,
                backgroundColor: Colors.white24,
                child: CircleAvatar(
                  radius: 35.r,
                  backgroundImage: NetworkImage(image),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthSummaryCard() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String disease = "...";
        String year = "...";
        if (state is UserLoaded && state.userModel is PatientModel) {
          final p = state.userModel as PatientModel;
          disease = p.diseaseType;
          year = p.diagnosisYear ?? "غير محدد";
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 3, // مساحة أكبر للأمراض
                  child: _buildSummaryItem(
                    "نوع التشخيص",
                    disease,
                    Icons.healing_outlined,
                    isDiseaseList: true,
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey[100],
                  thickness: 1,
                  width: 25.w,
                ),
                Expanded(
                  flex: 2,
                  child: _buildSummaryItem(
                    "سنة الإصابة",
                    year,
                    Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon, {
    bool isDiseaseList = false,
  }) {
    // معالجة نص الأمراض لتحويله إلى قائمة
    List<String> items = isDiseaseList
        ? value.split(RegExp(r'[,،]')).map((e) => e.trim()).toList()
        : [value];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[400]),
        SizedBox(height: 5.h),
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 8.h),
        // استخدام Wrap هنا هو السر في منع الـ Overflow
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4.w,
          runSpacing: 4.h,
          children: items.map((text) {
            return Text(
              text + (isDiseaseList && text != items.last ? "،" : ""),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: primaryTurquoise,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red[50]
                : primaryTurquoise.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : primaryTurquoise,
            size: 22.sp,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 12.sp,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildSourceToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: SharedPrefHelper.healthSourceNotifier,
      builder: (context, currentSource, child) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10.h),
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              _buildToggleItem("ساعة ذكية", true, currentSource),
              _buildToggleItem("قراءة يدوية", false, currentSource),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleItem(String title, bool isWatch, bool currentSelected) {
    bool isSelected = currentSelected == isWatch;
    return Expanded(
      child: GestureDetector(
        onTap: () async => await SharedPrefHelper.saveHealthSource(isWatch),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryTurquoise : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 12.h),
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- Logic & Navigation ---

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showVitalsSheet() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddVitalsSheet(patientId: uid),
      );
    }
  }

  Future<void> _onLogoutPressed() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'خروج',
              style: GoogleFonts.tajawal(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<UserCubit>().clearUserData();
      await SharedPrefHelper.clearLoginData();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showFastingBottomSheet(BuildContext context) async {
    TimeOfDay? savedStartTime = await SharedPrefHelper.getFastingStartTime();
    int savedDuration = await SharedPrefHelper.getFastingDuration();
    TimeOfDay selectedTime = savedStartTime ?? TimeOfDay.now();
    int selectedDuration = savedDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final endTime = _calculateEndTime(selectedTime, selectedDuration);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              25.w,
              25.h,
              25.w,
              MediaQuery.of(context).viewInsets.bottom + 25.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تتبع ساعات الصيام',
                  style: GoogleFonts.tajawal(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryTurquoise,
                  ),
                ),
                SizedBox(height: 20.h),
                ListTile(
                  tileColor: lightCardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  leading: const Icon(Icons.access_time, color: Colors.orange),
                  title: Text(
                    'بدأت الصيام الساعة',
                    style: GoogleFonts.tajawal(fontSize: 13.sp),
                  ),
                  trailing: Text(
                    selectedTime.format(context),
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: primaryTurquoise,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null)
                      setSheetState(() => selectedTime = picked);
                  },
                ),
                SizedBox(height: 20.h),
                Slider(
                  value: selectedDuration.toDouble(),
                  min: 6,
                  max: 16,
                  divisions: 10,
                  activeColor: primaryTurquoise,
                  onChanged: (v) =>
                      setSheetState(() => selectedDuration = v.toInt()),
                ),
                Text(
                  'مدة الصيام: $selectedDuration ساعة (تنتهي عند ${endTime.format(context)})',
                  style: GoogleFonts.tajawal(
                    color: Colors.grey[700],
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 25.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTurquoise,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  onPressed: () async {
                    await SharedPrefHelper.saveFastingData(
                      selectedTime,
                      selectedDuration,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'حفظ التذكير',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TimeOfDay _calculateEndTime(TimeOfDay start, int durationHours) {
    int totalMinutes = (start.hour * 60) + start.minute + (durationHours * 60);
    int finalMinutes = totalMinutes % (24 * 60);
    return TimeOfDay(hour: finalMinutes ~/ 60, minute: finalMinutes % 60);
  }
}
