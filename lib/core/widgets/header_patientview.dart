import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_state.dart';
import 'package:health_compass/feature/health_tracking/presentation/HealthStatus_Card.dart';

class header_patientview extends StatelessWidget {
  const header_patientview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 440,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          String? imageUrl;

                          if (state is UserLoaded) {
                            imageUrl = state.userModel.profileImage;
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.profileSettings,
                              );
                              print('Profile image tapped');
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  (imageUrl != null && imageUrl.isNotEmpty)
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: (imageUrl == null || imageUrl.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      color: Color(0xFF00796B),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      String userName = 'يا حليم';
                      if (state is UserLoaded) {
                        userName = state.userModel.fullName;
                      }
                      return Text(
                        '.. اهلاً بعودتك $userName',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'نتمنى لك دوام الصحه',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 40,
            child: HealthStatusCard(),
          ),
        ],
      ),
    );
  }
}
