import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/screens/doctor_info.dart';
import 'package:health_compass/screens/family_member_info.dart';
import 'package:health_compass/screens/patient_info.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UserType extends StatefulWidget {
  const UserType({super.key});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  String? selectedUserType;

  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: const CircularProgressIndicator(
        color: Color(0xFF41BFAA),
      ),

      inAsyncCall: isloading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 218, 218, 218),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 65,
                ),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientInfoScreen(),
                                    ),
                                  );
                                } else if (selectedUserType == "طبيب") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorInfoScreen(),
                                    ),
                                  );
                                } else if (selectedUserType ==
                                    "فرد من العائلة") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FamilyMemberInfoScreen(),
                                    ),
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
      ),
    );
  }

  void showsnackbar(BuildContext context, {required String massage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(massage, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
    );
  }
}
