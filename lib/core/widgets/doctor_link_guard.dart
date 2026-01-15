import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/auth/presentation/screen/AvailableDoctorsScreen.dart';
import '../../feature/auth/presentation/cubit/cubit/user_cubit.dart';
import '../../feature/auth/presentation/cubit/cubit/user_state.dart';
import '../../feature/auth/data/model/PatientModel.dart';

class DoctorLinkGuard extends StatelessWidget {
  final Widget child;

  const DoctorLinkGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    print("📢 Opening Appointment Page...");
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        print("🛡️ Guard Logic Started. Current State: $state");
        
        if (state is UserLoaded) {
          print("👤 User is Loaded. Type: ${state.userModel.runtimeType}");
          
          if (state.userModel is PatientModel) {
            final patient = state.userModel as PatientModel;
            print("🏥 Patient found. Doctor IDs: ${patient.doctorIds}");
            print("❓ Is list empty? ${patient.doctorIds.isEmpty}");

            if (patient.doctorIds.isEmpty) {
              print("⛔ Blocking access - Showing NotLinkedView");
              return const _NotLinkedView();
            } else {
              print("✅ Access granted - User has doctor");
            }
          } else {
            print("⚠️ User is NOT a PatientModel (It is ${state.userModel.runtimeType})");
          }
        }

        if (state is UserLoading) {
           return const Scaffold(body: Center(child: CircularProgressIndicator())); 
        }

        if (state is UserLoaded) {
          if (state.userModel is PatientModel) {
            final patient = state.userModel as PatientModel;
            if (patient.doctorIds.isEmpty) {
              return const _NotLinkedView(); 
            }
          }
        }
        
        return child; 
      },
    );
  }
}

class _NotLinkedView extends StatelessWidget {
  const _NotLinkedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('يجب عليك الارتباط بطبيب أولاً', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvailableDoctorsScreen()),
                );},
              child: const Text('بحث عن طبيب'),
            ),
          ],
        ),
      ),
    );
  }
}