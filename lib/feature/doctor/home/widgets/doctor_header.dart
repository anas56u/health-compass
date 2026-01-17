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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              "إلغاء",
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<UserCubit>().clearUserData();
              await SharedPrefHelper.clearLoginData();
              
              await SharedPrefHelper.removeData("is_logged_in");
              await SharedPrefHelper.removeData("user_type");
              await SharedPrefHelper.removeData("uid"); 

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.login, 
        (route) => false
      );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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