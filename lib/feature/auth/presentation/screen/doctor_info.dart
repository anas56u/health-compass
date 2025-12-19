import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_state.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DoctorInfoScreen extends StatefulWidget {
  DoctorInfoScreen({super.key, required this.email, required this.password});
  final String email;
  final String password;

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  String? fullName;
  String? phoneNumber;
  String? specialization;
  String? licenseNumber;
  String? experienceYears;
  String? clinicLocation;
  String? hospitalName;
  bool isLoading = false;

  void _pickImage() {
    print("اضغط لإضافة صورة");
  }

  void _registerDoctor(BuildContext context) {
    if (fullName == null || fullName!.isEmpty) {
      showsnackbar(context, massage: "يرجى إدخال الاسم الكامل");
      return;
    }
    if (phoneNumber == null) {
      showsnackbar(context, massage: "يرجى إدخال رقم الهاتف");
      return;
    }
    if (specialization == null || specialization!.isEmpty) {
      showsnackbar(context, massage: "يرجى إدخال التخصص");
      return;
    }
    if (licenseNumber == null || licenseNumber!.isEmpty) {
      showsnackbar(context, massage: "يرجى إدخال رقم الترخيص");
      return;
    }

    final newDoctor = DoctorModel(
      uid: '',
      email: widget.email,
      fullName: fullName!,
      phoneNumber: phoneNumber!,
      createdAt: DateTime.now(),
      specialization: specialization!,
      licenseNumber: licenseNumber!,
      experienceYears: experienceYears ?? '',
      clinicLocation: clinicLocation ?? '',
      hospitalName: hospitalName ?? '',
    );

    context.read<SignupCubit>().registerUser(
      userModel: newDoctor,
      password: widget.password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {if (state is SignupSuccess) {
          showsnackbar(context, massage: "تم إنشاء حساب الطبيب بنجاح");
          
          
          Navigator.pushReplacementNamed(context, AppRoutes.patientHome); 
        } else if (state is SignupFailure) {
          showsnackbar(context, massage: state.error);
        }
      
      },
      builder: (context, state) {
        isLoading = state is SignupLoading;
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CircularProgressIndicator(
            color: Color(0xFF41BFAA),
          ),
          child: CustomScaffold(
            backgroundColor: const Color(0xFFE0E7EC),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 280),
                              child: BackButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Text(
                              "تسجيل طبيب جديد",
                              style: GoogleFonts.tajawal(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 7),
                            GestureDetector(
                              onTap: () {
                                showsnackbar(
                                  context,
                                  massage: "this feutere coming soon",
                                );
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(
                                  0xFF41BFAA,
                                ).withOpacity(0.2),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "اضغط لإضافة صورة شخصية",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),

                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "الإسم الكامل",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل إسمك الكامل",
                              onChanged: (value) {
                                fullName = value;
                              },
                            ),
                            const SizedBox(height: 17),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "رقم الهاتف",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            IntlPhoneField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF5F9FC),
                                hintText: "ادخل رقم الهاتف",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF41BFAA),
                                    width: 1.8,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                  ),
                                ),
                              ),
                              initialCountryCode: 'JO',
                              textAlign: TextAlign.left,
                              style: const TextStyle(color: Colors.black),
                              dropdownTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              onChanged: (phone) {
                                phoneNumber = phone.completeNumber;
                              },
                            ),
                            const SizedBox(height: 17),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "التخصص",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل التخصص",
                              onChanged: (value) => specialization = value,
                            ),

                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "رقم الترخيص",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل رقم الترخيص",
                              onChanged: (value) => licenseNumber = value,
                            ),

                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "سنوات الخبرة",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل عدد سنوات الخبرة",
                              onChanged: (value) => experienceYears = value,
                            ),

                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "مكان العيادة",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل مكان العيادة",
                              onChanged: (value) => clinicLocation = value,
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "اسم المستشفى",
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextfild(
                              hinttext: "ادخل اسم المستشفى",
                              onChanged: (value) => hospitalName = value,
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _registerDoctor(context),
                              child: custom_button(
                                onPressed: () => _registerDoctor(context),
                                buttonText: 'تأكيد',
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                              height: 40,
                              indent: 20,
                              endIndent: 20,
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
      },
    );
  }
}

void showsnackbar(BuildContext context, {required String massage}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(massage, style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
    ),
  );
}
