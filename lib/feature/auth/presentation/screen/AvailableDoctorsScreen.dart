import 'package:flutter/material.dart';
import 'package:health_compass/feature/patient/data/repo/patient_repo.dart';
import '../../../auth/data/model/doctormodel.dart';

class AvailableDoctorsScreen extends StatelessWidget {
  const AvailableDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text("الأطباء المتاحون"),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DoctorModel>>(
        future: PatientRepo().getAllDoctors(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا يوجد أطباء متاحين حالياً"));
          }

          final doctors = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _buildDoctorCard(context, doctor);
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
              backgroundImage: doctor.profileImage != null && doctor.profileImage!.isNotEmpty
                  ? NetworkImage(doctor.profileImage!)
                  : null,
              child: doctor.profileImage == null || doctor.profileImage!.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF0D9488), size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await PatientRepo().sendLinkRequest(doctor.uid, doctor.fullName);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("تم إرسال الطلب للدكتور ${doctor.fullName}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("فشل إرسال الطلب")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("طلب ارتباط", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}