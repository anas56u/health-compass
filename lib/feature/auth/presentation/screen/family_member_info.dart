import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class FamilyMemberInfoScreen extends StatelessWidget {
  FamilyMemberInfoScreen({super.key});
  String? fullName, phoneNumber;
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
                      Row(
                        children: [
                          BackButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserType(),
                                ),
                              );
                            },
                          ),
                          skipButton(context),
                        ],
                      ),
                      Text(
                        ":الربط مع افراد الاسرة",
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "اربط حسابك مع من يحبك لمتابعة حالتك الصحية",
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "هل ترغب بربط حسابك مع احد عائلتك؟",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: Row(
                          children: [
                            Text(
                              "لا",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: true),
                            const SizedBox(width: 25),

                            Text(
                              "نعم",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: false),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "الاسم الكامل للمتابع",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextfild(
                        hinttext: "ادخل الإسم بالكامل",
                        onChanged: (value) {
                          fullName = value;
                        },
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "رقم الهاتف للمتابع",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                              width: 1.5,
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
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "ماهي صله القرابه بينكم؟",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "ابن/ ـة",
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Radio(value: true),
                          const SizedBox(width: 25),
                          Text(
                            "أم",
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Radio(value: false),
                          const SizedBox(width: 25),

                          Text(
                            "أب",
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Radio(value: false),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Row(
                          children: [
                            Text(
                              "قريب",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: true),
                            const SizedBox(width: 25),

                            Text(
                              "مقدم رعاية",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: false),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          ":الصلاحية المتاحة",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: Row(
                          children: [
                            Text(
                              "عرض تقارير فقط",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: true),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 114),
                        child: Row(
                          children: [
                            Text(
                              "متابعة تفاعلية",
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Radio(value: false),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Patientview_body(),
                            ),
                          );
                        },
                        child: custom_button(
                          buttonText: 'تأكيد',
                          width: 150,
                          onPressed: () {
                            if (fullName == null || phoneNumber == null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Patientview_body(),
                                ),
                              );
                            }
                          },
                        ),
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

Padding skipButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 155),
    child: Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Patientview_body()),
            );
          },
          child: Text(
            'تخطي',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
