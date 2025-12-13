import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart';
import 'package:health_compass/feature/auth/presentation/screen/user_type.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  String? fullName;
  String? phoneNumber;
  String? diagnosisYear;
  String? specificDiseaseName;
  String? selectedDisease;

  bool? isTakingMeds;
  bool? hasOtherIssues;
  bool isLoading = false;

  Future<void> sendDataToFirebase() async {
    if (fullName == null || phoneNumber == null || selectedDisease == null) {
      showsnackbar(context, massage: "يرجى ملء كافة الحقول الأساسية");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        showsnackbar(context, massage: "يرجى تسجيل الدخول أولاً");
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> patientData = {
        'uid': currentUser.uid,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'disease_type': selectedDisease,
        'diagnosis_year': diagnosisYear,
        'specific_disease': specificDiseaseName,
        'is_taking_meds': isTakingMeds,
        'has_other_issues': hasOtherIssues,
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('patients').add(patientData);

      showsnackbar(context, massage: "تم حفظ بيانات المريض بنجاح");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FamilyMemberInfoScreen()),
        );
      }
    } catch (e) {
      showsnackbar(context, massage: "حدث خطأ: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        // زر الرجوع
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
                          "تسجيل مريض جديد",
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
                            fillColor: const Color(0xFFF5F9FC),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                          initialCountryCode: 'JO',
                          onChanged: (phone) {
                            phoneNumber = phone.completeNumber;
                          },
                        ),
                        const SizedBox(height: 17),

                        // نوع المرض (Dropdown)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "نوع المرض",
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FC),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFDAE3EA),
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDisease,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                              hint: Text(
                                "اختيار نوع المرض",
                                style: GoogleFonts.tajawal(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              items:
                                  [
                                    'الضغط',
                                    'السكري',
                                    'أمراض القلب',
                                    'الكوليسترول',
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.tajawal(
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedDisease = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        // الأدوية (Radio)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "هل تقوم بأخذ اي ادوية؟",
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "لا",
                                style: GoogleFonts.tajawal(fontSize: 13),
                              ),
                              Radio<bool>(
                                value: false,
                                groupValue: isTakingMeds,
                                activeColor: const Color(0xFF41BFAA),
                                onChanged: (val) =>
                                    setState(() => isTakingMeds = val),
                              ),
                              const SizedBox(width: 25),
                              Text(
                                "نعم",
                                style: GoogleFonts.tajawal(fontSize: 13),
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: isTakingMeds,
                                activeColor: const Color(0xFF41BFAA),
                                onChanged: (val) =>
                                    setState(() => isTakingMeds = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 17),

                        // سنة التشخيص
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "سنة تشخيص المرض",
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "ادخل سنة التشخيص",
                          onChanged: (value) {
                            diagnosisYear = value;
                          },
                        ),
                        const SizedBox(height: 24),

                        // اذكرها
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "اذكرها",
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextfild(
                          hinttext: "اذكرها",
                          onChanged: (value) {
                            specificDiseaseName = value;
                          },
                        ),
                        const SizedBox(height: 17),

                        // مشاكل أخرى (Radio)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "هل تعاني من مشكلات صحيه أخرى؟",
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "لا",
                                style: GoogleFonts.tajawal(fontSize: 13),
                              ),
                              Radio<bool>(
                                value: false,
                                groupValue: hasOtherIssues,
                                activeColor: const Color(0xFF41BFAA),
                                onChanged: (val) {
                                  setState(() {
                                    hasOtherIssues = val;
                                  });
                                },
                              ),

                              const SizedBox(width: 25),
                              Text(
                                "نعم",
                                style: GoogleFonts.tajawal(fontSize: 13),
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: hasOtherIssues,
                                activeColor: const Color(0xFF41BFAA),
                                onChanged: (val) {
                                  setState(() {
                                    hasOtherIssues = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // زر التأكيد
                        GestureDetector(
                          onTap: sendDataToFirebase,
                          child: custom_button(
                            buttonText: 'تأكيد',
                            width: 150,
                            onPressed: sendDataToFirebase,
                          ),
                        ),
                        const Divider(
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
  }
}

void showsnackbar(BuildContext context, {required String massage}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(massage, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
    ),
  );
}
