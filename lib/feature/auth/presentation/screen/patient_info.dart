import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({
    super.key,
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  // البيانات
  String? fullName;
  String? phoneNumber;
  String? diagnosisYear;
  String? specificDiseaseName;
  String? medications; // ✅ متغير جديد لحفظ أسماء الأدوية

  List<String> selectedDiseases = [];
  bool? isTakingMeds;
  bool? hasOtherIssues;
  File? _profileImage;

  // الثوابت
  final Color primaryColor = const Color(0xFF41BFAA);
  final List<String> _diseaseOptions = [
    'الضغط',
    'السكري',
    'أمراض القلب',
    'الكوليسترول',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _registerPatient(BuildContext context) {
    // 1. التحقق من الحقول الأساسية
    if (fullName == null ||
        phoneNumber == null ||
        selectedDiseases.isEmpty ||
        isTakingMeds == null ||
        hasOtherIssues == null) {
      showsnackbar(
        context,
        massage: "يرجى ملء كافة الحقول والإجابة على الأسئلة",
      );
      return;
    }

    // 2. ✅ التحقق: إذا اختار نعم للأدوية، يجب أن يكتب اسمها
    if (isTakingMeds == true && (medications == null || medications!.isEmpty)) {
      showsnackbar(context, massage: "يرجى كتابة أسماء الأدوية التي تتناولها");
      return;
    }

    // 3. ✅ التحقق: إذا اختار نعم لمشاكل أخرى، يجب أن يذكرها
    if (hasOtherIssues == true &&
        (specificDiseaseName == null || specificDiseaseName!.isEmpty)) {
      showsnackbar(context, massage: "يرجى ذكر المشكلات الصحية الأخرى");
      return;
    }

    final diseaseString = selectedDiseases.join(", ");

    final newPatient = PatientModel(
      uid: '',
      email: widget.email,
      fullName: fullName!,
      phoneNumber: phoneNumber!,
      createdAt: DateTime.now(),
      diseaseType: diseaseString,
      diagnosisYear: diagnosisYear,
      isTakingMeds: isTakingMeds!,
      // ✅ هنا يمكنك تمرير medications للموديل إذا قمت بتحديثه ليقبله
      // medications: medications,
      specificDisease: specificDiseaseName,
      hasOtherIssues: hasOtherIssues!,
    );

    context.read<SignupCubit>().registerUser(
      userModel: newPatient,
      password: widget.password,
      profileImage: _profileImage, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          showsnackbar(context, massage: "تم إنشاء الحساب وحفظ البيانات بنجاح");
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
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
              appBar: AppBar(
                backgroundColor: const Color(0xFFF5F7FA),
                elevation: 0,
                leading: const BackButton(color: Colors.black),
                title: Text(
                  "بيانات المريض",
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
                      // --- صورة البروفايل ---
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

                      // --- البيانات ---
                      _buildSectionTitle("البيانات الشخصية"),
                      _buildLabel("الاسم الكامل"),
                      CustomTextfild(
                        hinttext: "مثال: محمد أحمد",
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

                      _buildSectionTitle("السجل الطبي"),
                      _buildLabel("نوع المرض (اختر واحداً أو أكثر)"),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _diseaseOptions.map((disease) {
                          final isSelected = selectedDiseases.contains(disease);
                          return FilterChip(
                            label: Text(disease),
                            labelStyle: GoogleFonts.tajawal(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedDiseases.add(disease);
                                } else {
                                  selectedDiseases.remove(disease);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel("سنة التشخيص"),
                      CustomTextfild(
                        hinttext: "مثال: 2020",
                        onChanged: (value) => diagnosisYear = value,
                      ),
                      const SizedBox(height: 20),

                      // ✅ السؤال عن الأدوية
                      _buildLabel("هل تتناول أدوية حالياً؟"),
                      _buildYesNoSelector(
                        groupValue: isTakingMeds,
                        onChanged: (val) => setState(() => isTakingMeds = val),
                      ),

                      // ✅ حقل الأدوية يظهر فقط عند اختيار نعم
                      if (isTakingMeds == true) ...[
                        const SizedBox(height: 15),
                        CustomTextfild(
                          hinttext: "اذكر أسماء الأدوية...",
                          onChanged: (value) => medications = value,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ✅ السؤال عن مشكلات أخرى
                      _buildLabel("هل تعاني من مشكلات صحية أخرى؟"),
                      _buildYesNoSelector(
                        groupValue: hasOtherIssues,
                        onChanged: (val) =>
                            setState(() => hasOtherIssues = val),
                      ),

                      // ✅ حقل المشكلات يظهر فقط عند اختيار نعم
                      if (hasOtherIssues == true) ...[
                        const SizedBox(height: 15),
                        CustomTextfild(
                          hinttext: "يرجى ذكرها هنا...",
                          onChanged: (value) => specificDiseaseName = value,
                        ),
                      ],

                      const SizedBox(height: 40),

                      Center(
                        child: custom_button(
                          buttonText: 'إنشاء الملف الطبي',
                          width: double.infinity,
                          onPressed: () => _registerPatient(context),
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

  // --- Widgets ---

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

  Widget _buildYesNoSelector({
    required bool? groupValue,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSelectableCard(
            label: "نعم",
            isSelected: groupValue == true,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSelectableCard(
            label: "لا",
            isSelected: groupValue == false,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
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
