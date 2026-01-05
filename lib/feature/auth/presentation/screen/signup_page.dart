import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/core/widgets/custom_text.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:google_sign_in/google_sign_in.dart';

class signup_page extends StatefulWidget {
  const signup_page({super.key});

  @override
  State<signup_page> createState() => _signup_pageState();
}

class _signup_pageState extends State<signup_page> {
  String email = "";
  String password = "";
  String confirmPassword = "";

  // متغيرات للتحكم في الأيقونة فقط (بما أننا لن نعدل الـ CustomTextfild)
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    // 1. إغلاق لوحة المفاتيح عند الضغط في أي مكان
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(
          color: Color(0xFF41BFAA),
        ),
        inAsyncCall: isloading,
        child: CustomScaffold(
          // جعل خلفية السكافولد شفافة للسماح بظهور التدرج
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // 2. الخلفية المتدرجة (Gradient)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF41BFAA), // اللون الأساسي
                  Color(0xFF2D82B5), // تدرج أغمق
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    // 3. البطاقة البيضاء العائمة
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // حواف دائرية ناعمة
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // ظل هادئ
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // الشعار
                            Image.asset("assets/images/logo.jpeg", height: 100),

                            const SizedBox(height: 10),

                            Text(
                              "انشاء حساب",
                              style: GoogleFonts.tajawal(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "مرحبا بك في تطبيق بوصلة الصحة",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // === البريد الإلكتروني ===
                            const Align(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "البريد الالكتروني",
                                size: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextfild(
                              hinttext: "ادخل البريد الالكتروني",
                              onChanged: (value) {
                                email = value;
                              },
                            ),

                            const SizedBox(height: 16),

                            // === كلمة المرور ===
                            const Align(
                              alignment: Alignment.centerRight,
                              child: CustomText(text: "كلمه المرور", size: 12),
                            ),
                            const SizedBox(height: 8),
                            // استخدام Stack لوضع الأيقونة فوق الحقل دون تغيير الكود الداخلي للحقل
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                CustomTextfild(
                                  hinttext: "ادخل كلمة المرور",
                                  onChanged: (value) {
                                    password = value;
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF41BFAA),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // === تأكيد كلمة المرور ===
                            const Align(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "تأكيد كلمة المرور",
                                size: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                CustomTextfild(
                                  hinttext: "تاكيد كلمه المرور",
                                  onChanged: (value) {
                                    confirmPassword = value;
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF41BFAA),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: custom_button(
                                buttonText: "انشاء حساب",
                                onPressed: () async {
                                  if (confirmPassword == password) {
                                    if (formkey.currentState != null &&
                                        formkey.currentState!.validate()) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.userType,
                                        arguments: {
                                          'email': email.trim(),
                                          'password': password.trim(),
                                        },
                                      );
                                    }
                                  } else {
                                    showsnackbar(
                                      context,
                                      massage: "كلمات المرور غير متطابقة",
                                    );
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 4. زر جوجل التفاعلي الجديد
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Add Google Logic
                                print("Google Clicked");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                surfaceTintColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                overlayColor: Colors.grey.shade100,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/google.png",
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "تابع باستخدام Google",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                              indent: 20,
                              endIndent: 20,
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
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
                                const SizedBox(width: 5),
                                Text(
                                  "هل لديك حساب؟",
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey[700],
                                  ),
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
        ),
      ),
    );
  }

  void showsnackbar(BuildContext context, {required String massage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(massage, style: GoogleFonts.tajawal(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

 
}
