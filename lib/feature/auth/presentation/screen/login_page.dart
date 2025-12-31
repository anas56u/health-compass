import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/themes/font_weight_helper.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/core/widgets/custom_scaffold.dart';
import 'package:health_compass/core/widgets/custom_text.dart';
import 'package:health_compass/feature/auth/di/auth_di.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/login_cubit.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/feature/auth/presentation/screen/signup_page.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthDI.loginCubit,
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  // متغير لإظهار/إخفاء كلمة المرور
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating, // تحسين مظهر السناك بار
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Patientview_body()),
            );
          });
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      // 1. إغلاق الكيبورد عند الضغط في الفراغ
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScaffold(
          // جعل الخلفية شفافة للسماح بظهور التدرج (إذا كان CustomScaffold يدعم ذلك)
          // إذا لم يدعم، سيعمل التدرج داخل الـ Container فقط
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // 2. الخلفية المتدرجة
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF41BFAA), // اللون الأساسي (Teal)
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/images/logo.jpeg", height: 100),

                            const SizedBox(height: 10),

                            Text(
                              "تسجيل الدخول",
                              style: AppTextStyling.fontFamilyTajawal.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeightHelper.bold,
                                color: AppColors.textDark,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "مرحبا بك في تطبيق بوصلة الصحة",
                              style: AppTextStyling.fontFamilyTajawal.copyWith(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // البريد الإلكتروني
                            const Align(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "البريد الالكتروني",
                                size: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextfild(
                              controller: _emailController,
                              hinttext: "ادخل البريد الالكتروني",
                              onChanged: (value) {},
                            ),

                            const SizedBox(height: 20),

                            // كلمة المرور
                            const Align(
                              alignment: Alignment.centerRight,
                              child: CustomText(text: "كلمه المرور", size: 12),
                            ),
                            const SizedBox(height: 8),
                            // Stack لوضع أيقونة العين فوق الـ CustomTextfild
                            Stack(
                              alignment:
                                  Alignment.centerLeft, // الأيقونة لليسار
                              children: [
                                CustomTextfild(
                                  controller: _passwordController,
                                  hinttext: "ادخل كلمة المرور",
                                  // ⚠️ تأكد أن CustomTextfild يدعم obscureText
                                  // obscureText: !_isPasswordVisible,
                                  onChanged: (value) {},
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF41BFAA),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // نسيت كلمة المرور & تذكرني
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.forgetPassword,
                                    );
                                  },
                                  child: Text(
                                    "نسيت كلمة المرور؟",
                                    style: GoogleFonts.cairo(
                                      color: Colors.teal,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "تذكّرني",
                                      style: GoogleFonts.cairo(fontSize: 13),
                                    ),
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF2EC8C8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // زر تسجيل الدخول (باستخدام Cubit)
                            BlocBuilder<LoginCubit, LoginState>(
                              builder: (context, state) {
                                final isLoading = state is LoginLoading;
                                return custom_button(
                                  width: double.infinity,
                                  buttonText: isLoading
                                      ? "جاري تسجيل الدخول..."
                                      : "تسجيل الدخول",
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<LoginCubit>().login(
                                              email: _emailController.text
                                                  .trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            );
                                          }
                                        },
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // زر جوجل (التصميم الجديد المحسن)
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Google Sign In Logic
                                print("Google Sign In");
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

                            // رابط التسجيل
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const signup_page(), // تأكد من اسم الكلاس الصحيح (SignupPage أو signup_page)
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "سجّل الآن",
                                    style: AppTextStyling.fontFamilyTajawal
                                        .copyWith(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                  ),
                                ),
                                Text(
                                  " ليس لديك حساب؟ ",
                                  style: AppTextStyling.fontFamilyTajawal
                                      .copyWith(
                                        color: Colors.grey[700],
                                        fontSize: 13,
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
}
