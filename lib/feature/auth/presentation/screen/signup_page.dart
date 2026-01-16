import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/routes/routes.dart'; // ✅ تأكد من الاستيراد
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/core/widgets/custom_text.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// ✅ تغيير الاسم ليتوافق مع معايير فلاتر
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String email = "";
  String password = "";
  String confirmPassword = "";

  // متغيرات للتحكم في الإخفاء والإظهار
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(
          color: Color(0xFF41BFAA),
        ),
        inAsyncCall: isloading,
        child: Scaffold(
          // ✅ استبدلت CustomScaffold بـ Scaffold لضمان العمل إذا لم يكن CustomScaffold موجوداً
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF41BFAA), Color(0xFF2D82B5)],
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                CustomTextfild(
                                  hinttext: "ادخل كلمة المرور",
                                  obscureText: !_isPasswordVisible,
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
                                  obscureText: !_isConfirmPasswordVisible,
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
                                      // ✅ الانتقال لصفحة اختيار النوع مع تمرير البيانات
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

                            // ... (أزرار جوجل وغيرها يمكن أن تبقى كما هي) ...
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
                                    // ✅ استخدام المسار الموحد لتسجيل الدخول
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
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
