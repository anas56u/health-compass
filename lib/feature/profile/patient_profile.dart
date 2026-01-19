import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';

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
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
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
    final List<Map<String, dynamic>> buttons = [
      {
        'text': 'اضافة قراءة يدوية',
        'action': () {
          print('إضافة قراءة يدوية');
        }
      },
     
      {
        'text': 'اضافة او تعديل اوقات الصيام',
        'action': () {
          print('تعديل أوقات الصيام');
        }
      },
      {
        'text': 'تسجيل الخروج',
        'action': _onLogoutPressed,
      },
    ];

    return Column(
      children: buttons.map((btn) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: btn['action'] as VoidCallback,
            child: Text(btn['text'] as String),
          ),
        );
      }).toList(),
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
        (route) => false
      );
    }
  }

  

 
}