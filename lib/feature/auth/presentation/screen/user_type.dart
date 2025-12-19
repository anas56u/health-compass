import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/presentation/screen/doctor_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/patient_info.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UserType extends StatefulWidget {
  final String email;
  final String password;
  const UserType({super.key, required this.email, required this.password});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  String? selectedUserType;

  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: const Color(0xFFE0E7EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 65),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset("assets/images/logo.jpeg", height: 110),
                    Row(
                      children: [
                        Text(
                          "       Health Compass ",
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "أهلاً بك في",
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "دعنا ننشىء تجربة صحية مخصصة لك",
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        ":أنا أكون",
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedUserType = "مريض";
                        });
                      },

                      child: Container(
                        width: 300,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: selectedUserType == "مريض"
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF1CA9A9).withOpacity(0.3),
                                    const Color(0xFF006C6C).withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.blueGrey.shade50,
                                    Colors.blueGrey.shade50,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selectedUserType == "مريض"
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                          border: selectedUserType == "مريض"
                              ? Border.all(
                                  color: const Color(0xFF1CA9A9),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            Icon(Icons.personal_injury),
                            Text(
                              "مريض",
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "تتبع صحتي وإدارة الأدوية",
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedUserType = "طبيب";
                        });
                      },
                      child: Container(
                        width: 300,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: selectedUserType == "طبيب"
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF1CA9A9).withOpacity(0.3),
                                    const Color(0xFF006C6C).withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.blueGrey.shade50,
                                    Colors.blueGrey.shade50,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selectedUserType == "طبيب"
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                          border: selectedUserType == "طبيب"
                              ? Border.all(
                                  color: const Color(0xFF1CA9A9),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            Icon(Icons.person_3),
                            Text(
                              'طبيب',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'مراقبة المريض وتقديم الرعاية',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedUserType = "فرد من العائلة";
                        });
                      },
                      child: Container(
                        width: 300,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: selectedUserType == "فرد من العائلة"
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF1CA9A9).withOpacity(0.3),
                                    const Color(0xFF006C6C).withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.blueGrey.shade50,
                                    Colors.blueGrey.shade50,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selectedUserType == "فرد من العائلة"
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                          border: selectedUserType == "فرد من العائلة"
                              ? Border.all(
                                  color: const Color(0xFF1CA9A9),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            Icon(Icons.family_restroom_rounded),
                            Text(
                              'فرد من العائلة',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'تابع تقدم صحتك مع من تحب',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    custom_button(
                      buttonText: 'متابعة',
                      width: 200,
                      onPressed: selectedUserType != null
                          ? () {
                              if (selectedUserType == "مريض") {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.patientInfo,
                                  arguments: {
                                    'email': widget.email,
                                    'password': widget.password,
                                  },
                                );
                              } else if (selectedUserType == "طبيب") {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.doctorInfo,
                                  arguments: {
                                    'email': widget.email,
                                    'password': widget.password,
                                  },
                                );
                              } else if (selectedUserType == "فرد من العائلة") {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.familyMemberInfo,
                                  arguments: {
                                    'email': widget.email,
                                    'password': widget.password,
                                  },
                                );
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
