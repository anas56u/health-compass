import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import '../../../../../core/cache/shared_pref_helper.dart';
import '../../../../../core/routes/routes.dart';


class DoctorHeader extends StatelessWidget {
  const DoctorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String doctorName = "";
        String? profileImage;

        if (state is UserLoaded) {
          doctorName = state.userModel.fullName;
          if (state.userModel.profileImage != null && 
              state.userModel.profileImage!.isNotEmpty) {
            profileImage = state.userModel.profileImage;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ زر تسجيل الخروج (بدل زر القائمة القديم)
                    IconButton(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(
                        Icons.logout_rounded, 
                        color: Colors.white, 
                        size: 28
                      ),
                      tooltip: "تسجيل الخروج",
                    ),
                    
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : const AssetImage('assets/images/logo.jpeg') as ImageProvider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Text(
                  'مرحباً بك د. $doctorName',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'تابع تقدم الحالة الصحية للمرضى',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق النافذة بالضغط خارجها أثناء التحميل
      builder: (dialogContext) => AlertDialog( // نستخدم dialogContext لتجنب مشاكل الـ context
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            Text(
              "تسجيل الخروج",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          style: GoogleFonts.tajawal(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // إغلاق الديالوج
            child: Text(
              "إلغاء",
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              try {
                // 1. إظهار مؤشر تحميل لإخبار المستخدم أن هناك عملية تجري
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );

                // 2. تسجيل الخروج من Firebase (مهم جداً!)
                await FirebaseAuth.instance.signOut(); //

                // 3. مسح البيانات من Cubit
                if (context.mounted) {
                  context.read<UserCubit>().clearUserData(); //
                }

                // 4. مسح البيانات المحلية
                // ملاحظة: دالة clearLoginData تقوم بالفعل بمسح is_logged_in و uid
                // فلا داعي لتكرار استدعاء removeData لنفس المفاتيح بعدها
                await SharedPrefHelper.clearLoginData(); //
                
                // مسح أي بيانات إضافية إن وجدت
                await SharedPrefHelper.removeData("user_type");

                // 5. التوجيه لصفحة تسجيل الدخول
                if (context.mounted) {
                  // إغلاق مؤشر التحميل والديالوغ السابق
                  Navigator.of(context).popUntil((route) => route.isFirst); 
                  
                  // الانتقال لصفحة الدخول ومسح كل الصفحات السابقة
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              } catch (e) {
                // في حال حدوث خطأ، قم بإغلاق مؤشر التحميل وأظهر رسالة
                if (context.mounted) {
                  Navigator.pop(context); // إغلاق الـ Loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء الخروج: $e')),
                  );
                }
              }
            },
            child: Text(
              "خروج",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}