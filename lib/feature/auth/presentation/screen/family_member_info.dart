import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:health_compass/core/widgets/custom_textfild.dart';

class FamilyMemberInfoScreen extends StatefulWidget {
  const FamilyMemberInfoScreen({super.key});

  @override
  State<FamilyMemberInfoScreen> createState() => _FamilyMemberInfoScreenState();
}

class _FamilyMemberInfoScreenState extends State<FamilyMemberInfoScreen> {
  String? fullName;
  String? phoneNumber;
  bool isLoading = false;

  // القيم الافتراضية
  bool wantToLink = true;
  String selectedRelation = 'son';
  String selectedRole = 'relative';
  String selectedPermission = 'view_only';

  Future<void> sendFamilyDataToFirebase() async {
    if (!wantToLink) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Patientview_body()),
      );
      return;
    }
    if (fullName == null || fullName!.isEmpty) {
      showsnackbar(context, massage: "يرجى إدخال اسم المرافق");
      return;
    }
    if (phoneNumber == null) {
      showsnackbar(context, massage: "يرجى إدخال رقم هاتف المرافق");
      return;
    }
    setState(() => isLoading = true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      Map<String, dynamic> familyData = {
        'patient_uid': currentUser.uid,
        'member_name': fullName,
        'member_phone': phoneNumber,
        'relation': selectedRelation,
        'role': selectedRole,
        'permission': selectedPermission,
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('family_members')
          .add(familyData);

      showsnackbar(context, massage: "تم إضافة فرد العائلة بنجاح");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Patientview_body()),
        );
      }
    } catch (e) {
      // ✅ التعديل هنا: طباعة الخطأ للمبرمج فقط
      print("Error saving family member: $e");

      // ✅ عرض رسالة لطيفة للمستخدم بدون تفاصيل تقنية
      showsnackbar(
        context,
        massage: "حدث خطأ غير متوقع، يرجى التحقق من الاتصال والمحاولة مجدداً",
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF41BFAA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(color: primaryColor),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                // --- الشريط العلوي ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.black,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Patientview_body(),
                            ),
                          );
                        },
                        child: Text(
                          'تخطي',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- المحتوى ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "الربط مع أفراد العائلة",
                          style: GoogleFonts.tajawal(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "اربط حسابك مع من يحبك لمتابعة حالتك الصحية والاطمئنان عليك.",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // بطاقة السؤال الرئيسي
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "هل ترغب بربط حسابك مع أحد أفراد عائلتك؟",
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSelectableCard(
                                      title: "نعم",
                                      isSelected: wantToLink,
                                      onTap: () =>
                                          setState(() => wantToLink = true),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildSelectableCard(
                                      title: "لا",
                                      isSelected: !wantToLink,
                                      onTap: () =>
                                          setState(() => wantToLink = false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // عرض الفورم فقط إذا اختار "نعم"
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: Container(),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25),

                              _buildLabel("الاسم الكامل للمرافق"),
                              CustomTextfild(
                                hinttext: "مثال: أحمد محمد",
                                onChanged: (val) => fullName = val,
                              ),

                              const SizedBox(height: 20),

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
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
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

                              const SizedBox(height: 25),

                              _buildLabel("صلة القرابة"),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildChip(
                                    "ابن/ـة",
                                    "son",
                                    selectedRelation,
                                    (val) =>
                                        setState(() => selectedRelation = val),
                                  ),
                                  _buildChip(
                                    "أم",
                                    "mother",
                                    selectedRelation,
                                    (val) =>
                                        setState(() => selectedRelation = val),
                                  ),
                                  _buildChip(
                                    "أب",
                                    "father",
                                    selectedRelation,
                                    (val) =>
                                        setState(() => selectedRelation = val),
                                  ),
                                  _buildChip(
                                    "زوج/ـة",
                                    "spouse",
                                    selectedRelation,
                                    (val) =>
                                        setState(() => selectedRelation = val),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              _buildLabel("الدور"),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildChip(
                                      "قريب",
                                      "relative",
                                      selectedRole,
                                      (val) =>
                                          setState(() => selectedRole = val),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildChip(
                                      "مقدم رعاية",
                                      "caregiver",
                                      selectedRole,
                                      (val) =>
                                          setState(() => selectedRole = val),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              _buildLabel("الصلاحية المتاحة"),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    RadioListTile(
                                      title: Text(
                                        "عرض تقارير فقط",
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                        ),
                                      ),
                                      value: 'view_only',
                                      groupValue: selectedPermission,
                                      activeColor: primaryColor,
                                      onChanged: (val) => setState(
                                        () =>
                                            selectedPermission = val.toString(),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                    RadioListTile(
                                      title: Text(
                                        "متابعة تفاعلية (كامل الصلاحيات)",
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                        ),
                                      ),
                                      value: 'interactive',
                                      groupValue: selectedPermission,
                                      activeColor: primaryColor,
                                      onChanged: (val) => setState(
                                        () =>
                                            selectedPermission = val.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          crossFadeState: wantToLink
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: custom_button(
                            buttonText: wantToLink
                                ? 'تأكيد وحفظ'
                                : 'متابعة بدون ربط',
                            width: double.infinity,
                            onPressed: sendFamilyDataToFirebase,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF41BFAA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF41BFAA) : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.tajawal(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    String label,
    String value,
    String groupValue,
    Function(String) onSelect,
  ) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF41BFAA).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF41BFAA) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: isSelected ? const Color(0xFF41BFAA) : Colors.black54,
            fontWeight: FontWeight.bold,
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
