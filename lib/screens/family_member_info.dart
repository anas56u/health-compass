import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/screens/user_type.dart';
import 'package:health_compass/widgets/custom_textfild.dart';
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
                        " :الربط مع افراد الاسرة",
                        style: GoogleFonts.tajawal(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "هل ترغب بربط حسابك مع احد عائلتك؟",
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 156),
                        child: Row(
                          children: [
                            Text(
                              "لا",
                              style: GoogleFonts.tajawal(fontSize: 13),
                            ),
                            Radio(value: true),
                            const SizedBox(width: 25),
                            Text(
                              "نعم",
                              style: GoogleFonts.tajawal(fontSize: 13),
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
                          "رقم الهاتف للمتابع",
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
