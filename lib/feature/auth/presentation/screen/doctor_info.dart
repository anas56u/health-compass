import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class DoctorInfoScreen extends StatelessWidget {
  DoctorInfoScreen({super.key});
  String? fullName;

  String? phoneNumber;

  String? specialization;

  String? licenseNumber;

  String? experienceYears;

  void _pickImage() {
    print("اضغط لإضافة صورة");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 280),
                        child: BackButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserType(),
                              ),
                            );
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
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        initialCountryCode: 'JO',
                        textAlign: TextAlign.left,
                        style: const TextStyle(color: Colors.black),
                        dropdownTextStyle: const TextStyle(color: Colors.black),
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
                        hinttext: "ادخل اسم التخصص",
                        onChanged: (value) {
                          fullName = value;
                        },
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
                        onChanged: (value) {
                          fullName = value;
                        },
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
                        onChanged: (value) {
                          fullName = value;
                        },
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
                        onChanged: (value) {
                          fullName = value;
                        },
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
                        onChanged: (value) {
                          fullName = value;
                        },
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorInfoScreen(),
                            ),
                          );
                        },
                        child: custom_button(
                          buttonText: 'تأكيد',
                          width: 150,
                          onPressed: () {
                            if (fullName == null ||
                                phoneNumber == null ||
                                specialization == null ||
                                licenseNumber == null ||
                                experienceYears == null) {
                              showsnackbar(
                                context,
                                massage: "يرجى تعبئة جميع الحقول قبل المتابعة",
                              );
                            } else {
                              showsnackbar(
                                context,
                                massage: "تم حفظ معلومات الطبيب بنجاح",
                              );
                            }
                          },
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
