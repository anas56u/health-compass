import 'package:flutter/material.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart';
import 'package:health_compass/feature/patient/data/repo/patient_repo.dart';
import 'package:health_compass/feature/auth/presentation/screen/chatscreen.dart'; // استدعاء صفحة الشات

class MyDoctorsScreen extends StatelessWidget {
  const MyDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "أطبائي",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // سنستخدم FutureBuilder لجلب الأطباء (يفترض استخدام دالة تجلب الأطباء المرتبطين فقط)
      // ملاحظة: هنا استخدمت getAllDoctors كمثال، يجب استبدالها بدالة تجلب "Linked Doctors" إذا توفرت
      body: FutureBuilder<List<DoctorModel>>(
        future: PatientRepo().getAllDoctors(), 
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

          final doctors = snapshot.data!;

          return ListView.builder(
            itemCount: doctors.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              return _buildDoctorChatCard(context, doctors[index]);
            },
          );
        },
      ),
    );
  }

  // تصميم الكارد "مثل الواتس أب"
  Widget _buildDoctorChatCard(BuildContext context, DoctorModel doctor) {
    return InkWell(
      onTap: () {
        // عند الضغط، ننتقل لصفحة الشات ونمرر بيانات الطبيب
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(otherUser: doctor),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // صورة الطبيب (Avatar)
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (doctor.profileImage != null && doctor.profileImage!.isNotEmpty)
                      ? NetworkImage(doctor.profileImage!)
                      : null,
                  child: (doctor.profileImage == null || doctor.profileImage!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey, size: 30)
                      : null,
                ),
                // نقطة الحالة (أونلاين) - ديكور إضافي اختياري
               
              ],
            ),
            const SizedBox(width: 16),
            
            // معلومات الطبيب
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // الوقت (يمكن جعله ديناميكي لاحقاً)
                    
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.done_all, size: 16, color: Colors.blue), // علامة الصحين
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "انقر لبدء المحادثة مع  طبيب ${doctor.specialization}", // نص توضيحي
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
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لا يوجد أطباء مضافين",
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }
}