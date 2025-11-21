import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/themes/font_weight_helper.dart';
import 'package:health_compass/core/widgets/custom_scaffold.dart';
import 'package:health_compass/feature/auth/di/auth_di.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/login_cubit.dart';
import 'package:health_compass/screens/PatientView_body.dart';
import 'package:health_compass/screens/signup_page.dart';
import 'package:health_compass/widgets/custom_button.dart';
import 'package:health_compass/widgets/custom_text.dart';
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
            ),
          );
          // Navigate to home screen after successful login
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Patientview_body(),
              ),
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
            ),
          );
        }
      },
      child: CustomScaffold(
        backgroundColor: AppColors.primary,
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/images/logo.jpeg", height: 110),
                        const SizedBox(height: 3),
                        Text(
                          "تسجيل الدخول",
                          style: AppTextStyling.fontFamilyTajawal.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeightHelper.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          "مرحبا بك في تطبيق بوصلة الصحة",
                          style: AppTextStyling.fontFamilyTajawal,
                        ),
                        const SizedBox(height: 20),
                        const CustomText(text: "البريد الالكتروني", size: 10),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          controller: _emailController,
                          hinttext: "ادخل البريد الالكتروني",
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 38),
                        const CustomText(text: "كلمه المرور", size: 10),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          controller: _passwordController,
                          hinttext: "ادخل كلمة المرور",
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgetPasswordView,
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
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF2EC8C8),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading = state is LoginLoading;
                            return custom_button(
                              buttonText: isLoading
                                  ? "جاري تسجيل الدخول..."
                                  : "تسجيل الدخول",
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<LoginCubit>().login(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text
                                              .trim(),
                                        );
                                      }
                                    },
                            );
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
                        const SizedBox(height: 17),
                        const Divider(
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
                                    builder: (context) => const signup_page(),
                                  ),
                                );
                              },
                              child: Text(
                                "سجّل الآن",
                                style: AppTextStyling.fontFamilyTajawal
                                    .copyWith(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                            Text(
                              " ليس لديك حساب؟ ",
                              style: AppTextStyling.fontFamilyTajawal.copyWith(
                                color: Colors.grey[700],
                                fontSize: 12,
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
    );
  }
}
