import 'package:flutter/material.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart';

class MyPatientsScreen extends StatelessWidget {
  const MyPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: const Text(
           "المرضى",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<PatientModel>>(
        // نستدعي الدالة الجديدة التي أنشأناها في الخطوة 1
        future: DoctorRequestsRepo().getMyPatients(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
          }

          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final patients = snapshot.data!;

          return ListView.builder(
            itemCount: patients.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              return _buildPatientChatCard(context, patients[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPatientChatCard(BuildContext context, PatientModel patient) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(otherUser: patient),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                  backgroundImage: (patient.profileImage != null && patient.profileImage!.isNotEmpty)
                      ? NetworkImage(patient.profileImage!)
                      : null,
                  child: (patient.profileImage == null || patient.profileImage!.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFF0D9488), size: 30)
                      : null,
                ),
               
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                     
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // نعرض نوع المرض كمعلومة إضافية للطبيب
                      Expanded(
                        child: Text(
                          "الحالة: ${patient.diseaseType}", 
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لا يوجد مرضى مرتبطين بك حالياً",
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }
}