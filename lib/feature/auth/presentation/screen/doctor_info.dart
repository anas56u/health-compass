import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_state.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DoctorInfoScreen extends StatefulWidget {
  const DoctorInfoScreen({
    super.key,
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  // البيانات
  String? fullName;
  String? phoneNumber;
  String? specialization;
  String? licenseNumber;
  String? experienceYears;
  String? clinicLocation;
  String? hospitalName;
  File? _profileImage;

  // الثوابت
  final Color primaryColor = const Color(0xFF41BFAA);

  // دالة اختيار الصورة
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // دالة التسجيل
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
      listener: (context, state) {
        if (state is SignupSuccess) {
          showsnackbar(context, massage: "تم إنشاء حساب الطبيب بنجاح");
          Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
        } else if (state is SignupFailure) {
          showsnackbar(context, massage: state.error);
        }
      },
      builder: (context, state) {
        bool isLoading = state is SignupLoading;
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(color: primaryColor),
          child: Directionality(
            textDirection: TextDirection.rtl, // ضمان الاتجاه العربي
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ
              appBar: AppBar(
                backgroundColor: const Color(0xFFF5F7FA),
                elevation: 0,
                leading: const BackButton(color: Colors.black),
                title: Text(
                  "بيانات الطبيب",
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- قسم الصورة الشخصية ---
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[400],
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          _profileImage == null
                              ? "إضافة صورة شخصية"
                              : "تغيير الصورة",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- المعلومات الشخصية ---
                      _buildSectionTitle("المعلومات الشخصية"),
                      _buildLabel("الاسم الكامل"),
                      CustomTextfild(
                        hinttext: "د. محمد أحمد",
                        onChanged: (value) => fullName = value,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("رقم الهاتف"),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "79xxxxxxx",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        initialCountryCode: 'JO',
                        textAlign: TextAlign.right,
                        languageCode: "ar",
                        onChanged: (phone) =>
                            phoneNumber = phone.completeNumber,
                      ),

                      const SizedBox(height: 30),

                      // --- المعلومات المهنية ---
                      _buildSectionTitle("المعلومات المهنية"),

                      _buildLabel("التخصص"),
                      CustomTextfild(
                        hinttext: "مثال: باطنية، قلب",
                        onChanged: (value) => specialization = value,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("رقم الترخيص"),
                      CustomTextfild(
                        hinttext: "12345",
                        onChanged: (value) => licenseNumber = value,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("سنوات الخبرة"),
                      CustomTextfild(
                        hinttext: "مثال: 5",
                        onChanged: (value) => experienceYears = value,
                      ),

                      const SizedBox(height: 30),

                      // --- معلومات العيادة ---
                      _buildSectionTitle("معلومات العيادة"),

                      _buildLabel("مكان العيادة"),
                      CustomTextfild(
                        hinttext: "المدينة، الشارع",
                        onChanged: (value) => clinicLocation = value,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("اسم المستشفى (إن وجد)"),
                      CustomTextfild(
                        hinttext: "مستشفى...",
                        onChanged: (value) => hospitalName = value,
                      ),

                      const SizedBox(height: 40),

                      // --- زر التأكيد ---
                      Center(
                        child: custom_button(
                          buttonText: 'تأكيد التسجيل',
                          width: double.infinity,
                          onPressed: () => _registerDoctor(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- دوال مساعدة لبناء الواجهة ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const Divider(thickness: 1, height: 10),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

void showsnackbar(BuildContext context, {required String massage}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(massage, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
