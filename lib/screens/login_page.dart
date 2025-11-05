import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/screens/forgotpass_page.dart';
import 'package:health_compass/screens/signup_page.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:health_compass/widgets/custom_text.dart';
import 'package:health_compass/widgets/custom_textfild.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class login_page extends StatefulWidget {
  login_page({super.key});

  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String email = "";

  String password = "";

  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isloading,
      progressIndicator: const CircularProgressIndicator(
        color: Color(0xFF41BFAA),
      ),

      child: Scaffold(
        backgroundColor: const Color(0xFF41BFAA),
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
                        const SizedBox(height: 3),
                        Text(
                          "تسجيل الدخول",
                          style: GoogleFonts.tajawal(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          "مرحبا بك في تطبيق بوصلة الصحة",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomText(
                          text: "البريد الالكتروني",
                          size: 10,
                        ),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "ادخل البريد الالكتروني",
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        const SizedBox(height: 38),
                        CustomText(
                          text: "كلمه المرور",
                          size: 10,
                        ),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "ادخل كلمة المرور",
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "نسيت كلمة المرور؟",
                                style: GoogleFonts.cairo(
                                  color: Colors.teal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "تذكّرني",
                                  style: GoogleFonts.cairo(fontSize: 14),
                                ),
                                Checkbox(
                                  value: false,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF2EC8C8),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        custom_button(
                          buttonText: "تسجيل الدخول",
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              isloading = true;
                              setState(() {});
                              try {
                                await Login();
                                showsnackbar(context, massage: "Login success");
                              } on FirebaseAuthException catch (e) {
                                if (e.code == "weak-password") {
                                  showsnackbar(
                                    context,
                                    massage:
                                        "The password provided is too weak.",
                                  );
                                } else if (e.code == "email-already-in-use") {
                                  showsnackbar(
                                    context,
                                    massage:
                                        "The account already exists for that email.",
                                  );
                                }

                                showsnackbar(context, massage: e.code);
                                print(e);
                              }
                              isloading = false;
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 0.8,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/google.png",
                                height: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Google تابع باستخدام ",
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 17),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          height: 40,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => signup_page(),
                                  ),
                                );
                              },
                              child: Text(
                                "سجّل الآن",
                                style: GoogleFonts.cairo(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "ليس لديك حساب؟ ",
                              style: GoogleFonts.cairo(color: Colors.grey[700]),
                            ),
                          ],
                        ),
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

  Future<void> Login() async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
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
