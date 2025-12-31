import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/core.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/presentation/screen/doctor_info.dart';
// import 'package:health_compass/feature/auth/presentation/screen/family_member_info.dart'; // لم نعد بحاجة لهذا الاستيراد هنا
import 'package:health_compass/feature/auth/presentation/screen/patient_info.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UserType extends StatefulWidget {
  final String email;
  final String password;
  const UserType({super.key, required this.email, required this.password});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType>
    with SingleTickerProviderStateMixin {
  String? selectedUserType;
  bool isloading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF41BFAA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ModalProgressHUD(
        inAsyncCall: isloading,
        progressIndicator: const CircularProgressIndicator(
          color: Color(0xFF41BFAA),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF26A69A), Color(0xFF006064)],
            ),
          ),
          child: CustomScaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 40,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/logo.jpeg",
                                height: 110,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 5),
                                  Text(
                                    "أهلاً بك في",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    " Health Compass",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                "دعنا ننشىء تجربة صحية مخصصة لك",
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),

                              const SizedBox(height: 30),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "أنا أكون:",
                                  style: GoogleFonts.tajawal(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // --- ✅ تم حذف خيار فرد العائلة ---
                              _buildTypeCard(
                                value: "مريض",
                                title: "مريض",
                                subtitle: "تتبع صحتي وإدارة الأدوية",
                                icon: Icons.personal_injury,
                                activeColor: activeColor,
                              ),

                              const SizedBox(
                                height: 15,
                              ), // مسافة أكبر قليلاً بين الخيارين

                              _buildTypeCard(
                                value: "طبيب",
                                title: "طبيب",
                                subtitle: "مراقبة المريض وتقديم الرعاية",
                                icon: Icons.person_3,
                                activeColor: activeColor,
                              ),

                              const SizedBox(height: 40),

                              AnimatedOpacity(
                                opacity: selectedUserType != null ? 1.0 : 0.5,
                                duration: const Duration(milliseconds: 300),
                                child: custom_button(
                                  buttonText: 'متابعة',
                                  width: double.infinity,
                                  onPressed: selectedUserType != null
                                      ? () => _handleNavigation(context)
                                      : null,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
  }) {
    bool isSelected = selectedUserType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ), // زيادة المساحة الرأسية قليلاً
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context) {
    if (selectedUserType == "مريض") {
      Navigator.pushNamed(
        context,
        AppRoutes.patientInfo,
        arguments: {'email': widget.email, 'password': widget.password},
      );
    } else if (selectedUserType == "طبيب") {
      Navigator.pushNamed(
        context,
        AppRoutes.doctorInfo,
        arguments: {'email': widget.email, 'password': widget.password},
      );
    }
    // ✅ تم حذف شرط الانتقال لفرد العائلة
  }
}
