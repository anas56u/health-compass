import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: lightCardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHealthSummaryCard(),
                      const SizedBox(height: 30),
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
                      const SizedBox(height: 25),
                      _buildSectionLabel("عن التطبيق والدعم"),
                      _buildActionTile(
                        icon: Icons.info_outline_rounded,
                        title: "عن التطبيق",
                        subtitle: "تعرف على مشروع بوصلة الصحة",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutAppScreen(),
                          ),
                        ),
                      ),
                      _buildActionTile(
                        icon: Icons.security_outlined,
                        title: "سياسة الخصوصية",
                        subtitle: "كيف نحمي بياناتك وصلاحياتك",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                      ),
                      _buildActionTile(
                        icon: Icons.support_agent_rounded,
                        title: "تواصل معنا",
                        subtitle: "فريق الدعم الفني جاهز لمساعدتك",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactSupportScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildSectionLabel("إدارة الحساب"),
                      _buildActionTile(
                        icon: Icons.logout_rounded,
                        title: "تسجيل الخروج",
                        subtitle: "الخروج الآمن من الحساب",
                        isDestructive: true,
                        onTap: _onLogoutPressed,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
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
          if (state.userModel.profileImage?.isNotEmpty ?? false)
            image = state.userModel.profileImage!;
        }

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 3),
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(image),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("نوع التشخيص", disease, Icons.healing_outlined),
              Container(width: 1, height: 40, color: Colors.grey[100]),
              _buildSummaryItem(
                "سنة الإصابة",
                year,
                Icons.calendar_today_outlined,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: primaryTurquoise,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 15),
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red[50]
                : primaryTurquoise.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : primaryTurquoise,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey[500]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDestructive ? Colors.red[200] : Colors.grey[300],
        ),
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final endTime = _calculateEndTime(selectedTime, selectedDuration);
          return Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تتبع ساعات الصيام',
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTurquoise,
                  ),
                ),
                const SizedBox(height: 25),
                ListTile(
                  tileColor: lightCardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  leading: const Icon(Icons.access_time, color: Colors.orange),
                  title: Text(
                    'بدأت الصيام الساعة',
                    style: GoogleFonts.tajawal(),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مدة الصيام:',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$selectedDuration ساعات',
                      style: GoogleFonts.tajawal(color: primaryTurquoise),
                    ),
                  ],
                ),
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
                  'سينتهي صيامك عند: ${endTime.format(context)}',
                  style: GoogleFonts.tajawal(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTurquoise,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
