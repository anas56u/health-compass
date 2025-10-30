import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/screens/login_page.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:health_compass/widgets/custom_textfild.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class register_page extends StatefulWidget {
  const register_page({super.key});

  @override
  State<register_page> createState() => _register_pageState();
}

class _register_pageState extends State<register_page> {
  String email = "";

  String password = "";

  String confirmPassword = "";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

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
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        Container(
                          width: 300,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 15),
                        Container(
                          width: 300,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 15),
                        Container(
                          width: 300,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 35),
                        custom_button(buttonText: 'متابعة', width: 200),
                      ],
                    ),
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

  Future<void> regester() async {
    UserCredential user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }
}
