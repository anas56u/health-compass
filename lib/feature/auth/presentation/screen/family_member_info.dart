import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/signup_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class FamilyMemberInfoScreen extends StatefulWidget {
  final String email;
  final String password;

  const FamilyMemberInfoScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<FamilyMemberInfoScreen> createState() => _FamilyMemberInfoScreenState();
}

class _FamilyMemberInfoScreenState extends State<FamilyMemberInfoScreen> {
  String? fullName;
  String? phoneNumber;
  File? _profileImage;

  // ✅ القيم الافتراضية
  String selectedRelation = 'son';
  String selectedPermission = 'view_only';

  final Color primaryColor = const Color(0xFF41BFAA);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _registerFamilyMember(BuildContext context) {
    if (fullName == null || fullName!.isEmpty) {
      showsnackbar(context, massage: "يرجى إدخال الاسم الكامل");
      return;
    }
    if (phoneNumber == null) {
      showsnackbar(context, massage: "يرجى إدخال رقم الهاتف");
      return;
    }

    // ✅ إنشاء الموديل مع القيم المختارة
    final newFamilyMember = FamilyMemberModel(
      uid: '',
      email: widget.email,
      fullName: fullName!,
      phoneNumber: phoneNumber!,
      createdAt: DateTime.now(),
      profileImage: '',
      relation: selectedRelation, // ✅ تمرير العلاقة
      permission: selectedPermission, // ✅ تمرير الصلاحية
    );

    context.read<SignupCubit>().registerUser(
      userModel: newFamilyMember,
      password: widget.password,
      profileImage: _profileImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          showsnackbar(context, massage: "تم إنشاء حساب فرد العائلة بنجاح ✅");
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.familyHome,
            (route) => false,
            // يمكن تمرير arguments هنا إذا كان الراوتر يدعمها
            arguments: {'permission': state.permission},
          );
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
                  "بيانات فرد العائلة",
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
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(
                                    Icons.family_restroom,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- المعلومات الشخصية ---
                      _buildSectionTitle("المعلومات الشخصية"),
                      _buildLabel("الاسم الكامل"),
                      CustomTextfild(
                        hinttext: "الاسم الرباعي",
                        onChanged: (value) => fullName = value,
                      ),
                      const SizedBox(height: 15),
                      _buildLabel("رقم الهاتف"),
                      IntlPhoneField(
                        initialCountryCode: 'JO',
                        textAlign: TextAlign.right,
                        languageCode: "ar",
                        onChanged: (phone) =>
                            phoneNumber = phone.completeNumber,
                      ),
                      const SizedBox(height: 25),

                      // --- صلة القرابة ---
                      _buildSectionTitle("صلتك بالمريض"),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildRelationChip("ابن/ـة", "son", Icons.child_care),
                          _buildRelationChip("أب/أم", "parent", Icons.elderly),
                          _buildRelationChip(
                            "زوج/ـة",
                            "partner",
                            Icons.favorite,
                          ),
                          _buildRelationChip("أخ/أخت", "sibling", Icons.people),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // ---  صلاحيات الحساب ---
                      _buildSectionTitle("صلاحيات الحساب"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPermissionCard(
                              title: "عرض فقط",
                              value: "view_only",
                              icon: Icons.visibility_rounded,
                              description: "مشاهدة البيانات دون تعديل",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPermissionCard(
                              title: "متابعة تفاعلية",
                              value: "interactive",
                              icon: Icons.edit_note_rounded,
                              description: "إمكانية إضافة وتعديل البيانات",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // --- زر التأكيد ---
                      Center(
                        child: custom_button(
                          buttonText: 'تأكيد التسجيل',
                          width: double.infinity,
                          onPressed: () => _registerFamilyMember(context),
                        ),
                      ),
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

  Widget _buildRelationChip(String label, String value, IconData icon) {
    bool isSelected = selectedRelation == value;
    return GestureDetector(
      onTap: () => setState(() => selectedRelation = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String value,
    required IconData icon,
    required String description,
  }) {
    bool isSelected = selectedPermission == value;
    return GestureDetector(
      onTap: () => setState(() => selectedPermission = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void showsnackbar(BuildContext context, {required String massage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(massage), backgroundColor: Colors.black87),
    );
  }
}
