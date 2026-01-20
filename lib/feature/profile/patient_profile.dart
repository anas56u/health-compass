import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/core/widgets/add_vitals_sheet.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart'; // تأكد من استيراد الكيوبيت

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool _isEnglish = false;
  bool _isPointsSystem = true;
  bool _isVoiceAssistant = true;
  bool _isNotifications = true;

  static const primaryTurquoise = Color(0xFF169086);
  static const lightCardBg = Color(0xFFEDF1F6);
  static const buttonBg = Color(0xFFE2E8F0);
  static const mainText = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildPageTheme(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<FamilyCubit, FamilyState>(
          // استماع لنتائج عمليات الحفظ (إضافة القراءة)
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
            backgroundColor: primaryTurquoise,
            body: Stack(
              children: [
                _buildHeader(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: const BoxDecoration(
                      color: lightCardBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(Theme.of(context)),
                          const SizedBox(height: 25),
                          Text(
                            'الاضافات:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildPageTheme() {
    return ThemeData(
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTurquoise,
        primary: primaryTurquoise,
        surface: lightCardBg,
        onSurface: mainText,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: const Color(0xFF555555),
          side: const BorderSide(color: primaryTurquoise, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryTurquoise;
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryTurquoise.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 15),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                String image = 'https://i.pravatar.cc/150?img=11';
                String name = 'جاري التحميل...';
                String email = '';

                if (state is UserLoaded) {
                  name = state.userModel.fullName;
                  email = state.userModel.email;
                  if (state.userModel.profileImage != null &&
                      state.userModel.profileImage!.isNotEmpty) {
                    image = state.userModel.profileImage!;
                  }
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(image),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String disease = '...';
        String year = '...';

        if (state is UserLoaded && state.userModel is PatientModel) {
          final patient = state.userModel as PatientModel;
          disease = patient.diseaseType;
          year = patient.diagnosisYear ?? 'غير محدد';
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn("نوع الامراض:", disease, theme),
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              _buildInfoColumn('سنة التشخيص:', year, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String title, String value, ThemeData theme) {
    return Column(
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    final List<Map<String, dynamic>> buttons = [
      {
        'text': 'اضافة قراءة يدوية',
        'action': () {
          if (userId != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddVitalsSheet(patientId: userId),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطأ: لم يتم العثور على بيانات المستخدم'),
              ),
            );
          }
        },
      },
      {
        'text': 'اضافة او تعديل اوقات الصيام',
        'action': () {
          print('تعديل أوقات الصيام');
        },
      },
      {'text': 'تسجيل الخروج', 'action': _onLogoutPressed},
    ];

    return Column(
      children: buttons
          .map(
            (btn) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: Icon(
                  btn['text'].contains('خروج')
                      ? Icons.logout
                      : Icons.add_circle_outline,
                  color: btn['text'].contains('خروج')
                      ? Colors.red
                      : primaryTurquoise,
                ),
                title: Text(
                  btn['text'],
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    color: btn['text'].contains('خروج')
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: btn['action'],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _onLogoutPressed() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل تريد تسجيل الخروج؟',
            style: GoogleFonts.tajawal(color: Colors.grey[700]),
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
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<UserCubit>().clearUserData();
      await SharedPrefHelper.clearLoginData();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  // دالة لإظهار نافذة إعدادات الصيام
  void _showFastingBottomSheet(BuildContext context) async {
    // تحميل البيانات المحفوظة
    TimeOfDay? savedStartTime = await SharedPrefHelper.getFastingStartTime();
    int savedDuration = await SharedPrefHelper.getFastingDuration();

    TimeOfDay selectedTime = savedStartTime ?? TimeOfDay.now();
    int selectedDuration = savedDuration;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final endTime = _calculateEndTime(selectedTime, selectedDuration);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'تتبع ساعات الصيام',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // ✅ التصحيح هنا: حذفنا PatientProfilePage.
                      color: primaryTurquoise,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- القسم الأول: وقت البدء ---
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                // ✅ التصحيح هنا أيضاً
                                primary: primaryTurquoise,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.watch_later_outlined,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'بدأت الصيام الساعة:',
                                style: GoogleFonts.tajawal(),
                              ),
                            ],
                          ),
                          Text(
                            selectedTime.format(context),
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              // ✅ وهنا
                              color: primaryTurquoise,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- القسم الثاني: المدة ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مدة الصيام:',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$selectedDuration ساعات',
                        style: GoogleFonts.tajawal(
                          // ✅ وهنا
                          color: primaryTurquoise,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 6,
                    max: 16,
                    divisions: 10,
                    // ✅ وهنا
                    activeColor: primaryTurquoise,
                    inactiveColor: Colors.grey[200],
                    onChanged: (double value) {
                      setSheetState(() {
                        selectedDuration = value.toInt();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // --- القسم الثالث: النتيجة ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'سينتهي صيامك عند الساعة',
                          style: GoogleFonts.tajawal(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          endTime.format(context),
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- زر الحفظ ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // ✅ وهنا
                        backgroundColor: primaryTurquoise,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await SharedPrefHelper.saveFastingData(
                          selectedTime,
                          selectedDuration,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم حفظ وقت الصيام بنجاح',
                              style: GoogleFonts.tajawal(),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'حفظ التذكير',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TimeOfDay _calculateEndTime(TimeOfDay start, int durationHours) {
    int totalMinutes = (start.hour * 60) + start.minute + (durationHours * 60);

    // التعامل مع تجاوز منتصف الليل (24 ساعة)
    int finalMinutes = totalMinutes % (24 * 60);

    return TimeOfDay(hour: finalMinutes ~/ 60, minute: finalMinutes % 60);
  }
}
