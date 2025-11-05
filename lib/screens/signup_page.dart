import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/screens/login_page.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:health_compass/widgets/custom_text.dart';
import 'package:health_compass/widgets/custom_textfild.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class signup_page extends StatefulWidget {
  const signup_page({super.key});

  @override
  State<signup_page> createState() => _signup_pageState();
}

class _signup_pageState extends State<signup_page> {
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

                        Text(
                          "انشاء حساب",
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
                        const SizedBox(height: 17),
                        CustomText(text: "كلمه المرور", size: 10),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "ادخل كلمة المرور",
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        const SizedBox(height: 17),
                       CustomText(
                          text: "تأكيد كلمة المرور",
                          size: 10,
                        ),
                        SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "تاكيد كلمه المرور   ",
                          onChanged: (value) {
                            confirmPassword = value;
                          },
                        ),
                        const SizedBox(height: 24),

                        custom_button(
                          buttonText: "انشاء حساب",
                          onPressed: () async {
                            if (confirmPassword == password) {
                              if (formkey.currentState != null &&
                                  formkey.currentState!.validate()) {
                                isloading = true;
                                setState(() {});
                                try {
                                  await regester();
                                  showsnackbar(context, massage: "regesterd");
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
                                }
                                isloading = false;
                                setState(() {});
                              }
                            } else {
                              showsnackbar(
                                context,
                                massage: "كلمة المرور غير متطابقة",
                              );
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
                                    builder: (context) => login_page(),
                                  ),
                                );
                              },
                              child: Text(
                                "سجّل الدخول الآن",
                                style: GoogleFonts.cairo(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "هل لديك حساب؟",
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
